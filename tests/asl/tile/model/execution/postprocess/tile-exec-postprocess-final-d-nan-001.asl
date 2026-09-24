// PTO-TEST: {"id":"PTO-AVS-TILE-MODEL-EXECUTION-POSTPROCESS-FINAL-D-NAN-001","source":"asl/tile/model/execution/postprocess.asl","requirements":["PTO-MATRIX-POSTPROCESS-BITEXACT-001"],"kind":"execution","summary":"final FP16 D canonicalizes signaling and quiet NaNs before RowMax and GroupMax","pass_condition":"D, RowMax, and GroupMax contain the canonical FP16 quiet NaN and only the signaling-NaN D conversion raises the profile's invalid flag","related_sources":["asl/tile/model/execution/matrix-postprocess.asl","asl/arch/features/minmax.asl"]}

func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 512, 1, 16, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor);
    ConfigureTile(1, 512, 1, 16, 1, 2, TileDataType_FP32,
        TileLayout_RowMajor);
    ConfigureTile(2, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor);
    ConfigureTile(3, 128, 1, 1, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, Zeros{PTO_XLEN} + 0x7f800001);
    WriteTileElement(0, 0, 1, Zeros{PTO_XLEN} + 0x7fc00000);

    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 25;
    let started = ExecuteCommandInstruction(instruction, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6} + 1, Zeros{3}, Zeros{4} + 1,
        TRUE, TRUE, FALSE, FALSE);

    _BundleTileBindings[[0]].valid = TRUE;
    _BundleTileBindings[[0]].destination_valid = TRUE;
    _BundleTileBindings[[0]].destination = 1;
    _BundleTileBindings[[0]].source0_valid = TRUE;
    _BundleTileBindings[[0]].source0 = 0;
    _BundleTileBindings[[0]].source1_valid = TRUE;
    _BundleTileBindings[[0]].source1 = 0;
    _BundleTileBindings[[1]].valid = TRUE;
    _BundleTileBindings[[1]].destination_valid = TRUE;
    _BundleTileBindings[[1]].destination = 2;
    _BundleTileBindings[[1]].source0_valid = TRUE;
    _BundleTileBindings[[1]].source0 = 2;
    _BundleTileBindings[[2]].valid = TRUE;
    _BundleTileBindings[[2]].destination_valid = TRUE;
    _BundleTileBindings[[2]].destination = 3;

    assert NumericStatusFlags() == Zeros{5};
    CommitMatrixResult(1, _Tiles[[0]], TileDataType_FP32);

    assert _Tiles[[1]].data_type == TileDataType_FP16;
    assert _Tiles[[2]].data_type == TileDataType_FP16;
    assert _Tiles[[3]].data_type == TileDataType_FP16;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 0x7e00;
    assert ReadTileElement(1, 0, 1) == Zeros{PTO_XLEN} + 0x7e00;
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x7e00;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0x7e00;
    assert TileNumericValueClass(TileDataType_FP16,
        ReadTileElement(1, 0, 0)) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_FP16,
        ReadTileElement(2, 0, 0)) == NumericValue_QuietNaN;
    assert TileNumericValueClass(TileDataType_FP16,
        ReadTileElement(3, 0, 0)) == NumericValue_QuietNaN;
    // FP32 signaling-NaN -> FP16 canonicalization raises NV (bit 0); the
    // quiet NaN and subsequent qNaN/qNaN maxima add no flags in this profile.
    assert NumericStatusFlags() == Zeros{5} + 1;
    return 0;
end;
