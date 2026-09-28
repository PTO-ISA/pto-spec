// PTO-TEST: {"id":"PTO-AVS-BLOCK-ROW-EXPAND-BROADCAST-BYTE-OFFSET-R2-SUBVIEW-001","source":"asl/block/model/dispatch/expansion-schema.asl","requirements":["PTO-B-DATR-FIELDS-001","PTO-TROWEXPAND-CONTRACT-001","PTO-B-SUBVIEW-DESCRIPTOR-001","PTO-B-SUBVIEW-RANGE-001"],"kind":"execution","summary":"Decoded B.SUBVIEW selects a Local CUBE CELL range before row expansion applies its byte-offset slot, preserving earlier descriptor and temporary-view fault priority.","pass_condition":"M32 BF16 parent column 3 is selected by one-cell B.SUBVIEW offset 1 plus byte offset 2; a one-valid-column tail rejects slot 1 after deriving its view; invalid range preparation faults before an illegal selector; and unavailable temporary-view capacity raises Fault_TileAllocation first.","related_sources":["asl/block/model/operands/subview-descriptor.asl","asl/block/operands/B.SUBVIEW.asl","asl/tile/model/legality/reduction-and-expansion.asl"]}

pure func RowExpandStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = '00100';
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_BF16);
    return instruction;
end;

pure func RowExpandAttributes(byte_offset: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[17:15] = byte_offset;
    instruction[11:7] = Zeros{5} + 29;
    return instruction;
end;

pure func RowExpandCopyBinding(source: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

pure func Subview(source_select: boolean, size_code: integer,
                  offset: integer) => bits(64)
begin
    var instruction = Zeros{64} + 0x00000053;
    instruction[31] = if source_select then '1' else '0';
    instruction[10:7] = Zeros{4} + size_code;
    instruction[30:20] = Zeros{11} + offset;
    return instruction;
end;

func ConfigureM32Parent(valid_columns: integer {1..4})
begin
    let configured = ConfigureCubeTile(2, 256, 32, valid_columns,
        TileDataType_BF16, TileLayout_CUBE_M32);
    assert configured;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to valid_columns - 1 looplimit 4 do
            WriteTileElement(2, row, column,
                Zeros{PTO_XLEN} + 0x3f80 + row * 0x20 + column);
        end;
    end;
end;

func BeginSubviewRowExpand(byte_offset: bits(3),
                           parent_valid_columns: integer {1..4},
                           subview_offset: integer)
begin
    WriteGPR(0, Zeros{PTO_XLEN});
    ConfigureM32Parent(parent_valid_columns);
    let started = ExecuteCommandInstruction(RowExpandStart(), 32);
    let attributed = ExecuteCommandInstruction(
        RowExpandAttributes(byte_offset), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    SetBundleDimension(0,
        Zeros{PTO_XLEN} + (if parent_valid_columns == 3 then 1 else 2));
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let binding = ExecuteCommandInstruction(
        RowExpandCopyBinding(Zeros{6} + 2), 32);
    let modifier = ExecuteCommandInstruction(
        Subview(FALSE, 1, subview_offset), 32);
    assert binding == CommandExecution_Executed &&
           modifier == CommandExecution_Executed;
end;

func TestSubviewThenByteOffset()
begin
    ResetProfileState();
    BeginSubviewRowExpand(Zeros{3} + 2, 4, 1);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x044)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let descriptor = _BundleTileBindings[[0]].source0_subview.derived;
    assert descriptor.valid && descriptor.parent == 2 &&
           descriptor.origin_column == 2 && descriptor.valid_columns == 2;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].valid_rows == 32 &&
           _Tiles[[destination]].valid_columns == 2;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3f83;
    assert ReadTileElement(destination, 0, 1) ==
        Zeros{PTO_XLEN} + 0x3f83;
    assert ReadTileElement(destination, 31, 0) ==
        Zeros{PTO_XLEN} + 0x4363;
    assert _Tiles[[2]].data_type == TileDataType_BF16;
    assert NumericStatusFlags() == Zeros{5};
end;

func TestTailViewRejectsSecondSlot()
begin
    ResetProfileState();
    BeginSubviewRowExpand(Zeros{3} + 2, 3, 1);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x044)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    let descriptor = _BundleTileBindings[[0]].source0_subview.derived;
    assert descriptor.valid && descriptor.origin_column == 2 &&
           descriptor.valid_columns == 1;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
end;

func TestInvalidSubviewPrecedesSelector()
begin
    ResetProfileState();
    BeginSubviewRowExpand(Zeros{3} + 4, 4, 2);
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x044)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].source0_subview.derived.valid;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
end;

func TestSubviewAllocationPrecedesSelector()
begin
    ResetProfileState();
    let parent_ready = ConfigureCubeTile(2, 256, 32, 4,
        TileDataType_BF16, TileLayout_CUBE_M32);
    assert parent_ready;
    for row = 0 to 31 looplimit 32 do
        for column = 0 to 3 looplimit 4 do
            WriteTileElement(2, row, column,
                Zeros{PTO_XLEN} + 0x3f80 + row * 0x20 + column);
        end;
    end;
    MarkTileValidRegionDefined(2);
    for tile = 0 to 15 looplimit 16 do
        if tile != 2 then
            let configured = ConfigureCubeTile(tile as TileIndex, 256, 1, 1,
                TileDataType_BF16, TileLayout_CUBE_M32);
            assert configured;
        end;
    end;
    WriteGPR(0, Zeros{PTO_XLEN});
    let started = ExecuteCommandInstruction(RowExpandStart(), 32);
    let attributed = ExecuteCommandInstruction(
        RowExpandAttributes(Zeros{3} + 4), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 32);
    let binding = ExecuteCommandInstruction(
        RowExpandCopyBinding(Zeros{6} + 2), 32);
    let modifier = ExecuteCommandInstruction(Subview(FALSE, 1, 1), 32);
    assert binding == CommandExecution_Executed &&
           modifier == CommandExecution_Executed;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x044)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileAllocation;
    assert _BundleTileBindings[[0]].source0_subview.derived.valid;
    assert !_BundleTileBindings[[0]].source0_subview.materialized;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
end;

func main() => integer
begin
    TestSubviewThenByteOffset();
    TestTailViewRejectsSecondSlot();
    TestInvalidSubviewPrecedesSelector();
    TestSubviewAllocationPrecedesSelector();
    return 0;
end;
