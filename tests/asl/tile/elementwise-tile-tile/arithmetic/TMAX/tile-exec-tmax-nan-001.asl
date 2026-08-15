// PTO-TEST: {"id":"PTO-AVS-TILE-TMAX-NAN-001","source":"asl/tile/elementwise-tile-tile/arithmetic/TMAX.asl","requirements":["PTO-INST-TILE-TMAX"],"kind":"execution","summary":"TMAX applies deterministic floating NaN selection","pass_condition":"one NaN returns the numeric operand, two NaNs return canonical NaN, and signaling NaN reports invalid","related_sources":["asl/arch/features/mx-formats.asl","asl/tile/model/execution/elementwise.asl"]}
func main() => integer
begin
    let numeric = Zeros{PTO_XLEN} + 0x3f800000;
    let quiet_nan = Zeros{PTO_XLEN} + 0x7fc00001;
    let signaling_nan = Zeros{PTO_XLEN} + 0x7f800001;

    let (one_nan, one_invalid) = InstructionContractFloatingValue_TMAX(
        TileDataType_FP32, quiet_nan, numeric);
    assert one_nan == numeric;
    assert !one_invalid;

    let (two_nan, two_invalid) = InstructionContractFloatingValue_TMAX(
        TileDataType_FP32, quiet_nan, quiet_nan);
    assert two_nan == Zeros{PTO_XLEN} + 0x7fc00000;
    assert !two_invalid;

    let (signal_result, signal_invalid) = InstructionContractFloatingValue_TMAX(
        TileDataType_FP32, signaling_nan, numeric);
    assert signal_result == numeric;
    assert signal_invalid;
    return 0;
end;
