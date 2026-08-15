// PTO-TEST: {"id":"PTO-AVS-TILE-TNOT-CAPACITY-001","source":"asl/tile/elementwise-tile-tile/logical/TNOT.asl","requirements":["PTO-TNOT-CONTRACT-001"],"kind":"fault","summary":"TNOT preflights destination capacity before allocation.","pass_condition":"A 128-byte destination size rejects an LB0 shape requiring more capacity for TNOT.","related_sources":["asl/tile/model/legality/allocation-capacity.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(1, 256, 1, 32, 1, 17, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    for column = 0 to 16 looplimit 17 do
        WriteTileElement(1, 0, column as integer {0..65535},
            Zeros{PTO_XLEN} + column);
    end;

    let started = ExecuteCommandInstruction(
        Zeros{64} + 0xc1019181, 32);
    assert started == CommandExecution_Executed;
    SetBundleDimension(0, Zeros{PTO_XLEN} + 17);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 32);
    AddBundleTileBinding(
        TRUE, 0, 1, '1111', TRUE, FALSE, 1, 0, TRUE);

    let completed = ExecuteBundleTileOperation();
    assert !completed;
    assert _LastFault == Fault_TileAllocation;
    assert !_BundleTileBindings[[0]].destination_allocated_by_bundle;
    return 0;
end;
