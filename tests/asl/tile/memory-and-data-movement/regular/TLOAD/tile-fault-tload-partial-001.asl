// PTO-TEST: {"id":"PTO-AVS-TILE-TLOAD-PARTIAL-001","source":"asl/tile/memory-and-data-movement/regular/TLOAD.asl","requirements":["PTO-INST-TILE-TLOAD","PTO-TLOAD-MEMORY-001"],"kind":"fault","summary":"TLOAD stops at its first memory fault and retains completed Local reads without publishing a complete destination.","pass_condition":"The first element is loaded and recorded, the second element faults, and the destination remains partially defined rather than complete.","related_sources":["asl/tile/model/memory/load-store.asl","asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(5, 128, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor);
    Store(Zeros{PTO_XLEN} + 4088, 8, Zeros{PTO_XLEN} + 31);

    StartMemoryEventCapture(0);
    TLOAD(5, Zeros{PTO_XLEN} + 4088, Zeros{PTO_XLEN} + 1);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 1;
    assert !_MemoryReplayState.active;
    assert _MemoryReplayState.committed_event_count == 1;
    assert MemoryReplayCanRetryWholeRequest(Zeros{PTO_XLEN});
    StopMemoryEventCapture();

    assert TileLogicalElementDefined(_Tiles[[5]], 0);
    assert !_Tiles[[5]].contents_defined;
    assert ReadTileElement(5, 0, 0) == Zeros{PTO_XLEN} + 31;
    assert !TileLogicalElementDefined(_Tiles[[5]], 1);
    return 0;
end;
