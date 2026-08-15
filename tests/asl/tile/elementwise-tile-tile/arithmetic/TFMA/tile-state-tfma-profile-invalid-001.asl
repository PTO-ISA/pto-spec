// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-PROFILE-INVALID-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"state-transition","summary":"TFMA delegates invalid fused results to the selected numeric profile.","pass_condition":"The profile hook returns a quiet NaN and records NV without fixing a normative NaN payload.","related_sources":["asl/tile/model/execution/fused-multiply-add.asl","asl/arch/profile/reference-profile.asl"]}
func main() => integer
begin
    let (result, flags) = TileProfileFusedInvalidResult(
        TileDataType_FP32,
        Zeros{PTO_XLEN} + 0x7f800001,
        Zeros{PTO_XLEN} + 0x3f800000,
        Zeros{PTO_XLEN});
    assert TileNumericValueClass(TileDataType_FP32, result) ==
        NumericValue_QuietNaN;
    assert flags == Zeros{5} + 1;
    return 0;
end;
