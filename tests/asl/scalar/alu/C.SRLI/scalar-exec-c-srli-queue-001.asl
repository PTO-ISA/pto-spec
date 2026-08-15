// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SRLI-QUEUE-001","source":"asl/scalar/alu/C.SRLI.asl","requirements":["PTO-INST-SCALAR-C-SRLI"],"kind":"execution","summary":"C.SRLI reads old T#1 before pushing the shifted result","pass_condition":"decoded execution uses the pre-push source, preserves it as T#2, and advances TPC by two bytes","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x8000000000000001);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);

    var instruction: bits(48) = Zeros{48} + 0x182c;
    instruction[10:6] = Zeros{5} + 1;

    let status = ExecuteScalarInstruction(instruction, 16);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x4000000000000000;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 0x8000000000000001;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x102;
    assert InstructionContractResult_C_SRLI(
        Zeros{PTO_XLEN} + 0x8000000000000001,
        Zeros{5} + 1) == Zeros{PTO_XLEN} + 0x4000000000000000;
    return 0;
end;
