// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-ROUNDING-008","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR","PTO-MATRIX-QUANT-BITEXACT-001"],"kind":"execution","summary":"B.FPATR saturates assigned signed intermediates before offset and destination encoding","pass_condition":"REQ4 REQ8 DEQS16 and shift modes expose exact intermediate saturation results under non-saturating final control","related_sources":["asl/arch/profile/matrix-quantization.asl","asl/arch/profile/matrix-postprocess.asl"]}
func main() => integer
begin
    let scale_one = FP32ToFP19(Zeros{PTO_XLEN} + 0x3f800000);
    let offset_one = Zeros{PTO_XLEN} + 1;
    let control = NumericExecutionControl {
        rounding_mode = NumericRound_RNE,
        saturating = FALSE
    };

    let (req8, req8_flags) = TileProfileMatrixPostProcessWithFlags(
        Zeros{PTO_XLEN} + 300, '000011', Zeros{3}, Zeros{4},
        TileDataType_S8,
        MatrixQuantParameter(scale_one, offset_one, 9),
        Zeros{PTO_XLEN}, control);
    assert req8 == Zeros{PTO_XLEN};
    assert req8_flags == Zeros{5} + 0x14;

    let (req4, req4_flags) = TileProfileMatrixPostProcessWithFlags(
        Zeros{PTO_XLEN} + 20, '010001', Zeros{3}, Zeros{4},
        TileDataType_S4X2,
        MatrixQuantParameter(scale_one, offset_one, 5),
        Zeros{PTO_XLEN}, control);
    assert req4 == Zeros{PTO_XLEN};
    assert req4_flags == Zeros{5} + 0x14;

    let (deqs16, deqs16_flags) = TileProfileMatrixPostProcessWithFlags(
        Zeros{PTO_XLEN} + 70000, '010011', Zeros{3}, Zeros{4},
        TileDataType_S16,
        MatrixQuantParameter(scale_one, offset_one, 17),
        Zeros{PTO_XLEN}, control);
    assert deqs16 == Zeros{PTO_XLEN};
    assert deqs16_flags == Zeros{5} + 0x14;

    let (shifted, shifted_flags) = TileProfileMatrixPostProcessWithFlags(
        Zeros{PTO_XLEN} + 0x7fffffff, '001101', Zeros{3}, Zeros{4},
        TileDataType_S16, MatrixShiftParameter(0),
        Zeros{PTO_XLEN}, control);
    assert shifted == Zeros{PTO_XLEN} + 0x7fff;
    assert shifted_flags == Zeros{5} + 0x14;
    return 0;
end;
