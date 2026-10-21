<!-- GENERATED FROM: asl/block/model/dispatch/gm-obligation-dispatch.asl -->
# Gm Obligation Dispatch

**Normative ASL source:** `asl/block/model/dispatch/gm-obligation-dispatch.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-GM-OBLIGATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-gm-dispatch-purpose role=purpose-scope -->
## Purpose and scope

This unit is the Block dispatch bridge for tile operations that can touch global memory. It classifies the operation, chooses the request class and source, registers or reuses the matching GM obligation, validates early Shared-generation retirement, and invokes accepted tile execution.

The bridge keeps the Block stop and the asynchronous memory request tied to one dynamic occurrence. That allows waiting, fault, retry, and completion to update the same obligation instead of creating duplicate effects.

<!-- PTO-READER-BLOCK: block-gm-dispatch-concepts role=concepts-state -->
## Classification and request identity

`BundleTileOperationHasGMEffect` recognizes the Block tile operations whose execution can create GM work. `BundleTileGMRequestClass` maps them to tile, TLSU, atomic, or prefetch request classes, and `BundleFirstGMSourceTile` identifies the relevant source when the operation has one.

The registered obligation captures the current Core, PE, invocation, encoded occurrence, program order, execution-domain token, descriptor, bindings, and request class. Re-entering the same waiting stop reuses that record; another dynamic stop, even at the same PC, receives a distinct identity.

<!-- PTO-READER-BLOCK: block-gm-dispatch-rules role=rules-interactions -->
## Dispatch sequence

Before producer effects, the dispatcher checks whether a Shared-generation source can be retired early and records enough state to undo that retirement if applicability or execution fails. It then runs accepted applicability rules and the real tile operation. Success finalizes the retirement and advances the obligation through its owner-reported state.

If a source is not ready, the unchanged request remains waiting. A fault or failed accepted execution retires the failed early request and preserves retry identity as required by the GM-obligation owner. In particular, an unpublished Shared TSTORE source produces no GM effect and keeps collective arrival blocked until publication makes the original request executable.

<!-- PTO-READER-BLOCK: block-gm-dispatch-boundaries role=boundaries -->
## Boundaries

This unit does not implement the memory transfer, address calculation, atomic operation, or prefetch. Those semantics stay with the selected tile operation. It also cannot treat early source retirement as committed when the operation did not pass applicability and execution.

Operations without a GM effect bypass this obligation path. The bounded obligation storage and verification progress controls remain model mechanisms, not additional instruction operands or portable rejection rules.

<!-- PTO-READER-BLOCK: block-gm-dispatch-example role=example-usage -->
## Reading example

A TSTORE stop names a Shared source whose next generation has not published. Dispatch registers the dynamic request but does not consume bindings, emit a memory event, or fault merely because the source is waiting. `SYNC.CORE` cannot make an irrevocable arrival past that fault-capable request. After the producer publishes the source, the same stop and obligation retry, execute the real store, record completion, and only then allow the later collective to release.

<!-- PTO-READER-BLOCK: block-gm-dispatch-related role=related-owners-navigation -->
## Related owners

- [GM obligations](../../../arch/memory-model/gm-obligations.md) owns request identity and lifecycle state.
- [Shared-generation PE requests](../operands/shared-generation-pe-requests.md) owns waiting and publication for Shared sources.
- [Source lifetime](../state/source-lifetime.md) pins source generations used by dynamic occurrences.
- [Core synchronization](../../../arch/state/core-synchronization.md) observes unresolved obligations at collective boundaries.
- [Tile execution](tile-execution.md) routes accepted operations to their operation-specific owners.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/gm-obligation-dispatch.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-GM-OBLIGATION","surface":"block","classification":["model","dispatch","gm-obligation-dispatch"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ATOMIC-TSTORE-OBLIGATIONS","PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION","PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-ARCH-STATE-PROGRAM-COUNTER","PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}
func BundleTileOperationHasGMEffect() => boolean
begin
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       SelectedBundleTileMaskIsZero() then return FALSE; end;
    let current_pe_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    if _CurrentPEContextValid then
        if BundleSharedBindingPhysicalCount() != 0 &&
           _BundleSharedBindings[[0]].pe_mask[current_pe_bit] != '1' then
            return FALSE;
        end;
        for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
            if _BundleTileBindings[[binding]].valid &&
               _BundleTileBindings[[binding]].pe_mask[current_pe_bit] != '1' then
                return FALSE;
            end;
        end;
    end;
    let decoded = DecodeTileOperation(
        BundleTileDecodeFamily(_BundleOperation.operation_class),
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then return FALSE; end;
    case TileOperationOfIndex(decoded as
            integer {0..PTO_TILE_OPERATION_COUNT-1}) of
        when TileOperation_TLOAD, TileOperation_TSTORE,
             TileOperation_TPREFETCH,
             TileOperation_MGATHER, TileOperation_MSCATTER,
             TileOperation_MGATHER_MASK, TileOperation_MSCATTER_MASK,
             TileOperation_MGATHER_CAS, TileOperation_MGATHER_EXCH,
             TileOperation_MGATHER_MAX, TileOperation_MGATHER_MIN,
             TileOperation_MGATHER_ADD, TileOperation_MGATHER_INC,
             TileOperation_MGATHER_DEC, TileOperation_MGATHER_AND,
             TileOperation_MGATHER_OR, TileOperation_MGATHER_XOR,
             TileOperation_MSCATTER_MAX, TileOperation_MSCATTER_MIN,
             TileOperation_MSCATTER_ADD, TileOperation_MSCATTER_INC,
             TileOperation_MSCATTER_DEC, TileOperation_MSCATTER_AND,
             TileOperation_MSCATTER_OR, TileOperation_MSCATTER_XOR,
             TileOperation_MSCATTER_POPC => return TRUE;
        otherwise => return FALSE;
    end;
end;

func BundleTileGMRequestClass() => GMRequestClass
begin
    let decoded = DecodeTileOperation(
        BundleTileDecodeFamily(_BundleOperation.operation_class),
        BundleOperationDecodeCode(_BundleOperation));
    if decoded != PTO_TILE_OPERATION_COUNT &&
       TileOperationOfIndex(decoded as
           integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
           TileOperation_TPREFETCH then return GMRequest_Prefetch; end;
    if decoded != PTO_TILE_OPERATION_COUNT &&
       TileOperationOfIndex(decoded as
           integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
           TileOperation_TSTORE &&
       UInt(_BundleOperation.selector[4:0]) == 1 &&
       _BundleDataAttributesPresent && _BundleDataAttributes.canonicalize then
        return GMRequest_Atomic;
    end;
    if decoded != PTO_TILE_OPERATION_COUNT &&
       (TileOperationOfIndex(decoded as
            integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
            TileOperation_MGATHER_CAS ||
        TileOperationOfIndex(decoded as
            integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
            TileOperation_MGATHER_EXCH ||
        TileOperationOfIndex(decoded as
            integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
            TileOperation_MGATHER_MAX ||
        TileOperationOfIndex(decoded as
            integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
            TileOperation_MGATHER_MIN ||
        TileOperationOfIndex(decoded as
            integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
            TileOperation_MGATHER_ADD ||
        TileOperationOfIndex(decoded as
            integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
            TileOperation_MGATHER_INC ||
        TileOperationOfIndex(decoded as
            integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
            TileOperation_MGATHER_DEC ||
        TileOperationOfIndex(decoded as
            integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
            TileOperation_MGATHER_AND ||
        TileOperationOfIndex(decoded as
            integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
            TileOperation_MGATHER_OR ||
        TileOperationOfIndex(decoded as
            integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
            TileOperation_MGATHER_XOR) then return GMRequest_Atomic; end;
    return GMRequest_Tile;
end;

func BundleFirstGMSourceTile() => TileIndex
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].source0_valid then
            return _BundleTileBindings[[binding]].source0;
        end;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            return _BundleTileBindings[[binding]].destination;
        end;
    end;
    return 0 as TileIndex;
end;

func ValidateSharedGenerationEarlyRetirementStructure() => boolean
begin
    if !BundleAssembleOutputStructureLegal() then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !BundleSharedDestinationAssemblyPolicyLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let family = BundleTileDecodeFamily(_BundleOperation.operation_class);
    let decoded = DecodeTileOperation(family,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if !BundleProducerEffectEligible(operation) then return FALSE; end;
    if !BundleOperationScalarBindingSchemaLegal(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !BundleSharedTLSUSelected() ||
       BundleSharedBindingPhysicalCount() != 1 ||
       !_BundleSharedBindings[[0]].destination_assemble.valid ||
       !_BundleSharedBindings[[0]].destination_assemble.init then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let function = UInt(_BundleOperation.selector[4:0]);
    if function == 2 then
        // Retain TLSU operand-role and source descriptor legality, but do not
        // require payload definedness or inspect its elements for a PE that
        // is not a participant.
        if TileOperationOfIndex(operation) != TileOperation_TMOV ||
           BundleTileBindingCount() != 1 ||
           !_BundleTileBindings[[0]].valid ||
           !_BundleTileBindings[[0]].source0_valid ||
           _BundleTileBindings[[0]].source1_valid ||
           _BundleTileBindings[[0]].destination_valid ||
           _BundleTileBindings[[0]].destination_size != 0 ||
           _BundleTileBindings[[0]].pe_mask !=
               _BundleSharedBindings[[0]].pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    elsif function == 0 then
        if TileOperationOfIndex(operation) != TileOperation_TLOAD ||
           BundleTileBindingCount() != 0 ||
           !BundleSharedBindingIsDestination(0) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let valid_columns = UInt(_BundleDimensions[[0]]);
        let valid_rows = UInt(_BundleDimensions[[1]]);
        let columns = UInt(_BundleDimensions[[2]]);
        if valid_columns < 1 || valid_columns > 65535 ||
           valid_rows < 1 || valid_rows > 65535 ||
           columns < 1 || columns > 65535 || valid_columns > columns then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    else
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleCurrentPEIsNonparticipantSharedAssembly() then
        // A completed participant request is checked separately; this
        // structural preflight never blesses an unrelated active request.
        if !BundleSharedGenerationCompletionAvailableForCurrentPE() then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    end;
    if !ValidateBundleSharedGeneration() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    return TRUE;
end;

func RetireFailedEarlySharedGenerationRequest()
begin
    AbortBundleLocalGenerationsForBundle();
    if _LastFault != Fault_None ||
       !BundleSharedGenerationRequestWaiting(0) then
        AbortBundleSharedGenerationsForBundle();
    end;
end;

func FinalizeSharedGenerationEarlyRetirement()
begin
    CommitBundleLocalGeneration();
    RetireBundleConsumerDependencies();
    DiscardBundleSubviewMaterializations();
    FinalizeBundleTileAttempt(TileExecution_Executed);
end;

func ExecuteBundleTileOperationWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet) => boolean
begin
    var obligation_slot: GMObligationIndex = 0;
    var obligation_identity : integer = 0;
    var obligation_invocation : integer = 0;
    if BundleCurrentPEIsNonparticipantSharedAssembly() then
        if !ValidateSharedGenerationEarlyRetirementStructure() then
            RetireFailedEarlySharedGenerationRequest();
            return FALSE;
        end;
        ConsumeBundleSharedBindings(1);
        FinalizeSharedGenerationEarlyRetirement();
        return TRUE;
    end;
    if BundleSharedGenerationCompletionAvailableForCurrentPE() then
        if !ValidateSharedGenerationEarlyRetirementStructure() then
            RetireFailedEarlySharedGenerationRequest();
            return FALSE;
        end;
        if !ConsumeBundleSharedGenerationCompletionForCurrentPE() then
            RetireFailedEarlySharedGenerationRequest();
            return FALSE;
        end;
        FinalizeSharedGenerationEarlyRetirement();
        return TRUE;
    end;
    // The owning Atomic TSTORE record survives a drain until its encoded
    // BSTOP/BSTART boundary retries. Do not allocate a generic GM obligation
    // on that retry: the captured completion identity already represents the
    // actual effect and is distinguished from a later same-PC BSTART by its
    // execution-domain token.
    if BundleAtomicTStoreSelected() then
        let atomic_occurrence = FindCurrentAtomicTStoreOccurrence();
        if atomic_occurrence >= 0 &&
           _GMObligations[[_CurrentModelCore]][[_CurrentMemoryAgent]]
               [[atomic_occurrence as GMObligationIndex]]
                   .captured_atomic_tstore then
            return TRUE;
        end;
    end;
    let tracks_gm = BundleTileOperationHasGMEffect() &&
        !BundleAtomicTStoreSelected() &&
        _CurrentMemoryOrigin == MemoryEventOrigin_Kernel &&
        _KernelInvocationActiveByCore[[_CurrentModelCore]] &&
        _CurrentKernelInvocation != 0;
    if tracks_gm then
        let source = BundleFirstGMSourceTile();
        let generation_slot = BundleLocalGenerationSlotForSource(source);
        let source_generation = if generation_slot < 64 &&
            _LocalGenerations[[generation_slot]].generation_identity_valid
                then _LocalGenerations[[generation_slot]].generation_instance
                else Zeros{PTO_XLEN};
        let base_address = if _BundleScalarBindings[[0]].valid &&
            _BundleScalarBindings[[0]].source_count > 0 then
                ReadScalarRegisterOperand(
                    _BundleScalarBindings[[0]].source0)
            else Zeros{PTO_XLEN};
        let row_stride = if _BundleScalarBindings[[0]].valid &&
            _BundleScalarBindings[[0]].source_count > 1 then
                ReadScalarRegisterOperand(
                    _BundleScalarBindings[[0]].source1)
            else Zeros{PTO_XLEN};
        obligation_slot = RegisterKernelGMObligation(
            BundleTileGMRequestClass(), _BundleStartEncodedInstruction,
            ReadBPC(), _BundleOperation, _BundleArgument,
            _BundleTileBindings, _BundleScalarBindings,
            _BundleSharedBindings, _BundleDimensions, source,
            source_generation, _Tiles[[source]], _BundleExecutionMask,
            base_address, row_stride, CurrentBundleMemoryOrder(),
            TRUE, FALSE, FALSE, FALSE, TRUE);
        IssueGMObligation(_CurrentModelCore, _CurrentMemoryAgent,
            obligation_slot);
        obligation_identity =
            _GMObligations[[_CurrentModelCore]][[_CurrentMemoryAgent]]
                [[obligation_slot]].identity;
        obligation_invocation =
            _GMObligations[[_CurrentModelCore]][[_CurrentMemoryAgent]]
                [[obligation_slot]].invocation;
    end;
    var completed = FALSE;
    if _BundleControlAttributes.far then
        completed = ExecuteFarBundleTileOperationWithAcceptedApplicabilityRules(
            rules);
    else
        completed = ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules(
            rules);
    end;
    if tracks_gm then
        if _LastFault != Fault_None then
            FaultGMObligation(_CurrentModelCore, _CurrentMemoryAgent,
                obligation_slot);
        elsif completed &&
              !_GMObligations[[_CurrentModelCore]][[_CurrentMemoryAgent]]
                  [[obligation_slot]].captured_tstore_progress &&
              !_GMObligations[[_CurrentModelCore]][[_CurrentMemoryAgent]]
                  [[obligation_slot]].captured_atomic_tstore then
            CompleteGMObligationForIdentity(_CurrentModelCore,
                _CurrentMemoryAgent, obligation_slot,
                obligation_invocation, obligation_identity);
        end;
    end;
    if !completed then
        AbortBundleLocalGenerationsForBundle();
        if _LastFault != Fault_None ||
           !BundleSharedGenerationRequestWaiting(0) then
            AbortBundleSharedGenerationsForBundle();
        end;
    end;
    return completed;
end;

func ExecuteBundleTileOperation() => boolean
begin
    return ExecuteBundleTileOperationWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_None);
end;
```
<!-- GENERATED-ASL-END: unit -->
