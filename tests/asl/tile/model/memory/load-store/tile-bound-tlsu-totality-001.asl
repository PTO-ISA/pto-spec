// PTO-TEST: {"id":"PTO-AVS-TILE-TLSU-DIRECT-BOUND-001","source":"asl/tile/model/memory/load-store.asl","requirements":[],"kind":"boundary","summary":"direct TLSU selectors support every assigned four-bit type","pass_condition":"direct selector and four-bit type assertions hold","related_sources":[]}
func ConfigurePackedTlsuTile(index: TileIndex, columns: integer {1..16})
begin
    // Keep packed data and U64 index tiles on the same legal physical shape:
    // 16 rows x 16 power-of-two columns. Only the valid-column extent varies.
    ConfigureTile(index, 128, 1, 16, 1, columns, TileDataType_U4X2,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigurePackedTlsuTileTwoByTwo(index: TileIndex)
begin
    ConfigureTile(index, 256, 2, 2, 2, 2, TileDataType_U4X2,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigurePackedTlsuTileType(index: TileIndex,
                                columns: integer {1..16},
                                data_type: TileDataType)
begin
    assert TileDataTypeIsFourBit(data_type);
    ConfigureTile(index, 128, 1, 16, 1, columns, data_type,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigureIndexTlsuTile(index: TileIndex, columns: integer {1..16})
begin
    ConfigureTile(index, 2048, 1, 16, 1, columns, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTlsuPackedDirectSelectors()
begin
    StopMemoryEventCapture();
    ConfigurePackedTlsuTile(0, 3);
    ConfigurePackedTlsuTile(1, 3);
    ConfigurePackedTlsuTile(2, 3);

    Store(Zeros{PTO_XLEN} + 0x100, 1, Zeros{PTO_XLEN} + 0xba);
    Store(Zeros{PTO_XLEN} + 0x101, 1, Zeros{PTO_XLEN} + 0xc5);
    StartMemoryEventCapture(0);
    TLOAD(0, Zeros{PTO_XLEN} + 0x100, Zeros{PTO_XLEN} + 3);
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x100;
    assert _MemoryEvents[[0]].size_bytes == 1;
    assert _MemoryEvents[[0]].read_value == Zeros{PTO_XLEN} + 0xba;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x100;
    assert _MemoryEvents[[2]].address == Zeros{PTO_XLEN} + 0x101;
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 0xa;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 0xb;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 0x5;
    StopMemoryEventCapture();

    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(1, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(1, 0, 2, Zeros{PTO_XLEN} + 3);
    Store(Zeros{PTO_XLEN} + 0x110, 1, Zeros{PTO_XLEN} + 0x90);
    Store(Zeros{PTO_XLEN} + 0x111, 1, Zeros{PTO_XLEN} + 0xe0);
    StartMemoryEventCapture(0);
    TSTORE(Zeros{PTO_XLEN} + 0x110, Zeros{PTO_XLEN} + 3, 1);
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x110;
    assert _MemoryEvents[[0]].size_bytes == 1;
    assert _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 0x91;
    assert _MemoryEvents[[1]].write_value == Zeros{PTO_XLEN} + 0x21;
    assert _MemoryEvents[[2]].address == Zeros{PTO_XLEN} + 0x111;
    assert _MemoryEvents[[2]].write_value == Zeros{PTO_XLEN} + 0xe3;
    StopMemoryEventCapture();
    let packed_store_byte0 = LoadUnsigned(Zeros{PTO_XLEN} + 0x110, 1);
    let packed_store_byte1 = LoadUnsigned(Zeros{PTO_XLEN} + 0x111, 1);
    assert packed_store_byte0 == Zeros{PTO_XLEN} + 0x21;
    assert packed_store_byte1 == Zeros{PTO_XLEN} + 0xe3;

    // Packed addressing applies the byte stride between row starts, then uses
    // column parity to choose the containing byte and low/high nibble.
    ConfigurePackedTlsuTileTwoByTwo(39);
    Store(Zeros{PTO_XLEN} + 0x130, 1, Zeros{PTO_XLEN} + 0x21);
    Store(Zeros{PTO_XLEN} + 0x131, 1, Zeros{PTO_XLEN} + 0xee);
    Store(Zeros{PTO_XLEN} + 0x134, 1, Zeros{PTO_XLEN} + 0x43);
    TLOAD(39, Zeros{PTO_XLEN} + 0x130, Zeros{PTO_XLEN} + 4);
    assert ReadTileElement(39, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(39, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(39, 1, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTileElement(39, 1, 1) == Zeros{PTO_XLEN} + 4;

    WriteTileElement(39, 0, 0, Zeros{PTO_XLEN} + 5);
    WriteTileElement(39, 0, 1, Zeros{PTO_XLEN} + 6);
    WriteTileElement(39, 1, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(39, 1, 1, Zeros{PTO_XLEN} + 8);
    TSTORE(Zeros{PTO_XLEN} + 0x140, Zeros{PTO_XLEN} + 4, 39);
    let packed_strided_row0 = LoadUnsigned(
        Zeros{PTO_XLEN} + 0x140, 1);
    let packed_strided_row1 = LoadUnsigned(
        Zeros{PTO_XLEN} + 0x144, 1);
    assert packed_strided_row0 == Zeros{PTO_XLEN} + 0x65;
    assert packed_strided_row1 == Zeros{PTO_XLEN} + 0x87;

    TMOV(2, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(2, 0, 2) == Zeros{PTO_XLEN} + 3;

    // The one-level PTO model receives the peer fragment as the resolved
    // source tile; peer_tid remains an explicit legality/control operand.
    GMOV(0, 1, Zeros{PTO_XLEN} + 1);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 3;

    StartMemoryEventCapture(0);
    TPREFETCHAllPEs(Zeros{PTO_XLEN} + 0x120, Zeros{PTO_XLEN} + 2,
        2, 1, 2, TileDataType_U8);
    assert _MemoryEventCount == 8;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[0]].size_bytes == 1;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x121;
    StopMemoryEventCapture();
end;

func TestTlsuAllFourBitTypes()
begin
    ConfigurePackedTlsuTileType(33, 2, TileDataType_E2M1X2);
    ConfigurePackedTlsuTileType(34, 2, TileDataType_E1M2X2);
    ConfigurePackedTlsuTileType(35, 2, TileDataType_HiF4X2);
    ConfigurePackedTlsuTileType(36, 2, TileDataType_S4X2);
    ConfigurePackedTlsuTileType(37, 2, TileDataType_U4X2);
    ConfigureIndexTlsuTile(38, 2);
    WriteTileElement(38, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(38, 0, 1, Zeros{PTO_XLEN} + 1);

    for tile_offset = 0 to 4 do
        let tile = (33 + tile_offset) as TileIndex;
        let address = Zeros{PTO_XLEN} + 0x340 + tile_offset;
        Store(address, 1, Zeros{PTO_XLEN} + 0xaf);
        TLOAD(tile, address, Zeros{PTO_XLEN} + 2);
        assert ReadTileElement(tile, 0, 0) == Zeros{PTO_XLEN} + 0xf;
        assert ReadTileElement(tile, 0, 1) == Zeros{PTO_XLEN} + 0xa;

        WriteTileElement(tile, 0, 0, Zeros{PTO_XLEN} + tile_offset + 1);
        WriteTileElement(tile, 0, 1, Zeros{PTO_XLEN} + tile_offset + 5);
        TSTORE(address, Zeros{PTO_XLEN} + 2, tile);
        let stored = LoadUnsigned(address, 1);
        assert stored == Zeros{PTO_XLEN} +
            (tile_offset + 5) * 16 + tile_offset + 1;

        assert !IndexedTLSUTransferDataTypeLegal(
            _Tiles[[tile]].data_type);
    end;
end;

func main() => integer
begin
    ResetProfileState();
    TestTlsuPackedDirectSelectors();
    TestTlsuAllFourBitTypes();
    return 0;
end;
