// PTO-TEST: {"id":"PTO-AVS-SCALAR-AND-ALIASES-001","source":"asl/scalar/alu/AND.asl","requirements":["PTO-INST-SCALAR-AND"],"kind":"boundary","summary":"AND snapshots T and U sources before publishing a shifted unmodified result to T","pass_condition":"raw no-modifier code 11, maximum shift, non-consuming sources, queue order, and mnemonic contract match AND","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Ones{PTO_XLEN});
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 3);

    var instruction: bits(48) = Zeros{48} + 0x00002005;
    instruction[11:7] = Zeros{5} + 31;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;
    instruction[26:25] = '11';
    instruction[31:27] = Ones{5};

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x0000000180000000;
    assert ReadTemporaryQueue(TRUE, 1) == Ones{PTO_XLEN};
    assert InstructionContractResult_AND(
        Ones{PTO_XLEN},
        Zeros{PTO_XLEN} + 3,
        '11',
        31) == Zeros{PTO_XLEN} + 0x0000000180000000;
    return 0;
end;
