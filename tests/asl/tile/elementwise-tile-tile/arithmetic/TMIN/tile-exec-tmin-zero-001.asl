// PTO-TEST: {"id":"PTO-AVS-TILE-TMIN-ZERO-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMIN.asl","requirements":["PTO-INST-TILE-TMIN"],"kind":"execution","summary":"TMIN resolves floating signed-zero ties independently of operand order","pass_condition":"mixed zeros produce negative zero and two positive zeros retain positive zero","related_sources":["asl/arch/features/mx-formats.asl"]}
func main() => integer
begin
    let positive_zero = Zeros{PTO_XLEN};
    let negative_zero = Zeros{PTO_XLEN} + 0x80000000;

    let (forward, forward_invalid) = InstructionContractFloatingValue_TMIN(
        TileDataType_FP32, negative_zero, positive_zero);
    let (reverse, reverse_invalid) = InstructionContractFloatingValue_TMIN(
        TileDataType_FP32, positive_zero, negative_zero);
    let (same, same_invalid) = InstructionContractFloatingValue_TMIN(
        TileDataType_FP32, positive_zero, positive_zero);
    assert forward == negative_zero;
    assert reverse == negative_zero;
    assert same == positive_zero;
    assert !forward_invalid && !reverse_invalid && !same_invalid;
    return 0;
end;
