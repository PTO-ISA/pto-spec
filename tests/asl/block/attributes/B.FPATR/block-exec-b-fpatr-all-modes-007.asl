// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-ALL-MODES-007","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"execution","summary":"Every assigned B.FPATR PreQuantMode executes its source, parameter, and destination contract","pass_condition":"all 27 assigned modes convert an exact unit value to the expected destination encoding","related_sources":["asl/arch/profile/matrix-postprocess.asl","asl/arch/profile/matrix-quantization.asl"]}
func AssertMatrixModeUnit(
    mode: bits(6), source: Word, destination_type: TileDataType,
    parameter: Word, expected: Word)
begin
    let (result, flags) = TileProfileMatrixPostProcessWithFlags(
        source, mode, Zeros{3}, Zeros{4}, destination_type,
        parameter, Zeros{PTO_XLEN}, DefaultNumericExecutionControl());
    assert result == expected;
    assert flags == Zeros{5};
end;

func main() => integer
begin
    let fp32_one = Zeros{PTO_XLEN} + 0x3f800000;
    let s32_one = Zeros{PTO_XLEN} + 1;
    let s32_two = Zeros{PTO_XLEN} + 2;
    let scale = FP32ToFP19(fp32_one);
    let p0 = MatrixQuantParameter(scale, Zeros{PTO_XLEN}, 0);
    let p5 = MatrixQuantParameter(scale, Zeros{PTO_XLEN}, 5);
    let p9 = MatrixQuantParameter(scale, Zeros{PTO_XLEN}, 9);
    let p17 = MatrixQuantParameter(scale, Zeros{PTO_XLEN}, 17);
    let shift = MatrixShiftParameter(0);

    AssertMatrixModeUnit('000000', fp32_one, TileDataType_FP32,
        Zeros{PTO_XLEN}, fp32_one);
    AssertMatrixModeUnit('000001', fp32_one, TileDataType_FP16,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x3c00);
    AssertMatrixModeUnit('000010', s32_one, TileDataType_S8,
        p9, Zeros{PTO_XLEN} + 1);
    AssertMatrixModeUnit('000011', s32_one, TileDataType_S8,
        p9, Zeros{PTO_XLEN} + 1);
    AssertMatrixModeUnit('000100', s32_one, TileDataType_FP16,
        p0, Zeros{PTO_XLEN} + 0x3c00);
    AssertMatrixModeUnit('000101', s32_one, TileDataType_FP16,
        p0, Zeros{PTO_XLEN} + 0x3c00);
    AssertMatrixModeUnit('001100', s32_two, TileDataType_S16,
        shift, Zeros{PTO_XLEN} + 1);
    AssertMatrixModeUnit('001101', s32_two, TileDataType_S16,
        shift, Zeros{PTO_XLEN} + 1);
    AssertMatrixModeUnit('010000', fp32_one, TileDataType_BF16,
        Zeros{PTO_XLEN}, Zeros{PTO_XLEN} + 0x3f80);
    AssertMatrixModeUnit('010001', s32_one, TileDataType_S4X2,
        p5, Zeros{PTO_XLEN} + 1);
    AssertMatrixModeUnit('010010', s32_one, TileDataType_S4X2,
        p5, Zeros{PTO_XLEN} + 1);
    AssertMatrixModeUnit('010011', s32_one, TileDataType_S16,
        p17, Zeros{PTO_XLEN} + 1);
    AssertMatrixModeUnit('010100', s32_one, TileDataType_S16,
        p17, Zeros{PTO_XLEN} + 1);
    AssertMatrixModeUnit('010111', fp32_one, TileDataType_S8,
        p9, Zeros{PTO_XLEN} + 1);
    AssertMatrixModeUnit('011000', fp32_one, TileDataType_S8,
        p9, Zeros{PTO_XLEN} + 1);
    AssertMatrixModeUnit('011001', fp32_one, TileDataType_HiF8,
        p0, Zeros{PTO_XLEN} + 0x08);
    AssertMatrixModeUnit('011010', fp32_one, TileDataType_E4M3,
        p0, Zeros{PTO_XLEN} + 0x38);
    AssertMatrixModeUnit('011011', fp32_one, TileDataType_FP32,
        p0, fp32_one);
    AssertMatrixModeUnit('011100', fp32_one, TileDataType_HiF8,
        p0, Zeros{PTO_XLEN} + 0x08);
    AssertMatrixModeUnit('100000', fp32_one, TileDataType_FP16,
        p0, Zeros{PTO_XLEN} + 0x3c00);
    AssertMatrixModeUnit('100001', fp32_one, TileDataType_FP16,
        p0, Zeros{PTO_XLEN} + 0x3c00);
    AssertMatrixModeUnit('100010', fp32_one, TileDataType_BF16,
        p0, Zeros{PTO_XLEN} + 0x3f80);
    AssertMatrixModeUnit('100011', s32_one, TileDataType_BF16,
        p0, Zeros{PTO_XLEN} + 0x3f80);
    AssertMatrixModeUnit('100100', fp32_one, TileDataType_BF16,
        p0, Zeros{PTO_XLEN} + 0x3f80);
    AssertMatrixModeUnit('100101', fp32_one, TileDataType_E4M3,
        p0, Zeros{PTO_XLEN} + 0x38);
    AssertMatrixModeUnit('100110', fp32_one, TileDataType_FP32,
        p0, fp32_one);
    AssertMatrixModeUnit('100111', s32_one, TileDataType_BF16,
        p0, Zeros{PTO_XLEN} + 0x3f80);
    return 0;
end;
