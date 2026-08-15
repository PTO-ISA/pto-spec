// PTO-TEST: {"id":"PTO-AVS-SCALAR-SRAW-MASKED-001","source":"asl/scalar/alu/SRAW.asl","requirements":["PTO-INST-SCALAR-SRAW"],"kind":"boundary","summary":"SRAW masks the register count and snapshots T and U sources before U publication","pass_condition":"masked count, non-consuming sources, queue alias order, and mnemonic contract match SRAW","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x80000001);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 32);

    var instruction: bits(48) = Zeros{48} + 0x00006025;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x80000001;
    assert ReadTemporaryQueue(FALSE, 0) ==
        Zeros{PTO_XLEN} + 0xffffffff80000001;
    assert ReadTemporaryQueue(FALSE, 1) == Zeros{PTO_XLEN} + 32;
    assert InstructionContractShiftAmount_SRAW(Zeros{PTO_XLEN} + 32) == 0;
    assert InstructionContractResult_SRAW(
        Zeros{PTO_XLEN} + 0x80000001,
        Zeros{PTO_XLEN} + 32) ==
        Zeros{PTO_XLEN} + 0xffffffff80000001;
    return 0;
end;
