// PTO-TEST: {"id":"PTO-AVS-TILE-MGATHER-MASK-LANES-001","source":"asl/tile/memory-and-data-movement/irregular/MGATHER_MASK.asl","requirements":["PTO-INST-TILE-MGATHER-MASK"],"kind":"execution","summary":"MGATHER_MASK requests only exact-one predicate lanes and pads every disabled destination lane.","pass_condition":"The enabled lane loads one byte, the disabled lane becomes zero padding, and only one load event is recorded.","related_sources":["asl/tile/model/memory/gather-scatter.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(0, 128, 1, 2, 1, 2, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigureTile(1, 128, 1, 2, 1, 2, TileDataType_U16,
        TileLayout_RowMajor, TileLocation_Any);
    ConfigurePredicateTile(2, 128, 1, 2, 1, 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTilePredicateBit(2, 0, 0, TRUE);
    WriteTilePredicateBit(2, 0, 1, FALSE);
    Store(Zeros{PTO_XLEN} + 0x280, 1, Zeros{PTO_XLEN} + 0x62);
    Store(Zeros{PTO_XLEN} + 0x281, 1, Zeros{PTO_XLEN} + 0x73);

    StartMemoryEventCapture(0);
    MGATHER_MASK(0, Zeros{PTO_XLEN} + 0x280, 1, 2, TilePad_Zero);

    assert _MemoryEventCount == 1;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0x62;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN};
    StopMemoryEventCapture();
    return 0;
end;
