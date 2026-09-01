// PTO-TEST: {"id":"PTO-AVS-TILE-TLOAD-16X16-STRIDE-003","source":"asl/tile/memory-and-data-movement/regular/TLOAD.asl","requirements":["PTO-INST-TILE-TLOAD","PTO-TLOAD-MEMORY-001"],"kind":"boundary","summary":"TLOAD preserves every row of a 16 by 16 S32 rectangle across the row-ten address boundary","pass_condition":"all 256 independently initialized values load through a 64-byte row stride without row aliasing or wrap","related_sources":["asl/tile/model/memory/load-store.asl","asl/tile/model/memory/stride.asl"]}
func main() => integer
begin
    ResetProfileState();
    let base_address = Zeros{PTO_XLEN} + 0x400;
    ConfigureTile(4, 1024, 16, 16, 16, 16, TileDataType_S32,
        TileLayout_RowMajor, TileLocation_Any);
    for row = 0 to 15 do
        for column = 0 to 15 do
            let element = row * 16 + column;
            Store(
                base_address + NaturalToWord(
                    (element * 4) as integer {0..262144}),
                4,
                Zeros{PTO_XLEN} + element + 1);
        end;
    end;

    TLOAD(4, base_address, Zeros{PTO_XLEN} + 64);

    assert _LastFault == Fault_None;
    for row = 0 to 15 do
        for column = 0 to 15 do
            let element = row * 16 + column;
            assert ReadTileElement(4, row, column) ==
                Zeros{PTO_XLEN} + element + 1;
        end;
    end;
    return 0;
end;
