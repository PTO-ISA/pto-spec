// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-FORMATS-003","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"execution","summary":"B.FPATR cast and scaled floating modes publish exact destination encodings","pass_condition":"FP16, BF16, E4M3, HiF8, and scaled FP32 modes encode representative exact values","related_sources":["asl/arch/profile/reference-quantization.asl","asl/arch/features/mx-formats.asl"]}
func main() => integer
begin
    let control = DefaultNumericExecutionControl();
    let one_point_five = Zeros{PTO_XLEN} + 0x3fc00000;
    let scale_one = MatrixQuantParameter(
        FP32ToFP19(Zeros{PTO_XLEN} + 0x3f800000),
        Zeros{PTO_XLEN}, 0);

    let (fp16, fp16_flags) = TileProfileMatrixPostProcessWithFlags(
        one_point_five, '000001', Zeros{3}, Zeros{4},
        TileDataType_FP16, Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, control);
    assert fp16 == Zeros{PTO_XLEN} + 0x3e00;
    assert fp16_flags == Zeros{5};

    let (bf16, bf16_flags) = TileProfileMatrixPostProcessWithFlags(
        one_point_five, '010000', Zeros{3}, Zeros{4},
        TileDataType_BF16, Zeros{PTO_XLEN}, Zeros{PTO_XLEN}, control);
    assert bf16 == Zeros{PTO_XLEN} + 0x3fc0;
    assert bf16_flags == Zeros{5};

    let (e4m3, e4m3_flags) = TileProfileMatrixPostProcessWithFlags(
        one_point_five, '011010', Zeros{3}, Zeros{4},
        TileDataType_E4M3, scale_one, Zeros{PTO_XLEN}, control);
    assert e4m3 == Zeros{PTO_XLEN} + 0x3c;
    assert e4m3_flags == Zeros{5};

    let (hif8, hif8_flags) = TileProfileMatrixPostProcessWithFlags(
        one_point_five, '011001', Zeros{3}, Zeros{4},
        TileDataType_HiF8, scale_one, Zeros{PTO_XLEN}, control);
    assert hif8 == Zeros{PTO_XLEN} + 0x0c;
    assert hif8_flags == Zeros{5};

    let half_scale = MatrixQuantParameter(
        FP32ToFP19(Zeros{PTO_XLEN} + 0x3f000000),
        Zeros{PTO_XLEN}, 0);
    let (fp32, fp32_flags) = TileProfileMatrixPostProcessWithFlags(
        one_point_five, '011011', Zeros{3}, Zeros{4},
        TileDataType_FP32, half_scale, Zeros{PTO_XLEN}, control);
    assert fp32 == Zeros{PTO_XLEN} + 0x3f400000;
    assert fp32_flags == Zeros{5};
    return 0;
end;
