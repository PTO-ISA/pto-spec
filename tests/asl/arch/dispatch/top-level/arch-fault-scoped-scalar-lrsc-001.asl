// PTO-TEST: {"id":"PTO-AVS-ARCH-SCOPED-SCALAR-LRSC-FAULT-001","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-INSTRUCTION-FETCH-001","PTO-REQ-SCALAR-SHAREABILITY-CARRIER-001","PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001","PTO-ARCH-PE-EXECUTION-CONTEXT-001","PTO-INST-SCALAR-LR-D","PTO-INST-SCALAR-SC-D"],"kind":"fault","summary":"Scoped LR faults preserve the old monitor, mismatched scoped SC misses without access, and a matching scoped SC fault clears its monitor without publishing status.","pass_condition":"Fault and miss boundaries preserve the established reservation, destination, memory, event, TPC, and recovery behavior while the carrier scope remains instruction-local.","related_sources":["asl/scalar/model/dispatch/top-level.asl","asl/scalar/model/amo/semantics.asl","asl/arch/memory-model/fault-precision.asl"]}

func BuildScopedCarrier(payload: bits(48), length_code: bits(2),
                        scope_code: bits(2)) => bits(64)
begin
    var carrier: bits(64) = Zeros{64};
    carrier[63:16] = payload;
    carrier[11:10] = length_code;
    carrier[9:8] = scope_code;
    carrier[7:0] = Zeros{8} + 0x1f;
    return carrier;
end;

func WriteScopedCarrier(address: Word, carrier: bits(64))
begin
    WriteMemoryByte(address, carrier[7:0]);
    WriteMemoryByte(address + 1, carrier[15:8]);
    WriteMemoryByte(address + 2, carrier[23:16]);
    WriteMemoryByte(address + 3, carrier[31:24]);
    WriteMemoryByte(address + 4, carrier[39:32]);
    WriteMemoryByte(address + 5, carrier[47:40]);
    WriteMemoryByte(address + 6, carrier[55:48]);
    WriteMemoryByte(address + 7, carrier[63:56]);
end;

func TestScopedLRFaultPreservesPriorMonitor()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let fault_address = Zeros{PTO_XLEN} + 0x141;
    let prior_reservation = Zeros{PTO_XLEN} + 0x280;
    let old_destination = Zeros{PTO_XLEN} + 0x55;
    _ReservationValid = TRUE;
    _ReservationAddress = prior_reservation;
    _ReservationSize = 8;
    _ReservationShareability = MemoryShareability_InterCore;
    StartMemoryEventCapture(0);
    WriteGPR(2, fault_address);
    WriteGPR(5, old_destination);
    SetCurrentACR(2);
    WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteTPC(entry);
    var lr: bits(48) = Zeros{48} + 0x1800000b;
    lr[11:7] = Zeros{5} + 5;
    lr[19:15] = Zeros{5} + 2;
    lr[24:20] = Ones{5};
    let status = ExecutePTOInstruction(
        BuildScopedCarrier(lr, '01', '01'), 64);
    assert status == PTOInstruction_Rejected;
    assert _LastFault == Fault_DataAlignment;
    assert _FaultAddress == fault_address;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _TrapContexts[[1]].tpc == entry;
    assert _MemoryEventCount == 0;
    assert _ReservationValid;
    assert _ReservationAddress == prior_reservation;
    assert _ReservationSize == 8;
    assert _ReservationShareability == MemoryShareability_InterCore;
    assert ReadGPR(5) == old_destination;
    assert _CurrentMemoryShareability == MemoryShareability_Private;
    let recovered = RecoverTrapContext(1);
    assert recovered;
    assert ReadTPC() == entry;
end;

