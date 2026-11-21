<!-- GENERATED FROM: asl/arch/memory-model/atomic-tstore-obligations.asl -->
# Atomic Tstore Obligations

**Normative ASL source:** `asl/arch/memory-model/atomic-tstore-obligations.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ATOMIC-TSTORE-OBLIGATIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-model-atomic-tstore-obligations-purpose role=purpose-scope -->
## Why drain lookup needs an occurrence

Atomic TSTORE may pause at commit while an admitted GM obligation progresses. These lookups distinguish the current occurrence from other uses of the same static instruction address.

<!-- PTO-READER-BLOCK: arch-memory-model-atomic-tstore-obligations-state role=concepts-state -->
## Lookup identity

The current Core and PE select the obligation table. The invocation, bundle PC and execution-domain token distinguish dynamic occurrences within that table.

<!-- PTO-READER-BLOCK: arch-memory-model-atomic-tstore-obligations-rules role=rules-interactions -->
## Which records remain visible

`CurrentAtomicTStoreDrainPending` recognizes submitted, validated or issued captured work. `FindCurrentAtomicTStoreOccurrence` can also find a completed or cancelled record so the same domain can resolve a retry.

<!-- PTO-READER-BLOCK: arch-memory-model-atomic-tstore-obligations-boundary role=boundaries -->
## Invocation teardown

`KernelHasIrrevocableAtomicTStore` scans the selected Core across its PEs for unfinished irrevocable work of the requested invocation. The GM obligation and kernel lifecycle owners perform progress and teardown.

<!-- PTO-READER-BLOCK: arch-memory-model-atomic-tstore-obligations-example role=example-usage -->
## Commit retry example

When an atomic store finishes before its bundle retries commit, the occurrence lookup can still find the completed record for the same token. A later dynamic bundle at the same address uses a different token.

<!-- PTO-READER-BLOCK: arch-memory-model-atomic-tstore-obligations-related role=related-owners-navigation -->
## Related owners

See [GM obligations](gm-obligations.md) for request state and [kernel lifecycle](../state/kernel-lifecycle.md) for invocation teardown.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/atomic-tstore-obligations.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-ATOMIC-TSTORE-OBLIGATIONS","surface":"arch","classification":["memory-model","atomic-tstore-obligations"],"depends_on":["PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","PTO-ARCH-STATE-PROGRAM-COUNTER","PTO-BLOCK-MODEL-STATE-CONTROL-STATE"]}
readonly func CurrentAtomicTStoreDrainPending() => boolean
begin
    for slot = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
        let obligation = _GMObligations[[_CurrentModelCore]]
            [[_CurrentMemoryAgent]][[slot]];
        if obligation.active && obligation.captured_atomic_tstore &&
           obligation.request_class == GMRequest_Atomic &&
           obligation.descriptor.operation_class == BundleOperation_TileMemory &&
           obligation.descriptor.selector_valid &&
           UInt(obligation.descriptor.selector[4:0]) == 1 &&
           obligation.invocation == _CurrentKernelInvocation &&
           obligation.instruction_pc == ReadBPC() &&
           obligation.execution_domain_token == _BundleExecutionDomainToken &&
           (obligation.state == GMObligation_Submitted ||
            obligation.state == GMObligation_Validated ||
            obligation.state == GMObligation_Issued) then
            return TRUE;
        end;
    end;
    return FALSE;
end;

readonly func KernelHasIrrevocableAtomicTStore(
    core: PTOModelCoreIdentity, invocation: integer) => boolean
begin
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        for slot = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
            let obligation = _GMObligations[[core]][[pe]][[slot]];
            if obligation.active && obligation.invocation == invocation &&
               obligation.captured_atomic_tstore && obligation.irrevocable &&
               obligation.state != GMObligation_Completed &&
               obligation.state != GMObligation_Cancelled then
                return TRUE;
            end;
        end;
    end;
    return FALSE;
end;

// Completed and cancelled requests remain discoverable while the same dynamic
// execution domain is still selected. Completion prevents the commit retry
// from reissuing effects; cancellation prevents a squashed stale domain from
// readmitting work. A later dynamic BSTART has a different domain token.
readonly func FindCurrentAtomicTStoreOccurrence()
    => integer {-1..PTO_MODEL_GM_OBLIGATIONS-1}
begin
    for slot = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
        let obligation = _GMObligations[[_CurrentModelCore]]
            [[_CurrentMemoryAgent]][[slot]];
        if obligation.active && obligation.captured_atomic_tstore &&
           obligation.request_class == GMRequest_Atomic &&
           obligation.descriptor.operation_class == BundleOperation_TileMemory &&
           obligation.descriptor.selector_valid &&
           UInt(obligation.descriptor.selector[4:0]) == 1 &&
           obligation.invocation == _CurrentKernelInvocation &&
           obligation.instruction_pc == ReadBPC() &&
           obligation.execution_domain_token == _BundleExecutionDomainToken then
            return slot as integer {-1..PTO_MODEL_GM_OBLIGATIONS-1};
        end;
    end;
    return -1;
end;

readonly func FindCurrentAtomicTStoreObligation()
    => integer {-1..PTO_MODEL_GM_OBLIGATIONS-1}
begin
    for slot = 0 to PTO_MODEL_GM_OBLIGATIONS - 1 do
        let obligation = _GMObligations[[_CurrentModelCore]]
            [[_CurrentMemoryAgent]][[slot]];
        if obligation.active && obligation.request_class == GMRequest_Atomic &&
           obligation.descriptor.operation_class == BundleOperation_TileMemory &&
           obligation.descriptor.selector_valid &&
           UInt(obligation.descriptor.selector[4:0]) == 1 &&
           obligation.invocation == _CurrentKernelInvocation &&
           obligation.instruction_pc == ReadBPC() &&
           obligation.execution_domain_token == _BundleExecutionDomainToken &&
           obligation.state != GMObligation_Completed &&
           obligation.state != GMObligation_Cancelled then
            return slot as integer {-1..PTO_MODEL_GM_OBLIGATIONS-1};
        end;
    end;
    return -1;
end;
```
<!-- GENERATED-ASL-END: unit -->
