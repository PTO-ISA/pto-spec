// PTO-TEST: {"id":"PTO-AVS-ARCH-SCOPED-SCALAR-AMO-PAIR-EXECUTION-001","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-INSTRUCTION-DISPATCH-001","PTO-REQ-INSTRUCTION-FETCH-001","PTO-REQ-SCALAR-SHAREABILITY-CARRIER-001","PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001","PTO-INST-SCALAR-LD-ADD","PTO-INST-SCALAR-SWAPD","PTO-INST-SCALAR-CASD","PTO-INST-SCALAR-LR-D","PTO-INST-SCALAR-SC-D","PTO-INST-SCALAR-HL-LDIP","PTO-INST-SCALAR-HL-SDIP"],"kind":"execution","summary":"Executes scoped Scalar AMO ADD/SWAP, CAS, LR/SC, and paired loads/stores through the fetched 64-bit carrier.","pass_condition":"One scope reaches each indivisible atomic or every pair component; aq/rl, CAS miss, matching LR/SC, operands, memory, events, and single-instruction retirement remain intact.","related_sources":["asl/scalar/model/dispatch/amo.asl","asl/scalar/model/dispatch/agu.asl","asl/arch/memory-model/atomicity.asl"]}

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

func RunScopedAtomicAdd(scope_code: bits(2),
                        expected_scope: MemoryShareability)
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let target = Zeros{PTO_XLEN} + 0x900;
    var payload: bits(48) = Zeros{48} + 0x400b;
    payload[11:7] = Zeros{5} + 3;
    payload[19:15] = Zeros{5} + 1;
    payload[24:20] = Zeros{5} + 2;
    payload[26] = '1';
    payload[25] = '1';
    WriteTPC(entry);
    WriteGPR(1, target);
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    Store(target, 8, Zeros{PTO_XLEN} + 10);
    WriteScopedCarrier(entry,
        BuildScopedCarrier(payload, '01', scope_code));
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(target, 8, Zeros{PTO_XLEN} + 10);

    let before_cycle = _SystemRegisters.cycle;
    let status = ExecuteNextPTOInstruction();

    assert status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert _SystemRegisters.cycle == before_cycle + 1;
    assert ReadTPC() == entry + 8;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 10;
    assert LoadTranslatedUnsigned(target, 8) == Zeros{PTO_XLEN} + 15;
    assert _MemoryEventCount == 2;
    let atomic = _MemoryEvents[[1]];
    assert atomic.kind == MemoryEvent_Atomic;
    assert atomic.request_class == MemoryRequestClass_Scalar;
    assert atomic.shareability == expected_scope;
    assert atomic.order == MemoryOrder_AcquireRelease;
    assert atomic.write_performed;
    assert MemoryEventsShareabilityCompatible(_MemoryEvents[[0]], atomic);
    assert MemoryExecutionAllowedRC();
end;

func TestScopedAtomicSwapPreservesOldValueAndScope()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let target = Zeros{PTO_XLEN} + 0x980;
    var payload: bits(48) = Zeros{48} + 0x1800600b;
    payload[11:7] = Zeros{5} + 5;
    payload[19:15] = Zeros{5} + 1;
    payload[24:20] = Zeros{5} + 2;
    payload[26] = '1';
    payload[25] = '1';
    WriteTPC(entry);
    WriteGPR(1, target);
    WriteGPR(2, Zeros{PTO_XLEN} + 7);
    Store(target, 8, Zeros{PTO_XLEN} + 10);
    WriteScopedCarrier(entry, BuildScopedCarrier(payload, '01', '10'));
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(target, 8, Zeros{PTO_XLEN} + 10);

    let status = ExecuteNextPTOInstruction();
    assert status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == entry + 8;
    assert ReadGPR(5) == Zeros{PTO_XLEN} + 10;
    assert LoadTranslatedUnsigned(target, 8) == Zeros{PTO_XLEN} + 7;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[1]].shareability == MemoryShareability_InterCore;
    assert _MemoryEvents[[1]].order == MemoryOrder_AcquireRelease;
    assert _MemoryEvents[[1]].write_performed;
end;

