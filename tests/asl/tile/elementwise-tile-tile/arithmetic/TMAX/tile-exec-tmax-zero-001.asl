// PTO-TEST: {"id":"PTO-AVS-TILE-TMAX-ZERO-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl","requirements":["PTO-INST-TILE-TMAX"],"kind":"execution","summary":"TMAX resolves floating signed-zero ties independently of operand order","pass_condition":"mixed zeros produce positive zero and two negative zeros retain negative zero","related_sources":["asl/arch/features/mx-formats.asl"]}
func main() => integer
begin
    let positive_zero = Zeros{PTO_XLEN};
    let negative_zero = Zeros{PTO_XLEN} + 0x80000000;

    let (forward, forward_invalid) = InstructionContractFloatingValue_TMAX(
        TileDataType_FP32, negative_zero, positive_zero);
    let (reverse, reverse_invalid) = InstructionContractFloatingValue_TMAX(
        TileDataType_FP32, positive_zero, negative_zero);
    let (same, same_invalid) = InstructionContractFloatingValue_TMAX(
        TileDataType_FP32, negative_zero, negative_zero);
    assert forward == positive_zero;
    assert reverse == positive_zero;
    assert same == negative_zero;
    assert !forward_invalid && !reverse_invalid && !same_invalid;
    return 0;
end;
