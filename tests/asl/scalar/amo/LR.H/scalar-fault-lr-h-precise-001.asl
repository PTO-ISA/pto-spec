// PTO-TEST: {"id":"PTO-AVS-SCALAR-LR-H-PRECISE-001","source":"asl/scalar/amo/LR.H.asl","requirements":["PTO-INST-SCALAR-LR-H"],"kind":"fault","summary":"LR.H access fault preserves the prior reservation and destination","pass_condition":"trap routing, destination, event, prior reservation, and recovery match the LR.H contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/fault-precision.asl"]}
func CheckLRHPreciseFault()
begin
    let aligned_address = Zeros{PTO_XLEN} + 320;
    let fault_address = aligned_address + 1;
    let prior_reservation = Zeros{PTO_XLEN} + 128;
    let old_destination = Zeros{PTO_XLEN} + 0x55;

    _ReservationValid = TRUE;
    _ReservationAddress = prior_reservation;
    _ReservationSize = 8;
    StartMemoryEventCapture(0);
    WriteGPR(2, fault_address);
    WriteGPR(5, old_destination);
    SetCurrentACR(2);
    PTOv0WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x1000000b;
    instruction[11:7] = Zeros{5} + 5;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Ones{5};

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_DataAlignment;
    assert _FaultAddress == fault_address;
    assert CurrentACR() == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _TrapContexts[[1]].valid;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x100;
    assert _MemoryEventCount == 0;
    assert _ReservationValid;
    assert _ReservationAddress == prior_reservation;
    assert _ReservationSize == 8;
    assert ReadGPR(5) == old_destination;

    let recovered = RecoverTrapContext(1);
    assert recovered;
    assert CurrentACR() == 2;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
    assert !_TrapContexts[[1]].valid;
end;

func main() => integer
begin
    ResetProfileState();
    CheckLRHPreciseFault();
    return 0;
end;
