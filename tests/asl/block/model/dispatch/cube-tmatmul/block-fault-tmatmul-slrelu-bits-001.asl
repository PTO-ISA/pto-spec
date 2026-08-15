// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-SLRELU-BITS-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-B-FPATR-MATRIX-POSTPROCESS-001"],"kind":"fault","summary":"scalar LReLU accepts only one low nineteen-bit FP19 carrier","pass_condition":"bit nineteen raises Fault_TileLegality before destination allocation","related_sources":["asl/block/model/dispatch/scalar-schema.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteGPR(1, Zeros{PTO_XLEN} + 0x00080000);

    var start = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3} + 2, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleScalarBinding(0, 0, 1, 0, 0, 1);
    AddBundleTileBinding(
        TRUE, 3, 1, '1111', TRUE, TRUE, 1, 2, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_Tiles[[48]].allocated;
    return 0;
end;
