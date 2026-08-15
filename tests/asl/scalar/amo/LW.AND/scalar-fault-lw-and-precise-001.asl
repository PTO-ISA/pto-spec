// PTO-TEST: {"id":"PTO-AVS-SCALAR-LW-AND-PRECISE-001","source":"asl/scalar/amo/LW.AND.asl","requirements":["PTO-INST-SCALAR-LW-AND"],"kind":"fault","summary":"LW.AND alignment fault is precise and restores the original TPC","pass_condition":"trap routing, destination, memory, event, reservation, queues, and recovery match the LW.AND contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/fault-precision.asl"]}
func CheckLWANDPreciseAlignmentFault()
begin
    let aligned_address = Zeros{PTO_XLEN} + 256;
    let fault_address = aligned_address + 1;
    let old_value = Zeros{PTO_XLEN} + 5;
    let operand = Zeros{PTO_XLEN} + 7;
    let reservation_address = Zeros{PTO_XLEN} + 512;
    let old_destination = Zeros{PTO_XLEN} + 0x55;

    Store(aligned_address, 4, old_value);
    _ReservationValid = TRUE;
    _ReservationAddress = reservation_address;
    _ReservationSize = 4;
    PushTemporaryQueue(TRUE, Zeros{PTO_XLEN} + 0x66);
    PushTemporaryQueue(FALSE, Zeros{PTO_XLEN} + 0x77);
    let old_t = ReadTemporaryQueue(TRUE, 0);
    let old_u = ReadTemporaryQueue(FALSE, 0);
    StartMemoryEventCapture(0);
    WriteGPR(2, fault_address);
    WriteGPR(3, operand);
    WriteGPR(5, old_destination);
    SetCurrentACR(2);
    PTOv0WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x1000200b;
    instruction[11:7] = Zeros{5} + 5;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_DataAlignment;
    assert _FaultAddress == fault_address;
    assert CurrentACR() == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _TrapContexts[[1]].valid;
    assert _TrapContexts[[1]].source_acr == 2;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x100;

    assert _MemoryEventCount == 0;
    assert LoadTranslatedUnsigned(aligned_address, 4) == old_value;
    assert _ReservationValid;
    assert _ReservationAddress == reservation_address;
    assert _ReservationSize == 4;
    assert ReadGPR(5) == old_destination;
    assert ReadTemporaryQueue(TRUE, 0) == old_t;
    assert ReadTemporaryQueue(FALSE, 0) == old_u;

    let recovered = RecoverTrapContext(1);
    assert recovered;
    assert CurrentACR() == 2;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
    assert !_TrapContexts[[1]].valid;
end;

func main() => integer
begin
    ResetProfileState();
    CheckLWANDPreciseAlignmentFault();
    return 0;
end;