func TestScopedSCMismatchMissesWithoutAccess()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let address = Zeros{PTO_XLEN} + 0x300;
    Store(address, 8, Zeros{PTO_XLEN} + 0x1122334455667788);
    var lr: bits(48) = Zeros{48} + 0x1800000b;
    lr[11:7] = Zeros{5} + 3;
    lr[19:15] = Zeros{5} + 1;
    var sc: bits(48) = Zeros{48} + 0x1800100b;
    sc[11:7] = Zeros{5} + 4;
    sc[19:15] = Zeros{5} + 2;
    sc[24:20] = Zeros{5} + 1;
    WriteTPC(entry);
    WriteGPR(1, address);
    WriteGPR(2, Zeros{PTO_XLEN} + 7);
    WriteScopedCarrier(entry, BuildScopedCarrier(lr, '01', '01'));
    WriteScopedCarrier(entry + 8, BuildScopedCarrier(sc, '01', '00'));
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(address, 8,
        Zeros{PTO_XLEN} + 0x1122334455667788);

    let lr_status = ExecuteNextPTOInstruction();
    assert lr_status == PTOInstruction_Executed;
    assert _ReservationValid;
    assert _ReservationShareability == MemoryShareability_IntraCore;
    let sc_status = ExecuteNextPTOInstruction();
    assert sc_status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == entry + 16;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 1;
    assert !_ReservationValid;
    assert LoadTranslatedUnsigned(address, 8) ==
        Zeros{PTO_XLEN} + 0x1122334455667788;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[1]].shareability == MemoryShareability_IntraCore;
end;

func TestScopedSCFaultClearsMonitorWithoutStatus()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let aligned = Zeros{PTO_XLEN} + 0x400;
    let fault_address = aligned + 1;
    let old_destination = Zeros{PTO_XLEN} + 0x55;
    Store(aligned, 8, Zeros{PTO_XLEN} + 0x1122334455667788);
    var lr: bits(48) = Zeros{48} + 0x1800000b;
    lr[11:7] = Zeros{5} + 3;
    lr[19:15] = Zeros{5} + 1;
    var sc: bits(48) = Zeros{48} + 0x1800100b;
    sc[11:7] = Zeros{5} + 4;
    sc[19:15] = Zeros{5} + 2;
    sc[24:20] = Zeros{5} + 1;
    WriteTPC(entry);
    WriteGPR(1, aligned);
    WriteGPR(2, Zeros{PTO_XLEN} + 7);
    WriteScopedCarrier(entry, BuildScopedCarrier(lr, '01', '10'));
    WriteScopedCarrier(entry + 8, BuildScopedCarrier(sc, '01', '10'));
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(aligned, 8,
        Zeros{PTO_XLEN} + 0x1122334455667788);
    SetCurrentACR(2);
    WriteContextRegister(1, 0x0f01, Zeros{PTO_XLEN} + 0x900);
    WriteGPR(3, fault_address);
    WriteGPR(4, old_destination);

    let lr_status = ExecuteNextPTOInstruction();
    assert lr_status == PTOInstruction_Executed;
    assert _ReservationValid;
    assert _ReservationShareability == MemoryShareability_InterCore;
    WriteGPR(3, fault_address);
    WriteTPC(entry + 8);
    sc[24:20] = Zeros{5} + 3;
    WriteScopedCarrier(entry + 8, BuildScopedCarrier(sc, '01', '10'));
    let status = ExecuteNextPTOInstruction();
    assert status == PTOInstruction_Rejected;
    assert _LastFault == Fault_DataAlignment;
    assert _FaultAddress == fault_address;
    assert ReadTPC() == Zeros{PTO_XLEN} + 0x900;
    assert _TrapContexts[[1]].tpc == entry + 8;
    assert _MemoryEventCount == 2;
    assert !_ReservationValid;
    assert ReadGPR(4) == old_destination;
    assert LoadTranslatedUnsigned(aligned, 8) ==
        Zeros{PTO_XLEN} + 0x1122334455667788;
    assert _CurrentMemoryShareability == MemoryShareability_Private;
    let recovered = RecoverTrapContext(1);
    assert recovered;
    assert ReadTPC() == entry + 8;
end;

func main() => integer
begin
    TestScopedLRFaultPreservesPriorMonitor();
    TestScopedSCMismatchMissesWithoutAccess();
    TestScopedSCFaultClearsMonitorWithoutStatus();
    return 0;
end;
