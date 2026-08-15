// PTO-TEST: {"id":"PTO-AVS-SCALAR-SLL-MASKED-001","source":"asl/scalar/alu/SLL.asl","requirements":["PTO-INST-SCALAR-SLL"],"kind":"boundary","summary":"SLL masks the register count and snapshots T and U sources before U publication","pass_condition":"masked count, non-consuming sources, queue alias order, and mnemonic contract match SLL","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x81);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 64);

    var instruction: bits(48) = Zeros{48} + 0x00007005;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x81;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x81;
    assert ReadTemporaryQueue(FALSE, 1) == Zeros{PTO_XLEN} + 64;
    assert InstructionContractShiftAmount_SLL(Zeros{PTO_XLEN} + 64) == 0;
    assert InstructionContractResult_SLL(Zeros{PTO_XLEN} + 0x81, Zeros{PTO_XLEN} + 64) == Zeros{PTO_XLEN} + 0x81;
    return 0;
end;
