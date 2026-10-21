// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-SQUASH","surface":"block","classification":["model","operands","local-generation-squash"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION","PTO-BLOCK-MODEL-STATE-ATOMIC-TSTORE-SOURCE-LIFETIME","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-BLOCK-MODEL-STATE-SHARED-GENERATION","PTO-BLOCK-MODEL-STATE-TYPES"]}
readonly func AtomicTStoreOwnsLocalConsumerDependency(
    core: PTOModelCoreIdentity, invocation: integer, source: TileIndex,
    participant_mask: bits(4), instruction_pc: Word,
    execution_domain: integer) => boolean
begin
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        for request = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
            let obligation = _GMObligations[[core]][[pe]][[request]];
            if obligation.active && obligation.captured_atomic_tstore &&
               obligation.invocation == invocation &&
               obligation.execution_domain_token == execution_domain &&
               obligation.instruction_pc == instruction_pc &&
               obligation.irrevocable &&
               obligation.atomic_tstore_committed_count != 0 &&
               obligation.state != GMObligation_Completed &&
               obligation.state != GMObligation_Cancelled then
                for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
                    if obligation.bundle_tile_bindings[[binding]].valid &&
                       obligation.bundle_tile_bindings[[binding]].pe_mask ==
                           participant_mask &&
                       ((obligation.bundle_tile_bindings[[binding]]
                             .source0_valid &&
                         obligation.bundle_tile_bindings[[binding]].source0 ==
                             source) ||
                        (obligation.bundle_tile_bindings[[binding]]
                             .source1_valid &&
                         obligation.bundle_tile_bindings[[binding]].source1 ==
                             source)) then
                        return TRUE;
                    end;
                end;
            end;
        end;
    end;
    return FALSE;
end;

func CancelReversibleAtomicTStoreRequestsForDomain(
    core: PTOModelCoreIdentity, invocation: integer, domain: integer)
begin
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        for request = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
            let obligation = _GMObligations[[core]][[pe]][[request]];
            if obligation.active && obligation.captured_atomic_tstore &&
               obligation.invocation == invocation &&
               obligation.execution_domain_token == domain &&
               obligation.reversible && !obligation.irrevocable &&
               obligation.atomic_tstore_committed_count == 0 &&
               obligation.state != GMObligation_Completed &&
               obligation.state != GMObligation_Cancelled then
                _GMObligations[[core]][[pe]][[request]].state =
                    GMObligation_Cancelled;
                _GMObligations[[core]][[pe]][[request]]
                    .atomic_tstore_finalization_pending = FALSE;
            end;
        end;
    end;
end;

