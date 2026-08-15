// PTO-TEST: {"id":"PTO-AVS-TILE-TSTORE-DIRECT-001","source":"asl/tile/memory-and-data-movement/regular/TSTORE.asl","requirements":["PTO-INST-TILE-TSTORE"],"kind":"execution","summary":"TSTORE writes one valid rectangle using a logical-element row stride and preserves its source Tile.","pass_condition":"The four U64 elements reach the strided GM addresses while the source descriptor and payload remain unchanged.","related_sources":["asl/tile/model/memory/load-store.asl"]}
func main() => integer
begin
    ResetProfileState();
    ConfigureTile(4, 256, 2, 2, 2, 2, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(4, 1, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(4, 1, 1, Zeros{PTO_XLEN} + 4);

    let stride = InstructionContractDenseStride_TSTORE(4);
    TSTORE(Zeros{PTO_XLEN} + 0x300, stride, 4);

    assert _LastFault == Fault_None;
    let value00 = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 8);
    let value01 = LoadUnsigned(Zeros{PTO_XLEN} + 0x308, 8);
    let value10 = LoadUnsigned(Zeros{PTO_XLEN} + 0x320, 8);
    let value11 = LoadUnsigned(Zeros{PTO_XLEN} + 0x328, 8);
    assert value00 == Zeros{PTO_XLEN} + 1;
    assert value01 == Zeros{PTO_XLEN} + 2;
    assert value10 == Zeros{PTO_XLEN} + 3;
    assert value11 == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(4, 1, 1) == Zeros{PTO_XLEN} + 4;
    assert _Tiles[[4]].allocated;
    assert _Tiles[[4]].contents_defined;
    return 0;
end;
