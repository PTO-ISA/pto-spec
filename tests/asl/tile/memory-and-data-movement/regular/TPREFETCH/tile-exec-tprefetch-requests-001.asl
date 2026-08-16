// PTO-TEST: {"id":"PTO-AVS-TILE-TPREFETCH-REQUESTS-001","source":"asl/tile/memory-and-data-movement/regular/TPREFETCH.asl","requirements":["PTO-INST-TILE-TPREFETCH"],"kind":"execution","summary":"TPREFETCH issues the complete typed footprint for all four PEs without allocating a Tile.","pass_condition":"A two-element U8 footprint emits two load events per PE at the requested addresses and leaves Tile capacity unused.","related_sources":["asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    StartMemoryEventCapture(0);

    TPREFETCHAllPEs(Zeros{PTO_XLEN} + 0x180,
        Zeros{PTO_XLEN} + 2, 2, 1, 2, TileDataType_U8);

    assert _MemoryEventCount == 8;
    assert _MemoryEvents[[0]].agent == 0;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x180;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x181;
    assert _MemoryEvents[[6]].agent == 3;
    assert _MemoryEvents[[7]].address == Zeros{PTO_XLEN} + 0x181;
    assert CoreTileCapacityInUse() == 0;
    StopMemoryEventCapture();
    return 0;
end;
