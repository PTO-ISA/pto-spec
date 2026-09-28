// PTO-TEST: {"id":"PTO-AVS-BLOCK-ROW-EXPAND-BROADCAST-BYTE-OFFSET-R2-POSITIVE-001","source":"asl/block/model/dispatch/expansion-schema.asl","requirements":["PTO-B-DATR-FIELDS-001","PTO-TROWEXPAND-CONTRACT-001","PTO-TROWEXPANDADD-CONTRACT-001","PTO-TROWEXPANDEXPDIF-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Decoded row expansion selects operation-typed byte-offset slots across CUBE M16/M32 widths, preserves COPY bits and carrier backing, and keeps EXPDIF geometry on its BF16 source type.","pass_condition":"M32 BF16 offset 2, M16 BF16 offset 6, M32 U8 offset 3, M16 U8 offset 7, M16 U32 offset 4, and offset zero publish exact selected-slot splats; U16-backed BF16 remains U16, ADD consumes the selected U8 element, and mixed BF16-to-FP32 EXPDIF selects the BF16 slot before widening.","related_sources":["asl/block/attributes/B.DATR.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/expansion.asl"]}

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

pure func RowExpandCopyBinding(source: bits(6)) => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00005013;
    instruction[25:20] = source;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

pure func RowExpandBinaryBinding(source0: bits(6), source1: bits(6))
        => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00004013;
    instruction[25:20] = source0;
    instruction[31:26] = source1;
    instruction[19] = '1';
    instruction[18:15] = '0010';
    instruction[11:9] = '001';
    return instruction;
end;

pure func RawCopyValue(data_type: TileDataType, row: integer,
                       column: integer) => bits(PTO_XLEN)
begin
    if data_type == TileDataType_BF16 ||
       data_type == TileDataType_FP16 then
        return Zeros{PTO_XLEN} + 0x3f80 + row * 0x100 + column * 0x10;
    elsif data_type == TileDataType_U8 ||
          data_type == TileDataType_S8 then
        return Zeros{PTO_XLEN} + 0x40 + row * 8 + column;
    else
        return Zeros{PTO_XLEN} + 0x10000 + row * 0x100 + column;
    end;
end;

func RunSelectedRawCopy(layout: TileLayout, layout_code: bits(5),
                        operation_type: TileDataType,
                        backing_type: TileDataType,
                        valid_columns: integer {1..8},
                        byte_offset: bits(3), selected_slot: integer {0..7})
begin
    ResetProfileState();
    let broadcast_ready = ConfigureCubeTile(1, 512, 2, valid_columns,
        backing_type, layout);
    assert broadcast_ready;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to valid_columns - 1 looplimit 8 do
            WriteTileElement(1, row, column,
                RawCopyValue(operation_type, row, column));
        end;
    end;
    let started = ExecuteCommandInstruction(
        RowExpandStart(operation_type, '00100'), 32);
    let attributed = ExecuteCommandInstruction(
        RowExpandAttributes(DTYPE_NONE, layout_code, byte_offset), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + valid_columns);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let binding = ExecuteCommandInstruction(
        RowExpandCopyBinding(Zeros{6} + 1), 32);
    assert binding == CommandExecution_Executed;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x044)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedExpansionSchemaLegal(operation);
    for scalar = 0 to PTO_BUNDLE_SCALAR_BINDING_COUNT - 1
        looplimit PTO_BUNDLE_SCALAR_BINDING_COUNT do
        assert !_BundleScalarBindings[[scalar]].valid;
    end;
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].layout == layout;
    assert _Tiles[[destination]].valid_rows == 2;
    assert _Tiles[[destination]].valid_columns == valid_columns;
    for row = 0 to 1 looplimit 2 do
        let selected = RawCopyValue(operation_type, row, selected_slot);
        for column = 0 to valid_columns - 1 looplimit 8 do
            assert ReadTileElement(destination, row, column) == selected;
        end;
    end;
    assert _Tiles[[1]].data_type == backing_type;
    assert NumericStatusFlags() == Zeros{5};
end;

