// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-NORM-PHYSICAL-SHAPE-006","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"fault","summary":"Ordinary-layout TCVT retains exact physical Row and Col legality","pass_condition":"equal valid shapes with different physical Row counts reject during bundle schema preflight before allocation, while paired source and destination capacities with equal physical shape pass direct legality","related_sources":["asl/block/model/dispatch/tcvt-schema.asl","asl/tile/model/legality/operand-schema.asl","asl/tile/model/shape/rows-columns.asl"]}
func AssertDirectPhysicalShapePairing()
begin
    ResetProfileState();
    ConfigureTile(
        0, 256, 64, 1, 64, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        1, 128, 128, 1, 64, 1, TileDataType_E8M0,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(
        2, 512, 128, 1, 64, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    MarkTileValidRegionDefined(0);
    MarkTileValidRegionDefined(2);

    assert !TileOperandsLegal_TCVT(
        1, 0, DefaultNumericExecutionControl());
    assert TileOperandsLegal_TCVT(
        1, 2, DefaultNumericExecutionControl());
end;

func AssertBundlePhysicalMismatchRejectedBeforeAllocation()
begin
    ResetProfileState();
    ConfigureTile(
        1, 256, 64, 1, 64, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Any);
    MarkTileValidRegionDefined(1);
    let capacity_before = TileCapacityInUse();
    let started = ExecuteCommandInstruction(
        Zeros{PTO_XLEN} + 0x09b19181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDataAttributeState(
        Zeros{5} + 13, Zeros{5}, '11', Zeros{3}, Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 64);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert TileCapacityInUse() == capacity_before;
end;

func main() => integer
begin
    AssertDirectPhysicalShapePairing();
    AssertBundlePhysicalMismatchRejectedBeforeAllocation();
    return 0;
end;
