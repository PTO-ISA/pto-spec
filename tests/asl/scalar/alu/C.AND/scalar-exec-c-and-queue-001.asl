// PTO-TEST: {"id":"PTO-AVS-SCALAR-C-AND-QUEUE-001","source":"asl/scalar/alu/C.AND.asl","requirements":["PTO-INST-SCALAR-C-AND"],"kind":"execution","summary":"C.AND computes the bitwise conjunction of snapshotted T and U sources","pass_condition":"decoded execution snapshots both relative sources, pushes one exact result to T, and advances TPC by two bytes","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 5);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 3);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);

    var instruction: bits(48) = Zeros{48} + 0x0028;
    instruction[10:6] = Zeros{5} + 24;
    instruction[15:11] = Zeros{5} + 28;

    let status = ExecuteScalarInstruction(instruction, 16);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x0000000000000001;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 5;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x102;
    assert InstructionContractResult_C_AND(
        Zeros{PTO_XLEN} + 5,
        Zeros{PTO_XLEN} + 3) == Zeros{PTO_XLEN} + 0x0000000000000001;
    return 0;
end;