func TestScopedInterCoreEncodedAtomicCommunication()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let address = Zeros{PTO_XLEN} + 0xa00;
    let core0 = LaunchKernelInvocation(0, entry);
    let core1 = LaunchKernelInvocation(1, entry);
    assert core0 == KernelLifecycle_Started;
    assert core1 == KernelLifecycle_Started;
    Store(address, 8, Zeros{PTO_XLEN} + 1);
    var payload: bits(48) = Zeros{48} + 0x400b;
    payload[11:7] = Zeros{5} + 3;
    payload[19:15] = Zeros{5} + 1;
    payload[24:20] = Zeros{5} + 2;
    payload[26] = '1';
    payload[25] = '1';
    WriteScopedCarrier(entry, BuildScopedCarrier(payload, '01', '10'));
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(address, 8, Zeros{PTO_XLEN} + 1);

    SelectExecutionContext(0, 0);
    WriteTPC(entry);
    WriteGPR(1, address);
    WriteGPR(2, Zeros{PTO_XLEN} + 2);
    let first = ExecuteNextPTOInstruction();
    assert first == PTOInstruction_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 1;

    SelectExecutionContext(1, 0);
    WriteTPC(entry);
    WriteGPR(1, address);
    WriteGPR(2, Zeros{PTO_XLEN} + 4);
    let second = ExecuteNextPTOInstruction();
    assert second == PTOInstruction_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 3;
    assert LoadTranslatedUnsigned(address, 8) == Zeros{PTO_XLEN} + 7;
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[1]].core_identity == 0;
    assert _MemoryEvents[[2]].core_identity == 1;
    assert _MemoryEvents[[1]].shareability == MemoryShareability_InterCore;
    assert _MemoryEvents[[2]].shareability == MemoryShareability_InterCore;
    assert MemoryEventsShareabilityCompatible(_MemoryEvents[[1]],
        _MemoryEvents[[2]]);
    assert MemoryScopeConforming();
    assert MemoryExecutionAllowedRC();
end;

func TestScopedCASMissKeepsReadAndNoWrite()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let target = Zeros{PTO_XLEN} + 0x900;
    var payload: bits(48) = Zeros{48} + 0x301b;
    payload[11:7] = Zeros{5} + 3;
    payload[19:15] = Zeros{5} + 1;
    payload[24:20] = Zeros{5} + 2;
    payload[31:27] = Zeros{5} + 4;
    payload[26] = '1';
    payload[25] = '1';
    WriteTPC(entry);
    WriteGPR(1, target);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x55);
    WriteGPR(4, Zeros{PTO_XLEN} + 0x66);
    WriteGPR(3, Zeros{PTO_XLEN} + 0xaa);
    Store(target, 8, Zeros{PTO_XLEN} + 0x44);
    WriteScopedCarrier(entry, BuildScopedCarrier(payload, '01', '01'));
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(target, 8, Zeros{PTO_XLEN} + 0x44);
    _ReservationValid = TRUE;
    _ReservationAddress = target;
    _ReservationSize = 8;
    _ReservationShareability = MemoryShareability_IntraCore;

    let status = ExecuteNextPTOInstruction();

    assert status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == entry + 8;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x44;
    assert LoadTranslatedUnsigned(target, 8) == Zeros{PTO_XLEN} + 0x44;
    assert _ReservationValid;
    assert _MemoryEventCount == 2;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Atomic;
    assert !_MemoryEvents[[1]].write_performed;
    assert _MemoryEvents[[1]].shareability ==
        MemoryShareability_IntraCore;
end;

func TestScopedLRSCUsesOneMatchingReservationScope()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let address = Zeros{PTO_XLEN} + 0x900;
    var lr: bits(48) = Zeros{48} + 0x1800000b;
    lr[11:7] = Zeros{5} + 3;
    lr[19:15] = Zeros{5} + 1;
    var sc: bits(48) = Zeros{48} + 0x1800100b;
    sc[11:7] = Zeros{5} + 4;
    sc[19:15] = Zeros{5} + 2;
    sc[24:20] = Zeros{5} + 1;
    WriteTPC(entry);
    WriteGPR(1, address);
    WriteGPR(2, Zeros{PTO_XLEN} + 0x778899aabbccddee);
    Store(address, 8, Zeros{PTO_XLEN} + 0x1122334455667788);
    WriteScopedCarrier(entry, BuildScopedCarrier(lr, '01', '01'));
    WriteScopedCarrier(entry + 8, BuildScopedCarrier(sc, '01', '01'));
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(address, 8,
        Zeros{PTO_XLEN} + 0x1122334455667788);

    let lr_status = ExecuteNextPTOInstruction();
    assert lr_status == PTOInstruction_Executed;
    assert ReadTPC() == entry + 8;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x1122334455667788;
    assert _ReservationValid;
    assert _ReservationShareability == MemoryShareability_IntraCore;

    let sc_status = ExecuteNextPTOInstruction();
    assert sc_status == PTOInstruction_Executed;
    assert _LastFault == Fault_None;
    assert ReadTPC() == entry + 16;
    assert ReadGPR(4) == Zeros{PTO_XLEN};
    assert LoadTranslatedUnsigned(address, 8) ==
        Zeros{PTO_XLEN} + 0x778899aabbccddee;
    assert !_ReservationValid;
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[2]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[1]].shareability ==
        MemoryShareability_IntraCore;
    assert _MemoryEvents[[2]].shareability ==
        MemoryShareability_IntraCore;
