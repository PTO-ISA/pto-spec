// PTO-UNIT: {"id":"PTO-TEST-SCALAR-CSEL-SELECT-001","surface":"scalar","classification":["alu","CSEL","scalar-exec-csel-select-001"],"depends_on":["PTO-SCALAR-CSEL"]}
// PTO-TEST: {"id":"PTO-AVS-SCALAR-CSEL-SELECT-001","source":"asl/scalar/alu/CSEL.asl","requirements":["PTO-INST-SCALAR-CSEL"],"kind":"execution","summary":"CSEL treats every nonzero predicate as true and negates the false source only for raw modifier code 11","pass_condition":"decoded true and false selections, modulo negation, destination publication, and TPC match the mnemonic contract","related_sources":["asl/scalar/model/dispatch/alu.asl","asl/scalar/model/alu/semantics.asl"]}

func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 0x8000000000000000);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x1111);
    WriteGPR(3, Zeros{PTO_XLEN} + 7);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);

    var true_instruction: bits(48) = Zeros{48} + 0x00000077;
    true_instruction[11:7] = Zeros{5} + 4;
    true_instruction[19:15] = Zeros{5} + 2;
    true_instruction[24:20] = Zeros{5} + 3;
    true_instruction[26:25] = '11';
    true_instruction[31:27] = Zeros{5} + 1;

    let true_status = ExecuteScalarInstruction(
        true_instruction,
        32);
    assert true_status == ScalarExecution_Executed;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0x1111;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x104;

    WriteGPR(1, Zeros{PTO_XLEN});
    var false_instruction = true_instruction;
    false_instruction[11:7] = Zeros{5} + 5;

    let false_status = ExecuteScalarInstruction(
        false_instruction,
        32);
    assert false_status == ScalarExecution_Executed;
    assert ReadGPR(5) == Zeros{PTO_XLEN} - 7;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x108;
    return 0;
end;
