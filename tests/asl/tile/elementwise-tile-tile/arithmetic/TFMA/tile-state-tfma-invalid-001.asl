// PTO-TEST: {"id":"PTO-AVS-TILE-TFMA-INVALID-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TFMA.asl","requirements":["PTO-TFMA-CONTRACT-001"],"kind":"state-transition","summary":"TFMA identifies every fixed invalid fused floating case.","pass_condition":"Signaling NaN, zero times infinity, and opposite infinities produce a profile-selected quiet NaN with NV.","related_sources":["asl/tile/model/execution/fused-multiply-add.asl"]}
func AssertTFMAInvalid(left: Word, right: Word, addend: Word)
begin
    let (result, flags) = InstructionContractValue_TFMA(
        TileDataType_FP32, left, right, addend);
    assert TileNumericValueClass(TileDataType_FP32, result) ==
        NumericValue_QuietNaN;
    assert flags == Zeros{5} + 1;
end;

func main() => integer
begin
    AssertTFMAInvalid(
        Zeros{PTO_XLEN} + 0x7f800001,
        Zeros{PTO_XLEN} + 0x3f800000,
        Zeros{PTO_XLEN});
    AssertTFMAInvalid(
        Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0x7f800000,
        Zeros{PTO_XLEN});
    AssertTFMAInvalid(
        Zeros{PTO_XLEN} + 0x7f800000,
        Zeros{PTO_XLEN} + 0x3f800000,
        Zeros{PTO_XLEN} + 0xff800000);
    return 0;
end;
