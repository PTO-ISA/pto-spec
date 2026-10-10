// PTO-TEST: {"id":"PTO-AVS-TILE-TLEA-TYPE-WIDTHS-001","source":"asl/tile/tile-scalar-and-immediate/arithmetic/TLEA.asl","requirements":["PTO-TLEA-CONTRACT-001"],"kind":"execution","summary":"TLEA extends every accepted index type before applying every accepted byte scale.","pass_condition":"S32, U32, S64, and U64 inputs each produce the expected low-64-bit result for element widths 8, 16, 32, and 64.","related_sources":["asl/tile/model/legality/lea-operands.asl","asl/tile/model/execution/lea.asl"]}
func CheckTLEATypeWidth(
    source_type: TileDataType, source_bits: integer {32,64},
    value: Word, element_bits: Word, expected: Word)
begin
    ResetProfileState();
    ConfigureTile(0, 128, source_bits, 2, 1, 1,
        source_type, TileLayout_RowMajor);
    ConfigureTile(1, 128, 64, 1, 1, 1,
        TileLEADestinationDataType(source_type), TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, value);
    assert _Tiles[[0]].columns != _Tiles[[1]].columns;
    assert TileOperandsLegal_TLEA(1, 0, element_bits);
    TLEA(1, 0, element_bits);
    assert ReadTileElement(1, 0, 0) == expected;
end;

func main() => integer
begin
    let s32_negative_two = Zeros{PTO_XLEN} + 0xfffffffe;
    CheckTLEATypeWidth(TileDataType_S32, 32, s32_negative_two,
        Zeros{PTO_XLEN} + 8, Zeros{PTO_XLEN} + 0xfffffffffffffffe);
    CheckTLEATypeWidth(TileDataType_S32, 32, s32_negative_two,
        Zeros{PTO_XLEN} + 16, Zeros{PTO_XLEN} + 0xfffffffffffffffc);
    CheckTLEATypeWidth(TileDataType_S32, 32, s32_negative_two,
        Zeros{PTO_XLEN} + 32, Zeros{PTO_XLEN} + 0xfffffffffffffff8);
    CheckTLEATypeWidth(TileDataType_S32, 32, s32_negative_two,
        Zeros{PTO_XLEN} + 64, Zeros{PTO_XLEN} + 0xfffffffffffffff0);

    let u32_high_bit = Zeros{PTO_XLEN} + 0x80000000;
    CheckTLEATypeWidth(TileDataType_U32, 32, u32_high_bit,
        Zeros{PTO_XLEN} + 8, Zeros{PTO_XLEN} + 0x80000000);
    CheckTLEATypeWidth(TileDataType_U32, 32, u32_high_bit,
        Zeros{PTO_XLEN} + 16, Zeros{PTO_XLEN} + 0x100000000);
    CheckTLEATypeWidth(TileDataType_U32, 32, u32_high_bit,
        Zeros{PTO_XLEN} + 32, Zeros{PTO_XLEN} + 0x200000000);
    CheckTLEATypeWidth(TileDataType_U32, 32, u32_high_bit,
        Zeros{PTO_XLEN} + 64, Zeros{PTO_XLEN} + 0x400000000);

    let s64_negative_three = Zeros{PTO_XLEN} + 0xfffffffffffffffd;
    CheckTLEATypeWidth(TileDataType_S64, 64, s64_negative_three,
        Zeros{PTO_XLEN} + 8, Zeros{PTO_XLEN} + 0xfffffffffffffffd);
    CheckTLEATypeWidth(TileDataType_S64, 64, s64_negative_three,
        Zeros{PTO_XLEN} + 16, Zeros{PTO_XLEN} + 0xfffffffffffffffa);
    CheckTLEATypeWidth(TileDataType_S64, 64, s64_negative_three,
        Zeros{PTO_XLEN} + 32, Zeros{PTO_XLEN} + 0xfffffffffffffff4);
    CheckTLEATypeWidth(TileDataType_S64, 64, s64_negative_three,
        Zeros{PTO_XLEN} + 64, Zeros{PTO_XLEN} + 0xffffffffffffffe8);

    let u64_three = Zeros{PTO_XLEN} + 3;
    CheckTLEATypeWidth(TileDataType_U64, 64, u64_three,
        Zeros{PTO_XLEN} + 8, Zeros{PTO_XLEN} + 3);
    CheckTLEATypeWidth(TileDataType_U64, 64, u64_three,
        Zeros{PTO_XLEN} + 16, Zeros{PTO_XLEN} + 6);
    CheckTLEATypeWidth(TileDataType_U64, 64, u64_three,
        Zeros{PTO_XLEN} + 32, Zeros{PTO_XLEN} + 12);
    CheckTLEATypeWidth(TileDataType_U64, 64, u64_three,
        Zeros{PTO_XLEN} + 64, Zeros{PTO_XLEN} + 24);
    return 0;
end;
