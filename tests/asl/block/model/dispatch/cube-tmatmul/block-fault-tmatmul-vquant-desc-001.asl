// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-VQUANT-DESC-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-B-FPATR-MATRIX-POSTPROCESS-001"],"kind":"fault","summary":"TMATMUL rejects a vector quantization Tile whose descriptor is not Local U64 ND row-major","pass_condition":"the malformed vector parameter raises Fault_TileLegality before the destination hand is allocated","related_sources":["asl/tile/model/execution/postprocess.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(3, 128, 1, 1, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 4);

    var start = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6} + 2, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    AddBundleTileBinding(
        TRUE, 3, 1, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, FALSE, 3, 0, TRUE);

    assert !_Tiles[[48]].allocated;
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[48]].allocated;
    return 0;
end;
