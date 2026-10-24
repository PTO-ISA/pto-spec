// PTO-TEST: {"id":"PTO-AVS-ARCH-TSTORE-ATOMIC-LOCAL-CONSUMER-SQUASH-004","source":"asl/arch/state/kernel-lifecycle.asl","requirements":["PTO-TSTORE-STRIDED-ATOMIC-RED-001","PTO-ARCH-GM-OBLIGATIONS-001","PTO-B-ASSEMBLE-CONSUMER-READINESS-001","PTO-B-ASSEMBLE-SPECULATION-001","PTO-B-SOURCE-LIFETIME-PE-COMPLETION-001"],"kind":"state-transition","summary":"irrevocable Atomic TSTORE retains its exact LocalGeneration consumer dependency through domain squash and retires it after drain","pass_condition":"a decoded B.IOT/B.ASSEMBLE TMATMUL producer creates and publishes a Local FP32 CUBE_M16 parent; a Normal Function-1 control stores from that generated parent; a second encoded Atomic Function-1 Local TSTORE captures its whole-parent dependency; after one committed RMW, exact-domain squash leaves the dependency eligible and parent intact; draining the remaining RMW preserves original invocation provenance and retires the dependency only at quiescence","related_sources":["asl/block/model/operands/local-generation.asl","asl/block/model/operands/local-generation-squash.asl","asl/block/model/operands/portable-carriers.asl","asl/tile/model/memory/atomic-tstore.asl","asl/tile/model/memory/gm-obligation-progress.asl"]}

pure func LocalConsumerProducerStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00031181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP16);
    return instruction;
end;

pure func LocalConsumerProducerBinder() => bits(64)
begin
    var instruction = Zeros{64} + 0x00004013;
    instruction[31:26] = Zeros{6} + 2;
    instruction[25:20] = Zeros{6} + 1;
    instruction[19] = '1';
    instruction[18:15] = Zeros{4} + 2;
    instruction[11:9] = '111';
    return instruction;
end;

pure func LocalConsumerProducerAssemble() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001053;
    instruction[31] = '1';
    instruction[11] = '1';
    instruction[10:7] = Zeros{4} + 1;
    return instruction;
end;

func ProduceLocalFP32Parent(entry: Word) => TileIndex
begin
    let left_ready = ConfigureCubeTileForMask(1, 128, 1, 1,
        TileDataType_FP16, TileLayout_CUBE_M16, '1111');
    let right_ready = ConfigureCubeTileForMask(2, 128, 1, 2,
        TileDataType_FP16, TileLayout_CUBE_N8, '1111');
    assert left_ready && right_ready;
    InstallRelativeTileFixture(1, 1);
    InstallRelativeTileFixture(2, 2);
    WriteTileElement(1, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(2, 0, 0, Zeros{PTO_XLEN} + 0x3c00);
    WriteTileElement(2, 0, 1, Zeros{PTO_XLEN} + 0x4000);
    MarkTileValidRegionDefined(1);
    MarkTileValidRegionDefined(2);

    let producer_start = ExecuteCommandInstruction(
        LocalConsumerProducerStart(), 32);
    SetBundleFixedPointAttributeState(Zeros{6}, Zeros{3}, Zeros{4},
        FALSE, FALSE, FALSE, FALSE);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 1);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(2, Zeros{PTO_XLEN} + 1);
    let producer_binding = ExecuteCommandInstruction(
        LocalConsumerProducerBinder(), 32);
    let producer_assemble = ExecuteCommandInstruction(
        LocalConsumerProducerAssemble(), 32);
    assert producer_start == CommandExecution_Executed &&
           producer_binding == CommandExecution_Executed &&
           producer_assemble == CommandExecution_Executed &&
           _BundleTileBindings[[0]].destination_assemble.valid &&
           _BundleTileBindings[[0]].destination_assemble.init &&
           _BundleTileBindings[[0]].destination_assemble.last &&
           BundleCubeMatrixSelected() &&
           BundleLocalDestinationAllocationBytes(0) == 256 &&
           TileCubeDescriptorShapeLegal(256, 1, 2,
               TileDataType_FP32, TileLayout_CUBE_M16);
    let producer_complete = CompleteBundleAt(entry + 0x20);
    assert producer_complete && _LastFault == Fault_None;
    let generation_slot = BundleLocalGenerationSlot(0, '1111');
    let parent = _LocalGenerations[[generation_slot]].working_destination;
    let producer_domain = _BundleExecutionDomainToken;
    let writer_cells = BundleLocalGenerationCellCount(1);
    assert writer_cells == 1;
    let producer_ready = CompleteBundleLocalGenerationWriterEvent(
        generation_slot, producer_domain, 0, writer_cells);
    assert producer_ready &&
           _LocalGenerations[[generation_slot]].published &&
           _LocalGenerations[[generation_slot]].per_pe_published[[0]] &&
           _Tiles[[parent]].data_type == TileDataType_FP32 &&
           _Tiles[[parent]].layout == TileLayout_CUBE_M16 &&
           _Tiles[[parent]].valid_rows == 1 &&
           _Tiles[[parent]].valid_columns == 2 &&
           BundleLocalGenerationSlotForSource(parent) == generation_slot &&
           TileReadLogicalElement(_Tiles[[parent]], 0) ==
               Zeros{PTO_XLEN} + 0x3f800000 &&
           TileReadLogicalElement(_Tiles[[parent]], 1) ==
               Zeros{PTO_XLEN} + 0x40000000;
    assert ResolveRelativeTileSource(0) == parent;
    return parent;