func SquashBundleExecutionDomain(domain: integer)
begin
    // Resolve the exact Atomic request state before mutating source
    // dependencies or occurrence tokens. A zero-effect reversible request is
    // terminally cancelled; an already committed request keeps its snapshot
    // and exact consumer dependency until the scheduler drains it.
    CancelReversibleAtomicTStoreRequestsForDomain(_CurrentModelCore,
        _CurrentKernelInvocation, domain);
    for slot = 0 to 63 do
        var covered: bits(2048) = Zeros{2048};
        var ready: bits(2048) = Zeros{2048};
        var writers_left: integer {0..16} = 0;
        var compacted_writers: LocalGenerationWriterSnapshot =
            _LocalGenerations[[slot]].writers;
        for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
            looplimit 16 do
            if _LocalGenerations[[slot]].writers[[writer]].valid &&
               _LocalGenerations[[slot]].writers[[writer]].identity
                   .execution_domain_token == domain then
                _LocalGenerations[[slot]].writers[[writer]].valid = FALSE;
                _LocalGenerations[[slot]].writers[[writer]].ready = FALSE;
            end;
        end;
        for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
            looplimit 16 do
            if _LocalGenerations[[slot]].writers[[writer]].valid then
                compacted_writers[[writers_left]] =
                    _LocalGenerations[[slot]].writers[[writer]];
                writers_left = (writers_left + 1) as integer {0..16};
                for cell = 0 to 2047 do
                    if cell < _LocalGenerations[[slot]].writers[[writer]]
                        .cell_count then
                        let index = _LocalGenerations[[slot]].writers[[writer]]
                            .offset_cells + cell;
                        if index < 2048 then
                            covered[index] = '1';
                            if _LocalGenerations[[slot]].writers[[writer]].ready then
                                ready[index] = '1';
                            end;
                        end;
                    end;
                end;
            end;
        end;
        _LocalGenerations[[slot]].covered_cells = covered;
        _LocalGenerations[[slot]].ready_cells = ready;
        for writer = writers_left to 15 do
            compacted_writers[[writer]].valid = FALSE;
            compacted_writers[[writer]].ready = FALSE;
        end;
        _LocalGenerations[[slot]].writers = compacted_writers;
        _LocalGenerations[[slot]].writer_count = writers_left as integer {0..16};
        for index = 0 to _LocalGenerations[[slot]].consumer_count - 1
            looplimit 16 do
            if _LocalGenerations[[slot]].consumers[[index]].valid &&
               _LocalGenerations[[slot]].consumers[[index]]
                   .execution_domain_token == domain then
                let dependency = _LocalGenerations[[slot]].consumers[[index]];
                if !AtomicTStoreOwnsLocalConsumerDependency(
                       _CurrentModelCore, _CurrentKernelInvocation,
                       dependency.source, dependency.participant_mask,
                       dependency.consumer_instruction_instance,
                       dependency.execution_domain_token) then
                    _LocalGenerations[[slot]].consumers[[index]].state =
                        BundleConsumerDependency_Cancelled;
                    _LocalGenerations[[slot]].consumers[[index]].valid = FALSE;
                end;
            end;
        end;
        for pe = 0 to 3 do
            var pe_covered = Zeros{2048};
            var pe_ready = Zeros{2048};
            for writer = 0 to _LocalGenerations[[slot]].writer_count - 1
                looplimit 16 do
                if _LocalGenerations[[slot]].writers[[writer]].valid &&
                   _LocalGenerations[[slot]].writers[[writer]].pe_mask[
                       PTOPEMaskBitOfPEIdentity(pe)] == '1' then
                    for cell = 0 to 2047 do
                        if cell < _LocalGenerations[[slot]].writers[[writer]].cell_count &&
                           _LocalGenerations[[slot]].writers[[writer]].offset_cells + cell < 2048 then
                            let index = _LocalGenerations[[slot]].writers[[writer]].offset_cells + cell;
                            pe_covered[index] = '1';
                            if _LocalGenerations[[slot]].writers[[writer]].ready then
                                pe_ready[index] = '1';
                            end;
                        end;
                    end;
                end;
            end;
            _LocalGenerations[[slot]].per_pe_covered_cells[[pe]] = pe_covered;
            _LocalGenerations[[slot]].per_pe_ready_cells[[pe]] = pe_ready;
        end;
        if writers_left == 0 && _LocalGenerations[[slot]].open then
            var retained_consumer = FALSE;
            for consumer = 0 to _LocalGenerations[[slot]].consumer_count - 1
                looplimit 16 do
                if _LocalGenerations[[slot]].consumers[[consumer]].valid then
                    retained_consumer = TRUE;
                end;
            end;
            if !retained_consumer then AbortBundleLocalGeneration(slot); end;
        end;
    end;
    SquashPEOwnedSharedGenerationRequest(_CurrentModelCore,
        _CurrentKernelInvocation, domain);
    SquashSourceLifetimes(_CurrentModelCore,
        _CurrentKernelInvocation, domain);
end;

// PTO-NDF: PTO-B-ASSEMBLE-SPECULATION-001
// Architecture event entry point for an execution-domain squash.  The event
// is not instruction-encoded; a control-flow, fault, or interrupt mechanism
// invokes this procedure after the decoded writer path has registered its
// portable identity.
func EnterBundleExecutionDomainSquashEvent(domain: integer)
begin
    SquashBundleExecutionDomain(domain);
end;
