// PTO-TEST: {"id":"PTO-AVS-ARCH-MATRIX-QUANT-001","source":"asl/arch/profile/matrix-quantization.asl","requirements":["PTO-MATRIX-QUANT-BITEXACT-001"],"kind":"execution","summary":"Matrix quantization helpers encode parameters and representative destination values exactly","pass_condition":"FP19 scale, signed offset, integer wrap, FP16, E4M3, and HiF8 helpers return exact carriers","related_sources":["asl/arch/data-types/fp19.asl"]}
func main() => integer
begin
    let one = FP32ToFP19(Zeros{PTO_XLEN} + 0x3f800000);
    let parameter = MatrixQuantParameter(
        one, Zeros{PTO_XLEN} + 0x1ff, 9);
    assert parameter[31:13] == one;
    assert MatrixQuantOffset(parameter, 9) == -1;
    assert MatrixShiftParameter(15)[35:32] == '1111';

    let control = DefaultNumericExecutionControl();
    let (wrapped, wrapped_flags) = ReferenceMatrixIntegerEncoding(
        130.0, TileDataType_S8, control);
    assert wrapped == Zeros{PTO_XLEN} + 0xffffffffffffff82;
    assert wrapped_flags == Zeros{5} + 0x14;
    let (fp16, fp16_flags) = ReferenceMatrixFloatingEncoding(
        1.5, TileDataType_FP16, control);
    assert fp16 == Zeros{PTO_XLEN} + 0x3e00;
    assert fp16_flags == Zeros{5};
    let (e4m3, e4m3_flags) = ReferenceMatrixFloatingEncoding(
        1.5, TileDataType_E4M3, control);
    assert e4m3 == Zeros{PTO_XLEN} + 0x3c;
    assert e4m3_flags == Zeros{5};
    let (hif8, hif8_flags) = ReferenceMatrixFloatingEncoding(
        1.5, TileDataType_HiF8, control);
    assert hif8 == Zeros{PTO_XLEN} + 0x0c;
    assert hif8_flags == Zeros{5};
    let rhb = NumericExecutionControl {
        rounding_mode = NumericRound_RHB,
        saturating = FALSE
    };
    let (negative_halfway, halfway_flags) =
        ReferenceMatrixFloatingEncoding(
            -1.00390625, TileDataType_BF16, rhb);
    assert negative_halfway == Zeros{PTO_XLEN} + 0xbf80;
    assert halfway_flags == Zeros{5} + 0x10;
    return 0;
end;
