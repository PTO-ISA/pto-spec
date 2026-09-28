// PTO-TEST: {"id":"PTO-AVS-BLOCK-ROW-EXPAND-BROADCAST-BYTE-OFFSET-R2-NEGATIVE-001","source":"asl/block/model/dispatch/expansion-schema.asl","requirements":["PTO-B-DATR-FIELDS-001","PTO-TROWEXPAND-CONTRACT-001","PTO-TCOLEXPAND-CONTRACT-001"],"kind":"execution","summary":"Decoded illegal row-broadcast offsets fault before effects while RowMajor and column expansion retain their zero-RMode restriction and PE_MASK zero bypasses selector checks.","pass_condition":"M32 BF16 offset 1, M32 U8 offset 4, M16 U32 offset 2, an offset selecting beyond ValidColumns, RowMajor nonzero RMode, and TCOLEXPAND nonzero RMode fault with no destination; PE_MASK=0000 with an invalid offset succeeds without source reads, allocation, or fault.","related_sources":["asl/block/attributes/B.DATR.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/block/model/operands/subview-descriptor.asl"]}

pure func RowExpandStart(data_type: TileDataType,
                         function: bits(5)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = function;
    instruction[31:27] = TileDataTypeToEncoding(data_type);
    return instruction;
end;

pure func RowExpandAttributes(data_type: bits(5), layout: bits(5),
                               byte_offset: bits(3)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = data_type;
    instruction[17:15] = byte_offset;
    instruction[11:7] = layout;
    return instruction;
end;

pure func RowExpandCopyBinding(source: bits(6), column_axis: boolean)
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

func RunIllegalRowSelector(layout: TileLayout, layout_code: bits(5),
                           data_type: TileDataType,
                           valid_columns: integer {1..8},
                           byte_offset: bits(3))
begin
    ResetProfileState();
    var source_ready = FALSE;
    if layout == TileLayout_RowMajor then
        ConfigureTile(1, 256, 2, valid_columns, 2,
            valid_columns, data_type, layout);
        source_ready = TRUE;
    else
        source_ready = ConfigureCubeTile(1, 512, 2, valid_columns,
            data_type, layout);
    end;
    assert source_ready;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to valid_columns - 1 looplimit 8 do
            WriteTileElement(1, row, column,
                Zeros{PTO_XLEN} + 1 + row * 8 + column);
        end;
    end;
    let started = ExecuteCommandInstruction(
        RowExpandStart(data_type, '00100'), 32);
    let attributed = ExecuteCommandInstruction(
        RowExpandAttributes(DTYPE_NONE, layout_code, byte_offset), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + valid_columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let binding = ExecuteCommandInstruction(
        RowExpandCopyBinding(Zeros{6} + 1, FALSE), 32);
    assert binding == CommandExecution_Executed;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x044)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert NumericStatusFlags() == Zeros{5};
end;

func TestColumnExpansionRejectsRMode()
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(1, 128, 2, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    assert source_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 2);
    let started = ExecuteCommandInstruction(
        RowExpandStart(TileDataType_U8, '10100'), 32);
    let attributed = ExecuteCommandInstruction(
        RowExpandAttributes(DTYPE_NONE, Zeros{5} + 29,
            Zeros{3} + 1), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let binding = ExecuteCommandInstruction(
        RowExpandCopyBinding(Zeros{6} + 1, TRUE), 32);
    assert binding == CommandExecution_Executed;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x054)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
end;

func TestZeroPEMaskBypassesInvalidSelector()
begin
    ResetProfileState();
    let started = ExecuteCommandInstruction(
        RowExpandStart(TileDataType_BF16, '00100'), 32);
    let attributed = ExecuteCommandInstruction(
        RowExpandAttributes(DTYPE_NONE, Zeros{5} + 29,
            Zeros{3} + 1), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    AddBundleTileBinding(TRUE, 3, 1, '0000', TRUE, TRUE, 60, 61, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    assert !_Tiles[[0]].allocated && !_Tiles[[60]].allocated &&
           !_Tiles[[61]].allocated;
    assert NumericStatusFlags() == Zeros{5};
end;

func main() => integer
begin
    RunIllegalRowSelector(TileLayout_CUBE_M32, Zeros{5} + 29,
        TileDataType_BF16, 2, Zeros{3} + 1);
    RunIllegalRowSelector(TileLayout_CUBE_M32, Zeros{5} + 29,
        TileDataType_U8, 4, Zeros{3} + 4);
    RunIllegalRowSelector(TileLayout_CUBE_M16, Zeros{5} + 31,
        TileDataType_U32, 2, Zeros{3} + 2);
    RunIllegalRowSelector(TileLayout_CUBE_M16, Zeros{5} + 31,
        TileDataType_BF16, 3, Zeros{3} + 6);
    RunIllegalRowSelector(TileLayout_RowMajor, Zeros{5},
        TileDataType_BF16, 2, Zeros{3} + 2);
    TestColumnExpansionRejectsRMode();
    TestZeroPEMaskBypassesInvalidSelector();
    return 0;
end;
