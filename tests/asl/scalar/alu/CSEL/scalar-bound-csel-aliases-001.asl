// PTO-UNIT: {"id":"PTO-TEST-SCALAR-CSEL-ALIASES-001","surface":"scalar","classification":["alu","CSEL","scalar-bound-csel-aliases-001"],"depends_on":["PTO-SCALAR-CSEL"]}
// PTO-TEST: {"id":"PTO-AVS-SCALAR-CSEL-ALIASES-001","source":"asl/scalar/alu/CSEL.asl","requirements":["PTO-INST-SCALAR-CSEL"],"kind":"boundary","summary":"CSEL eagerly snapshots relative sources and preserves all three unmodified modifier aliases","pass_condition":"raw codes 00 through 10 are equal, T and U reads are non-consuming, source-destination aliases use snapshots, and queue publication is ordered","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/alu.asl"]}

func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 1);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x55);

    assert InstructionContractResult_CSEL(
        Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0xaa,
        Zeros{PTO_XLEN} + 0x55,
        '00') == Zeros{PTO_XLEN} + 0x55;
    assert InstructionContractResult_CSEL(
        Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0xaa,
        Zeros{PTO_XLEN} + 0x55,
        '01') == Zeros{PTO_XLEN} + 0x55;
    assert InstructionContractResult_CSEL(
        Zeros{PTO_XLEN},
        Zeros{PTO_XLEN} + 0xaa,
        Zeros{PTO_XLEN} + 0x55,
        '10') == Zeros{PTO_XLEN} + 0x55;

    var instruction: bits(48) = Zeros{48} + 0x00000077;
    instruction[11:7] = Zeros{5} + 31;
    instruction[19:15] = Zeros{5} + 28;
    instruction[24:20] = Zeros{5} + 28;
    instruction[26:25] = '10';
    instruction[31:27] = Zeros{5} + 24;

    let status = ExecuteScalarInstruction(
        instruction,
        32);
    assert status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x55;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x55;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 1;
    return 0;
end;
