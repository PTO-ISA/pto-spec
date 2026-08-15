// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-SLLI-QUEUE-001","source":"asl/scalar/alu/C.SLLI.asl","requirements":["PTO-INST-SCALAR-C-SLLI"],"kind":"execution","summary":"C.SLLI reads old T#1 before pushing the shifted result","pass_condition":"decoded execution uses the pre-push source, preserves it as T#2, and advances TPC by two bytes","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x8000000000000001);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);

    var instruction: bits(48) = Zeros{48} + 0x102c;
    instruction[10:6] = Zeros{5} + 1;

    let status = ExecuteScalarInstruction(instruction, 16);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x0000000000000002;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 0x8000000000000001;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x102;
    assert InstructionContractResult_C_SLLI(
        Zeros{PTO_XLEN} + 0x8000000000000001,
        Zeros{5} + 1) == Zeros{PTO_XLEN} + 0x0000000000000002;
    return 0;
end;
