// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-CUBE-MASK-010","source":"asl/block/model/dispatch/cube-tmatmul.asl","requirements":["PTO-CUBE-LOCAL-MATRIX-001"],"kind":"execution","summary":"Local CUBE Matrix keeps zero-mask no-op precedence and requires full participation","pass_condition":"zero mask bypasses malformed operands full mask executes CUBE primaries and a nonzero partial mask rejects before allocation","related_sources":["asl/block/model/dispatch/tile-schema.asl"]}
func StartMaskTMATMUL()
begin
    var start: bits(64) = Zeros{64} + 0x00031181;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
end;

func PrepareMaskPrimaries()
begin
    assert ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    assert ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
end;

func InstallMaskAttributes()
begin
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
end;

func main() => integer
begin
    ResetProfileState();
    StartMaskTMATMUL();
    AddBundleTileBinding(
        TRUE, 0, 1, '0000', TRUE, TRUE, 62, 63, TRUE);
    let zero_completed = ExecuteBundleTileOperation();
    assert zero_completed;
    assert _LastFault == Fault_None;
    assert CoreTileCapacityInUse() == 0;

    ResetProfileState();
    PrepareMaskPrimaries();
    StartMaskTMATMUL();
    InstallMaskAttributes();
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
    let full_completed = ExecuteBundleTileOperation();
    assert full_completed;
    assert _LastFault == Fault_None;
    assert _BundleTileBindings[[0]].destination_allocated_by_bundle;

    ResetProfileState();
    PrepareMaskPrimaries();
    StartMaskTMATMUL();
    InstallMaskAttributes();
    AddBundleTileBinding(
        TRUE, 0, 1, '0011', TRUE, TRUE, 1, 2, TRUE);
    let partial_completed = ExecuteBundleTileOperation();
    assert !partial_completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
