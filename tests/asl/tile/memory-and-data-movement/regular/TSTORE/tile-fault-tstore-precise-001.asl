// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-PRECISE-001","source":"asl/tile/memory-and-data-movement/regular/TSTORE.asl","requirements":["PTO-INST-TILE-TSTORE"],"kind":"fault","summary":"TSTORE preflights its full footprint before the first GM or source-state effect.","pass_condition":"A second element on an unmapped page faults with zero memory events and leaves the first address and source Tile unchanged.","related_sources":["asl/tile/model/memory/load-store.asl","asl/arch/memory-model/fault-precision.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(5, 128, 1, 2, 1, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 21);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 22);
    Store(Zeros{PTO_XLEN} + 4088, 8, Zeros{PTO_XLEN} + 9);

    StartMemoryEventCapture(0);
    TSTORE(Zeros{PTO_XLEN} + 4088, Zeros{PTO_XLEN} + 1, 5);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();

    ClearFault();
    let preserved = LoadUnsigned(Zeros{PTO_XLEN} + 4088, 8);
    assert preserved == Zeros{PTO_XLEN} + 9;
    assert ReadTileElement(5, 0, 0) == Zeros{PTO_XLEN} + 21;
    assert ReadTileElement(5, 0, 1) == Zeros{PTO_XLEN} + 22;
    assert InstructionContractZeroMaskNoEffect_TSTORE('0000');
    return 0;
end;