end;

pure func NormalLocalStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP32);
    return instruction;
end;

pure func NormalLocalDATR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 25;
    return instruction;
end;

pure func NormalLocalSource() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicLocalStart() => bits(64)
begin
    var instruction = Zeros{64} + 0x00111181;
    instruction[31:27] = TileDataTypeToEncoding(TileDataType_FP32);
    return instruction;
end;

pure func AtomicLocalDATR() => bits(64)
begin
    var instruction = Zeros{64} + 0x00001023;
    instruction[25] = '1';
    instruction[24:20] = DTYPE_NONE;
    instruction[11:7] = Zeros{5} + 25;
    return instruction;
end;

pure func AtomicLocalSource() => bits(64)
begin
    var instruction = Zeros{64} + 0x00005013;
    instruction[25:20] = Zeros{6};
    instruction[18:15] = Zeros{4};
    instruction[11:9] = '001';
    instruction[19] = '1';
    return instruction;
end;

pure func AtomicLocalAddress() => bits(64)
begin
    var instruction = Zeros{64} + 0x00000013;
    instruction[19:15] = Zeros{5} + 2;
    instruction[24:20] = Zeros{5} + 3;
    return instruction;
end;

func main() => integer
begin
    ResetProfileState();
    let normal_entry = Zeros{PTO_XLEN} + 0xe00;
    let normal_launch = LaunchKernelInvocation(0, normal_entry);
    assert normal_launch == KernelLifecycle_Started;
    SelectExecutionContext(0, 0);
    let normal_parent = ProduceLocalFP32Parent(normal_entry);
    let normal_slot = BundleLocalGenerationSlot(0, '1111');
    _PC = normal_entry + 0x20;
    _BPC = normal_entry + 0x20;
    let normal_start = ExecuteCommandInstruction(NormalLocalStart(), 32);
    let normal_attributes = ExecuteCommandInstruction(NormalLocalDATR(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let normal_source = ExecuteCommandInstruction(NormalLocalSource(), 32);
    assert normal_start == CommandExecution_Executed &&
           normal_attributes == CommandExecution_Executed &&
           normal_source == CommandExecution_Executed &&
           !BundleAtomicTStoreSelected() &&
           BundleTileSourceIndex(0, FALSE) == normal_parent;
    let normal_completed = CompleteBundleAt(normal_entry + 0x38);
    let normal_first = LoadUnsigned(Zeros{PTO_XLEN}, 4);
    let normal_second = LoadUnsigned(Zeros{PTO_XLEN} + 4, 4);
    assert normal_completed && _LastFault == Fault_None &&
           normal_first == Zeros{PTO_XLEN} + 0x3f800000 &&
           normal_second == Zeros{PTO_XLEN} + 0x40000000 &&
           _LocalGenerations[[normal_slot]].published;

    ResetProfileState();
    let entry = Zeros{PTO_XLEN} + 0xf00;
    let launched = LaunchKernelInvocation(0, entry);
    assert launched == KernelLifecycle_Started;
    let invocation = _KernelInvocationByCore[[0]];
    SelectExecutionContext(0, 0);
    let parent = ProduceLocalFP32Parent(entry);
    let generation_slot = BundleLocalGenerationSlot(0, '1111');

    let base = Zeros{PTO_XLEN} + 0xa00;
    Store(base, 4, Zeros{PTO_XLEN} + 0x40400000);
    Store(base + 4, 4, Zeros{PTO_XLEN} + 0x40800000);
    WriteGPR(2, base);
    WriteGPR(3, Zeros{PTO_XLEN} + 4);
    _PC = entry + 0x40;
    _BPC = entry + 0x40;
    let started = ExecuteCommandInstruction(AtomicLocalStart(), 32);
    SetBundleDimension(0, Zeros{PTO_XLEN} + 2);
    SetBundleDimension(1, Zeros{PTO_XLEN} + 1);
    let attributes = ExecuteCommandInstruction(AtomicLocalDATR(), 32);
    let source = ExecuteCommandInstruction(AtomicLocalSource(), 32);
    let address = ExecuteCommandInstruction(AtomicLocalAddress(), 32);
    assert started == CommandExecution_Executed &&
           attributes == CommandExecution_Executed &&
           source == CommandExecution_Executed &&
           address == CommandExecution_Executed &&
           BundleAtomicTStoreSelected() &&
           BundleTileSourceIndex(0, FALSE) == parent &&
           _BundleTileBindings[[0]].pe_mask == '1000';

    StartMemoryEventCapture(0);
    SetVerificationGMProgressDeferred(TRUE);
    let admitted = ExecuteBundleTileOperation();
    assert admitted && _LastFault == Fault_None;
    let slot = FindCurrentAtomicTStoreObligation();
    assert slot >= 0;
    let pending = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    let dependency = _LocalGenerations[[generation_slot]].consumers[[0]];
    assert pending.active && pending.captured_atomic_tstore &&
           pending.state == GMObligation_Issued &&
           pending.atomic_tstore_target_count == 2 &&
           pending.atomic_tstore_committed_count == 0 &&
           pending.invocation == invocation &&
           dependency.valid &&
           dependency.state == BundleConsumerDependency_Eligible &&
           dependency.source == parent && dependency.participant_mask == '1000' &&
           dependency.execution_domain_token == pending.execution_domain_token &&
           dependency.consumer_instruction_instance == pending.instruction_pc;

    SetVerificationGMProgressDeferred(FALSE);
    SetVerificationGMProgressBeatBudget(1);
    ProgressKernelGMObligationsForCore(0, invocation);
    let partial = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert partial.irrevocable && partial.atomic_tstore_committed_count == 1 &&
           partial.state == GMObligation_Issued && _MemoryEventCount == 1 &&
           _LocalGenerations[[generation_slot]].consumers[[0]].valid;
    let domain = pending.execution_domain_token;
    EnterBundleExecutionDomainSquashEvent(domain);
    let after_squash = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert after_squash.irrevocable &&
           after_squash.atomic_tstore_committed_count == 1 &&
           after_squash.state == GMObligation_Issued &&
           _LocalGenerations[[generation_slot]].generation_identity_valid &&
           _LocalGenerations[[generation_slot]].published &&
           _LocalGenerations[[generation_slot]].consumers[[0]].valid &&
           _LocalGenerations[[generation_slot]].consumers[[0]].state ==
               BundleConsumerDependency_Eligible &&
           AtomicTStoreOwnsLocalConsumerDependency(0, invocation, parent,
               '1000', pending.instruction_pc, domain) &&
           TileReadLogicalElement(_Tiles[[parent]], 0) ==
               Zeros{PTO_XLEN} + 0x3f800000 && _MemoryEventCount == 1;

    SetVerificationGMProgressBeatBudget(0);
    ProgressKernelGMObligationsForCore(0, invocation);
    let drained = _GMObligations[[0]][[0]][[slot as GMObligationIndex]];
    assert drained.state == GMObligation_Completed &&
           drained.invocation == invocation &&
           drained.execution_domain_token == domain &&
           drained.atomic_tstore_committed_count == 2 &&
           !drained.atomic_tstore_finalization_pending &&
           !_LocalGenerations[[generation_slot]].consumers[[0]].valid &&
           _LocalGenerations[[generation_slot]].consumers[[0]].state ==
               BundleConsumerDependency_Retired && _MemoryEventCount == 2;
    let first_event = _MemoryEvents[[0 as MemoryEventIndex]];
    let second_event = _MemoryEvents[[1 as MemoryEventIndex]];
    assert first_event.kind == MemoryEvent_Atomic &&
           first_event.invocation == invocation &&
           first_event.address == base &&
           first_event.read_value == Zeros{PTO_XLEN} + 0x40400000 &&
           first_event.write_value == Zeros{PTO_XLEN} + 0x40800000;
    assert second_event.kind == MemoryEvent_Atomic &&
           second_event.invocation == invocation &&
           second_event.address == base + 4 &&
           second_event.read_value == Zeros{PTO_XLEN} + 0x40800000 &&
           second_event.write_value == Zeros{PTO_XLEN} + 0x40c00000;
    StopMemoryEventCapture();
    SetVerificationGMProgressBeatBudget(0);
    return 0;
end;
