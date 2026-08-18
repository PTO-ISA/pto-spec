// PTO-TEST: {"id":"PTO-AVS-ARCH-MATRIX-POST-001","source":"asl/arch/profile/matrix-postprocess.asl","requirements":["PTO-MATRIX-POSTPROCESS-BITEXACT-001"],"kind":"execution","summary":"Matrix post-processing combines conversion, activation, reduction, and status without identity fallback","pass_condition":"representative S8 activation and maximum reduction return exact values and flags","related_sources":["asl/tile/model/execution/postprocess.asl"]}
func main() => integer
begin
    let control = DefaultNumericExecutionControl();
    let scale_one = MatrixQuantParameter(
        FP32ToFP19(Zeros{PTO_XLEN} + 0x3f800000),
        Zeros{PTO_XLEN}, 9);
    let (converted, flags) = TileProfileMatrixPostProcessWithFlags(
        Zeros{PTO_XLEN} + 0xc0000000,
        '011000', '001', Zeros{4}, TileDataType_S8,
        scale_one, Zeros{PTO_XLEN}, control);
    assert converted == Zeros{PTO_XLEN};
    assert flags == Zeros{5};

    let (maximum, reduction_flags) =
        TileProfileMatrixReductionStepWithFlags(
            Zeros{PTO_XLEN} + 3,
            Zeros{PTO_XLEN} + 7,
            FALSE,
            TileDataType_S32);
    assert maximum == Zeros{PTO_XLEN} + 7;
    assert reduction_flags == Zeros{5};
    let (minimum_abs, minimum_abs_flags) =
        TileProfileMatrixReductionStepWithFlags(
            Zeros{PTO_XLEN} + 0xffffffff80000000,
            Zeros{PTO_XLEN} + 0xffffffff80000000,
            TRUE,
            TileDataType_S32);
    assert minimum_abs == Zeros{PTO_XLEN} + 0x7fffffff;
    assert minimum_abs_flags == Zeros{5} + 4;
    return 0;
end;
