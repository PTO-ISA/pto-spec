// PTO-TEST: {"id":"PTO-AVS-BLOCK-TMATMUL-PRESENCE-001","source":"asl/block/execution/BSTART.TMATMUL.asl","requirements":["PTO-TMATMUL-CONTRACT-001"],"kind":"boundary","summary":"Absent B.DATR differs from explicit DataType zero for TMATMUL.","pass_condition":"Explicit FP64 BType rejects before destination allocation even though omitted B.DATR would inherit the legal FP32 AType.","related_sources":["asl/block/model/state/descriptor-state.asl","asl/block/model/dispatch/cube-tmatmul.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 128, 4, 8, 1, 1, TileDataType_FP32,
        TileLayout_RowMajor, TileLocation_Matrix);
    ConfigureTile(2, 128, 2, 8, 1, 1, TileDataType_FP64,
        TileLayout_RowMajor, TileLocation_Matrix);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 2);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 3);
    var start: bits(64) = Zeros{64} + 0x00031181;
    start[31:27] = Zeros{5} + 1;
    let started = ExecuteCommandInstruction(start, 32);
    assert started == CommandExecution_Executed;
    SetBundleFixedPointAttributeState(
        Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDataAttributeState(Zeros{5}, Zeros{5}, Zeros{2}, Zeros{3},
        Zeros{3}, FALSE, FALSE);
    _BundleDataAttributesPresent = TRUE;
    AddBundleTileBinding(TRUE, 0, 1, '1111', TRUE, TRUE, 1, 2, TRUE);
    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileLegality;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
