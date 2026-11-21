<!-- GENERATED FROM: asl/arch/memory-model/atomic-tstore-obligations.asl -->
# Atomic Tstore Obligations

**Normative ASL source:** `asl/arch/memory-model/atomic-tstore-obligations.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-ATOMIC-TSTORE-OBLIGATIONS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-memory-model-atomic-tstore-obligations-purpose role=purpose-scope -->
## 为何排空查询需要区分动态发生实例

已接纳的 GM obligation 推进期间，原子 TSTORE 可能在提交时等待。这些查询按动态发生实例区分同一静态指令地址的多次执行。

<!-- PTO-READER-BLOCK: arch-memory-model-atomic-tstore-obligations-state role=concepts-state -->
## 查询身份

当前 Core 和 PE 选择 obligation 表。Invocation、bundle PC 与执行域 token 区分表内不同的动态发生实例。

<!-- PTO-READER-BLOCK: arch-memory-model-atomic-tstore-obligations-rules role=rules-interactions -->
## 可见的记录

`CurrentAtomicTStoreDrainPending` 识别已提交、已验证或已发出的捕获任务。`FindCurrentAtomicTStoreOccurrence` 也能找到已完成或已取消的记录，供同一执行域处理重试。

<!-- PTO-READER-BLOCK: arch-memory-model-atomic-tstore-obligations-boundary role=boundaries -->
## Invocation 清理

`KernelHasIrrevocableAtomicTStore` 跨选定 Core 的各个 PE 查找目标 invocation 尚未完成的不可撤销任务。具体推进和清理由 GM obligation 与 kernel 生命周期的规范源负责。

<!-- PTO-READER-BLOCK: arch-memory-model-atomic-tstore-obligations-example role=example-usage -->
## 提交重试示例

原子存储先完成而 bundle 随后重试提交时，发生实例查询仍可借相同 token 找到已完成的记录。后来在同一地址执行的动态 bundle 使用不同的 token。

<!-- PTO-READER-BLOCK: arch-memory-model-atomic-tstore-obligations-related role=related-owners-navigation -->
## 相关规范源

有关请求状态，参见 [GM obligations](gm-obligations.md)，有关 invocation 清理，参见 [kernel 生命周期](../state/kernel-lifecycle.md)。
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
