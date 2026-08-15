// PTO-TEST: {"id":"PTO-AVS-SCALAR-BCNT-SELECTORS-001","source":"asl/scalar/alu/BCNT.asl","requirements":["PTO-INST-SCALAR-BCNT"],"kind":"boundary","summary":"BCNT assigns full-width counts, relative sources, queue destinations, and discard destinations","pass_condition":"T#1 all-ones returns 64 to T, U#1 alternating bits returns 32 to U, and destination code 24 discards without consuming either source queue","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Ones{PTO_XLEN});
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0xaaaaaaaaaaaaaaaa);
    var to_t: bits(48) = Zeros{48} + 0x00006067;
    to_t[11:7] = Zeros{5} + 31;
    to_t[19:15] = Zeros{5} + 24;
    to_t[25:20] = Ones{6};
    let to_t_status = ExecuteScalarInstruction(to_t, 32);
    assert to_t_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 64;
    assert ReadTemporaryQueue(TRUE, 1) == Ones{PTO_XLEN};
    var to_u = to_t;
    to_u[11:7] = Zeros{5} + 30;
    to_u[19:15] = Zeros{5} + 28;
    let to_u_status = ExecuteScalarInstruction(to_u, 32);
    assert to_u_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 32;
    assert ReadTemporaryQueue(FALSE, 1) == Zeros{PTO_XLEN} + 0xaaaaaaaaaaaaaaaa;
    var discard = to_t;
    discard[11:7] = Zeros{5} + 24;
    discard[19:15] = Zeros{5} + 1;
    WriteGPR(1, Zeros{PTO_XLEN});
    let discard_status = ExecuteScalarInstruction(discard, 32);
    assert discard_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 64;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 32;
    return 0;
end;
