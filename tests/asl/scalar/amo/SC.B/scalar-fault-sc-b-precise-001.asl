// PTO-TEST: {"id":"PTO-AVS-SCALAR-SC-B-PRECISE-001","source":"asl/scalar/amo/SC.B.asl","requirements":["PTO-INST-SCALAR-SC-B"],"kind":"fault","summary":"SC.B line-matched access fault clears the reservation without publishing status","pass_condition":"trap, memory, destination, event, reservation clear, and recovery match the SC.B contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/fault-precision.asl"]}
func CheckSCBPreciseFault()
begin
    let aligned_address = Zeros{PTO_XLEN} + 256;
    let fault_address = Zeros{PTO_XLEN} + PTO_MODEL_MEMORY_BYTES;
    let old_destination = Zeros{PTO_XLEN} + 0x55;
    _ReservationValid = TRUE;
    _ReservationAddress = fault_address;
    _ReservationSize = 1;
    StartMemoryEventCapture(0);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x1122334455667788);
    WriteGPR(3, fault_address);
    WriteGPR(5, old_destination);
    SetCurrentACR(2);
    PTOv0WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x0000100b;
    instruction[11:7] = Zeros{5} + 5;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_DataPage;
    assert _FaultAddress == fault_address;
    assert CurrentACR() == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _TrapContexts[[1]].valid;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x100;
    assert _MemoryEventCount == 0;
    assert !_ReservationValid;
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
    CheckSCBPreciseFault();
    return 0;
end;
