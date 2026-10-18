// PTO-TEST: {"id":"PTO-AVS-BLOCK-LOCAL-GENERATION-RECOVERY-ISOLATION-001","source":"asl/block/model/operands/local-generation-squash.asl","requirements":["PTO-B-ASSEMBLE-SPECULATION-001","PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001","PTO-ARCH-CORE-SYNCHRONIZATION-001","PTO-ARCH-KERNEL-LIFECYCLE-001"],"kind":"state-transition","summary":"interrupt return preserves peer readiness and a scoped squash retains the later Core writer","pass_condition":"a parked PE returns at the same barrier PC without rewinding peer Local generation publication, the global writer-domain allocator assigns distinct PE domains, and squash of the interrupted PE removes only its writer while retaining the peer writer and readiness","related_sources":["asl/block/model/operands/portable-carriers.asl","asl/arch/state/trap-context.asl","asl/arch/state/core-synchronization.asl","asl/block/model/operands/local-generation.asl"]}
func TestInterruptedPERecoveryPreservesPeerWriter()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x700;
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    _PC = entry + 4;
    _BPC = entry;
    _CurrentProgramOrder = 4;
    _PEProgramOrder[[0]][[0]] = 4;
    _ReservationValid = TRUE;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert _ScalarExecutionBlocked;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1000';
    assert _ReservationValid;
    let parked_pc = ReadTPC();

    RaiseInterrupt(0 as InterruptID, Zeros{24} + 9);
    assert _ACRTrapAsynchronous[[0]];
    assert _TrapContexts[[0]].valid;
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    WriteGPR(2, Zeros{PTO_XLEN} + 0xa00);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0xa00, Zeros{8} + 0x34);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0xa01, Zeros{8} + 0x12);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0xa02, Zeros{8} + 0x78);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0xa03, Zeros{8} + 0x56);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0xa04, Zeros{8} + 0xbc);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0xa05, Zeros{8} + 0x9a);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0xa06, Zeros{8} + 0xf0);
    WriteMemoryByte(Zeros{PTO_XLEN} + 0xa07, Zeros{8} + 0xde);
    var handler_lr: bits(48) = ZeroExtend{48}(Zeros{32} + 0x1800000b);
    handler_lr[11:7] = Zeros{5} + 5;
    handler_lr[19:15] = Zeros{5} + 2;
    handler_lr[24:20] = Ones{5};
    let handler_lr_status = ExecuteScalarInstruction(handler_lr, 32);
    assert handler_lr_status == ScalarExecution_Executed;
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Handler;
    assert _ReservationValid;
    assert _ReservationAddress == Zeros{PTO_XLEN} + 0xa00;
    let handler_event = AddStoreEvent(0, Zeros{PTO_XLEN} + 0xa00, 8,
        Zeros{PTO_XLEN} + 3, MemoryOrder_Relaxed, 1);
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert _ScalarExecutionBlocked;
    assert _ReservationValid;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1000';

    SelectExecutionContext(0, 1);
    _LocalGenerations[[0]].open = TRUE;
    _LocalGenerations[[0]].generation_identity_valid = TRUE;
    _LocalGenerations[[0]].generation_instance =
        Zeros{PTO_XLEN} + 0x77;
    _LocalGenerations[[0]].per_pe_ready_cells[[1]][7] = '1';
    _LocalGenerations[[0]].per_pe_published[[1]] = TRUE;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1000';
    assert _LocalGenerations[[0]].generation_identity_valid;
    assert _LocalGenerations[[0]].generation_instance ==
        Zeros{PTO_XLEN} + 0x77;
    assert _LocalGenerations[[0]].per_pe_ready_cells[[1]][7] == '1';
    assert _LocalGenerations[[0]].per_pe_published[[1]];

    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _PC = parked_pc;
        _CurrentProgramOrder = 4;
        _ReservationValid = TRUE;
        _ScalarExecutionBlocked = FALSE;
        SyncCore();
        if pe_number < PTO_MODEL_MEMORY_AGENTS - 1 then
            assert !_CoreSyncRecords[[0]][[0]].released;
            assert _ReservationValid;
        end;
    end;
    assert _CoreSyncRecords[[0]][[0]].released;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        assert !_ReservationValid;
    end;
    SelectExecutionContext(0, 0);
    assert !_ReservationValid;

    let recovered = RecoverTrapContext(0);
    assert recovered;
    assert ReadTPC() == parked_pc;
    assert !_ReservationValid;
    assert _CurrentMemoryOrigin == MemoryEventOrigin_Kernel;
    assert _CoreSyncRecords[[0]][[0]].arrived == '1111';
    assert _CoreSyncRecords[[0]][[0]].released;
    assert _MemoryEvents[[handler_event]].active;
    assert _MemoryEvents[[handler_event]].origin == MemoryEventOrigin_Handler;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    assert _PEBarrierNextGeneration[[0]][[0]] == 1;
    assert _PEReleaseValid[[0]][3] == '0';
    assert _CoreSyncRecords[[0]][[0]].consumed[3] == '1';
    for pe_number = 1 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        assert !_ReservationValid;
    end;

    SelectExecutionContext(0, 2);
    _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
    _ScalarExecutionBlocked = FALSE;
    SyncCore();
    _CurrentProgramOrder = 5;
    let later_kernel_event = AddStoreEvent(2,
        Zeros{PTO_XLEN} + 0xa08, 8, Zeros{PTO_XLEN} + 4,
        MemoryOrder_Relaxed, 1);
    assert _MemoryEvents[[handler_event]].origin ==
        MemoryEventOrigin_Handler;
    assert !MemoryCollectiveSyncBefore(handler_event, later_kernel_event);
    SelectExecutionContext(0, 1);
    _ScalarExecutionBlocked = FALSE;
    SyncCore();

    SelectExecutionContext(0, 0);
    BeginBundleAt(entry, BundleKind_TileElement,
        BundleTransfer_Fallthrough, entry + 8, entry + 4,
        Zeros{PTO_XLEN}, FALSE);
    let interrupted_domain = _BundleExecutionDomainToken;
    SelectExecutionContext(0, 1);
    BeginBundleAt(entry, BundleKind_TileElement,
        BundleTransfer_Fallthrough, entry + 8, entry + 4,
        Zeros{PTO_XLEN}, FALSE);
    let peer_domain = _BundleExecutionDomainToken;
    assert interrupted_domain != peer_domain;
    assert _NextBundleExecutionDomainToken > peer_domain;

    _LocalGenerations[[0]].writer_count = 2;
    _LocalGenerations[[0]].writers[[0]].valid = TRUE;
    _LocalGenerations[[0]].writers[[0]].offset_cells = 0;
    _LocalGenerations[[0]].writers[[0]].cell_count = 1;
    _LocalGenerations[[0]].writers[[0]].ready = TRUE;
    _LocalGenerations[[0]].writers[[0]].pe_mask = Zeros{4};
    _LocalGenerations[[0]].writers[[0]].pe_mask[
        PTOPEMaskBitOfPEIdentity(0)] = '1';
    _LocalGenerations[[0]].writers[[0]].identity.instruction_instance =
        Zeros{PTO_XLEN} + 0x101;
    _LocalGenerations[[0]].writers[[0]].identity.execution_domain_token =
        interrupted_domain;
    _LocalGenerations[[0]].writers[[1]].valid = TRUE;
    _LocalGenerations[[0]].writers[[1]].offset_cells = 1;
    _LocalGenerations[[0]].writers[[1]].cell_count = 1;
    _LocalGenerations[[0]].writers[[1]].ready = TRUE;
    _LocalGenerations[[0]].writers[[1]].pe_mask = Zeros{4};
    _LocalGenerations[[0]].writers[[1]].pe_mask[
        PTOPEMaskBitOfPEIdentity(1)] = '1';
    _LocalGenerations[[0]].writers[[1]].identity.instruction_instance =
        Zeros{PTO_XLEN} + 0x202;
    _LocalGenerations[[0]].writers[[1]].identity.execution_domain_token =
        peer_domain;
    SelectExecutionContext(0, 0);
    EnterBundleExecutionDomainSquashEvent(interrupted_domain);
    assert _LocalGenerations[[0]].writer_count == 1;
    assert _LocalGenerations[[0]].writers[[0]].valid;
    assert _LocalGenerations[[0]].writers[[0]].identity.instruction_instance ==
        Zeros{PTO_XLEN} + 0x202;
    assert _LocalGenerations[[0]].writers[[0]].identity.execution_domain_token ==
        peer_domain;
    assert _LocalGenerations[[0]].ready_cells[1] == '1';
    assert _LocalGenerations[[0]].per_pe_ready_cells[[1]][1] == '1';
    assert _LocalGenerations[[0]].per_pe_published[[1]];
    assert _LocalGenerations[[0]].generation_instance ==
        Zeros{PTO_XLEN} + 0x77;
end;

func main() => integer
begin
    TestInterruptedPERecoveryPreservesPeerWriter();
    return 0;
end;
