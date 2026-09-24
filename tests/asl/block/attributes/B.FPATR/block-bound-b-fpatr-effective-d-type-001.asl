// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-EFFECTIVE-D-TYPE-001","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-B-FPATR-MATRIX-POSTPROCESS-001"],"kind":"boundary","summary":"Effective D preserves the accumulator for mode zero and gates reductions by the final D type","pass_condition":"all assigned FP16/BF16/FP32 outputs allow reduction while S32 U32 integer and FP8 outputs reject it","related_sources":["asl/tile/model/legality/matrix-postprocess.asl","asl/block/model/dispatch/cube-destination.asl"]}

func AssertReductionOutputType(mode: integer {0..63},
                               accumulator: TileDataType,
                               expected: TileDataType,
                               reduction_legal: boolean)
begin
    let code = Zeros{6} + mode;
    assert BundleFPATRAccumulatorTypeLegal(code, accumulator);
    let effective = BundleFPATREffectiveDataType(code, accumulator);
    assert effective == expected;
    assert BundleFPATRReductionDataTypeLegal(effective) == reduction_legal;
end;

func AssertReductionSourcePreflightRejects(mode: integer {0..63},
                                           accumulator: TileDataType)
begin
    SetBundleFixedPointAttributeState(
        Zeros{6} + mode, Zeros{3}, Zeros{4}, TRUE, FALSE, FALSE, FALSE);
    assert !BundleMatrixPostProcessSourcesLegal(
        2, 1, 1, accumulator, TileLayout_CUBE_M16);
end;

func main() => integer
begin
    ResetProfileState();
    AssertReductionOutputType(0, TileDataType_FP32,
        TileDataType_FP32, TRUE);
    AssertReductionOutputType(0, TileDataType_S32,
        TileDataType_S32, FALSE);
    AssertReductionOutputType(0, TileDataType_U32,
        TileDataType_U32, FALSE);

    for mode = 1 to 5 looplimit 5 do
        AssertReductionOutputType(mode,
            if mode == 1 then TileDataType_FP32 else TileDataType_S32,
            if mode == 2 || mode == 3 then TileDataType_S8
            else TileDataType_FP16,
            mode == 1 || mode == 4 || mode == 5);
    end;
    AssertReductionOutputType(12, TileDataType_S32,
        TileDataType_S16, FALSE);
    AssertReductionOutputType(13, TileDataType_S32,
        TileDataType_S16, FALSE);
    AssertReductionOutputType(16, TileDataType_FP32,
        TileDataType_BF16, TRUE);
    AssertReductionOutputType(17, TileDataType_S32,
        TileDataType_S4X2, FALSE);
    AssertReductionOutputType(18, TileDataType_S32,
        TileDataType_S4X2, FALSE);
    AssertReductionOutputType(19, TileDataType_S32,
        TileDataType_S16, FALSE);
    AssertReductionOutputType(20, TileDataType_S32,
        TileDataType_S16, FALSE);
    AssertReductionOutputType(23, TileDataType_FP32,
        TileDataType_S8, FALSE);
    AssertReductionOutputType(24, TileDataType_FP32,
        TileDataType_S8, FALSE);
    AssertReductionOutputType(25, TileDataType_FP32,
        TileDataType_HiF8, FALSE);
    AssertReductionOutputType(26, TileDataType_FP32,
        TileDataType_E4M3, FALSE);
    AssertReductionOutputType(27, TileDataType_FP32,
        TileDataType_FP32, TRUE);
    AssertReductionOutputType(28, TileDataType_FP32,
        TileDataType_HiF8, FALSE);
    AssertReductionOutputType(32, TileDataType_FP32,
        TileDataType_FP16, TRUE);
    AssertReductionOutputType(33, TileDataType_FP32,
        TileDataType_FP16, TRUE);
    AssertReductionOutputType(34, TileDataType_FP32,
        TileDataType_BF16, TRUE);
    AssertReductionOutputType(35, TileDataType_S32,
        TileDataType_BF16, TRUE);
    AssertReductionOutputType(36, TileDataType_FP32,
        TileDataType_BF16, TRUE);
    AssertReductionOutputType(37, TileDataType_FP32,
        TileDataType_E4M3, FALSE);
    AssertReductionOutputType(38, TileDataType_FP32,
        TileDataType_FP32, TRUE);
    AssertReductionOutputType(39, TileDataType_S32,
        TileDataType_BF16, TRUE);

    AssertReductionSourcePreflightRejects(0, TileDataType_S32);
    AssertReductionSourcePreflightRejects(0, TileDataType_U32);
    AssertReductionSourcePreflightRejects(2, TileDataType_S32);
    AssertReductionSourcePreflightRejects(12, TileDataType_S32);
    AssertReductionSourcePreflightRejects(17, TileDataType_S32);
    AssertReductionSourcePreflightRejects(25, TileDataType_FP32);
    AssertReductionSourcePreflightRejects(26, TileDataType_FP32);

    var saturating = DefaultNumericExecutionControl();
    saturating.saturating = TRUE;
    let scale_one = MatrixQuantParameter(
        FP32ToFP19(Zeros{PTO_XLEN} + 0x3f800000),
        Zeros{PTO_XLEN}, 0);
    let (saturated_d, saturation_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 0x47c00000, '100001', Zeros{3},
            '0001', TileDataType_FP16, scale_one,
            Zeros{PTO_XLEN}, saturating);
    assert saturated_d == Zeros{PTO_XLEN} + 0x7bff;
    assert saturation_flags == Zeros{5} + 0x14;
    let (reduced_saturated_d, reduction_flags) =
        TileProfileMatrixReductionStepWithFlags(
            Zeros{PTO_XLEN}, saturated_d, FALSE, TileDataType_FP16);
    assert reduced_saturated_d == saturated_d;
    assert reduction_flags == Zeros{5};
    return 0;
end;
