// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-WIDTH-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"execution","summary":"TFMA integer arithmetic wraps at the selected element width.","pass_condition":"Signed and unsigned eight-bit fused operations return only their modulo-width carrier bits.","related_sources":["asl/tile/model/execution/fused-multiply-add.asl"]}
func main() => integer
begin
    let (signed_result, signed_flags) = InstructionContractValue_TFMA(
        TileDataType_S8,
        Zeros{PTO_XLEN} + 0xff,
        Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 3);
    assert signed_result == Zeros{PTO_XLEN} + 1;
    assert signed_flags == Zeros{5};

    let (unsigned_result, unsigned_flags) = InstructionContractValue_TFMA(
        TileDataType_U8,
        Zeros{PTO_XLEN} + 0x80,
        Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 1);
    assert unsigned_result == Zeros{PTO_XLEN} + 1;
    assert unsigned_flags == Zeros{5};
    return 0;
end;
