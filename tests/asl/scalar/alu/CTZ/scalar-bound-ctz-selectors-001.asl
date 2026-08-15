// PTO-TEST: {"id":"PTO-AVS-SCALAR-CTZ-SELECTORS-001","source":"asl/scalar/alu/CTZ.asl","requirements":["PTO-INST-SCALAR-CTZ"],"kind":"boundary","summary":"CTZ assigns full-width zero, relative sources, queue destinations, and discard destinations","pass_condition":"T#1 zero returns 64 to T, U#1 value eight returns three to U, and destination code 24 discards without consuming either source queue","related_sources":["asl/scalar/model/types/operands.asl"]}
func main() => integer
begin
    ResetProfileState();
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN});
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 8);
    var to_t: bits(48) = Zeros{48} + 0x00004067;
    to_t[11:7] = Zeros{5} + 31;
    to_t[19:15] = Zeros{5} + 24;
    to_t[25:20] = Ones{6};
    let to_t_status = ExecuteScalarInstruction(to_t, 32);
    assert to_t_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 64;
    assert ReadTemporaryQueue(TRUE, 1) == Zeros{PTO_XLEN};
    var to_u = to_t;
    to_u[11:7] = Zeros{5} + 30;
    to_u[19:15] = Zeros{5} + 28;
    let to_u_status = ExecuteScalarInstruction(to_u, 32);
    assert to_u_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 3;
    assert ReadTemporaryQueue(FALSE, 1) == Zeros{PTO_XLEN} + 8;
    var discard = to_t;
    discard[11:7] = Zeros{5} + 24;
    discard[19:15] = Zeros{5} + 1;
    WriteGPR(1, Ones{PTO_XLEN});
    let discard_status = ExecuteScalarInstruction(discard, 32);
    assert discard_status == ScalarExecution_Executed;
    assert ReadTemporaryQueue(TRUE, 0) == Zeros{PTO_XLEN} + 64;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 3;
    return 0;
end;
