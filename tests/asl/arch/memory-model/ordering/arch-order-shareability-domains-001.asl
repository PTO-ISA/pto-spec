// PTO-TEST: {"id":"PTO-AVS-ARCH-ORDER-SHAREABILITY-DOMAINS-001","source":"asl/arch/memory-model/ordering.asl","requirements":["PTO-ARCH-MEMORY-MODEL-SHAREABILITY-001","PTO-ARCH-MEMORY-MODEL-CONFLICT-001","PTO-ARCH-MEMORY-MODEL-VISIBILITY-001","PTO-ARCH-MEMORY-MODEL-ATOMIC-CROSS-AGENT-001","PTO-ARCH-MEMORY-MODEL-MIXED-SIZE-001"],"kind":"ordering","summary":"Checks strict request-domain compatibility, neutral initialization, excluded-event isolation, preserved program order, and byte-footprint boundaries.","pass_condition":"Only matching domain keys communicate; legacy events do not mask mismatches between covered accesses; initial values remain neutral; disjoint and mixed-size footprints retain their existing rules.","related_sources":["asl/arch/memory-model/memory-events.asl","asl/arch/memory-model/atomicity.asl"]}

func StartShareabilityEvents()
begin
    ResetProfileState();
    StartMemoryEventCapture(0);
    _CurrentMemoryRequestClass = MemoryRequestClass_Scalar;
end;

func RecordScalarStore(core: PTOModelCoreIdentity, pe: MemoryAgentId,
                       scope: MemoryShareability, address: Word,
                       value: Word, size_bytes: integer {1,2,4,8})
begin
    _CurrentModelCore = core;
    _CurrentMemoryAgent = pe;
    _CurrentMemoryShareability = scope;
    _CurrentMemoryRequestClass = MemoryRequestClass_Scalar;
    RecordStoreEvent(address, size_bytes, value, MemoryOrder_Relaxed);
end;

func RecordScalarLoad(core: PTOModelCoreIdentity, pe: MemoryAgentId,
                      scope: MemoryShareability, address: Word,
                      value: Word, size_bytes: integer {1,2,4,8})
begin
    _CurrentModelCore = core;
    _CurrentMemoryAgent = pe;
    _CurrentMemoryShareability = scope;
    _CurrentMemoryRequestClass = MemoryRequestClass_Scalar;
    RecordLoadEvent(address, size_bytes, value, MemoryOrder_Relaxed);
end;

func TestScalarIntraCoreCommunicatesWithTileAndIndexedRequests()
begin
    StartShareabilityEvents();
    let address = Zeros{PTO_XLEN} + 0x100;
    let value = Zeros{PTO_XLEN} + 0x11;
    - = AddInitialWriteEvent(address, 8, Zeros{PTO_XLEN});
    RecordScalarStore(0, 0, MemoryShareability_IntraCore,
        address, value, 8);
    _CurrentModelCore = 0;
    _CurrentMemoryAgent = 1;
    RecordTileLoadEvent(address, 8, value, MemoryOrder_Relaxed);
    assert _MemoryEvents[[2]].request_class == MemoryRequestClass_Tile;
    assert _MemoryEvents[[2]].shareability == MemoryShareability_IntraCore;
    assert MemoryEventsShareabilityCompatible(
        _MemoryEvents[[1]], _MemoryEvents[[2]]);
    assert MemoryReadsFromBefore(1, 2);
    assert MemoryScopeConforming();
    assert MemoryExecutionAllowedRC();

    StartShareabilityEvents();
    - = AddInitialWriteEvent(address, 8, Zeros{PTO_XLEN});
    RecordScalarStore(1, 0, MemoryShareability_IntraCore,
        address, value, 8);
    _CurrentModelCore = 1;
    _CurrentMemoryAgent = 2;
    RecordIndexedLoadEvent(address, 8, value, MemoryOrder_Relaxed);
    assert _MemoryEvents[[2]].request_class ==
        MemoryRequestClass_IndexedGenerated;
    assert MemoryEventsShareabilityCompatible(
        _MemoryEvents[[1]], _MemoryEvents[[2]]);
    assert MemoryReadsFromBefore(1, 2);
    assert MemoryScopeConforming();
    assert MemoryExecutionAllowedRC();

    StartShareabilityEvents();
    - = AddInitialWriteEvent(address, 8, Zeros{PTO_XLEN});
    _CurrentModelCore = 0;
    _CurrentMemoryAgent = 1;
    RecordTileStoreEvent(address, 8, value, MemoryOrder_Relaxed);
    RecordScalarLoad(0, 0, MemoryShareability_IntraCore,
        address, value, 8);
    assert _MemoryEvents[[1]].request_class == MemoryRequestClass_Tile;
    assert _MemoryEvents[[2]].request_class == MemoryRequestClass_Scalar;
    SetMemoryReadFrom(2, 1);
    assert MemoryEventsShareabilityCompatible(
        _MemoryEvents[[1]], _MemoryEvents[[2]]);
    assert MemoryReadsFromBefore(1, 2);
    assert MemoryScopeConforming();
    assert MemoryExecutionAllowedRC();
