// PTO-TEST: {"id":"PTO-AVS-BLOCK-EXPDIF-OPERATION-VIEW-R4-001","source":"asl/block/model/dispatch/expansion-schema.asl","requirements":["PTO-TROWEXPANDEXPDIF-CONTRACT-001"],"kind":"execution","summary":"Decoded EXPDIF interprets equal-width U16 source backing through its BF16 source operation type and retains FP32 output typing.","pass_condition":"The decoded row EXPDIF accepts U16-backed BF16 views, produces FP32 exp(BF16(1)-BF16(1)) == 1.0, and preserves both U16 source descriptors.","related_sources":["asl/block/model/dispatch/destination-shape.asl","asl/tile/model/legality/reduction-and-expansion.asl","asl/tile/model/execution/expansion.asl"]}
pure func ExpdifViewOperationStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = '10';
    instruction[24:20] = Zeros{5} + 11;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_BF16);
    return instruction;
end;

pure func ExpdifViewDataAttributes() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00001023;
    instruction[24:20] = TileDataTypeToEncoding(TileDataType_FP32);
    instruction[11:7] = Zeros{5} + 29;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let source = ConfigureCubeTile(1, 256, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M32);
    let broadcast = ConfigureCubeTile(2, 256, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M32);
    assert source && broadcast;
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(1, row, 0, Zeros{PTO_XLEN} + 0x3f80);
        WriteTileElement(1, row, 1, Zeros{PTO_XLEN} + 0x4000);
        WriteTileElement(2, row, 0, Zeros{PTO_XLEN} + 0x3f80);
        WriteTileElement(2, row, 1, Zeros{PTO_XLEN} + 0x4000);
    end;

    let started = ExecuteCommandInstruction(ExpdifViewOperationStart(), 32);
    let attributed = ExecuteCommandInstruction(
        ExpdifViewDataAttributes(), 32);
    assert started == CommandExecution_Executed;
    assert attributed == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 3, '1111', TRUE, TRUE, 1, 2, TRUE);
    let (expected_result, -) =
        TileExpandValueWithTypesAndFlags(
            TileExpand_EXPDIF,
            TileDataType_BF16,
            TileDataType_FP32,
            Zeros{PTO_XLEN} + 0x3f80,
            Zeros{PTO_XLEN} + 0x3f80);
    var all_expected_flags = Zeros{5};
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            let (-, element_flags) = TileExpandValueWithTypesAndFlags(
                TileExpand_EXPDIF,
                TileDataType_BF16,
                TileDataType_FP32,
                ReadTileElement(1, row, column),
                ReadTileElement(2, row, 0));
            all_expected_flags = all_expected_flags OR element_flags;
        end;
    end;
    let operation = DecodeTileOperation(
        TileDecode_TEPL, Zeros{12} + 0x04b)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert BundleOperationBindingsComplete(operation);
    assert SelectedBundleClosedExpansionSchemaLegal(operation);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert _Tiles[[destination]].data_type == TileDataType_FP32;
    assert _Tiles[[1]].data_type == TileDataType_U16;
    assert _Tiles[[2]].data_type == TileDataType_U16;
    assert ReadTileElement(destination, 0, 0) == expected_result;
    assert NumericStatusFlags() == all_expected_flags;
    return 0;
end;
