// PTO-TEST: {"id":"PTO-AVS-SCALAR-REV-SELECTORS-001","source":"asl/scalar/alu/REV.asl","requirements":["PTO-INST-SCALAR-REV"],"kind":"boundary","summary":"REV assigns byte and non-byte widths, relative sources, queue destinations, and discard destinations","pass_condition":"T#1 reverses 32 bits to T, U#1 reverses 16 bits to U, and a seven-bit width returns zero to a discard destination without consuming either queue","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x11223344);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x1234);
    var to_t: bits(48) = Zeros{48} + 0x00007067;
    to_t[11:7] = Zeros{5} + 31;
    to_t[19:15] = Zeros{5} + 24;
    to_t[25:20] = Zeros{6} + 31;
    let to_t_status = ExecuteScalarInstruction(to_t, 32);
    assert to_t_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 0x44332211;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN} + 0x11223344;
    var to_u = to_t;
    to_u[11:7] = Zeros{5} + 30;
    to_u[19:15] = Zeros{5} + 28;
    to_u[25:20] = Zeros{6} + 15;
    let to_u_status = ExecuteScalarInstruction(to_u, 32);
    assert to_u_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x3412;
    assert ReadTemporaryQueue(FALSE, 1) == Zeros{PTO_XLEN} + 0x1234;
    var discard = to_t;
    discard[11:7] = Zeros{5} + 24;
    discard[19:15] = Zeros{5} + 1;
    discard[25:20] = Zeros{6} + 6;
    WriteGPR(1, Ones{PTO_XLEN});
    let discard_status = ExecuteScalarInstruction(discard, 32);
    assert discard_status == ScalarExecution_Executed;
    assert InstructionContractResult_REV(Ones{PTO_XLEN}, 7, 0) ==
        Zeros{PTO_XLEN};
    return 0;
end;
