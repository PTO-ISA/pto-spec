// PTO-TEST: {"id":"PTO-AVS-TILE-TUNPACK-FIELD-001","source":"asl/tile/layout-and-rearrangement/layout/TUNPACK.asl","requirements":["PTO-TUNPACK-CONTRACT-001","PTO-INST-TILE-TUNPACK"],"kind":"execution","summary":"TUNPACK preserves legacy U32 fields and extracts selected bytes from non-packed CUBE sources, including partial tails and selected-only definedness.","pass_condition":"Each raw-word slot yields a complete zero-filled destination word, including BF16 and odd M16 tails; undefined unselected elements and physical padding are not read, while invalid selected spans reject.","related_sources":["asl/tile/model/execution/rearrangement.asl","asl/tile/model/legality/layout-rearrangement.asl"]}
func main() => integer
begin
    ResetProfileState();
    let configured_1 = ConfigureCubeTile(1, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32);
    let configured_2 = ConfigureCubeTile(2, 128, 2, 1, TileDataType_U32,
        TileLayout_CUBE_M32);
    assert configured_1 && configured_2;
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x44332211);
    WriteTileElement(1, 1, 0, Zeros{PTO_XLEN} + 0x88776655);
    TUNPACK(2, 1, Zeros{PTO_XLEN} + 0x00000201);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x00003322;
    assert ReadTileElement(2, 1, 0) == Zeros{PTO_XLEN} + 0x00007766;
    TUNPACK(2, 1, Zeros{PTO_XLEN} + 0x00000103);
    assert ReadTileElement(2, 0, 0) == Zeros{PTO_XLEN} + 0x00000044;
    assert !TileOperandsLegal_TUNPACK(2, 1, Zeros{PTO_XLEN} + 0x00000500);
    let configured_3 = ConfigureCubeTile(3, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16);
    let configured_4 = ConfigureCubeTile(4, 128, 2, 2, TileDataType_U32,
        TileLayout_CUBE_M16);
    assert configured_3 && configured_4;
    WriteTileElement(3, 0, 0, Zeros{PTO_XLEN} + 0x44332211);
    WriteTileElement(3, 0, 1, Zeros{PTO_XLEN} + 0x88776655);
    WriteTileElement(3, 1, 0, Zeros{PTO_XLEN} + 0x44332211);
    WriteTileElement(3, 1, 1, Zeros{PTO_XLEN} + 0x88776655);
    WriteTileElement(4, 0, 0, Zeros{PTO_XLEN});
    WriteTileElement(4, 0, 1, Zeros{PTO_XLEN});
    TUNPACK(4, 3, Zeros{PTO_XLEN} + 0x00000201);
    assert ReadTileElement(4, 0, 0) == Zeros{PTO_XLEN} + 0x00003322;
    assert ReadTileElement(4, 0, 1) == Zeros{PTO_XLEN} + 0x00007766;

    // A BF16 source can be unpacked into a U16 operation-view destination.
    let configured_5 = ConfigureCubeTile(5, 128, 2, 2,
        TileDataType_BF16, TileLayout_CUBE_M32);
    let configured_6 = ConfigureCubeTile(6, 128, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M32);
    assert configured_5 && configured_6;
    WriteTileElement(5, 0, 0, Zeros{PTO_XLEN} + 0x3f80);
    WriteTileElement(5, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    WriteTileElement(5, 1, 0, Zeros{PTO_XLEN} + 0x4040);
    WriteTileElement(5, 1, 1, Zeros{PTO_XLEN} + 0x4080);
    TUNPACK(6, 5, Zeros{PTO_XLEN} + 0x00000202);
    assert ReadTileElement(6, 0, 0) == Zeros{PTO_XLEN} + 0x4000;
    assert ReadTileElement(6, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(6, 1, 0) == Zeros{PTO_XLEN} + 0x4080;

    // An incomplete U8 source word still produces four valid U8 destination
    // elements, with the selected byte followed by zero-filled bytes.
    let configured_7 = ConfigureCubeTile(7, 128, 2, 1,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_8 = ConfigureCubeTile(8, 128, 2, 4,
        TileDataType_U8, TileLayout_CUBE_M32);
    assert configured_7 && configured_8;
    WriteTileElement(7, 0, 0, Zeros{PTO_XLEN} + 0xa1);
    WriteTileElement(7, 1, 0, Zeros{PTO_XLEN} + 0xb2);
    TUNPACK(8, 7, Zeros{PTO_XLEN} + 0x00000100);
    assert ReadTileElement(8, 0, 0) == Zeros{PTO_XLEN} + 0xa1;
    assert ReadTileElement(8, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(8, 0, 3) == Zeros{PTO_XLEN};

    // U16 backed by one logical element per word may select both of its
    // bytes.  The zero-filled high half remains a second valid U16 element.
    let configured_9 = ConfigureCubeTile(9, 128, 2, 1,
        TileDataType_U16, TileLayout_CUBE_M32);
    let configured_10 = ConfigureCubeTile(10, 128, 2, 2,
        TileDataType_U16, TileLayout_CUBE_M32);
    assert configured_9 && configured_10;
    WriteTileElement(9, 0, 0, Zeros{PTO_XLEN} + 0x1234);
    WriteTileElement(9, 1, 0, Zeros{PTO_XLEN} + 0xabcd);
    TUNPACK(10, 9, Zeros{PTO_XLEN} + 0x00000200);
    assert ReadTileElement(10, 0, 0) == Zeros{PTO_XLEN} + 0x1234;
    assert ReadTileElement(10, 0, 1) == Zeros{PTO_XLEN};

    // A U16 source with six valid bytes has a two-byte final raw-word tail.
    // Extraction repeats per word without compacting that tail.
    let configured_11 = ConfigureCubeTile(11, 256, 2, 3,
        TileDataType_U16, TileLayout_CUBE_M32);
    let configured_12 = ConfigureCubeTile(12, 256, 2, 4,
        TileDataType_U16, TileLayout_CUBE_M32);
    assert configured_11 && configured_12;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 2 looplimit 3 do
            WriteTileElement(11, row, column,
                Zeros{PTO_XLEN} + 0x5100 + (row * 16) + column);
        end;
    end;
    TUNPACK(12, 11, Zeros{PTO_XLEN} + 0x00000200);
    assert ReadTileElement(12, 0, 0) == Zeros{PTO_XLEN} + 0x5100;
    assert ReadTileElement(12, 0, 1) == Zeros{PTO_XLEN};
    assert ReadTileElement(12, 0, 2) == Zeros{PTO_XLEN} + 0x5102;
    assert ReadTileElement(12, 0, 3) == Zeros{PTO_XLEN};

    // Three raw-word slots in M16 leave the final CELL's second slot as
    // padding.  Only the one valid byte in the final source word is read.
    let configured_13 = ConfigureCubeTile(13, 256, 2, 9,
        TileDataType_U8, TileLayout_CUBE_M16);
    let configured_14 = ConfigureCubeTile(14, 256, 2, 12,
        TileDataType_U8, TileLayout_CUBE_M16);
    assert configured_13 && configured_14;
    for row = 0 to 1 looplimit 2 do
        for column = 0 to 8 looplimit 9 do
            WriteTileElement(13, row, column,
                Zeros{PTO_XLEN} + 0x30 + (row * 16) + column);
        end;
    end;
    TUNPACK(14, 13, Zeros{PTO_XLEN} + 0x00000100);
    assert ReadTileElement(14, 0, 0) == Zeros{PTO_XLEN} + 0x30;
    assert ReadTileElement(14, 0, 4) == Zeros{PTO_XLEN} + 0x34;
    assert ReadTileElement(14, 0, 8) == Zeros{PTO_XLEN} + 0x38;
    assert ReadTileElement(14, 0, 9) == Zeros{PTO_XLEN};

    // Selected-only definedness: a defined first U8 element is sufficient,
    // though the second valid source element is intentionally undefined.
    let configured_15 = ConfigureCubeTile(15, 128, 2, 2,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_16 = ConfigureCubeTile(16, 128, 2, 4,
        TileDataType_U8, TileLayout_CUBE_M32);
    assert configured_15 && configured_16;
    WriteTileElement(15, 0, 0, Zeros{PTO_XLEN} + 0x71);
    WriteTileElement(15, 1, 0, Zeros{PTO_XLEN} + 0x72);
    assert !_Tiles[[15]].contents_defined;
    assert TileOperandsLegal_TUNPACK(
        16, 15, Zeros{PTO_XLEN} + 0x00000100);
    TUNPACK(16, 15, Zeros{PTO_XLEN} + 0x00000100);
    assert ReadTileElement(16, 1, 0) == Zeros{PTO_XLEN} + 0x72;

    // The same descriptor is rejected when the selected element itself is
    // undefined, or when the requested interval exceeds a partial word.
    _Tiles[[15]] = TileInfoWithLogicalElementAndDefined(
        _Tiles[[15]], TileLogicalLinearIndex(_Tiles[[15]], 0, 0),
        Zeros{PTO_XLEN} + 0x71, FALSE);
    assert !TileOperandsLegal_TUNPACK(
        16, 15, Zeros{PTO_XLEN} + 0x00000100);
    assert !TileOperandsLegal_TUNPACK(
        16, 15, Zeros{PTO_XLEN} + 0x00000101);

    let configured_17 = ConfigureCubeTile(17, 256, 2, 5,
        TileDataType_U8, TileLayout_CUBE_M32);
    let configured_18 = ConfigureCubeTile(18, 256, 2, 8,
        TileDataType_U8, TileLayout_CUBE_M32);
    assert configured_17 && configured_18;
    assert !TileOperandsLegal_TUNPACK(
        18, 17, Zeros{PTO_XLEN} + 0x00000101);
    return 0;
end;
