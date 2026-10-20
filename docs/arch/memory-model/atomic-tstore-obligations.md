<!-- GENERATED FROM: asl/arch/memory-model/atomic-tstore-obligations.asl -->
# Atomic Tstore Obligations

**Normative ASL source:** `asl/arch/memory-model/atomic-tstore-obligations.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ATOMIC-TSTORE-OBLIGATIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

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
           obligation.state != GMObligation_Completed &&
           obligation.state != GMObligation_Cancelled then
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
