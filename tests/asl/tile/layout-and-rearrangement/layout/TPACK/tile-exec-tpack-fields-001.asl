// PTO-TEST: {"id":"PTO-AVS-TILE-TPACK-FIELDS-001","source":"asl/tile/layout-and-rearrangement/layout/TPACK.asl","requirements":["PTO-TPACK-CONTRACT-001","PTO-INST-TILE-TPACK"],"kind":"execution","summary":"TPACK preserves legacy U32 fields and assembles selected bytes from staged, mixed-width, partially valid, and undefined-tail Local CUBE sources.","pass_condition":"Legacy encodings remain bit-exact; the staged four-U8 witness, equal raw-word pairing, M16 odd-word tail, selected-only definedness, and rejection of an out-of-span byte all match the frozen contract.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/layout-rearrangement.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured_1 = ConfigureCubeTile(1, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32);
    let configured_2 = ConfigureCubeTile(2, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32);
    let configured_3 = ConfigureCubeTile(3, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32);
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(1, row, 0, Zeros{PTO_XLEN} + 0x00001234);
        WriteTileElement(2, row, 0, Zeros{PTO_XLEN} + 0x00abcdef);
    end;
    TPACK(3, 1, 2, Zeros{PTO_XLEN} + 0x00000202);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0xcdef1234;
    assert ReadTileElement(3, 1, 0) == Zeros{PTO_XLEN} + 0xcdef1234;
    TPACK(3, 1, 2, Zeros{PTO_XLEN} + 0x00000301);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0xabcdef34;
    TPACK(3, 1, 2, Zeros{PTO_XLEN} + 0x00000103);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0xef001234;
    TPACK(3, 1, 2, Zeros{PTO_XLEN} + 0x00000101);
    assert ReadTileElement(3, 0, 0) == Zeros{PTO_XLEN} + 0x0000ef34;
    let configured_4 = ConfigureCubeTile(4, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16);
    let configured_5 = ConfigureCubeTile(5, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16);
    let configured_6 = ConfigureCubeTile(6, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 1 looplimit 2 do
            WriteTileElement(4, row, column, Zeros{PTO_XLEN} + 0x00001234);
            WriteTileElement(5, row, column, Zeros{PTO_XLEN} + 0x00abcdef);
        end;
    end;
    TPACK(6, 4, 5, Zeros{PTO_XLEN} + 0x00000202);
    assert ReadTileElement(6, 0, 0) == Zeros{PTO_XLEN} + 0xcdef1234;
    assert ReadTileElement(6, 0, 1) == Zeros{PTO_XLEN} + 0xcdef1234;
    assert !TileOperandsLegal_TPACK(6, 4, 5, Zeros{PTO_XLEN} + 0x00000100);

    // One-byte U8 sources are legal when only one byte is selected.  Each
    // complete destination word is valid; its unused bytes are zero-filled.
    let configured_7 = ConfigureCubeTile(7, 128, 2, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_8 = ConfigureCubeTile(8, 128, 2, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_9 = ConfigureCubeTile(9, 128, 2, 4,
        TileDataType_U8, TileLayout_CUBE_M32);
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(7, row, 0, Zeros{PTO_XLEN} + 0x10 + row);
        WriteTileElement(8, row, 0, Zeros{PTO_XLEN} + 0x20 + row);
    end;
    TPACK(9, 7, 8, Zeros{PTO_XLEN} + 0x00000101);
    assert ReadTileElement(9, 0, 0) == Zeros{PTO_XLEN} + 0x10;
    assert ReadTileElement(9, 0, 1) == Zeros{PTO_XLEN} + 0x20;
    assert ReadTileElement(9, 0, 2) == Zeros{PTO_XLEN};
    assert ReadTileElement(9, 0, 3) == Zeros{PTO_XLEN};

    // Four one-byte columns are assembled through the required three-stage
    // two-source sequence.  Intermediate valid zero bytes are not mistaken
    // for required source input bytes.
    let configured_10 = ConfigureCubeTile(10, 128, 32, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_11 = ConfigureCubeTile(11, 128, 32, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_12 = ConfigureCubeTile(12, 128, 32, 4,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_13 = ConfigureCubeTile(13, 128, 32, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_14 = ConfigureCubeTile(14, 128, 32, 4,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_15 = ConfigureCubeTile(15, 128, 32, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_16 = ConfigureCubeTile(16, 128, 32, 4,
        TileDataType_U8, TileLayout_CUBE_M32);
    for row = 0 to 31 looplimit 32 do
        WriteTileElement(10, row, 0, Zeros{PTO_XLEN} + 0xa0 + row);
        WriteTileElement(11, row, 0, Zeros{PTO_XLEN} + 0xb0 + row);
        WriteTileElement(13, row, 0, Zeros{PTO_XLEN} + 0xc0 + row);
        WriteTileElement(15, row, 0, Zeros{PTO_XLEN} + 0xd0 + row);
    end;
    TPACK(12, 10, 11, Zeros{PTO_XLEN} + 0x00000101);
    TPACK(14, 12, 13, Zeros{PTO_XLEN} + 0x00000102);
    TPACK(16, 14, 15, Zeros{PTO_XLEN} + 0x00000103);
    assert ReadTileElement(16, 0, 0) == Zeros{PTO_XLEN} + 0xa0;
    assert ReadTileElement(16, 0, 1) == Zeros{PTO_XLEN} + 0xb0;
    assert ReadTileElement(16, 0, 2) == Zeros{PTO_XLEN} + 0xc0;
    assert ReadTileElement(16, 0, 3) == Zeros{PTO_XLEN} + 0xd0;
    assert ReadTileElement(16, 31, 0) == Zeros{PTO_XLEN} + 0xbf;
    assert ReadTileElement(16, 31, 1) == Zeros{PTO_XLEN} + 0xcf;
    assert ReadTileElement(16, 31, 2) == Zeros{PTO_XLEN} + 0xdf;
    assert ReadTileElement(16, 31, 3) == Zeros{PTO_XLEN} + 0xef;

    // Mixed non-packed backing types pair at the same raw-word slot.  The
    // unselected logical bytes of each source are never required defined.
    let configured_17 = ConfigureCubeTile(17, 128, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M32);
    let configured_18 = ConfigureCubeTile(18, 128, 2, 1,
        TileDataType_U32, TileLayout_CUBE_M32);
    let configured_19 = ConfigureCubeTile(19, 128, 2, 4,
        TileDataType_U8, TileLayout_CUBE_M32);
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(17, row, 0, Zeros{PTO_XLEN} + 0x2211);
        WriteTileElement(17, row, 1, Zeros{PTO_XLEN} + 0x4433);
        WriteTileElement(18, row, 0, Zeros{PTO_XLEN} + 0xaabbccdd);
    end;
    TPACK(19, 17, 18, Zeros{PTO_XLEN} + 0x00000102);
    assert ReadTileElement(19, 0, 0) == Zeros{PTO_XLEN} + 0x11;
    assert ReadTileElement(19, 0, 1) == Zeros{PTO_XLEN} + 0x22;
    assert ReadTileElement(19, 0, 2) == Zeros{PTO_XLEN} + 0xdd;
    assert ReadTileElement(19, 0, 3) == Zeros{PTO_XLEN};

    // M16 has two raw word slots per CELL row.  Three participating slots
    // leave the final CELL's second slot as padding, and a one-byte tail is
    // legal when each selected prefix fits that word's logical byte span.
    let configured_20 = ConfigureCubeTile(20, 256, 2, 5,
        TileDataType_U16, TileLayout_CUBE_M16);
    let configured_21 = ConfigureCubeTile(21, 256, 2, 9,
        TileDataType_U8, TileLayout_CUBE_M16);
    let configured_22 = ConfigureCubeTile(22, 256, 2, 12,
        TileDataType_U8, TileLayout_CUBE_M16);
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 4 looplimit 5 do
            WriteTileElement(20, row, column,
                Zeros{PTO_XLEN} + 0x100 + (row * 16) + column);
        end;
        for column = 0 to 8 looplimit 9 do
            WriteTileElement(21, row, column,
                Zeros{PTO_XLEN} + 0x40 + (row * 16) + column);
        end;
    end;
    TPACK(22, 20, 21, Zeros{PTO_XLEN} + 0x00000101);
    assert ReadTileElement(22, 0, 0) == Zeros{PTO_XLEN} + 0x00;
    assert ReadTileElement(22, 0, 1) == Zeros{PTO_XLEN} + 0x40;
    assert ReadTileElement(22, 0, 8) == Zeros{PTO_XLEN} + 0x04;
    assert ReadTileElement(22, 0, 9) == Zeros{PTO_XLEN} + 0x48;
    assert !TileOperandsLegal_TPACK(
        22, 20, 21, Zeros{PTO_XLEN} + 0x00000202);

    // Selected-only definedness: both sources have an undefined second valid
    // byte, but their defined first bytes suffice for a 1+1 pack.
    let configured_23 = ConfigureCubeTile(23, 128, 2, 2,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_24 = ConfigureCubeTile(24, 128, 2, 2,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_25 = ConfigureCubeTile(25, 128, 2, 4,
        TileDataType_U8, TileLayout_CUBE_M32);
    for row = 0 to 1 looplimit 2 do
        WriteTileElement(23, row, 0, Zeros{PTO_XLEN} + 0x51 + row);
        WriteTileElement(24, row, 0, Zeros{PTO_XLEN} + 0x61 + row);
    end;
    assert !_Tiles[[23]].contents_defined && !_Tiles[[24]].contents_defined;
    assert TileOperandsLegal_TPACK(
        25, 23, 24, Zeros{PTO_XLEN} + 0x00000101);
    TPACK(25, 23, 24, Zeros{PTO_XLEN} + 0x00000101);
    assert ReadTileElement(25, 1, 0) == Zeros{PTO_XLEN} + 0x52;
    assert ReadTileElement(25, 1, 1) == Zeros{PTO_XLEN} + 0x62;
    assert ReadTileElement(25, 1, 2) == Zeros{PTO_XLEN};

    return 0;
end;
