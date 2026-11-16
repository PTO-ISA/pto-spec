// PTO-TEST: {"id":"PTO-AVS-ARCH-SCOPED-SCALAR-CROSS-PATH-001","source":"asl/arch/dispatch/top-level.asl","requirements":["PTO-REQ-SCALAR-SHAREABILITY-CARRIER-001","PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001","PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001","PTO-INST-TILE-TLOAD","PTO-INST-TILE-TSTORE","PTO-INST-TILE-MSCATTER"],"kind":"execution","summary":"Actual scoped Scalar instructions communicate with TLOAD/TSTORE and MSCATTER across PEs, and IntraCore AMO ADD completes across two PEs.","pass_condition":"Distinct nonzero values move through actual GM operations with matching IntraCore events; the cross-PE atomic pair observes serialized old values and completes one scoped GM obligation per instruction.","related_sources":["asl/scalar/model/dispatch/top-level.asl","asl/tile/model/memory/load-store.asl","asl/tile/model/memory/gather-scatter.asl","asl/arch/memory-model/gm-obligations.asl"]}

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
func ScopedWordLoadCarrier(scope_code: bits(2)) => bits(64)
begin
    var payload: bits(48) = Zeros{48} + 0x2009;
    payload[11:7] = Zeros{5} + 3;
    payload[19:15] = Zeros{5} + 1;
    return BuildScopedCarrier(payload, '01', scope_code);
end;
func ScopedWordStoreCarrier(scope_code: bits(2)) => bits(64)
begin
    var payload: bits(48) = Zeros{48} + 0x2049;
    payload[19:15] = Zeros{5} + 1;
    payload[31:27] = Zeros{5} + 2;
    return BuildScopedCarrier(payload, '01', scope_code);
end;
func CompleteCoreSyncAtSite(entry: Word)
begin
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _PC = entry + 4;
        _ScalarExecutionBlocked = FALSE;
        SyncCore();
    end;
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 2 do
        let pe = pe_number as MemoryAgentId;
        SelectExecutionContext(0, pe);
        _ScalarExecutionBlocked = FALSE;
        SyncCore();
    end;
    assert _CoreCollectiveHistorySequence[[0]] > 0;
end;
func TestScopedScalarStoreCommunicatesWithActualTLoad()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let address = Zeros{PTO_XLEN} + 0x900;
    let value = Zeros{PTO_XLEN} + 0x71a2b3c4;
    let carrier = ScopedWordStoreCarrier('01');
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    WriteScopedCarrier(entry, carrier);
    Store(address, 4, Zeros{PTO_XLEN});
    SelectExecutionContext(0, 0);
    WriteTPC(entry);
    WriteGPR(1, address);
    WriteGPR(2, value);
    _CurrentProgramOrder = 5;
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(address, 4, Zeros{PTO_XLEN});
    let status = ExecuteNextPTOInstruction();
    assert status == PTOInstruction_Executed;
    let scalar_obligation = _GMObligations[[0]][[0]][[0]];
    assert scalar_obligation.active;
    assert scalar_obligation.request_class == GMRequest_Scalar;
    assert scalar_obligation.shareability == MemoryShareability_IntraCore;
    assert scalar_obligation.encoded_request == carrier;
    assert scalar_obligation.instruction_pc == entry;
    assert scalar_obligation.submission_order == 6;
    assert scalar_obligation.state == GMObligation_Completed;
    CompleteCoreSyncAtSite(entry);
    SelectExecutionContext(0, 1);
    ConfigureTile(0, 128, 1, 1, 1, 1,
        TileDataType_U32, TileLayout_RowMajor);
    _CurrentProgramOrder = 6;
    TLOAD(0, address, Zeros{PTO_XLEN});
    assert ReadTileElement(0, 0, 0) == value;
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[1]].request_class == MemoryRequestClass_Scalar;
    assert _MemoryEvents[[1]].shareability == MemoryShareability_IntraCore;
    assert _MemoryEvents[[1]].agent == 0;
    assert _MemoryEvents[[1]].write_value == value;
    assert _MemoryEvents[[2]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[2]].request_class == MemoryRequestClass_Tile;
    assert _MemoryEvents[[2]].shareability == MemoryShareability_IntraCore;
    assert _MemoryEvents[[2]].agent == 1;
    assert _MemoryEvents[[2]].read_value == value;
    SetMemoryReadFrom(2, 1);
    assert MemoryCollectiveSyncBefore(1, 2);
    assert MemoryEventsShareabilityCompatible(_MemoryEvents[[1]],
        _MemoryEvents[[2]]);
    assert MemoryReadsFromBefore(1, 2);
    assert MemoryScopeConforming();
    assert MemoryExecutionAllowedRC();
