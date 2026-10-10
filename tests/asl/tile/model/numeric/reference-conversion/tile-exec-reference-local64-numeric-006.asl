// PTO-TEST: {"id":"PTO-AVS-ARCH-REFERENCE-LOCAL64-NUMERIC-006","source":"asl/tile/model/numeric/reference-conversion.asl","requirements":[],"kind":"execution","summary":"the reference Tile numeric profile computes bounded binary64 modulo and unary results","pass_condition":"large exact modulo, log, reciprocal, square root, reciprocal square root, and exponential overflow and underflow return independent binary64 encodings and flags","related_sources":["asl/tile/model/execution/elementwise.asl","asl/tile/model/execution/unary.asl"]}
func main() => integer
begin
    let (remainder, remainder_flags) = ReferenceTileFloatingModulo(
        TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7fefffffffffffff,
        Zeros{PTO_XLEN} + 0x3ff0000000000000);
    assert remainder == Zeros{PTO_XLEN};
    assert remainder_flags == Zeros{5};

    let (log_two, -) = ReferenceTileUnaryFinite(
        TileUnary_LOG, TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x4000000000000000);
    let (recip_two, recip_flags) = ReferenceTileUnaryFinite(
        TileUnary_RECIP, TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x4000000000000000);
    let (sqrt_four, sqrt_flags) = ReferenceTileUnaryFinite(
        TileUnary_SQRT, TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x4010000000000000);
    let (rsqrt_four, rsqrt_flags) = ReferenceTileUnaryFinite(
        TileUnary_RSQRT, TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x4010000000000000);
    assert log_two == Zeros{PTO_XLEN} + 0x3fe62e42fefa39ef;
    assert recip_two == Zeros{PTO_XLEN} + 0x3fe0000000000000;
    assert recip_flags == Zeros{5};
    assert sqrt_four == Zeros{PTO_XLEN} + 0x4000000000000000;
    assert sqrt_flags == Zeros{5};
    assert rsqrt_four == Zeros{PTO_XLEN} + 0x3fe0000000000000;
    assert rsqrt_flags == Zeros{5};

    let (exp_one, exp_one_flags) = ReferenceTileUnaryFinite(
        TileUnary_EXP, TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x3ff0000000000000);
    assert exp_one == Zeros{PTO_XLEN} + 0x4005bf0a8b145769;
    assert exp_one_flags == Zeros{5} + 0x10;

    let (overflow, overflow_flags) = ReferenceTileUnaryFinite(
        TileUnary_EXP, TileDataType_FP64,
        Zeros{PTO_XLEN} + 0x7fefffffffffffff);
    let (underflow, underflow_flags) = ReferenceTileUnaryFinite(
        TileUnary_EXP, TileDataType_FP64,
        Zeros{PTO_XLEN} + 0xffefffffffffffff);
    assert overflow == Zeros{PTO_XLEN} + 0x7ff0000000000000;
    assert overflow_flags == Zeros{5} + 0x14;
    assert underflow == Zeros{PTO_XLEN};
    assert underflow_flags == Zeros{5} + 0x18;
    return 0;
end;
