// PTO-TEST: {"id":"PTO-AVS-TILE-TCMP-FP32-S32-GT-002","source":"asl/tile/elementwise-tile-tile/logical/TCMP.asl","requirements":["PTO-TCMP-CONTRACT-001","PTO-TILE-CARRIER-REINTERPRETATION-001"],"kind":"execution","summary":"Decoded TCMP interprets FP32 backing carriers as S32 for ordered comparison","pass_condition":"S32 GT treats raw FP32-backed 0xffffffff as negative one and raw one as positive while preserving both source descriptors","related_sources":["asl/block/model/dispatch/comparison-schema.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/execution/comparison.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 2, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(2, 128, 8, 2, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0xffffffff);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN});

    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x88d19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        DTYPE_NONE, Zeros{5}, Zeros{2}, Zeros{3} + 3,
        Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed && _LastFault == Fault_None;
    let destination = _BundleTileBindings[[0]].destination;
    assert ReadTilePredicateByte(destination, 0) == '00000010';
    assert _Tiles[[1]].data_type == TileDataType_FP32;
    assert _Tiles[[2]].data_type == TileDataType_FP32;
    return 0;
end;
