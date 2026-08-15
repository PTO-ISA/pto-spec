// PTO-TEST: {"id":"PTO-AVS-SCALAR-CASW-PRECISE-001","source":"asl/scalar/amo/CASW.asl","requirements":["PTO-INST-SCALAR-CASW"],"kind":"fault","summary":"CASW access fault is precise and preserves destination and reservation","pass_condition":"trap, memory, event, destination, reservation, recovery, and TPC match the CASW contract","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/fault-precision.asl"]}
func CheckCASWPreciseFault()
begin
    let aligned_address = Zeros{PTO_XLEN} + 256;
    let fault_address = aligned_address + 1;
    let old_destination = Zeros{PTO_XLEN} + 0x55;
    _ReservationValid = TRUE;
    _ReservationAddress = Zeros{PTO_XLEN} + 128;
    _ReservationSize = 8;
    StartMemoryEventCapture(0);
    WriteGPR(2, fault_address);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x80000001);
    WriteGPR(4, Zeros{PTO_XLEN} + 0x1122334455667788);
    WriteGPR(5, old_destination);
    SetCurrentACR(2);
    PTOv0WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    ClearFault();

    var instruction: bits(48) = Zeros{48} + 0x0000201b;
    instruction[11:7] = Zeros{5} + 5;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    instruction[31:27] = Zeros{5} + 4;

    let status = ExecuteScalarInstruction(instruction, 32);
    assert status == ScalarExecution_Rejected;
    assert _LastFault == Fault_DataAlignment;
    assert _FaultAddress == fault_address;
    assert _MemoryEventCount == 0;
    assert _ReservationValid;
    assert _ReservationAddress == Zeros{PTO_XLEN} + 128;
    assert ReadGPR(5) == old_destination;
    assert CurrentACR() == 1;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _TrapContexts[[1]].tpc == Zeros{PTO_XLEN} + 0x100;
    let recovered = RecoverTrapContext(1);
    assert recovered;
    assert CurrentACR() == 2;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x100;
end;

func main() => integer
begin
    ResetProfileState();
    CheckCASWPreciseFault();
    return 0;
end;
