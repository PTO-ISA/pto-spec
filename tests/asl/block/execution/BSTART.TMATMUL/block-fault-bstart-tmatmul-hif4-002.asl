// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-HIF4-FAULT-002","source":"asl/block/execution/BSTART.TMATMUL.asl","requirements":["PTO-CUBE-MATRIX-SCALE-001"],"kind":"fault","summary":"Ordinary non-MX TMATMUL keeps HiF4X2 reserved from its input set.","pass_condition":"A decoded ordinary TMATMUL with HiF4X2 A and B rejects before destination allocation or source effects.","related_sources":["asl/tile/model/legality/matrix-functions.asl"]}

func main() => integer
begin
    ResetProfileState();
    let a_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_HiF4X2, TileLayout_CUBE_M16,
        TileLocation_Matrix, '1111');
    let b_ready = ConfigureCubeTileForMask(2, 128, 1, 1,
        TileDataType_HiF4X2, TileLayout_CUBE_N8,
        TileLocation_Matrix, '1111');
    assert a_ready && b_ready;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 14;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4}, FALSE, FALSE, FALSE, FALSE);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert !completed && _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
