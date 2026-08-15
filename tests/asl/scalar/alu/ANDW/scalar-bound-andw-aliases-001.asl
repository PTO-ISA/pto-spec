// PTO-TEST: {"id":"PTO-AVS-SCALAR-ANDW-ALIASES-001","source":"asl/scalar/alu/ANDW.asl","requirements":["PTO-INST-SCALAR-ANDW"],"kind":"boundary","summary":"ANDW snapshots T and U sources before publishing a maximum-shift result to T","pass_condition":"raw no-modifier code 11, maximum shift, non-consuming sources, queue order, and mnemonic contract match ANDW","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0xffffffffffffffff);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 1);

    var instruction: bits(48) = Zeros{48} + 0x00002025;
    instruction[11:7] = Zeros{5} + 31;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;
    instruction[26:25] = '11';
    instruction[31:27] = Ones{5};

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0xffffffff80000000;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x0000000000000001;
    assert InstructionContractResult_ANDW(
        Zeros{PTO_XLEN} + 0xffffffffffffffff,
        Zeros{PTO_XLEN} + 1,
        '11',
        31) == Zeros{PTO_XLEN} + 0xffffffff80000000;
    return 0;
end;
