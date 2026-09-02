// PTO-TEST: {"id":"PTO-AVS-TILE-TLSU-INDEXED-BOUND-002","source":"asl/tile/model/memory/load-store.asl","requirements":[],"kind":"boundary","summary":"indexed TLSU operations preflight and restart packed accesses","pass_condition":"indexed, preflight, and restart assertions hold","related_sources":[]}
func ConfigurePackedTlsuTile(index: TileIndex, columns: integer {1..16})
begin
    // Keep packed data and U64 index tiles on the same legal physical shape:
    // 16 rows x 16 power-of-two columns. Only the valid-column extent varies.
    ConfigureTile(index, 128, 1, 16, 1, columns, TileDataType_U4X2,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigureIndexTlsuTile(index: TileIndex, columns: integer {1..16})
begin
    ConfigureTile(index, 2048, 1, 16, 1, 1, TileDataType_U32,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigureByteTlsuTile(index: TileIndex, columns: integer {1..16})
begin
    ConfigureTile(index, 128, 1, 16, 1, columns, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTlsuPackedIndexedSelectors()
begin
    StopMemoryEventCapture();
    ConfigureByteTlsuTile(3, 3);
    ConfigureIndexTlsuTile(4, 3);
    ConfigureByteTlsuTile(5, 3);
    ConfigurePackedTlsuTile(6, 3);
    ConfigureIndexTlsuTile(7, 3);
    ConfigurePackedTlsuTile(8, 3);
    ConfigurePackedTlsuTile(9, 3);
    ConfigureIndexTlsuTile(10, 3);
    ConfigurePackedTlsuTile(11, 3);
    ConfigurePackedTlsuTile(12, 3);

    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 0x180, 1, Zeros{PTO_XLEN} + 0x21);
    Store(Zeros{PTO_XLEN} + 0x181, 1, Zeros{PTO_XLEN} + 0x43);
    Store(Zeros{PTO_XLEN} + 0x182, 1, Zeros{PTO_XLEN} + 0x65);
    StartMemoryEventCapture(1);
    MGATHER(3, Zeros{PTO_XLEN} + 0x180,
        Zeros{PTO_XLEN} + 3, 4);
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x180;
    assert _MemoryEvents[[0]].size_bytes == 1;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x181;
    assert _MemoryEvents[[2]].address == Zeros{PTO_XLEN} + 0x182;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0x21;
    assert ReadTileElement(3, 0, 1) == Zeros{PTO_XLEN} + 0x43;
    assert ReadTileElement(3, 0, 2) == Zeros{PTO_XLEN} + 0x65;
    StopMemoryEventCapture();

    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 5);
    WriteTileElement(5, 0, 2, Zeros{PTO_XLEN} + 6);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    Store(Zeros{PTO_XLEN} + 0x190, 1, Zeros{PTO_XLEN} + 0xa9);
    StartMemoryEventCapture(1);
    MSCATTER(Zeros{PTO_XLEN} + 0x190,
        Zeros{PTO_XLEN} + 3, 5, 4);
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[2]].kind == MemoryEvent_Store;
    StopMemoryEventCapture();
    let scatter_byte = LoadUnsigned(Zeros{PTO_XLEN} + 0x190, 1);
    let scatter_next = LoadUnsigned(Zeros{PTO_XLEN} + 0x191, 1);
    assert scatter_byte == Zeros{PTO_XLEN} + 4;
    assert scatter_next == Zeros{PTO_XLEN} + 5;

end;

