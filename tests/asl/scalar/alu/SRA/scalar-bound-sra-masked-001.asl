// PTO-TEST: {"id":"PTO-AVS-SCALAR-SRA-MASKED-001","source":"asl/scalar/alu/SRA.asl","requirements":["PTO-INST-SCALAR-SRA"],"kind":"boundary","summary":"SRA masks the register count and snapshots T and U sources before U publication","pass_condition":"masked count, non-consuming sources, queue alias order, and mnemonic contract match SRA","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, '1000000000000000000000000000000000000000000000000000000000000001');
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 64);

    var instruction: bits(48) = Zeros{48} + 0x00006005;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == '1000000000000000000000000000000000000000000000000000000000000001';
    assert ReadTemporaryQueue(FALSE, 0) == '1000000000000000000000000000000000000000000000000000000000000001';
    assert ReadTemporaryQueue(FALSE, 1) == Zeros{PTO_XLEN} + 64;
    assert InstructionContractShiftAmount_SRA(Zeros{PTO_XLEN} + 64) == 0;
    assert InstructionContractResult_SRA('1000000000000000000000000000000000000000000000000000000000000001', Zeros{PTO_XLEN} + 64) == '1000000000000000000000000000000000000000000000000000000000000001';
    return 0;
end;