end;
func TestActualTStoreCommunicatesWithScopedScalarLoad()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let address = Zeros{PTO_XLEN} + 0x980;
    let value = Zeros{PTO_XLEN} + 0x5c6d7e8f;
    let carrier = ScopedWordLoadCarrier('01');
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    WriteScopedCarrier(entry, carrier);
    Store(address, 4, Zeros{PTO_XLEN});
    SelectExecutionContext(0, 1);
    ConfigureTile(1, 128, 1, 1, 1, 1,
        TileDataType_U32, TileLayout_RowMajor);
    WriteTileElement(1, 0, 0, value);
    _CurrentProgramOrder = 5;
    StartMemoryEventCapture(1);
    - = AddInitialWriteEvent(address, 4, Zeros{PTO_XLEN});
    TSTORE(address, Zeros{PTO_XLEN}, 1);
    CompleteCoreSyncAtSite(entry);
    SelectExecutionContext(0, 0);
    WriteTPC(entry);
    WriteGPR(1, address);
    _CurrentProgramOrder = 6;
    let status = ExecuteNextPTOInstruction();
    assert status == PTOInstruction_Executed;
    assert ReadGPR(3) == value;
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[1]].request_class == MemoryRequestClass_Tile;
    assert _MemoryEvents[[1]].shareability == MemoryShareability_IntraCore;
    assert _MemoryEvents[[1]].agent == 1;
    assert _MemoryEvents[[1]].write_value == value;
    assert _MemoryEvents[[2]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[2]].request_class == MemoryRequestClass_Scalar;
    assert _MemoryEvents[[2]].shareability == MemoryShareability_IntraCore;
    assert _MemoryEvents[[2]].agent == 0;
    assert _MemoryEvents[[2]].read_value == value;
    SetMemoryReadFrom(2, 1);
    assert MemoryCollectiveSyncBefore(1, 2);
    assert MemoryEventsShareabilityCompatible(_MemoryEvents[[1]],
        _MemoryEvents[[2]]);
    assert MemoryReadsFromBefore(1, 2);
    assert MemoryScopeConforming();
    assert MemoryExecutionAllowedRC();
end;
func TestActualMscatterCommunicatesWithScopedScalarLoad()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let base = Zeros{PTO_XLEN} + 0xa00;
    let address = base + 8;
    let value = Zeros{PTO_XLEN} + 0x39a4c5d6;
    let carrier = ScopedWordLoadCarrier('01');
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    WriteScopedCarrier(entry, carrier);
    Store(address, 4, Zeros{PTO_XLEN});
    SelectExecutionContext(0, 1);
    ConfigureTile(0, 128, 1, 1, 1, 1,
        TileDataType_U32, TileLayout_RowMajor);
    ConfigureTile(1, 128, 1, 1, 1, 1,
        TileDataType_S64, TileLayout_RowMajor);
    WriteTileElement(0, 0, 0, value);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 8);
    _CurrentProgramOrder = 5;
    StartMemoryEventCapture(1);
    - = AddInitialWriteEvent(address, 4, Zeros{PTO_XLEN});
    MSCATTER(base, 0, 1);
    CompleteCoreSyncAtSite(entry);
    SelectExecutionContext(0, 0);
    WriteTPC(entry);
    WriteGPR(1, address);
    _CurrentProgramOrder = 6;
    let status = ExecuteNextPTOInstruction();
    assert status == PTOInstruction_Executed;
    assert ReadGPR(3) == value;
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Store;
    assert _MemoryEvents[[1]].request_class ==
        MemoryRequestClass_IndexedGenerated;
    assert _MemoryEvents[[1]].shareability == MemoryShareability_IntraCore;
    assert _MemoryEvents[[1]].agent == 1;
    assert _MemoryEvents[[1]].write_value == value;
    assert _MemoryEvents[[2]].kind == MemoryEvent_Load;
    assert _MemoryEvents[[2]].request_class == MemoryRequestClass_Scalar;
    assert _MemoryEvents[[2]].shareability == MemoryShareability_IntraCore;
    assert _MemoryEvents[[2]].agent == 0;
    assert _MemoryEvents[[2]].read_value == value;
    SetMemoryReadFrom(2, 1);
    assert MemoryCollectiveSyncBefore(1, 2);
    assert MemoryEventsShareabilityCompatible(_MemoryEvents[[1]],
        _MemoryEvents[[2]]);
    assert MemoryReadsFromBefore(1, 2);
    assert MemoryScopeConforming();
    assert MemoryExecutionAllowedRC();
