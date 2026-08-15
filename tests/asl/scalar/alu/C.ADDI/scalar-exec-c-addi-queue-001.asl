// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-ADDI-QUEUE-001","source":"asl/scalar/alu/C.ADDI.asl","requirements":["PTO-INST-SCALAR-C-ADDI"],"kind":"execution","summary":"C.ADDI sign-extends simm5 and adds it to the snapshotted T source","pass_condition":"decoded negative-immediate execution pushes the wrapping result to T and advances TPC by two bytes","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 5);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);

    var instruction: bits(48) = Zeros{48} + 0x000c;
    instruction[10:6] = Zeros{5} + 24;
    instruction[15:11] = Zeros{5} + 31;

    let status = ExecuteScalarInstruction(instruction, 16);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 4;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 5;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x102;
    assert InstructionContractResult_C_ADDI(
        Zeros{PTO_XLEN} + 5,
        Zeros{5} + 31) == Zeros{PTO_XLEN} + 4;
    return 0;
end;
