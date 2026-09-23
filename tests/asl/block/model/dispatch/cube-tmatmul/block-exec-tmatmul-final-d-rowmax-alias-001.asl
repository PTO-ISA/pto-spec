// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-FINAL-D-ROWMAX-ALIAS-001","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-B-FPATR-MATRIX-POSTPROCESS-001","PTO-MATRIX-POSTPROCESS-BITEXACT-001","PTO-CUBE-AUX-CELLREG-001"],"kind":"execution","summary":"FP16 RowMaxInit reads and replaces an aliased effective-D RowMaxIn/Out descriptor","pass_condition":"for two rows, RowMaxInit combines the old aliased values with final FP16 D, retaining the larger old value on one row and writing the larger new D value on the other","related_sources":["asl/tile/model/execution/postprocess.asl","asl/tile/model/legality/matrix-postprocess.asl"]}

pure func FinalDAliasStart() => bits(64)
begin
    var instruction: bits(64) = Zeros{64} + 0x00031181;
    instruction[31:27] = Zeros{5} + 4;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 2, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8, '1111');
    let row_max_ready = ConfigureCubeTileForMask(3, 128, 2, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, '1111');
    assert a_ready && b_ready && row_max_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x3e00);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    // The first old value is below final D and must be replaced; the second
    // old value is above final D and must participate in RowMaxInit.
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(3, 1, 0, Zeros{PTO_XLEN} + 0x4400);

    let started = ExecuteCommandInstruction(FinalDAliasStart(), 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6} + 1, Zeros{3}, Zeros{4},
        TRUE, FALSE, TRUE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    AddBundleTileBinding(
        TRUE, 0, 3, '1111', TRUE, TRUE, 1, 2, FALSE);
    AddBundleTileBinding(
        TRUE, 3, 1, '1111', TRUE, FALSE, 3, 0, TRUE);
    // Preserve the pre-existing effective-D RowMaxIn payload while binding
    // the same descriptor as RowMaxOut.
    _BundleTileBindings[[1]].destination_reused_by_generation = TRUE;

    let completed = ExecuteBundleTileOperation();
    assert _LastFault == Fault_None;
    assert completed;
    let destination = BundleMatrixDestinationAt(0);
    let row_max = BundleMatrixDestinationAt(1);
    let row_max_input = BundleMatrixSourceAt(2);
    assert destination == 0;
    assert row_max == 3;
    assert row_max_input == row_max;
    assert _Tiles[[destination]].data_type == TileDataType_FP16;
    assert _Tiles[[row_max]].data_type == TileDataType_FP16;
    assert ReadTileElement(destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(destination, 1, 0) ==
        Zeros{PTO_XLEN} + 0x4200;
    assert ReadTileElement(row_max, 0, 0) ==
        Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(row_max, 1, 0) ==
        Zeros{PTO_XLEN} + 0x4400;
    assert NumericStatusFlags() == Zeros{5};
    return 0;
end;