end;
func BuildScopedAtomicAddCarrier() => bits(64)
begin
    var payload: bits(48) = Zeros{48} + 0x400b;
    payload[11:7] = Zeros{5} + 3;
    payload[19:15] = Zeros{5} + 1;
    payload[24:20] = Zeros{5} + 2;
    payload[26] = '1';
    payload[25] = '1';
    return BuildScopedCarrier(payload, '01', '01');
end;
func TestIntraCoreAtomicADDCompletesAcrossPEs()
begin
    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0x100;
    let address = Zeros{PTO_XLEN} + 0xc00;
    let carrier = BuildScopedAtomicAddCarrier();
    let launch = LaunchKernelInvocation(0, entry);
    assert launch == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    WriteScopedCarrier(entry, carrier);
    Store(address, 8, Zeros{PTO_XLEN} + 10);
    StartMemoryEventCapture(0);
    - = AddInitialWriteEvent(address, 8, Zeros{PTO_XLEN} + 10);
    SelectExecutionContext(0, 0);
    WriteTPC(entry);
    WriteGPR(1, address);
    WriteGPR(2, Zeros{PTO_XLEN} + 5);
    _CurrentProgramOrder = 7;
    let first_status = ExecuteNextPTOInstruction();
    assert first_status == PTOInstruction_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 10;
    let first_obligation = _GMObligations[[0]][[0]][[0]];
    assert first_obligation.active && first_obligation.identity == 0 &&
           first_obligation.invocation == invocation;
    assert first_obligation.request_class == GMRequest_Atomic &&
           first_obligation.shareability == MemoryShareability_IntraCore &&
           first_obligation.encoded_request == carrier;
    assert first_obligation.instruction_pc == entry &&
           first_obligation.submission_order == 8 &&
           first_obligation.state == GMObligation_Completed;
    SelectExecutionContext(0, 1);
    WriteTPC(entry);
    WriteGPR(1, address);
    WriteGPR(2, Zeros{PTO_XLEN} + 7);
    _CurrentProgramOrder = 7;
    let second_status = ExecuteNextPTOInstruction();
    assert second_status == PTOInstruction_Executed;
    assert ReadGPR(3) == Zeros{PTO_XLEN} + 15;
    let second_obligation = _GMObligations[[0]][[1]][[0]];
    assert second_obligation.active && second_obligation.identity == 0 &&
           second_obligation.invocation == invocation;
    assert second_obligation.request_class == GMRequest_Atomic &&
           second_obligation.shareability == MemoryShareability_IntraCore &&
           second_obligation.encoded_request == carrier;
    assert second_obligation.instruction_pc == entry &&
           second_obligation.submission_order == 8 &&
           second_obligation.state == GMObligation_Completed;
    StopMemoryEventCapture();
    let final_memory_value = LoadUnsigned(address, 8);
    assert final_memory_value == Zeros{PTO_XLEN} + 22;
    assert _MemoryEventCount == 3;
    assert _MemoryEvents[[1]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[1]].core_identity == 0;
    assert _MemoryEvents[[1]].agent == 0;
    assert _MemoryEvents[[1]].request_class == MemoryRequestClass_Scalar;
    assert _MemoryEvents[[1]].shareability == MemoryShareability_IntraCore;
    assert _MemoryEvents[[1]].read_value == Zeros{PTO_XLEN} + 10;
    assert _MemoryEvents[[1]].write_value == Zeros{PTO_XLEN} + 15;
    assert _MemoryEvents[[2]].kind == MemoryEvent_Atomic;
    assert _MemoryEvents[[2]].core_identity == 0;
    assert _MemoryEvents[[2]].agent == 1;
    assert _MemoryEvents[[2]].request_class == MemoryRequestClass_Scalar;
    assert _MemoryEvents[[2]].shareability == MemoryShareability_IntraCore;
    assert _MemoryEvents[[2]].read_value == Zeros{PTO_XLEN} + 15;
    assert _MemoryEvents[[2]].write_value == Zeros{PTO_XLEN} + 22;
    SetMemoryReadFrom(1, 0);
    SetMemoryReadFrom(2, 1);
    assert MemoryEventsShareabilityCompatible(_MemoryEvents[[1]],
        _MemoryEvents[[2]]);
    assert MemoryScopeConforming();
    assert MemoryExecutionAllowedRC();
    assert _NextGMObligationIdentity[[0]][[0]] == 1;
    assert _NextGMObligationIdentity[[0]][[1]] == 1;
end;

func main() => integer
begin
    TestScopedScalarStoreCommunicatesWithActualTLoad();
    TestActualTStoreCommunicatesWithScopedScalarLoad();
    TestActualMscatterCommunicatesWithScopedScalarLoad();
    TestIntraCoreAtomicADDCompletesAcrossPEs();
    return 0;
end;
