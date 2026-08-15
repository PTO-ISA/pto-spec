// PTO-TEST: {"id":"PTO-AVS-SCALAR-LR-B-ALIASES-001","source":"asl/scalar/amo/LR.B.asl","requirements":["PTO-INST-SCALAR-LR-B"],"kind":"boundary","summary":"LR.B accepts every SrcZero alias and Reg5 queue source and destination","pass_condition":"ignored SrcZero, T address source, U destination, relaxed order, reservation, and TPC match the LR.B contract","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl"]}
func CheckLRBAliases()
begin
    let address = Zeros{PTO_XLEN} + 320;
    let old_value = Zeros{PTO_XLEN} + 0x80;
    Store(address, 1, old_value);
    StartMemoryEventCapture(0);
    PushTemporaryQueue(TRUE, address);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x77);
    WriteTPC(Zeros{PTO_XLEN} + 0x80);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x0000000b;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 29;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert ReadTemporaryQueue(TRUE, 0) == address;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x80;
    assert ReadTemporaryQueue(FALSE, 1) == Zeros{PTO_XLEN} + 0x77;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x84;
    assert _ReservationValid;
    assert _ReservationAddress == address;
    assert _ReservationSize == 1;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].order == MemoryOrder_Relaxed;
end;

func main() => integer
begin
    ResetProfileState();
    CheckLRBAliases();
    return 0;
end;
