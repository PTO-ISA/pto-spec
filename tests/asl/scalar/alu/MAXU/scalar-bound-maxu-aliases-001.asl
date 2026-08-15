// PTO-TEST: {"id":"PTO-AVS-SCALAR-MAXU-ALIASES-001","source":"asl/scalar/alu/MAXU.asl","requirements":["PTO-INST-SCALAR-MAXU"],"kind":"boundary","summary":"MAXU snapshots non-consuming T and U sources before publishing to U","pass_condition":"source queues persist, new U value uses old sources, and mnemonic contract matches MAXU","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0xffffffffffffffff);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x0000000000000001);

    var instruction: bits(48) = Zeros{48} + 0x0800405b;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0xffffffffffffffff;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0xffffffffffffffff;
    assert ReadTemporaryQueue(FALSE, 1) == Zeros{PTO_XLEN} + 0x0000000000000001;
    assert InstructionContractResult_MAXU(
        Zeros{PTO_XLEN} + 0xffffffffffffffff,
        Zeros{PTO_XLEN} + 0x0000000000000001) == Zeros{PTO_XLEN} + 0xffffffffffffffff;
    return 0;
end;
