// PTO-REQ-TLSU-001, PTO-REQ-MEMORY-COMPLETION-001,
// PTO-REQ-MEMORY-TSO-001: S4-T9 TLSU byte-address and packed totality tests.

func ConfigurePackedTlsuTile(index: TileIndex, columns: integer {1..16})
begin
    ConfigureTile(index, 256, 1, columns, 1, columns, TileDataType_U4X2,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigurePackedTlsuTileType(index: TileIndex,
                                columns: integer {1..16},
                                data_type: TileDataType)
begin
    assert TileDataTypeIsFourBit(data_type);
    ConfigureTile(index, 256, 1, columns, 1, columns, data_type,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigureIndexTlsuTile(index: TileIndex, columns: integer {1..16})
begin
    ConfigureTile(index, 256, 1, columns, 1, columns, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigureU32TlsuTile(index: TileIndex,
                          rows: integer {1..16},
                          columns: integer {1..16})
begin
    ConfigureTile(index, 256, rows, columns, rows, columns,
        TileDataType_U32, TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigureU8TlsuTile(index: TileIndex, columns: integer {1..16})
begin
    ConfigureTile(index, 256, 1, columns, 1, columns, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
end;

func TestTlsuRegularByteRowStride()
begin
    let load_base = Zeros{PTO_XLEN} + 0x500;
    ConfigureU32TlsuTile(29, 2, 2);
    Store(load_base, 4, Zeros{PTO_XLEN} + 0x11);
    Store(load_base + 4, 4, Zeros{PTO_XLEN} + 0x22);
    Store(load_base + 64, 4, Zeros{PTO_XLEN} + 0x33);
    Store(load_base + 68, 4, Zeros{PTO_XLEN} + 0x44);

    TLOAD(29, load_base, Zeros{PTO_XLEN} + 64);
    assert ReadTileElement(29, 0, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTileElement(29, 0, 1) == Zeros{PTO_XLEN} + 0x22;
    assert ReadTileElement(29, 1, 0) == Zeros{PTO_XLEN} + 0x33;
    assert ReadTileElement(29, 1, 1) == Zeros{PTO_XLEN} + 0x44;

    let store_base = Zeros{PTO_XLEN} + 0x600;
    ConfigureU32TlsuTile(30, 2, 2);
    WriteTileElement(30, 0, 0, Zeros{PTO_XLEN} + 0x55);
    WriteTileElement(30, 0, 1, Zeros{PTO_XLEN} + 0x66);
    WriteTileElement(30, 1, 0, Zeros{PTO_XLEN} + 0x77);
    WriteTileElement(30, 1, 1, Zeros{PTO_XLEN} + 0x88);

    TSTORE(store_base, Zeros{PTO_XLEN} + 64, 30);
    let stored00 = LoadUnsigned(store_base, 4);
    let stored01 = LoadUnsigned(store_base + 4, 4);
    let stored10 = LoadUnsigned(store_base + 64, 4);
    let stored11 = LoadUnsigned(store_base + 68, 4);
    assert stored00 == Zeros{PTO_XLEN} + 0x55;
    assert stored01 == Zeros{PTO_XLEN} + 0x66;
    assert stored10 == Zeros{PTO_XLEN} + 0x77;
    assert stored11 == Zeros{PTO_XLEN} + 0x88;
end;

func TestTlsuIndexedByteDisplacements()
begin
    let gather_base = Zeros{PTO_XLEN} + 0x700;
    ConfigureU32TlsuTile(31, 1, 2);
    ConfigureU32TlsuTile(32, 1, 2);
    ConfigureIndexTlsuTile(33, 2);
    WriteTileElement(33, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(33, 0, 1, Zeros{PTO_XLEN} + 12);
    Store(gather_base, 4, Zeros{PTO_XLEN} + 0x1234);
    Store(gather_base + 12, 4, Zeros{PTO_XLEN} + 0x5678);

    MGATHER(31, gather_base, 33);
    assert ReadTileElement(31, 0, 0) == Zeros{PTO_XLEN} + 0x1234;
    assert ReadTileElement(31, 0, 1) == Zeros{PTO_XLEN} + 0x5678;

    let scatter_base = Zeros{PTO_XLEN} + 0x780;
    WriteTileElement(32, 0, 0, Zeros{PTO_XLEN} + 0x9abc);
    WriteTileElement(32, 0, 1, Zeros{PTO_XLEN} + 0xdef0);
    MSCATTER(scatter_base, 32, 33);
    let scattered0 = LoadUnsigned(scatter_base, 4);
    let scattered1 = LoadUnsigned(scatter_base + 12, 4);
    assert scattered0 == Zeros{PTO_XLEN} + 0x9abc;
    assert scattered1 == Zeros{PTO_XLEN} + 0xdef0;
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

    // The one-level PTO model receives the peer fragment as the resolved
    // source tile; peer_tid remains an explicit legality/control operand.
    GMOV(0, 1, Zeros{PTO_XLEN} + 1);
    assert ReadTileElement(0, 0, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTileElement(0, 0, 1) == Zeros{PTO_XLEN} + 2;
    assert ReadTileElement(0, 0, 2) == Zeros{PTO_XLEN} + 3;

    StartMemoryEventCapture(0);
    TPREFETCH(Zeros{PTO_XLEN} + 0x120, 2);
    assert _MemoryEventCount == 2;
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
        TLOAD(tile, address);
        assert ReadTileElement(tile, 0, 0) == Zeros{PTO_XLEN} + 0xf;
        assert ReadTileElement(tile, 0, 1) == Zeros{PTO_XLEN} + 0xa;

        WriteTileElement(tile, 0, 0, Zeros{PTO_XLEN} + tile_offset + 1);
        WriteTileElement(tile, 0, 1, Zeros{PTO_XLEN} + tile_offset + 5);
        TSTORE(address, tile);
        let stored = LoadUnsigned(address, 1);
        assert stored == Zeros{PTO_XLEN} +
            (tile_offset + 5) * 16 + tile_offset + 1;

        assert !TileOperandsLegal_MGATHER(tile, address, 38);
        assert !TileOperandsLegal_MSCATTER(address, tile, 38);
    end;
end;

func TestTlsuPackedIndexedTransferRejected()
begin
    ConfigurePackedTlsuTile(3, 3);
    ConfigureIndexTlsuTile(4, 3);
    ConfigurePackedTlsuTile(5, 3);
    ConfigurePackedTlsuTile(6, 3);
    assert !TileOperandsLegal_MGATHER(3, Zeros{PTO_XLEN}, 4);
    assert !TileOperandsLegal_MSCATTER(Zeros{PTO_XLEN}, 5, 4);
    assert !TileOperandsLegal_MGATHER_MASK(
        3, Zeros{PTO_XLEN}, 4, 6, TilePad_Null);
    assert !TileOperandsLegal_MSCATTER_MASK(
        Zeros{PTO_XLEN}, 5, 4, 6);
    assert !TileOperandsLegal_MGATHER_CAS(
        3, Zeros{PTO_XLEN}, 4, 5, 6);
end;

func TestTlsuPackedPreflightAndRestart()
begin
    StopMemoryEventCapture();
    ConfigurePackedTlsuTile(13, 5);
    ConfigureIndexTlsuTile(14, 3);
    ConfigureU8TlsuTile(15, 3);
    ConfigurePackedTlsuTile(16, 3);
    ConfigurePackedTlsuTile(17, 3);

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

end;

func TestTlsuFaultPositionMatrix()
begin
    let base_address = Zeros{PTO_XLEN} + 0x380;

    ConfigurePackedTlsuTile(26, 5);
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

    ConfigureU8TlsuTile(27, 3);
    ConfigureIndexTlsuTile(28, 3);
    ConfigureU8TlsuTile(30, 3);
    for lane = 0 to 2 do
        WriteTileElement(27, 0, lane, Zeros{PTO_XLEN} + 9);
        WriteTileElement(30, 0, lane, Zeros{PTO_XLEN} + 2);
    end;

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
        StartMemoryEventCapture(2);
        MGATHER(27, base_address, 28);
        assert _LastFault == Fault_DataPage;
        assert _MemoryEventCount == 0;
        StopMemoryEventCapture();

        ClearFault();
        StartMemoryEventCapture(2);
        MSCATTER(base_address, 27, 28);
        assert _LastFault == Fault_DataPage;
        assert _MemoryEventCount == 0;
        StopMemoryEventCapture();
    end;
end;

func TestTlsuDecodedSelectorClosure()
begin
    StopMemoryEventCapture();
    ConfigureU8TlsuTile(20, 1);
    ConfigureU8TlsuTile(21, 1);
    ConfigureIndexTlsuTile(22, 1);
    ConfigureU8TlsuTile(23, 1);
    ConfigureU8TlsuTile(24, 1);
    ConfigureU8TlsuTile(25, 1);
    ConfigureU8TlsuTile(26, 1);
    ConfigureU8TlsuTile(27, 1);
    ConfigureU8TlsuTile(28, 1);
    WriteTileElement(20, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(21, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(22, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(23, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(24, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(25, 0, 0, Zeros{PTO_XLEN} + 4);
    WriteTileElement(26, 0, 0, Zeros{PTO_XLEN} + 1);
    WriteTileElement(27, 0, 0, Zeros{PTO_XLEN} + 3);
    WriteTileElement(28, 0, 0, Zeros{PTO_XLEN} + 5);

    Store(Zeros{PTO_XLEN} + 0x300, 1, Zeros{PTO_XLEN} + 0xa2);
    var operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.address = Zeros{PTO_XLEN} + 0x300;
    let (load_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12}, operands);
    assert load_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 0xa2;

    operands = DefaultTileInstructionOperands();
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 21;
    let (store_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 1, operands);
    assert store_status == TileExecution_Executed;
    let stored_byte = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 1);
    assert stored_byte == Zeros{PTO_XLEN} + 3;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.source0 = 21;
    let (move_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 2, operands);
    assert move_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;

    operands = DefaultTileInstructionOperands();
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.byte_count = 1;
    let (prefetch_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 3, operands);
    assert prefetch_status == TileExecution_Executed;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 22;
    let (gather_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 4, operands);
    assert gather_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;

    operands = DefaultTileInstructionOperands();
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 21;
    operands.source1 = 22;
    let (scatter_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 5, operands);
    assert scatter_status == TileExecution_Executed;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 22;
    operands.source1 = 26;
    let (gather_mask_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 6, operands);
    assert gather_mask_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;

    operands = DefaultTileInstructionOperands();
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 21;
    operands.source1 = 22;
    operands.source2 = 26;
    let (scatter_mask_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 7, operands);
    assert scatter_mask_status == TileExecution_Executed;
    let scatter_masked_byte = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 1);
    assert scatter_masked_byte == Zeros{PTO_XLEN} + 3;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.source0 = 21;
    operands.scalar0 = Zeros{PTO_XLEN} + 2;
    let (gmov_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 13, operands);
    assert gmov_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;

    operands = DefaultTileInstructionOperands();
    operands.destination0 = 20;
    operands.address = Zeros{PTO_XLEN} + 0x300;
    operands.source0 = 22;
    operands.source1 = 27;
    operands.source2 = 28;
    let (gather_cas_status, -) = ExecuteTileInstruction(
        TileDecode_TLSU, Zeros{12} + 8, operands);
    assert gather_cas_status == TileExecution_Executed;
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 3;
    let gather_cas_byte = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 1);
    assert gather_cas_byte == Zeros{PTO_XLEN} + 5;

    // Keep direct mnemonic evidence in addition to decoded selector closure.
    Store(Zeros{PTO_XLEN} + 0x300, 1, Zeros{PTO_XLEN} + 3);
    MGATHER_CAS(20, Zeros{PTO_XLEN} + 0x300, 22, 27, 28);
    assert _LastFault == Fault_None;
    let direct_gather_cas_byte = LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 1);
    assert direct_gather_cas_byte == Zeros{PTO_XLEN} + 5;

    MGATHER_MASK(20, Zeros{PTO_XLEN} + 0x300, 22, 26,
        TilePad_Null);
    assert ReadTileElement(20, 0, 0) == Zeros{PTO_XLEN} + 5;
    MSCATTER_MASK(Zeros{PTO_XLEN} + 0x300, 21, 22, 26);
    let direct_scatter_masked_byte =
        LoadUnsigned(Zeros{PTO_XLEN} + 0x300, 1);
    assert direct_scatter_masked_byte == Zeros{PTO_XLEN} + 3;
end;

func TestTlsuTotality()
begin
    TestTlsuRegularByteRowStride();
    TestTlsuIndexedByteDisplacements();
    TestTlsuPackedDirectSelectors();
    TestTlsuAllFourBitTypes();
    TestTlsuPackedIndexedTransferRejected();
    TestTlsuPackedPreflightAndRestart();
    TestTlsuFaultPositionMatrix();
    TestTlsuDecodedSelectorClosure();
end;
