// PTO-TEST: {"id":"PTO-AVS-SCALAR-SWAPB-ALIASES-001","source":"asl/scalar/amo/SWAPB.asl","requirements":["PTO-INST-SCALAR-SWAPB"],"kind":"boundary","summary":"SWAPB reads T and U sources and pushes the prior value to U","pass_condition":"relative sources, U push, relaxed order, nonoverlap reservation, and TPC match the SWAPB contract","related_sources":["asl/scalar/model/types/operands.asl","asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl"]}
func CheckSWAPBAliases()
begin
    let address = Zeros{PTO_XLEN} + 256;
    let old_value = Zeros{PTO_XLEN} + 0x80;
    let replacement = Zeros{PTO_XLEN} + 0x1122334455667788;
    Store(address, 1, old_value);
    StartMemoryEventCapture(0);
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 512;
    _ReservationSize = 8;
    PushTemporaryQueue(TRUE, address);
    PushTemporaryQueue(FALSE, replacement);
    WriteTPC(Zeros{PTO_XLEN} + 0x80);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x0000600b;
    instruction[11:7] = Zeros{5} + 30;
    instruction[19:15] = Zeros{5} + 24;
    instruction[24:20] = Zeros{5} + 28;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Executed;
    assert _LastFault == Fault_None;
    assert LoadTranslatedUnsigned(address, 1) == Zeros{PTO_XLEN} + 0x88;
    assert ReadTemporaryQueue(TRUE, 0) == address;
    assert ReadTemporaryQueue(FALSE, 0) == Zeros{PTO_XLEN} + 0x80;
    assert ReadTemporaryQueue(FALSE, 1) == replacement;
    assert _ReservationValid;
    assert _ReservationAddress == Zeros{PTO_XLEN} + 512;
    assert _MemoryEventCount == 1;
    assert _MemoryEvents[[0]].order == MemoryOrder_Relaxed;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x84;
end;

func main() => integer
begin
    ResetProfileState();
    CheckSWAPBAliases();
    return 0;
end;
