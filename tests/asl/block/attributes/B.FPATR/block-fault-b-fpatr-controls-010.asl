// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-FPATR-CONTROLS-010","source":"asl/block/attributes/B.FPATR.asl","requirements":["PTO-INST-BLOCK-B-FPATR","PTO-MATRIX-QUANT-BITEXACT-001"],"kind":"fault","summary":"B.FPATR rejects controls that conflict with fixed rounding or saturation","pass_condition":"fixed FP16 BF16 E4M3 HiF8 and shift modes reject inapplicable fields while programmable integer modes retain them","related_sources":["asl/arch/profile/matrix-postprocess.asl","asl/block/model/dispatch/tile-schema.asl"]}
func main() => integer
begin
    assert BundleFPATRModeFixedRounding('000001');
    assert BundleFPATRModeFixedRounding('010000');
    assert BundleFPATRModeFixedRounding('011001');
    assert BundleFPATRModeFixedRounding('011010');
    assert BundleFPATRModeFixedRounding('100000');
    assert BundleFPATRModeFixedRounding('100001');
    assert BundleFPATRModeFixedRounding('100010');
    assert BundleFPATRModeFixedRounding('100100');
    assert BundleFPATRModeFixedRounding('100101');
    assert !BundleFPATRModeFixedRounding('000011');
    assert !BundleFPATRModeFixedRounding('010011');
    assert !BundleFPATRModeFixedRounding('100011');

    assert BundleFPATRModeFinalSatProgrammable('000011');
    assert BundleFPATRModeFinalSatProgrammable('010001');
    assert BundleFPATRModeFinalSatProgrammable('010011');
    assert BundleFPATRModeFinalSatProgrammable('011001');
    assert !BundleFPATRModeFinalSatProgrammable('001100');
    assert !BundleFPATRModeFinalSatProgrammable('001101');

    assert BundleFPATRDATRFieldsLegal('000001', Zeros{3}, FALSE);
    assert BundleFPATRDATRFieldsLegal('000001', Zeros{3}, TRUE);
    assert !BundleFPATRDATRFieldsLegal('000001', '001', FALSE);
    assert !BundleFPATRDATRFieldsLegal('011010', '101', TRUE);
    assert BundleFPATRDATRFieldsLegal('000011', '001', FALSE);
    assert BundleFPATRDATRFieldsLegal('010011', '101', TRUE);
    assert BundleFPATRDATRFieldsLegal('001100', Zeros{3}, FALSE);
    assert !BundleFPATRDATRFieldsLegal('001100', Zeros{3}, TRUE);
    assert !BundleFPATRDATRFieldsLegal('001101', '001', FALSE);

    let scale_one = MatrixQuantParameter(
        FP32ToFP19(Zeros{PTO_XLEN} + 0x3f800000),
        Zeros{PTO_XLEN}, 0);
    let directed = NumericExecutionControl {
        rounding_mode = NumericRound_RTP,
        saturating = FALSE
    };
    let (fixed_fp16, fixed_fp16_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 0x3f801000,
            '100000', Zeros{3}, Zeros{4}, TileDataType_FP16,
            scale_one, Zeros{PTO_XLEN}, directed);
    assert fixed_fp16 == Zeros{PTO_XLEN} + 0x3c00;
    assert fixed_fp16_flags == Zeros{5} + 0x10;

    let away = NumericExecutionControl {
        rounding_mode = NumericRound_RNA,
        saturating = FALSE
    };
    let (fixed_e4m3, fixed_e4m3_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 0x3f880000,
            '011010', Zeros{3}, Zeros{4}, TileDataType_E4M3,
            scale_one, Zeros{PTO_XLEN}, away);
    assert fixed_e4m3 == Zeros{PTO_XLEN} + 0x38;
    assert fixed_e4m3_flags == Zeros{5} + 0x10;

    let nearest = DefaultNumericExecutionControl();
    let (fixed_hif8, fixed_hif8_flags) =
        TileProfileMatrixPostProcessWithFlags(
            Zeros{PTO_XLEN} + 0x3f880000,
            '011001', Zeros{3}, Zeros{4}, TileDataType_HiF8,
            scale_one, Zeros{PTO_XLEN}, nearest);
    assert fixed_hif8 == Zeros{PTO_XLEN} + 0x09;
    assert fixed_hif8_flags == Zeros{5} + 0x10;
    return 0;
end;