end;

func TestLoadAndStorePairComponentsInheritCarrierScope()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let base = Zeros{PTO_XLEN} + 0x900;
    var load_pair: bits(48) = Zeros{48} + 0x3019001e;
    load_pair[27:23] = Zeros{5} + 3;
    load_pair[15:11] = Zeros{5} + 4;
    load_pair[35:31] = Zeros{5} + 1;
    WriteTPC(entry);
    WriteGPR(1, base);
    Store(base, 8, Zeros{PTO_XLEN} + 0x11);
    Store(base + 8, 8, Zeros{PTO_XLEN} + 0x22);
    WriteScopedCarrier(entry,
        BuildScopedCarrier(load_pair, '10', '10'));
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(base, 8, Zeros{PTO_XLEN} + 0x11);
    - = AddInitialWriteEvent(base + 8, 8, Zeros{PTO_XLEN} + 0x22);
    let load_status = ExecuteNextPTOInstruction();
    assert load_status == PTOInstruction_Executed && ReadTPC() == entry + 8;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 0x11;
    assert ReadGPR(4) == Zeros{PTO_XLEN} + 0x22;
    assert _MemoryEventCount == 4;
    assert _MemoryEvents[[2]].shareability ==
        MemoryShareability_InterCore;
    assert _MemoryEvents[[3]].shareability ==
        MemoryShareability_InterCore;

    ResetProfileState();
    let store_entry = Zeros{PTO_XLEN} + 0x180;
    var store_pair: bits(48) = Zeros{48} + 0x3059001e;
    store_pair[35:31] = Zeros{5} + 2;
    store_pair[10:6] = Zeros{5} + 3;
    store_pair[40:36] = Zeros{5} + 1;
    WriteTPC(store_entry);
    WriteGPR(1, base);
    WriteGPR(2, Zeros{PTO_XLEN} + 0xaabbccddeeff0011);
    WriteGPR(3, Zeros{PTO_XLEN} + 0x1122334455667788);
    WriteScopedCarrier(store_entry,
        BuildScopedCarrier(store_pair, '10', '00'));
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(base, 8, Zeros{PTO_XLEN});
    - = AddInitialWriteEvent(base + 8, 8, Zeros{PTO_XLEN});
    let store_status = ExecuteNextPTOInstruction();
    assert store_status == PTOInstruction_Executed && ReadTPC() == store_entry + 8;
    assert LoadTranslatedUnsigned(base, 8) ==
        Zeros{PTO_XLEN} + 0xaabbccddeeff0011;
    assert LoadTranslatedUnsigned(base + 8, 8) ==
        Zeros{PTO_XLEN} + 0x1122334455667788;
    assert _MemoryEventCount == 4;
    assert _MemoryEvents[[2]].shareability ==
        MemoryShareability_Private;
    assert _MemoryEvents[[3]].shareability ==
        MemoryShareability_Private;
end;

func main() => integer
begin
    RunScopedAtomicAdd('00', MemoryShareability_Private);
    RunScopedAtomicAdd('01', MemoryShareability_IntraCore);
    RunScopedAtomicAdd('10', MemoryShareability_InterCore);
    TestScopedAtomicSwapPreservesOldValueAndScope();
    TestScopedInterCoreEncodedAtomicCommunication();
    TestScopedCASMissKeepsReadAndNoWrite();
    TestScopedLRSCUsesOneMatchingReservationScope();
    TestLoadAndStorePairComponentsInheritCarrierScope();
    return 0;
end;
