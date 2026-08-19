// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-ACT-004","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"execution","summary":"B.FPATR activation selects the multiplier before destination conversion","pass_condition":"ReLU selects zero while scalar and vector PReLU replace the negative-path quantization multiplier","related_sources":["asl/tile/model/execution/postprocess.asl"]}
func main() => integer
begin
    let control = DefaultNumericExecutionControl();
    let scale_one = MatrixQuantParameter(
        FP32ToFP19(Zeros{PTO_XLEN} + 0x3f800000),
        Zeros{PTO_XLEN}, 9);
    let alpha_half = ZeroExtend{PTO_XLEN}(
        FP32ToFP19(Zeros{PTO_XLEN} + 0x3f000000));

    let (relu, relu_flags) = TileProfileMatrixPostProcessWithFlags(
        Zeros{PTO_XLEN} + 0xc0000000,
        '011000', '001', Zeros{4}, TileDataType_S8,
        scale_one, Zeros{PTO_XLEN}, control);
    assert relu == Zeros{PTO_XLEN};
    assert relu_flags == Zeros{5};

    let (scalar, scalar_flags) = TileProfileMatrixPostProcessWithFlags(
        Zeros{PTO_XLEN} + 0xc0800000,
        '011000', '010', Zeros{4}, TileDataType_S8,
        scale_one, alpha_half, control);
    assert scalar == Zeros{PTO_XLEN} + 0xfffffffffffffffe;
    assert scalar_flags == Zeros{5};

    let (vector, vector_flags) = TileProfileMatrixPostProcessWithFlags(
        Zeros{PTO_XLEN} + 0xc0800000,
        '011000', '011', Zeros{4}, TileDataType_S8,
        scale_one, alpha_half, control);
    assert vector == Zeros{PTO_XLEN} + 0xfffffffffffffffe;
    assert vector_flags == Zeros{5};
    return 0;
end;