end;

func TestPrivateAndIntraCoreSamePEMismatchIsNotPortable()
begin
    StartShareabilityEvents();
    let address = Zeros{PTO_XLEN} + 0x180;
    let value = Zeros{PTO_XLEN} + 0x11;
    RecordScalarStore(0, 0, MemoryShareability_Private,
        address, value, 8);
    RecordLegacyExcludedStoreEvent(address, 8,
        Zeros{PTO_XLEN} + 0x22, MemoryOrder_Relaxed);
    _CurrentModelCore = 0;
    _CurrentMemoryAgent = 0;
    RecordTileLoadEvent(address, 8, value, MemoryOrder_Relaxed);
    assert !MemoryEventsShareabilityCompatible(
        _MemoryEvents[[0]], _MemoryEvents[[2]]);
    assert !MemoryScopeConforming();

    StartShareabilityEvents();
    RecordScalarStore(0, 0, MemoryShareability_Private,
        address, value, 8);
    RecordScalarLoad(0, 0, MemoryShareability_IntraCore,
        address, value, 8);
    assert !MemoryEventsShareabilityCompatible(
        _MemoryEvents[[0]], _MemoryEvents[[1]]);
    assert !MemoryScopeConforming();
end;

func TestEqualScopeStillRequiresMatchingIdentity()
begin
    let address = Zeros{PTO_XLEN} + 0x200;
    let value = Zeros{PTO_XLEN} + 0x33;
    StartShareabilityEvents();
    RecordScalarStore(0, 0, MemoryShareability_Private,
        address, value, 8);
    RecordScalarLoad(0, 1, MemoryShareability_Private,
        address, value, 8);
    assert !MemoryScopeConforming();

    StartShareabilityEvents();
    RecordScalarStore(0, 0, MemoryShareability_IntraCore,
        address, value, 8);
    RecordScalarLoad(1, 0, MemoryShareability_IntraCore,
        address, value, 8);
    assert !MemoryScopeConforming();
end;

func TestReadReadScopeDifferenceIsNotConformanceViolation()
begin
    StartShareabilityEvents();
    let address = Zeros{PTO_XLEN} + 0x240;
    let value = Zeros{PTO_XLEN} + 0x44;
    - = AddInitialWriteEvent(address, 8, value);
    RecordScalarLoad(0, 0, MemoryShareability_Private,
        address, value, 8);
    RecordScalarLoad(0, 0, MemoryShareability_IntraCore,
        address, value, 8);
    assert !MemoryEventsShareabilityCompatible(
        _MemoryEvents[[1]], _MemoryEvents[[2]]);
    assert MemoryScopeConforming();
    assert MemoryCandidateExecutionValid();
    assert MemoryExecutionAllowedRC();
end;

func TestInterCoreAtomicOrderAndCrossScopeRejection()
begin
    StartShareabilityEvents();
    let address = Zeros{PTO_XLEN} + 0x280;
    - = AddInitialWriteEvent(address, 8, Zeros{PTO_XLEN} + 1);
    _CurrentModelCore = 0;
    _CurrentMemoryAgent = 0;
    _CurrentMemoryShareability = MemoryShareability_InterCore;
    _CurrentMemoryRequestClass = MemoryRequestClass_Scalar;
    RecordAtomicEvent(address, 8, Zeros{PTO_XLEN} + 1,
        Zeros{PTO_XLEN} + 2, MemoryOrder_AcquireRelease, TRUE);
    _CurrentModelCore = 1;
    _CurrentMemoryAgent = 2;
    RecordAtomicEvent(address, 8, Zeros{PTO_XLEN} + 2,
        Zeros{PTO_XLEN} + 3, MemoryOrder_AcquireRelease, TRUE);
    assert _MemoryEvents[[1]].shareability == MemoryShareability_InterCore;
    assert _MemoryEvents[[2]].shareability == MemoryShareability_InterCore;
    assert MemoryEventsShareabilityCompatible(
        _MemoryEvents[[1]], _MemoryEvents[[2]]);
    assert MemoryScopeConforming();
    assert MemoryExecutionAllowedRC();

    StartShareabilityEvents();
    RecordScalarStore(0, 0, MemoryShareability_IntraCore,
        address, Zeros{PTO_XLEN} + 1, 8);
    RecordScalarLoad(0, 1, MemoryShareability_InterCore,
        address, Zeros{PTO_XLEN} + 1, 8);
    assert !MemoryScopeConforming();