func TestSelectedArithmetic()
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(1, 128, 2, 4,
        TileDataType_U8, TileLayout_CUBE_M32);
    let broadcast_ready = ConfigureCubeTile(2, 128, 2, 4,
        TileDataType_U8, TileLayout_CUBE_M32);
    assert source_ready && broadcast_ready;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 3 looplimit 4 do
            WriteTileElement(1, row, column,
                Zeros{PTO_XLEN} + column + 1);
            WriteTileElement(2, row, column,
                Zeros{PTO_XLEN} + column + 1);
        end;
    end;
    let started = ExecuteCommandInstruction(
        RowExpandStart(TileDataType_U8, '00101'), 32);
    let attributed = ExecuteCommandInstruction(
        RowExpandAttributes(DTYPE_NONE, Zeros{5} + 29,
            Zeros{3} + 3), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let binding = ExecuteCommandInstruction(
        RowExpandBinaryBinding(Zeros{6} + 1, Zeros{6} + 2), 32);
    assert binding == CommandExecution_Executed;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x045)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedExpansionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 3 looplimit 4 do
            assert ReadTileElement(destination, row, column) ==
                Zeros{PTO_XLEN} + column + 5;
        end;
    end;
end;

func TestMixedExpdifSourceGeometry()
begin
    ResetProfileState();
    let source_ready = ConfigureCubeTile(1, 512, 2, 4,
        TileDataType_U16, TileLayout_CUBE_M16);
    let broadcast_ready = ConfigureCubeTile(2, 512, 2, 4,
        TileDataType_U16, TileLayout_CUBE_M16);
    assert source_ready && broadcast_ready;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 3 looplimit 4 do
            WriteTileElement(1, row, column,
                Zeros{PTO_XLEN} + 0x3f80);
            WriteTileElement(2, row, column,
                if column == 3 then Zeros{PTO_XLEN} + 0x3f80
                else Zeros{PTO_XLEN} + 0x4000 + column);
        end;
    end;
    let started = ExecuteCommandInstruction(
        RowExpandStart(TileDataType_BF16, '01011'), 32);
    let attributed = ExecuteCommandInstruction(
        RowExpandAttributes(TileDataTypeToEncoding(TileDataType_FP32),
            Zeros{5} + 31, Zeros{3} + 6), 32);
    assert started == CommandExecution_Executed &&
           attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 4);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    let binding = ExecuteCommandInstruction(
        RowExpandBinaryBinding(Zeros{6} + 1, Zeros{6} + 2), 32);
    assert binding == CommandExecution_Executed;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x04b)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedExpansionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert _Tiles[[1]].data_type == TileDataType_U16 &&
           _Tiles[[2]].data_type == TileDataType_U16;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 3 looplimit 4 do
            assert ReadTileElement(destination, row, column) ==
                Zeros{PTO_XLEN} + 0x3f800000;
        end;
    end;
end;

func main() => integer
begin
    RunSelectedRawCopy(TileLayout_CUBE_M32, Zeros{5} + 29,
        TileDataType_BF16, TileDataType_BF16, 2, Zeros{3} + 2, 1);
    RunSelectedRawCopy(TileLayout_CUBE_M16, Zeros{5} + 31,
        TileDataType_BF16, TileDataType_U16, 4, Zeros{3} + 6, 3);
    RunSelectedRawCopy(TileLayout_CUBE_M32, Zeros{5} + 29,
        TileDataType_U8, TileDataType_U8, 4, Zeros{3} + 3, 3);
    RunSelectedRawCopy(TileLayout_CUBE_M16, Zeros{5} + 31,
        TileDataType_U8, TileDataType_U8, 8, Zeros{3} + 7, 7);
    RunSelectedRawCopy(TileLayout_CUBE_M16, Zeros{5} + 31,
        TileDataType_U32, TileDataType_U32, 2, Zeros{3} + 4, 1);
    RunSelectedRawCopy(TileLayout_CUBE_M32, Zeros{5} + 29,
        TileDataType_BF16, TileDataType_BF16, 2, Zeros{3}, 0);
    TestSelectedArithmetic();
    TestMixedExpdifSourceGeometry();
    return 0;
end;
