<!-- GENERATED FROM: asl/block/model/dispatch/gm-obligation-dispatch.asl -->
# Gm Obligation Dispatch

**Normative ASL source:** `asl/block/model/dispatch/gm-obligation-dispatch.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-GM-OBLIGATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/gm-obligation-dispatch.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-GM-OBLIGATION","surface":"block","classification":["model","dispatch","gm-obligation-dispatch"],"depends_on":["PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-DISPATCH-TILE-EXECUTION","PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-ARCH-STATE-PROGRAM-COUNTER","PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}
func BundleTileOperationHasGMEffect() => boolean
begin
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       SelectedBundleTileMaskIsZero() then return FALSE; end;
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
    let tracks_gm = BundleTileOperationHasGMEffect() &&
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
                  [[obligation_slot]].captured_tstore_progress then
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
