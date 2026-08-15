// PTO-UNIT: {"id":"PTO-TEST-SCALAR-CSEL-READINESS-001","surface":"scalar","classification":["alu","CSEL","scalar-fault-csel-readiness-001"],"depends_on":["PTO-SCALAR-CSEL"]}
// PTO-TEST: {"id":"PTO-AVS-SCALAR-CSEL-READINESS-001","source":"asl/scalar/alu/CSEL.asl","requirements":["PTO-INST-SCALAR-CSEL"],"kind":"fault","summary":"CSEL rejects an unavailable relative source before selection or destination effects","pass_condition":"all three source selectors are preflighted, Fault_IllegalInstruction is reported, and destination, queues, and TPC remain unchanged","related_sources":["asl/arch/programming-model/execution-context.asl","asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/top-level.asl"]}

func main() => integer
begin
    ResetProfileState();
    WriteGPR(1, Zeros{PTO_XLEN} + 1);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x22);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x33);
    WriteGPR(4, Zeros{PTO_XLEN} + 0x44);
    WriteTPC(Zeros{PTO_XLEN} + 0x200);

    var instruction: bits(48) = Zeros{48} + 0x00000077;
    instruction[11:7] = Zeros{5} + 4;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 27;
    instruction[26:25] = '00';
    instruction[31:27] = Zeros{5} + 1;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_IllegalInstruction;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0x44;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x200;
    assert !TemporaryQueueSourceAvailable(TRUE, 3);
    return 0;
end;
