<!-- GENERATED FROM: asl/block/model/dispatch/gm-obligation-dispatch.asl -->
# Gm Obligation Dispatch

**Normative ASL source:** `asl/block/model/dispatch/gm-obligation-dispatch.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-GM-OBLIGATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-gm-dispatch-purpose role=purpose-scope -->
## 目的和范围

本单元是可能访问 global memory 的 tile operation 的 Block dispatch bridge。它分类 operation，选择 request class 和 source，注册或复用匹配的 GM obligation，验证 early Shared-generation retirement，并调用 accepted tile execution。

该 bridge 将 Block stop 和 asynchronous memory request 绑定到同一个 dynamic occurrence。这样，waiting、fault、retry 和 completion 可以更新同一 obligation，而不会产生重复 effect。

<!-- PTO-READER-BLOCK: block-gm-dispatch-concepts role=concepts-state -->
## Classification 和 request identity

`BundleTileOperationHasGMEffect` 识别其执行可以创建 GM work 的 Block tile operation。`BundleTileGMRequestClass` 将它们映射为 tile、TLSU、atomic 或 prefetch request class，`BundleFirstGMSourceTile` 在 operation 有 source 时标识相关 source。

registered obligation 捕获当前 Core、PE、invocation、encoded occurrence、program order、execution-domain token、descriptor、binding 和 request class。重新进入同一个 waiting stop 会复用该 record；另一个 dynamic stop 即使位于同一 PC，也会获得不同 identity。

<!-- PTO-READER-BLOCK: block-gm-dispatch-rules role=rules-interactions -->
## Dispatch 顺序

在 producer effect 之前，dispatcher 检查 Shared-generation source 能否 early retire，并记录足够状态，以便 applicability 或 execution 失败时撤销该 retirement。随后运行 accepted applicability rule 和真实 tile operation。成功会 finalize retirement，并通过 owner-reported state 推进 obligation。

如果 source 尚未 ready，unchanged request 保持 waiting。fault 或 failed accepted execution 会 retire failed early request，并按 GM-obligation owner 的要求保留 retry identity。尤其是，unpublished Shared TSTORE source 不产生 GM effect，并在 publication 使原 request 可执行之前持续阻塞 collective arrival。

<!-- PTO-READER-BLOCK: block-gm-dispatch-boundaries role=boundaries -->
## 边界

本单元不实现 memory transfer、address calculation、atomic operation 或 prefetch。这些语义留在所选 tile operation。若 operation 未通过 applicability 和 execution，它也不能把 early source retirement 当作 committed。

没有 GM effect 的 operation 绕过此 obligation path。有界 obligation storage 和 verification progress control 仍是模型机制，不是额外 instruction operand 或 portable rejection rule。

<!-- PTO-READER-BLOCK: block-gm-dispatch-example role=example-usage -->
## 阅读示例

一个 TSTORE stop 命名了 next generation 尚未发布的 Shared source。dispatch 注册 dynamic request，但不会只因 source 在等待就消费 binding、发出 memory event 或产生 fault。`SYNC.CORE` 不能越过该 fault-capable request 形成 irrevocable arrival。producer 发布 source 后，同一 stop 和 obligation retry，执行真实 store，记录 completion，随后才允许后续 collective release。

<!-- PTO-READER-BLOCK: block-gm-dispatch-related role=related-owners-navigation -->
## 相关所有者

- [GM obligations](../../../arch/memory-model/gm-obligations.md) 拥有 request identity 和 lifecycle state。
- [Shared-generation PE requests](../operands/shared-generation-pe-requests.md) 拥有 Shared source 的 waiting 和 publication。
- [Source lifetime](../state/source-lifetime.md) 固定 dynamic occurrence 使用的 source generation。
- [Core synchronization](../../../arch/state/core-synchronization.md) 在 collective boundary 观察 unresolved obligation。
- [Tile execution](tile-execution.md) 将 accepted operation 路由到其 operation-specific owner。
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
