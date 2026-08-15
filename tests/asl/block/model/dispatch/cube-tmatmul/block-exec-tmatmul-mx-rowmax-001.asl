// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-MX-ROWMAX-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-TMATMUL-MX-CONTRACT-001"],"kind":"execution","summary":"FP16 TMATMULMX routes RowMaxIn immediately after its two scale-free mathematical sources","pass_condition":"RowMaxOut folds the bound RowMaxIn value rather than an absent static scale position","related_sources":["asl/tile/model/execution/postprocess.asl","asl/tile/model/legality/matrix-functions.asl"]}

pure func MatrixMXRowMaxStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00431181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 1, 8, 1, 8, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(3, 128, 1, 1, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    for column = 0 to 7 looplimit 8 do
        WriteTileElement(2, 0, column,
            Zeros{PTO_XLEN} + column + 1);
    end;
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 100);

    let started = ExecuteCommandInstruction(MatrixMXRowMaxStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, TRUE, FALSE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 8);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 1, 1, '1111', TRUE, FALSE, 3, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert completed;
    assert _LastFault == Fault_None;
    let row_max = BundleMatrixDestinationAt(1);
    assert ReadTileElement(row_max, 0, 0) == Zeros{PTO_XLEN} + 100;
    return 0;
end;
