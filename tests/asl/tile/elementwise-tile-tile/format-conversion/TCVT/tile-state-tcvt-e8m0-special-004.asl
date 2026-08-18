// PTO-TEST: {"id":"PTO-AVS-TILE-TCVT-E8M0-SPECIAL-004","source":"asl/tile/elementwise-tile-tile/format-conversion/TCVT.asl","requirements":["PTO-TCVT-CONTRACT-001"],"kind":"state-transition","summary":"E8M0 conversion defines invalid inputs and finite range endpoints under Sat.","pass_condition":"Zero, negative, NaN, infinity, exact endpoints, and finite underflow or overflow return the selected carrier and exact NV, UF, OF, and NX flags.","related_sources":["asl/tile/model/numeric/formats.asl","asl/arch/data-types/formats/e8m0.asl"]}
func CheckE8M0Result(value: Word, source_type: TileDataType,
                      saturating: boolean, expected: Word,
                      expected_flags: bits(5))
begin
    let control = NumericExecutionControl {
        rounding_mode = NumericRound_RNE,
        saturating = saturating
    };
    let (result, flags) = TileProfileConvert(
        value, source_type, TileDataType_E8M0, control);
    assert result == expected;
    assert flags == expected_flags;
end;

func main() => integer
begin
    CheckE8M0Result(Zeros{PTO_XLEN}, TileDataType_BF16, FALSE,
        Zeros{PTO_XLEN} + 0xff, Zeros{5} + 0x01);
    CheckE8M0Result(Zeros{PTO_XLEN} + 0xbf80, TileDataType_BF16, TRUE,
        Zeros{PTO_XLEN} + 0xff, Zeros{5} + 0x01);
    CheckE8M0Result(Zeros{PTO_XLEN} + 0x7fc0, TileDataType_BF16, FALSE,
        Zeros{PTO_XLEN} + 0xff, Zeros{5} + 0x01);
    CheckE8M0Result(Zeros{PTO_XLEN} + 0x7f80, TileDataType_BF16, FALSE,
        Zeros{PTO_XLEN} + 0xff, Zeros{5} + 0x14);
    CheckE8M0Result(Zeros{PTO_XLEN} + 0x7f80, TileDataType_BF16, TRUE,
        Zeros{PTO_XLEN} + 0xfe, Zeros{5} + 0x14);

    CheckE8M0Result(Zeros{PTO_XLEN} + 0x00400000,
        TileDataType_FP32, FALSE, Zeros{PTO_XLEN}, Zeros{5});
    CheckE8M0Result(Zeros{PTO_XLEN} + 0x00200000,
        TileDataType_FP32, FALSE, Zeros{PTO_XLEN} + 0xff,
        Zeros{5} + 0x18);
    CheckE8M0Result(Zeros{PTO_XLEN} + 0x00200000,
        TileDataType_FP32, TRUE, Zeros{PTO_XLEN}, Zeros{5} + 0x18);
    CheckE8M0Result(Zeros{PTO_XLEN} + 0x7f000000,
        TileDataType_FP32, FALSE, Zeros{PTO_XLEN} + 0xfe, Zeros{5});
    CheckE8M0Result(Zeros{PTO_XLEN} + 0x7f7fffff,
        TileDataType_FP32, FALSE, Zeros{PTO_XLEN} + 0xff,
        Zeros{5} + 0x14);
    CheckE8M0Result(Zeros{PTO_XLEN} + 0x7f7fffff,
        TileDataType_FP32, TRUE, Zeros{PTO_XLEN} + 0xfe,
        Zeros{5} + 0x14);
    return 0;
end;
