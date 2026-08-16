// PTO-TEST: {"id":"PTO-AVS-TILE-TLSU-FAULTS-BOUND-003","source":"asl/tile/model/memory/load-store.asl","requirements":[],"kind":"boundary","summary":"TLSU faults identify exact byte positions without partial effects","pass_condition":"fault position and no-effect assertions hold","related_sources":[]}
func ConfigurePackedTlsuTile(index: TileIndex, columns: integer {1..16})
begin
    // Keep packed data and U64 index tiles on the same legal physical shape:
    // 16 rows x 16 power-of-two columns. Only the valid-column extent varies.
    ConfigureTile(index, 128, 1, 16, 1, columns, TileDataType_U4X2,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigureIndexTlsuTile(index: TileIndex, columns: integer {1..16})
begin
    ConfigureTile(index, 2048, 1, 16, 1, columns, TileDataType_U64,
        TileLayout_RowMajor, TileLocation_Any);
end;

func ConfigureByteTlsuTile(index: TileIndex, columns: integer {1..16})
begin
    ConfigureTile(index, 128, 1, 16, 1, columns, TileDataType_U8,
        TileLayout_RowMajor, TileLocation_Any);
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
        TSTORE(start_address, Zeros{PTO_XLEN} + 5, 26);
        assert _LastFault == Fault_DataPage;
        assert _MemoryEventCount == 0;
        StopMemoryEventCapture();

        let byte_count = if fault_position == 0 then 1 else 3;
        ClearFault();
        StartMemoryEventCapture(0);
        TPREFETCHAllPEs(start_address, NaturalToWord(byte_count),
            byte_count as integer {1..65535}, 1,
            (if byte_count == 1 then 1 else 4), TileDataType_U8);
        assert _LastFault == Fault_DataPage;
        assert _MemoryEventCount == 0;
        StopMemoryEventCapture();
    end;

    ConfigureByteTlsuTile(27, 3);
    ConfigureIndexTlsuTile(28, 3);
    ConfigurePackedTlsuTile(30, 3);
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

func main() => integer
begin
    ResetProfileState();
    TestTlsuFaultPositionMatrix();
    return 0;
end;
