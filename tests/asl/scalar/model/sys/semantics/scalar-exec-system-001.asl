// Migrated from the pre-four-surface executable test suite.
// PTO-TEST: {"id":"PTO-AVS-SCALAR-TESTSCALARSYSTEM-EXECUTION-001","source":"asl/scalar/model/sys/semantics.asl","requirements":[],"kind":"execution","summary":"Covers Scalar System.","pass_condition":"TestScalarSystem completes without assertion failure","related_sources":[]}
func TestScalarSystem()
begin
    ClearFault();
    WriteSystemRegister(SystemRegister_THREAD_PTR, Zeros{PTO_XLEN} + 123);
    let tp = ReadSystemRegister(SystemRegister_THREAD_PTR);
    assert tp == Zeros{PTO_XLEN} + 123;
    WriteSystemRegister(SystemRegister_GLOBAL_PTR, Zeros{PTO_XLEN} + 321);
    let global_ptr = ReadSystemRegister(SystemRegister_GLOBAL_PTR);
    assert global_ptr == Zeros{PTO_XLEN} + 321;
    WriteSystemRegister(SystemRegister_CORE_STATE, Zeros{PTO_XLEN} + 3);
    assert CurrentACR() == 3;
    SetCurrentACR(0);
    let thread_id = ReadSystemRegister(SystemRegister_THREAD_ID);
    let tile_capacity = ReadSystemRegister(SystemRegister_TILE_CAPACITY);
    let block_id = ReadSystemRegister(SystemRegister_BLOCKID);
    assert thread_id == Zeros{PTO_XLEN};
    assert tile_capacity ==
        Zeros{PTO_XLEN} + PTO_MODEL_MAX_TILE_CAPACITY_BYTES;
    assert block_id == Zeros{PTO_XLEN};

    WriteSystemRegister(SystemRegister_VENDOR, Ones{PTO_XLEN});
    assert _LastFault == Fault_IllegalInstruction;

    FenceData('0010', '0001');
    assert _LastFencePredecessor == '0010';
    assert _LastFenceSuccessor == '0001';

    ClearFault();
    let old_tp = SwapSystemRegister(SystemRegister_THREAD_PTR,
        Zeros{PTO_XLEN} + 456);
    assert old_tp == Zeros{PTO_XLEN} + 123;
    let new_tp = ReadSystemRegister(SystemRegister_THREAD_PTR);
    assert new_tp == Zeros{PTO_XLEN} + 456;
    let before_tlb = _TLBEpoch;
    ExecuteMaintenance(Maintenance_TLB_IV, Zeros{PTO_XLEN} + 0x1000);
    assert _TLBEpoch == before_tlb + 1;
    assert _LastMaintenanceOperation == Maintenance_TLB_IV;
    assert _LastMaintenanceOperand == Zeros{PTO_XLEN} + 0x1000;
    ExecuteMaintenance(Maintenance_TLB_IV, Zeros{PTO_XLEN} + 0x0001000000000000);
    assert _LastFault == Fault_DataPage;
    assert _TLBEpoch == before_tlb + 1;
    assert _LastMaintenanceOperand == Zeros{PTO_XLEN} + 0x1000;
    ClearFault();
    SetCurrentACR(2);
    ExecuteMaintenance(Maintenance_TLB_IALL, Zeros{PTO_XLEN});
    assert _LastFault == Fault_IllegalInstruction;
    assert _TLBEpoch == before_tlb + 1;
    SetCurrentACR(0);

    // A rejected swap preflights both access classes. In particular, reading
    // a timer-backed RO register must not refresh pending state before the
    // write fault is raised.
    _SystemRegisters.cycle = Zeros{PTO_XLEN} + 10;
    WriteSystemRegisterAddress(Zeros{24} + 0x0f21,
        Zeros{PTO_XLEN} + 9);
    _ExtendedSystemRegisters[[0x0f08]] = Zeros{PTO_XLEN};
    _ExtendedSystemRegisters[[0x0f09]] = Zeros{PTO_XLEN};
    ClearFault();
    let rejected_pending_swap = SwapSystemRegisterAddress(
        Zeros{24} + 0x0f08, Ones{PTO_XLEN});
    assert rejected_pending_swap == Zeros{PTO_XLEN};
    assert _LastFault == Fault_IllegalInstruction;
    assert _ExtendedSystemRegisters[[0x0f08]] == Zeros{PTO_XLEN};
    assert _ExtendedSystemRegisters[[0x0f09]] == Zeros{PTO_XLEN};
    ClearFault();
    ArchitectureAssert(Zeros{PTO_XLEN});
    assert _LastFault == Fault_Assert;
    ClearFault();
    let before_request = _ArchitectureRequestEpoch;
    ArchitectureEnterRequest('0001');
    assert _ArchitectureRequestEpoch == before_request + 1;
    ExecuteControlRequest(ExecutionControl_WaitEvent, Zeros{PTO_XLEN} + 17);
    assert _LastControlRequest == ExecutionControl_WaitEvent;
    assert _ControlRequestOperand == Zeros{PTO_XLEN} + 17;
    WriteTPC(Zeros{PTO_XLEN} + 0x100);
    BeginBundleAt(
        ReadTPC(),
        BundleKind_Standard,
        BundleTransfer_Direct,
        Zeros{PTO_XLEN} + 0x200,
        Zeros{PTO_XLEN} + 0x102,
        Zeros{PTO_XLEN} + 0x102,
        FALSE);
    SetCommitTarget(Zeros{PTO_XLEN} + 0x800);
    assert _BARG.bpcn == Zeros{PTO_XLEN} + 0x800;
    ResetBundleControlState();

    ClearFault();
    let translation_base = Zeros{24} + 0x1f10;
    WriteSystemRegisterAddress(translation_base, Zeros{PTO_XLEN} + 0x1234);
    let translation_base_value = ReadSystemRegisterAddress(translation_base);
    assert translation_base_value == Zeros{PTO_XLEN} + 0x1234;

    SetFault(Fault_DataPage, Zeros{PTO_XLEN} + 0x4000);
    let trap_status = ReadSystemRegisterAddress(Zeros{24} + 0x0f02);
    assert trap_status[62] == '1';
    assert trap_status[5:0] == Zeros{6} + 35;
    let trap_argument = ReadSystemRegisterAddress(Zeros{24} + 0x0f03);
    assert trap_argument == Zeros{PTO_XLEN} + 0x4000;

    SetCurrentACR(2);
    SetFault(Fault_Assert, Zeros{PTO_XLEN} + 0x2222);
    assert CurrentACR() == 1;
    SetCurrentACR(0);
    let acr1_trap_status = ReadSystemRegisterAddress(Zeros{24} + 0x1f02);
    let acr0_trap_status = ReadSystemRegisterAddress(Zeros{24} + 0x0f02);
    assert acr1_trap_status[5:0] == Zeros{6} + 52;
    assert acr0_trap_status[5:0] == Zeros{6} + 35;
    let acr1_trap_argument = ReadSystemRegisterAddress(Zeros{24} + 0x1f03);
    assert acr1_trap_argument == Zeros{PTO_XLEN} + 0x2222;

    ClearFault();
    WriteSystemRegisterAddress(Zeros{24} + 0x0010, Ones{PTO_XLEN});
    assert _LastFault == Fault_IllegalInstruction;
    ClearFault();
    let unknown_value = ReadSystemRegisterAddress(Zeros{24} + 0x100000);
    assert unknown_value == Zeros{PTO_XLEN};
    assert _LastFault == Fault_IllegalInstruction;

    ClearFault();
    RaiseInterrupt(7, Zeros{24} + 9);
    assert PackTrapStatus(CurrentACR())[63] == '1';
    assert PackTrapStatus(CurrentACR())[5:0] == Zeros{6} + 44;
    WriteSystemRegisterAddress(Zeros{24} + 0x0f0a, Zeros{PTO_XLEN} + 7);
    assert PackTrapStatus(CurrentACR())[63] == '0';

    ClearFault();
    WriteGPR(5, Zeros{PTO_XLEN} + 0x55);
    ExecuteSystemRegisterSet(5, Zeros{24} + 0x0000);
    ExecuteSystemRegisterGet(6, Zeros{24} + 0x0000);
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x55;

    ClearFault();
    WriteGPR(5, Zeros{PTO_XLEN} + 0x66);
    ExecuteSystemRegisterSwap(6, 5, Zeros{24} + 0x0000);
    assert ReadGPR(6) == Zeros{PTO_XLEN} + 0x55;
    let swapped_tp = ReadSystemRegister(SystemRegister_THREAD_PTR);
    assert swapped_tp == Zeros{PTO_XLEN} + 0x66;

    WriteSystemRegister(SystemRegister_THREAD_PTR, Zeros{PTO_XLEN} + 0x77);
    ExecuteCompressedSystemRegisterGet(Zeros{24} + 0x0000);
    assert ReadScalarRegisterOperand(24) == Zeros{PTO_XLEN} + 0x77;

    let before_instruction_fence = _InstructionCacheEpoch;
    FenceInstruction();
    assert _InstructionCacheEpoch == before_instruction_fence + 1;

    let before_close = _ArchitectureRequestEpoch;
    ArchitectureCloseRequest('0011');
    assert _ArchitectureRequestEpoch == before_close;
    assert _LastFault == Fault_IllegalInstruction;

    WritePC(Zeros{PTO_XLEN} + 0x400);
    ClearFault();
    SoftwareBreakpoint('01001');
    assert _LastFault == Fault_SoftwareBreakpoint;
    assert _FaultAddress == Zeros{PTO_XLEN} + 0x400;
    assert _BreakpointTag == '01001';
end;
func main() => integer
begin
    ResetProfileState();
    TestScalarSystem();
    return 0;
end;
