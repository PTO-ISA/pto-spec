// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GM-OBLIGATION-PROGRESS","surface":"tile","classification":["model","memory","gm-obligation-progress"],"depends_on":["PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","PTO-ARCH-STATE-PROGRAM-COUNTER","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION","PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-BLOCK-MODEL-STATE-SOURCE-LIFETIME","PTO-TILE-MODEL-MEMORY-ATOMIC-TSTORE","PTO-TILE-MODEL-MEMORY-LOAD-STORE"]}
func ProgressKernelGMObligationsForCore(core: PTOModelCoreIdentity,
                                        invocation: integer)
begin
    if VerificationGMProgressIsDeferred() then return; end;
    let original_core = _CurrentModelCore;
    let original_pe = _CurrentMemoryAgent;
    let original_invocation = _CurrentKernelInvocation;
    let original_history_override_valid =
        _MemoryEventCollectiveHistoryOverrideValid;
    let original_history_override = _MemoryEventCollectiveHistoryOverride;
    SaveSelectedPEExecutionContext();
    SaveSelectedCoreExecutionContext();
    for pe_number = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let pe = pe_number as MemoryAgentId;
        for slot_number = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
            let slot = slot_number as GMObligationIndex;
            let obligation = _GMObligations[[core]][[pe]][[slot]];
            if obligation.active && obligation.invocation == invocation &&
               ((obligation.captured_tstore_progress &&
                 obligation.request_class == GMRequest_Tile) ||
                (obligation.captured_atomic_tstore &&
                 obligation.request_class == GMRequest_Atomic)) &&
               (obligation.state == GMObligation_Validated ||
                obligation.state == GMObligation_Issued) then
                SelectExecutionContext(core, pe);
                SaveSelectedPEExecutionContext();
                var request_context =
                    _PEExecutionContexts[[core]][[pe]];
                _CurrentKernelInvocation = obligation.invocation;
                _CurrentProgramOrder = obligation.submission_order;
                _CurrentCollectiveEpoch = obligation.collective_epoch;
                _CurrentMemoryOrigin = MemoryEventOrigin_Kernel;
                _MemoryEventCollectiveHistoryOverrideValid = TRUE;
                _MemoryEventCollectiveHistoryOverride =
                    obligation.collective_history_sequence;
                _CurrentEncodedInstruction = obligation.encoded_request;
                _BundleStartEncodedInstruction = obligation.encoded_request;
                _BundleArgument = obligation.bundle_argument;
                _BundleOperation = obligation.descriptor;
                _BundleTileBindings = obligation.bundle_tile_bindings;
                _BundleScalarBindings = obligation.bundle_scalar_bindings;
                _BundleSharedBindings = obligation.bundle_shared_bindings;
                _BundleDimensions = obligation.bundle_dimensions;
                _BundleExecutionMask = obligation.execution_mask;
                _BundleExecutionDomainToken =
                    obligation.execution_domain_token;
                if obligation.captured_atomic_tstore then
                    _BundleDataAttributes =
                        obligation.atomic_tstore_data_attributes;
                    _BundleDataAttributesPresent = TRUE;
                end;
                _BPC = obligation.instruction_pc;
                SetCurrentACR(obligation.submission_acr);
                _LastFault = Fault_None;
                _FaultAddress = Zeros{PTO_XLEN};
                if obligation.state == GMObligation_Validated then
                    IssueGMObligation(core, pe, slot);
                end;
                let result = if obligation.captured_atomic_tstore then
                    ExecuteAtomicTStoreSnapshotProgress(core, pe, slot,
                        _VerificationGMProgressBeatBudget)
                    else ExecuteTileStoreSnapshotProgress(
                        obligation.source_snapshot,
                        obligation.base_address,
                        obligation.row_stride_bytes,
                        obligation.instruction_pc,
                        obligation.memory_order,
                        obligation.progress_element,
                        _VerificationGMProgressBeatBudget,
                        TRUE, core, pe, slot);
                if result == TileStoreProgress_Completed then
                    CompleteGMObligationForIdentity(core, pe, slot,
                        obligation.invocation, obligation.identity);
                elsif result == TileStoreProgress_Faulted then
                    FaultGMObligation(core, pe, slot);
                end;
                if _LastFault == Fault_None then
                    if obligation.captured_atomic_tstore &&
                       result == TileStoreProgress_Completed &&
                       obligation.atomic_tstore_finalization_pending &&
                       _KernelInvocationActiveByCore[[core]] &&
                       _KernelInvocationByCore[[core]] == invocation then
                        CommitBundleLocalGeneration();
                        RetireBundleConsumerDependencies();
                        FinalizeBundleTileAttempt(TileExecution_Executed);
                        if obligation.bundle_tile_bindings[[0]].source0_valid then
                            let source = obligation.bundle_tile_bindings[[0]]
                                .source0;
                            request_context.tiles[[source]] = _Tiles[[source]];
                            request_context.tile_allocation_masks[[source]] =
                                _TileAllocationMasks[[source]];
                            request_context.tile_payload_live_masks[[source]] =
                                _TilePayloadLiveMasks[[source]];
                            request_context.tile_payload_generations[[source]] =
                                _TilePayloadGenerations[[source]];
                        end;
                        _GMObligations[[core]][[pe]][[slot]]
                            .atomic_tstore_finalization_pending = FALSE;
                    elsif obligation.captured_atomic_tstore &&
                          result == TileStoreProgress_Completed &&
                          !_KernelInvocationActiveByCore[[core]] &&
                          KernelGMObligationsQuiescent(core, invocation) then
                        // Abort cleanup retires retained source-lifetime pins
                        // only after the last irrevocable request quiesces. It
                        // deliberately does not mark incomplete participants
                        // successful or consume their payload.
                        RetireSourceLifetimes(core, invocation);
                        _GMObligations[[core]][[pe]][[slot]]
                            .atomic_tstore_finalization_pending = FALSE;
                    end;
                    // The scheduler temporarily installed the captured
                    // request. Restore the owner's live kernel/parked/handler
                    // context, while carrying forward reservation invalidation
                    // caused by its real GM writes.
                    request_context.reservation_valid = _ReservationValid;
                    LoadPEExecutionContext(request_context);
                    SaveSelectedPEExecutionContext();
                    if core != original_core || pe != original_pe then
                        SelectExecutionContext(original_core, original_pe);
                    end;
                    _CurrentKernelInvocation = original_invocation;
                else
                    // A real service fault belongs to the captured request
                    // owner. Persist its trap/restart state before restoring
                    // the caller's selected context.
                    SaveSelectedPEExecutionContext();
                    if core != original_core || pe != original_pe then
                        SelectExecutionContext(original_core, original_pe);
                        _CurrentKernelInvocation = original_invocation;
                    end;
                end;
                _MemoryEventCollectiveHistoryOverrideValid =
                    original_history_override_valid;
                _MemoryEventCollectiveHistoryOverride =
                    original_history_override;
            end;
        end;
    end;
    _MemoryEventCollectiveHistoryOverrideValid =
        original_history_override_valid;
    _MemoryEventCollectiveHistoryOverride = original_history_override;
    _CurrentKernelInvocation = original_invocation;
end;
