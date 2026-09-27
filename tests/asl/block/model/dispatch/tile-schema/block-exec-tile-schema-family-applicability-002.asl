// PTO-TEST: {"id":"PTO-AVS-BLOCK-TILE-SCHEMA-FAMILY-APPLICABILITY-002","source":"asl/block/model/dispatch/tile-schema.asl","requirements":["PTO-TABS-CONTRACT-001","PTO-TCI-CONTRACT-001","PTO-TROWSUM-CONTRACT-001","PTO-TADDS-CONTRACT-001","PTO-TFMA-CONTRACT-001"],"kind":"execution","summary":"The closed binary schema applies only to binary operations and leaves other decoded Tile families unchanged.","pass_condition":"Decoded unary, generation, reduction, tile-scalar, and fused operations bypass the binary two-source check, and an unpredicated TABS bundle executes normally.","related_sources":["asl/block/model/dispatch/binary-operation-classification.asl","asl/block/model/dispatch/tile-execution.asl"]}
pure func TileSchemaFamilyStart(selector: bits(10), data_type: bits(5))
    => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00019181;
    instruction[26:25] = selector[6:5];
    instruction[24:20] = selector[4:0];
    instruction[31:27] = data_type;
    return instruction;
end;

func main() => integer
begin
    let tabs = DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x00f)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let tci = DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x066)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let trowsum = DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x040)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let tadds = DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x020)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let tfma = DecodeTileOperation(TileDecode_TEPL, Zeros{12} + 0x01c)
        as integer {0..PTO_TILE_OPERATION_COUNT-1};
    assert !TileOperationUsesClosedBinarySchema(tabs);
    assert !TileOperationUsesClosedBinarySchema(tci);
    assert !TileOperationUsesClosedBinarySchema(trowsum);
    assert !TileOperationUsesClosedBinarySchema(tadds);
    assert !TileOperationUsesClosedBinarySchema(tfma);
    assert SelectedBundleClosedBinarySchemaLegal(tabs);
    assert SelectedBundleClosedBinarySchemaLegal(tci);
    assert SelectedBundleClosedBinarySchemaLegal(trowsum);
    assert SelectedBundleClosedBinarySchemaLegal(tadds);
    assert SelectedBundleClosedBinarySchemaLegal(tfma);

    ResetProfileState();
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_BF16,
        TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0xbf80);
    MarkTileValidRegionDefined(1);
    let started = ExecuteCommandInstruction(
        TileSchemaFamilyStart(Zeros{10} + 0x00f,
            TileDataTypeToEncoding(TileDataType_BF16)), 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x3f80;
    return 0;
end;
