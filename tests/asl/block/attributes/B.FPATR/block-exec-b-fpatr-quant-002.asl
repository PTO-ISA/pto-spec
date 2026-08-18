// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-QUANT-002","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR"],"kind":"execution","summary":"B.FPATR scalar quantization multiplies, offsets, rounds, and applies Sat clamp or wrap","pass_condition":"REQ8 and QF322B8 scalar modes produce exact S8 values for ordinary, wrapping, and saturating cases","related_sources":["asl/arch/profile/reference-quantization.asl","asl/tile/model/execution/postprocess.asl"]}
func main() => integer
begin
    let scale_two = Zeros{PTO_XLEN} + 0x40000000;
    let offset_minus_one = Zeros{PTO_XLEN} + 0x1ff;
    let req8_param = MatrixQuantParameter(
        FP32ToFP19(scale_two), offset_minus_one, 9);
    let rne_wrap = NumericExecutionControl {
        rounding_mode = NumericRound_RNE,
        saturating = FALSE
    };
    let rne_sat = NumericExecutionControl {
        rounding_mode = NumericRound_RNE,
        saturating = TRUE
    };

    let (ordinary, ordinary_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 3,
            '000011', Zeros{3}, Zeros{4}, TileDataType_S8,
            req8_param, Zeros{PTO_XLEN}, rne_wrap);
    assert ordinary == Zeros{PTO_XLEN} + 5;
    assert ordinary_flags == Zeros{5};

    let (wrapped, wrapped_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 70,
            '000011', Zeros{3}, Zeros{4}, TileDataType_S8,
            MatrixQuantParameter(FP32ToFP19(scale_two),
                Zeros{PTO_XLEN}, 9),
            Zeros{PTO_XLEN}, rne_wrap);
    assert wrapped == Zeros{PTO_XLEN} + 0xffffffffffffff8c;
    assert wrapped_flags == Zeros{5} + 0x14;

    let (clamped, clamped_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 70,
            '000011', Zeros{3}, Zeros{4}, TileDataType_S8,
            MatrixQuantParameter(FP32ToFP19(scale_two),
                Zeros{PTO_XLEN}, 9),
            Zeros{PTO_XLEN}, rne_sat);
    assert clamped == Zeros{PTO_XLEN} + 127;
    assert clamped_flags == Zeros{5} + 0x14;

    let (shifted, shifted_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 0xffffffffffffffdf,
            '001101', Zeros{3}, Zeros{4}, TileDataType_S16,
            MatrixShiftParameter(0), Zeros{PTO_XLEN}, rne_wrap);
    assert shifted == Zeros{PTO_XLEN} + 0xffffffffffffffef;
    assert shifted_flags == Zeros{5};

    let (shift_saturated, shift_saturated_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 0x7fffffff,
            '001101', Zeros{3}, Zeros{4}, TileDataType_S16,
            MatrixShiftParameter(0), Zeros{PTO_XLEN}, rne_sat);
    assert shift_saturated == Zeros{PTO_XLEN} + 0x7fff;
    assert shift_saturated_flags == Zeros{5} + 0x14;
    return 0;
end;
