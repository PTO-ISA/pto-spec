// PTO-TEST: {"id":"PTO-AVS-BLOCK-B-DATR-RMODE-001","source":"asl/block/attributes/B.DATR.asl","requirements":["PTO-INST-BLOCK-B-DATR"],"kind":"boundary","summary":"All eight RMode encodings have assigned meanings.","pass_condition":"Zero selects the operation default and codes one through seven select RNE, RTZ, RTM, RTP, RNA, RTO, and RHB.","related_sources":["asl/scalar/model/fsu/arithmetic.asl"]}
func main() => integer
begin
    let operation_default = DecodeBundleRoundingSelection('000');
    assert operation_default.use_operation_default;
    let rne = DecodeBundleRoundingSelection('001');
    assert !rne.use_operation_default;
    assert rne.rounding_mode == NumericRound_RNE;
    assert DecodeBundleRoundingSelection('010').rounding_mode == NumericRound_RTZ;
    assert DecodeBundleRoundingSelection('011').rounding_mode == NumericRound_RTM;
    assert DecodeBundleRoundingSelection('100').rounding_mode == NumericRound_RTP;
    assert DecodeBundleRoundingSelection('101').rounding_mode == NumericRound_RNA;
    assert DecodeBundleRoundingSelection('110').rounding_mode == NumericRound_RTO;
    assert DecodeBundleRoundingSelection('111').rounding_mode == NumericRound_RHB;
    return 0;
end;
