// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-ACC-REUSE-024","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-ACCUMULATOR-OUTPUT-001"],"kind":"execution","summary":"A prior accumulator-type D may be explicitly rebound as C in a later block","pass_condition":"two distinct destination requests produce eleven then seventeen while preserving the first D snapshot","related_sources":["asl/block/model/operands/tile-bindings.asl"]}
func StartReuseACC(destination_hand: integer {0..3},
                   accumulator: TileIndex)
begin
    var start: bits(64) = Zeros{64} + 0x00231181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    AddBundleTileBinding(
        TRUE, destination_hand, 1, '1111',
        TRUE, FALSE, accumulator, 0, FALSE);
    AddBundleTileBinding(
        FALSE, 0, 0, '1111', TRUE, TRUE, 4, 5, TRUE);
end;

func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(4, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(5, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    let c_ready = ConfigureCubeTileForMask(6, 128, 1, 1,
        TileDataType_FP32, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready && c_ready;
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 0x4200);
    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 0x40a00000);

    StartReuseACC(0, 6);
    let first_completed = ExecuteBundleTileOperation();
    assert first_completed;
    let first_destination = BundleMatrixDestinationAt(0);
    assert ReadTileElement(first_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x41300000;
    let first_before = ReadTileElement(first_destination, 0, 0);

    ResetBundleControlState();
    StartReuseACC(1, first_destination);
    let second_completed = ExecuteBundleTileOperation();
    assert second_completed;
    let second_destination = BundleMatrixDestinationAt(0);
    assert second_destination != first_destination;
    assert ReadTileElement(second_destination, 0, 0) ==
        Zeros{PTO_XLEN} + 0x41880000;
    assert ReadTileElement(first_destination, 0, 0) == first_before;
    return 0;
end;