func TestTlsuPackedPreflightAndRestart()
begin
    StopMemoryEventCapture();
    ConfigurePackedTlsuTile(13, 5);
    ConfigureIndexTlsuTile(14, 3);
    ConfigureByteTlsuTile(15, 3);
    ConfigurePackedTlsuTile(16, 3);
    ConfigurePackedTlsuTile(17, 3);

    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 0xd);
    WriteTileElement(13, 0, 1, Zeros{PTO_XLEN} + 0xd);
    WriteTileElement(13, 0, 2, Zeros{PTO_XLEN} + 0xd);
    WriteTileElement(13, 0, 3, Zeros{PTO_XLEN} + 0xd);
    WriteTileElement(13, 0, 4, Zeros{PTO_XLEN} + 0xd);

    ClearFault();
    StartMemoryEventCapture(2);
    TLOAD(13, Zeros{PTO_XLEN} + 4096, Zeros{PTO_XLEN} + 5);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    assert ReadTileElement(13, 0, 0) == Zeros{PTO_XLEN} + 0xd;

    ClearFault();
    StartMemoryEventCapture(2);
    TLOAD(13, Zeros{PTO_XLEN} + 4095, Zeros{PTO_XLEN} + 5);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    assert ReadTileElement(13, 0, 2) == Zeros{PTO_XLEN} + 0xd;

    Store(Zeros{PTO_XLEN} + 4094, 1, Zeros{PTO_XLEN} + 0xaa);
    Store(Zeros{PTO_XLEN} + 4095, 1, Zeros{PTO_XLEN} + 0xbb);
    ClearFault();
    StartMemoryEventCapture(2);
    TLOAD(13, Zeros{PTO_XLEN} + 4094, Zeros{PTO_XLEN} + 5);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    assert ReadTileElement(13, 0, 4) == Zeros{PTO_XLEN} + 0xd;

    Store(Zeros{PTO_XLEN} + 0x1d0, 1, Zeros{PTO_XLEN} + 0x21);
    Store(Zeros{PTO_XLEN} + 0x1d1, 1, Zeros{PTO_XLEN} + 0x43);
    Store(Zeros{PTO_XLEN} + 0x1d2, 1, Zeros{PTO_XLEN} + 0x05);
    ClearFault();
    TLOAD(13, Zeros{PTO_XLEN} + 0x1d0, Zeros{PTO_XLEN} + 5);
    assert _LastFault == Fault_None;
    assert ReadTileElement(13, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(13, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(13, 0, 2) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(13, 0, 3) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(13, 0, 4) == Zeros{PTO_XLEN} + 5;

    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(13, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(13, 0, 2, Zeros{PTO_XLEN} + 3);
    WriteTileElement(13, 0, 3, Zeros{PTO_XLEN} + 4);
    WriteTileElement(13, 0, 4, Zeros{PTO_XLEN} + 5);
    Store(Zeros{PTO_XLEN} + 4094, 1, Zeros{PTO_XLEN} + 0xaa);
    Store(Zeros{PTO_XLEN} + 4095, 1, Zeros{PTO_XLEN} + 0xbb);
    ClearFault();
    StartMemoryEventCapture(2);
    TSTORE(Zeros{PTO_XLEN} + 4094, Zeros{PTO_XLEN} + 5, 13);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let fault_tstore_byte0 = LoadUnsigned(Zeros{PTO_XLEN} + 4094, 1);
    let fault_tstore_byte1 = LoadUnsigned(Zeros{PTO_XLEN} + 4095, 1);
    assert fault_tstore_byte0 == Zeros{PTO_XLEN} + 0xaa;
    assert fault_tstore_byte1 == Zeros{PTO_XLEN} + 0xbb;

    WriteTileElement(14, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(15, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(15, 0, 1, Zeros{PTO_XLEN} + 8);
    WriteTileElement(15, 0, 2, Zeros{PTO_XLEN} + 9);
    Store(Zeros{PTO_XLEN} + 4094, 1, Zeros{PTO_XLEN} + 0xaa);
    Store(Zeros{PTO_XLEN} + 4095, 1, Zeros{PTO_XLEN} + 0xbb);
    ClearFault();
    StartMemoryEventCapture(2);
    MSCATTER(Zeros{PTO_XLEN} + 4094,
        Zeros{PTO_XLEN} + 3, 15, 14);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let fault_scatter_byte0 = LoadUnsigned(Zeros{PTO_XLEN} + 4094, 1);
    let fault_scatter_byte1 = LoadUnsigned(Zeros{PTO_XLEN} + 4095, 1);
    assert fault_scatter_byte0 == Zeros{PTO_XLEN} + 0xaa;
    assert fault_scatter_byte1 == Zeros{PTO_XLEN} + 0xbb;

end;

func main() => integer
begin
    ResetProfileState();
    TestTlsuPackedIndexedSelectors();
    TestTlsuPackedPreflightAndRestart();
    return 0;
end;
