// PTO-TEST: {"id":"PTO-AVS-SCALAR-ADD-ALIASES-001","source":"asl/scalar/alu/ADD.asl","requirements":["PTO-INST-SCALAR-ADD"],"kind":"boundary","summary":"ADD snapshots T and U sources before publishing the shifted unmodified result to U","pass_condition":"raw no-modifier code 11, maximum shift, non-consuming sources, queue order, and mnemonic contract match ADD","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 1);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 1);

    var instruction: bits(48) = Zeros{48} + 0x00000005;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;
    instruction[26:25] = '11';
    instruction[31:27] = Ones{5};

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 1;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x0000000080000001;
    assert ReadTemporaryQueue(FALSE, 1) == Zeros{PTO_XLEN} + 1;
    assert InstructionContractResult_ADD(
        Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 1,
        '11',
        31) == Zeros{PTO_XLEN} + 0x0000000080000001;
    return 0;
end;