end;

func AssertNeutralInitialRead(scope: MemoryShareability)
begin
    StartShareabilityEvents();
    let address = Zeros{PTO_XLEN} + 0x300;
    let value = Zeros{PTO_XLEN} + 0x55;
    - = AddInitialWriteEvent(address, 8, value);
    _CurrentMemoryShareability = scope;
    RecordLoadEvent(address, 8, value, MemoryOrder_Relaxed);
    let initial = _MemoryEvents[[0]];
    let load = _MemoryEvents[[1]];
    assert load.read_from == (0 as MemoryEventIndex);
    assert MemoryEventsShareabilityCompatible(initial, load);
    assert MemoryReadsFromBefore(0, 1);
    assert MemoryExecutionAllowedRC();
end;

func TestNeutralInitialValuesForNonPrivateLoads()
begin
    AssertNeutralInitialRead(MemoryShareability_IntraCore);
    AssertNeutralInitialRead(MemoryShareability_InterCore);
end;

func TestDisjointBytesAndMixedSizeRemainDistinct()
begin
    StartShareabilityEvents();
    let address = Zeros{PTO_XLEN} + 0x380;
    RecordScalarStore(0, 0, MemoryShareability_Private,
        address, Zeros{PTO_XLEN} + 0xaa, 1);
    _CurrentModelCore = 0;
    _CurrentMemoryAgent = 1;
    RecordTileStoreEvent(address + 1, 1,
        Zeros{PTO_XLEN} + 0xbb, MemoryOrder_Relaxed);
    assert !MemoryEventRangesOverlap(
        _MemoryEvents[[0]], _MemoryEvents[[1]]);
    assert MemoryScopeConforming();

    StartShareabilityEvents();
    RecordScalarStore(0, 0, MemoryShareability_IntraCore,
        address, Zeros{PTO_XLEN} + 0x1122334455667788, 8);
    RecordScalarLoad(0, 1, MemoryShareability_IntraCore,
        address + 4, Zeros{PTO_XLEN} + 0x55667788, 4);
    assert MemoryEventPartialOverlap(
        _MemoryEvents[[0]], _MemoryEvents[[1]]);
    assert !MemoryCandidateExecutionValid();
end;

func TestDifferentLocationStoreStoreOrderSurvivesScopeDifference()
begin
    StartShareabilityEvents();
    let first_address = Zeros{PTO_XLEN} + 0x400;
    let second_address = Zeros{PTO_XLEN} + 0x408;
    RecordScalarStore(0, 0, MemoryShareability_Private,
        first_address, Zeros{PTO_XLEN} + 1, 8);
    RecordScalarStore(0, 0, MemoryShareability_InterCore,
        second_address, Zeros{PTO_XLEN} + 2, 8);
    assert MemoryPreservedProgramOrderBefore(0, 1);
    assert !MemoryProgramOrderLocationBefore(0, 1);
end;

func main() => integer
begin
    TestScalarIntraCoreCommunicatesWithTileAndIndexedRequests();
    TestPrivateAndIntraCoreSamePEMismatchIsNotPortable();
    TestEqualScopeStillRequiresMatchingIdentity();
    TestReadReadScopeDifferenceIsNotConformanceViolation();
    TestInterCoreAtomicOrderAndCrossScopeRejection();
    TestNeutralInitialValuesForNonPrivateLoads();
    TestDisjointBytesAndMixedSizeRemainDistinct();
    TestDifferentLocationStoreStoreOrderSurvivesScopeDifference();
    return 0;
end;
