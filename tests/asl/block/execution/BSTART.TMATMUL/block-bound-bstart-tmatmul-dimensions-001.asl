// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-DIM-001","source":"asl/block/execution/BSTART.TMATMUL.asl","requirements":["PTO-TMATMUL-CONTRACT-001"],"kind":"boundary","summary":"TMATMUL rejects zero and non-power-of-two resolved dimensions before allocation.","pass_condition":"Explicit M=0 and K=3 each raise TileLegality without allocating the destination or changing source payloads.","related_sources":["asl/tile/model/legality/matrix-shape.asl","asl/block/model/dispatch/cube-tmatmul.asl"]}
func RejectTMATMULDimension(dimension: BundleDimensionIndex, value: Word)
begin
    ResetProfileState();
    ConfigureTile(1, 128, 8, 8, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 8, 8, 1, 1, TileDataType_FP16,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 4;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(dimension, value);
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    assert ReadTileElement(1, 0, 0) == Zeros{PTO_XLEN} + 2;
end;

func main() => integer
begin
    RejectTMATMULDimension(0, Zeros{PTO_XLEN});
    RejectTMATMULDimension(2, Zeros{PTO_XLEN} + 3);
    return 0;
end;
