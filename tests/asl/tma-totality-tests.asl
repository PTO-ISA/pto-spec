// PTO-REQ-TMA-001, PTO-REQ-MEMORY-COMPLETION-001,
// PTO-REQ-MEMORY-TSO-001: S4-T9 packed TMA totality tests.

func ConfigurePackedTmaTile(index: TileIndex, columns: integer {1..16})
begin
    ConfigureTile(index, 256, 1, columns, 1, columns, TileDataType_U4,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigurePackedTmaTileType(index: TileIndex,
                                columns: integer {1..16},
                                data_type: TileDataType)
begin
    assert TileDataTypeIsFourBit(data_type);
    ConfigureTile(index, 256, 1, columns, 1, columns, data_type,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigureIndexTmaTile(index: TileIndex, columns: integer {1..16})
begin
    ConfigureTile(index, 256, 1, columns, 1, columns, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTmaPackedDirectSelectors()
begin
    StopMemoryEventCapture();
    ConfigurePackedTmaTile(0, 3);
    ConfigurePackedTmaTile(1, 3);
    ConfigurePackedTmaTile(2, 3);

    Store(Zeros{PTO_XLEN} + 0x100, 1, Zeros{PTO_XLEN} + 0xba);
    Store(Zeros{PTO_XLEN} + 0x101, 1, Zeros{PTO_XLEN} + 0xc5);
    StartMemoryEventCapture(0);
    TLOAD(0, Zeros{PTO_XLEN} + 0x100);
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
    TSTORE(Zeros{PTO_XLEN} + 0x110, 1);
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

    TMOV(2, 1);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(2, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(2, 0, 2) == Zeros{PTO_XLEN} + 3;

    StartMemoryEventCapture(0);
    TPREFETCH(Zeros{PTO_XLEN} + 0x120, 2);
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[0]].size_bytes == 1;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x121;
    StopMemoryEventCapture();
end;

func TestTmaAllFourBitTypes()
begin
    ConfigurePackedTmaTileType(33, 2, TileDataType_FP4);
    ConfigurePackedTmaTileType(34, 2, TileDataType_FPL4);
    ConfigurePackedTmaTileType(35, 2, TileDataType_S4);
    ConfigurePackedTmaTileType(36, 2, TileDataType_U4);
    ConfigureIndexTmaTile(37, 2);
    WriteTileElement(37, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(37, 0, 1, Zeros{PTO_XLEN} + 1);

    for tile_offset = 0 to 3 do
        let tile = (33 + tile_offset) as TileIndex;
        let address = Zeros{PTO_XLEN} + 0x340 + tile_offset;
        Store(address, 1, Zeros{PTO_XLEN} + 0xaf);
        TLOAD(tile, address);
        assert ReadTileElement(tile, 0, 0) == Zeros{PTO_XLEN} + 0xf;
        assert ReadTileElement(tile, 0, 1) == Zeros{PTO_XLEN} + 0xa;

        WriteTileElement(tile, 0, 0, Zeros{PTO_XLEN} + tile_offset + 1);
        WriteTileElement(tile, 0, 1, Zeros{PTO_XLEN} + tile_offset + 5);
        TSTORE(address, tile);
        let stored = LoadUnsigned(address, 1);
        assert stored == Zeros{PTO_XLEN} +
            (tile_offset + 5) * 16 + tile_offset + 1;

        Store(address, 1, Zeros{PTO_XLEN} + 0xa8 + tile_offset);
        MGATHER(tile, address, 37);
        assert ReadTileElement(tile, 0, 0) ==
            Zeros{PTO_XLEN} + 8 + tile_offset;
        assert ReadTileElement(tile, 0, 1) == Zeros{PTO_XLEN} + 0xa;
    end;
end;

func TestTmaPackedIndexedSelectors()
begin
    StopMemoryEventCapture();
    ConfigurePackedTmaTile(3, 3);
    ConfigureIndexTmaTile(4, 3);
    ConfigurePackedTmaTile(5, 3);
    ConfigurePackedTmaTile(6, 3);
    ConfigureIndexTmaTile(7, 3);
    ConfigurePackedTmaTile(8, 3);
    ConfigurePackedTmaTile(9, 3);
    ConfigureIndexTmaTile(10, 3);
    ConfigurePackedTmaTile(11, 3);
    ConfigurePackedTmaTile(12, 3);

    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 2, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 0x180, 1, Zeros{PTO_XLEN} + 0x21);
    StartMemoryEventCapture(1);
    MGATHER(3, Zeros{PTO_XLEN} + 0x180, 4);
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[0]].address == Zeros{PTO_XLEN} + 0x180;
    assert _MemoryEvents[[0]].size_bytes == 1;
    assert _MemoryEvents[[1]].address == Zeros{PTO_XLEN} + 0x180;
    assert _MemoryEvents[[2]].address == Zeros{PTO_XLEN} + 0x180;
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(3, 0, 1) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(3, 0, 2) == Zeros{PTO_XLEN} + 2;
    StopMemoryEventCapture();

    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 5);
    WriteTileElement(5, 0, 2, Zeros{PTO_XLEN} + 6);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 2, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 0x190, 1, Zeros{PTO_XLEN} + 0xa9);
    StartMemoryEventCapture(1);
    MSCATTER(Zeros{PTO_XLEN} + 0x190, 5, 4);
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 0xa4;
    assert _MemoryEvents[[1]].write_value == Zeros{PTO_XLEN} + 0xa5;
    assert _MemoryEvents[[2]].write_value == Zeros{PTO_XLEN} + 0x65;
    StopMemoryEventCapture();
    let scatter_byte = LoadUnsigned(Zeros{PTO_XLEN} + 0x190, 1);
    assert scatter_byte == Zeros{PTO_XLEN} + 0x65;

    WriteTileElement(6, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(6, 0, 1, Zeros{PTO_XLEN} + 8);
    WriteTileElement(6, 0, 2, Zeros{PTO_XLEN} + 9);
    WriteTileElement(7, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(7, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(7, 0, 2, Zeros{PTO_XLEN});
    WriteTileElement(8, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(8, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(8, 0, 2, Zeros{PTO_XLEN} + 1);
    Store(Zeros{PTO_XLEN} + 0x1a0, 1, Zeros{PTO_XLEN} + 0x21);
    StartMemoryEventCapture(1);
    MGATHER_MASK(6, Zeros{PTO_XLEN} + 0x1a0, 7, 8);
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Load;
    assert ReadTileElement(6, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(6, 0, 1) == Zeros{PTO_XLEN} + 8;
    assert ReadTileElement(6, 0, 2) == Zeros{PTO_XLEN} + 1;
    StopMemoryEventCapture();

    Store(Zeros{PTO_XLEN} + 0x1b0, 1, Zeros{PTO_XLEN} + 0xa9);
    StartMemoryEventCapture(1);
    MSCATTER_MASK(Zeros{PTO_XLEN} + 0x1b0, 5, 4, 8);
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 0xa4;
    assert _MemoryEvents[[1]].write_value == Zeros{PTO_XLEN} + 0x64;
    StopMemoryEventCapture();
    let masked_scatter_byte = LoadUnsigned(Zeros{PTO_XLEN} + 0x1b0, 1);
    assert masked_scatter_byte == Zeros{PTO_XLEN} + 0x64;

    WriteTileElement(10, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(10, 0, 1, Zeros{PTO_XLEN});
    WriteTileElement(10, 0, 2, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(11, 0, 1, Zeros{PTO_XLEN} + 9);
    WriteTileElement(11, 0, 2, Zeros{PTO_XLEN} + 2);
    WriteTileElement(12, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(12, 0, 1, Zeros{PTO_XLEN} + 5);
    WriteTileElement(12, 0, 2, Zeros{PTO_XLEN} + 6);
    Store(Zeros{PTO_XLEN} + 0x1c0, 1, Zeros{PTO_XLEN} + 0x21);
    StartMemoryEventCapture(1);
    MGATHER_CAS(9, Zeros{PTO_XLEN} + 0x1c0, 10, 11, 12);
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[0]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[0]].write_performed;
    assert _MemoryEvents[[0]].read_value == Zeros{PTO_XLEN} + 0x21;
    assert _MemoryEvents[[0]].write_value == Zeros{PTO_XLEN} + 0x24;
    assert !_MemoryEvents[[1]].write_performed;
    assert _MemoryEvents[[1]].read_value == Zeros{PTO_XLEN} + 0x24;
    assert _MemoryEvents[[1]].write_value == Zeros{PTO_XLEN} + 0x25;
    assert _MemoryEvents[[2]].write_performed;
    assert _MemoryEvents[[2]].write_value == Zeros{PTO_XLEN} + 0x64;
    StopMemoryEventCapture();
    assert ReadTileElement(9, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(9, 0, 1) == Zeros{PTO_XLEN} + 4;
    assert ReadTileElement(9, 0, 2) == Zeros{PTO_XLEN} + 2;
    let cas_byte = LoadUnsigned(Zeros{PTO_XLEN} + 0x1c0, 1);
    assert cas_byte == Zeros{PTO_XLEN} + 0x64;
end;

func TestTmaPackedPreflightAndRestart()
begin
    StopMemoryEventCapture();
    ConfigurePackedTmaTile(13, 5);
    ConfigureIndexTmaTile(14, 3);
    ConfigurePackedTmaTile(15, 3);
    ConfigurePackedTmaTile(16, 3);
    ConfigurePackedTmaTile(17, 3);

    WriteTileElement(13, 0, 0, Zeros{PTO_XLEN} + 0xd);
    WriteTileElement(13, 0, 1, Zeros{PTO_XLEN} + 0xd);
    WriteTileElement(13, 0, 2, Zeros{PTO_XLEN} + 0xd);
    WriteTileElement(13, 0, 3, Zeros{PTO_XLEN} + 0xd);
    WriteTileElement(13, 0, 4, Zeros{PTO_XLEN} + 0xd);

    ClearFault();
    StartMemoryEventCapture(2);
    TLOAD(13, Zeros{PTO_XLEN} + 4096);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    assert ReadTileElement(13, 0, 0) == Zeros{PTO_XLEN} + 0xd;

    ClearFault();
    StartMemoryEventCapture(2);
    TLOAD(13, Zeros{PTO_XLEN} + 4095);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    assert ReadTileElement(13, 0, 2) == Zeros{PTO_XLEN} + 0xd;

    Store(Zeros{PTO_XLEN} + 4094, 1, Zeros{PTO_XLEN} + 0xaa);
    Store(Zeros{PTO_XLEN} + 4095, 1, Zeros{PTO_XLEN} + 0xbb);
    ClearFault();
    StartMemoryEventCapture(2);
    TLOAD(13, Zeros{PTO_XLEN} + 4094);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    assert ReadTileElement(13, 0, 4) == Zeros{PTO_XLEN} + 0xd;

    Store(Zeros{PTO_XLEN} + 0x1d0, 1, Zeros{PTO_XLEN} + 0x21);
    Store(Zeros{PTO_XLEN} + 0x1d1, 1, Zeros{PTO_XLEN} + 0x43);
    Store(Zeros{PTO_XLEN} + 0x1d2, 1, Zeros{PTO_XLEN} + 0x05);
    ClearFault();
    TLOAD(13, Zeros{PTO_XLEN} + 0x1d0);
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
    TSTORE(Zeros{PTO_XLEN} + 4094, 13);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let fault_tstore_byte0 = LoadUnsigned(Zeros{PTO_XLEN} + 4094, 1);
    let fault_tstore_byte1 = LoadUnsigned(Zeros{PTO_XLEN} + 4095, 1);
    assert fault_tstore_byte0 == Zeros{PTO_XLEN} + 0xaa;
    assert fault_tstore_byte1 == Zeros{PTO_XLEN} + 0xbb;

    WriteTileElement(14, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(14, 0, 1, Zeros{PTO_XLEN} + 1);
    WriteTileElement(14, 0, 2, Zeros{PTO_XLEN} + 4);
    WriteTileElement(15, 0, 0, Zeros{PTO_XLEN} + 7);
    WriteTileElement(15, 0, 1, Zeros{PTO_XLEN} + 8);
    WriteTileElement(15, 0, 2, Zeros{PTO_XLEN} + 9);
    Store(Zeros{PTO_XLEN} + 4094, 1, Zeros{PTO_XLEN} + 0xaa);
    Store(Zeros{PTO_XLEN} + 4095, 1, Zeros{PTO_XLEN} + 0xbb);
    ClearFault();
    StartMemoryEventCapture(2);
    MSCATTER(Zeros{PTO_XLEN} + 4094, 15, 14);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let fault_scatter_byte0 = LoadUnsigned(Zeros{PTO_XLEN} + 4094, 1);
    let fault_scatter_byte1 = LoadUnsigned(Zeros{PTO_XLEN} + 4095, 1);
    assert fault_scatter_byte0 == Zeros{PTO_XLEN} + 0xaa;
    assert fault_scatter_byte1 == Zeros{PTO_XLEN} + 0xbb;

    WriteTileElement(16, 0, 0, Zeros{PTO_XLEN} + 0xa);
    WriteTileElement(16, 0, 1, Zeros{PTO_XLEN} + 0xa);
    WriteTileElement(16, 0, 2, Zeros{PTO_XLEN} + 0xa);
    WriteTileElement(17, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(17, 0, 1, Zeros{PTO_XLEN} + 2);
    WriteTileElement(17, 0, 2, Zeros{PTO_XLEN} + 3);
    ClearFault();
    StartMemoryEventCapture(2);
    MGATHER_CAS(15, Zeros{PTO_XLEN} + 4094, 14, 16, 17);
    assert _LastFault == Fault_DataPage;
    assert _MemoryEventCount == 0;
    StopMemoryEventCapture();
    let fault_cas_byte0 = LoadUnsigned(Zeros{PTO_XLEN} + 4094, 1);
    let fault_cas_byte1 = LoadUnsigned(Zeros{PTO_XLEN} + 4095, 1);
    assert fault_cas_byte0 == Zeros{PTO_XLEN} + 0xaa;
    assert fault_cas_byte1 == Zeros{PTO_XLEN} + 0xbb;
end;

func TestTmaFaultPositionMatrix()
begin
    let base_address = Zeros{PTO_XLEN} + 0x380;

    // Contiguous stores and prefetches reject when the first, a middle, or the
    // last containing byte is outside the modeled page, with no event prefix.
    ConfigurePackedTmaTile(26, 5);
    for lane = 0 to 4 do
        WriteTileElement(26, 0, lane, Zeros{PTO_XLEN} + lane + 1);
    end;
    for fault_position = 0 to 2 do
        let start_address = if fault_position == 0 then
            Zeros{PTO_XLEN} + 4096
            else if fault_position == 1 then Zeros{PTO_XLEN} + 4095
            else Zeros{PTO_XLEN} + 4094;
        ClearFault();
        StartMemoryEventCapture(0);
        TSTORE(start_address, 26);
        assert _LastFault == Fault_DataPage;
        assert _MemoryEventCount == 0;
        StopMemoryEventCapture();

        let byte_count = if fault_position == 0 then 1 else 3;
        ClearFault();
        StartMemoryEventCapture(0);
        TPREFETCH(start_address, byte_count);
        assert _LastFault == Fault_DataPage;
        assert _MemoryEventCount == 0;
        StopMemoryEventCapture();
    end;

    ConfigurePackedTmaTile(27, 3);
    ConfigureIndexTmaTile(28, 3);
    ConfigurePackedTmaTile(29, 3);
    ConfigurePackedTmaTile(30, 3);
    ConfigurePackedTmaTile(31, 3);
    ConfigurePackedTmaTile(32, 3);
    for lane = 0 to 2 do
        WriteTileElement(27, 0, lane, Zeros{PTO_XLEN} + 9);
        WriteTileElement(29, 0, lane, Zeros{PTO_XLEN} + 1);
        WriteTileElement(30, 0, lane, Zeros{PTO_XLEN} + 2);
        WriteTileElement(31, 0, lane, Zeros{PTO_XLEN} + 3);
        WriteTileElement(32, 0, lane, Zeros{PTO_XLEN} + 4);
    end;

    // Indexed gather, scatter, masked variants, and CAS all share the same
    // complete-footprint rule. Exercise the fault in every lane position.
    for fault_position = 0 to 2 do
        for lane = 0 to 2 do
            let index_value = if lane == fault_position then
                Zeros{PTO_XLEN} + 6400 else Zeros{PTO_XLEN} + (lane * 2);
            WriteTileElement(28, 0, lane, index_value);
            WriteTileElement(27, 0, lane, Zeros{PTO_XLEN} + 9);
        end;
        Store(base_address, 1, Zeros{PTO_XLEN} + 0x21);
        Store(base_address + 1, 1, Zeros{PTO_XLEN} + 0x43);
        Store(base_address + 2, 1, Zeros{PTO_XLEN} + 0x65);

        ClearFault();
        StartMemoryEventCapture(1);
        MGATHER_MASK(27, base_address, 28, 29);
        assert _LastFault == Fault_DataPage;
        assert _FaultAddress == Zeros{PTO_XLEN} + 4096;
        assert _MemoryEventCount == 0;
        StopMemoryEventCapture();
        for lane = 0 to 2 do
            assert ReadTileElement(27, 0, lane) == Zeros{PTO_XLEN} + 9;
        end;

        ClearFault();
        StartMemoryEventCapture(1);
        MSCATTER(base_address, 30, 28);
        assert _LastFault == Fault_DataPage;
        assert _MemoryEventCount == 0;
        StopMemoryEventCapture();

        ClearFault();
        StartMemoryEventCapture(1);
        MSCATTER_MASK(base_address, 30, 28, 29);
        assert _LastFault == Fault_DataPage;
        assert _MemoryEventCount == 0;
        StopMemoryEventCapture();

        ClearFault();
        StartMemoryEventCapture(1);
        MGATHER_CAS(27, base_address, 28, 31, 32);
        assert _LastFault == Fault_DataPage;
        assert _MemoryEventCount == 0;
        StopMemoryEventCapture();

        let preserved0 = LoadUnsigned(base_address, 1);
        let preserved1 = LoadUnsigned(base_address + 1, 1);
        let preserved2 = LoadUnsigned(base_address + 2, 1);
        assert preserved0 == Zeros{PTO_XLEN} + 0x21;
        assert preserved1 == Zeros{PTO_XLEN} + 0x43;
        assert preserved2 == Zeros{PTO_XLEN} + 0x65;
    end;
end;

func TestTmaDecodedSelectorClosure()
begin
    ConfigurePackedTmaTile(20, 1);
    ConfigurePackedTmaTile(21, 1);
    ConfigureIndexTmaTile(22, 1);
    ConfigurePackedTmaTile(23, 1);
    ConfigurePackedTmaTile(24, 1);
    ConfigurePackedTmaTile(25, 1);
    WriteTileElement(20, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(21, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(22, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(23, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(24, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(25, 0, 0, Zeros{PTO_XLEN} + 4);

    Store(Zeros{PTO_XLEN} + 0x300, 1, Zeros{PTO_XLEN} + 0xa2);
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.address = Zeros{PTO_XLEN} + 0x300;
    let (load_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, Zeros{12}, operands);
    assert load_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 2;

    operands = DefaultTileInstructionOperands();
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 21;
    let (store_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, Zeros{12} + 1, operands);
    assert store_status == TileExecution_Executed;
    let stored_byte = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 1);
    assert stored_byte == Zeros{PTO_XLEN} + 0xa3;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.source0 = 21;
    let (move_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, Zeros{12} + 2, operands);
    assert move_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;

    operands = DefaultTileInstructionOperands();
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.byte_count = 1;
    let (prefetch_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, Zeros{12} + 3, operands);
    assert prefetch_status == TileExecution_Executed;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 22;
    let (gather_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, Zeros{12} + 4, operands);
    assert gather_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;

    operands = DefaultTileInstructionOperands();
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 21;
    operands.source1 = 22;
    let (scatter_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, Zeros{12} + 5, operands);
    assert scatter_status == TileExecution_Executed;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 22;
    operands.source1 = 23;
    let (masked_gather_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, Zeros{12} + 6, operands);
    assert masked_gather_status == TileExecution_Executed;

    operands = DefaultTileInstructionOperands();
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 21;
    operands.source1 = 22;
    operands.source2 = 23;
    let (masked_scatter_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, Zeros{12} + 7, operands);
    assert masked_scatter_status == TileExecution_Executed;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 22;
    operands.source1 = 24;
    operands.source2 = 25;
    let (cas_status, -) = ExecuteTileInstruction(
        TileDecode_TMA, Zeros{12} + 8, operands);
    assert cas_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;
    let cas_byte = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 1);
    assert cas_byte == Zeros{PTO_XLEN} + 0xa4;
end;

func TestTmaTotality()
begin
    TestTmaPackedDirectSelectors();
    TestTmaAllFourBitTypes();
    TestTmaPackedIndexedSelectors();
    TestTmaPackedPreflightAndRestart();
    TestTmaFaultPositionMatrix();
    TestTmaDecodedSelectorClosure();
end;
