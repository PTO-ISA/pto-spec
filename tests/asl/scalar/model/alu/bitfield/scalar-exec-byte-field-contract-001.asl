// PTO-TEST: {"id":"PTO-AVS-SCALAR-BYTE-FIELD-CONTRACT-001","source":"asl/scalar/model/alu/bitfield.asl","requirements":["PTO-HL-BFI-DECISION-BINDING-001"],"kind":"execution","summary":"The scalar byte-field helper implements full and wrapping byte replacement.","pass_condition":"Four-byte duplication, two-byte wrap, and eight-byte replacement produce the selected XLEN words.","related_sources":["asl/scalar/alu/HL.BFI.asl"]}
func main() => integer
begin
    assert InsertByteField(
        Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 2,
        4,
        4) == Zeros{PTO_XLEN} + 0x0000000200000002;
    assert InsertByteField(
        Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x2211,
        7,
        2) == Zeros{PTO_XLEN} + 0x1100000000000022;
    assert InsertByteField(
        Ones{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x0123456789abcdef,
        0,
        8) == Zeros{PTO_XLEN} + 0x0123456789abcdef;
    return 0;
end;
