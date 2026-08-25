<!-- GENERATED FROM: asl/arch/state/trap-context.asl -->
# Trap Context

**Normative ASL source:** `asl/arch/state/trap-context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-TRAP-CONTEXT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-trap-context-purpose-scope role=purpose-scope -->
## 用途与范围

本单元拥有可移植陷阱上下文的保存、可恢复性检查与恢复，还包含由实现定义的钩子；这些钩子的默认函数体调用可移植路径。

<!-- PTO-READER-BLOCK: arch-trap-context-concepts-state role=concepts-state -->
## 已保存上下文

`SavePortableTrapContext` 把目标 ACR 上下文标为有效，并快照源 ACR、TPC、BPC、`core_state`、指令束控制与参数状态、标量/Tile/Shared 绑定、本地与共享代次、模板、临时队列以及谓词寄存器。

快照以目标 `AccessControlRing` 为索引；保存的 `source_acr` 标识恢复之后应选择的 ACR。

<!-- PTO-READER-BLOCK: arch-trap-context-rules-interactions role=rules-interactions -->
## 可恢复性与恢复

`PortableTrapContextRecoverable` 要求保存的上下文有效，并且保存的 BPC 与 TPC 最低位都为零。不满足条件时，`RecoverPortableTrapContext` 会立即返回 `FALSE`。

成功时，恢复会还原该所有者保存的每个可移植字段，把 `_CurrentACR` 设为保存的源 ACR，清除目标上下文的有效位，并返回 `TRUE`。

`SaveTrapContext`、`TrapContextRecoverable` 和 `RecoverTrapContext` 是由实现定义的配置档钩子。它们在本所有者中的函数体委托给对应的可移植辅助函数。

<!-- PTO-READER-BLOCK: arch-trap-context-boundaries role=boundaries -->
## 架构边界

可移植恢复刻意直接检查 `PortableTrapContextRecoverable`，而不通过活动配置档覆写分派。配置档可能要求额外的上下文寄存器状态，但可移植保存辅助函数不会创建这种目标专用状态。

可移植恢复失败时，不执行任何恢复赋值，也不会使已保存上下文失效。

<!-- PTO-READER-BLOCK: arch-trap-context-example-usage role=example-usage -->
## 非规范恢复流程

对于从 ACR3 保存到目标 ACR1 的有效对齐快照，成功的可移植恢复会还原快照、选择 ACR3 作为当前 ACR，并通过清除有效位消费 ACR1 快照。如果任一保存地址的最低位为一，则恢复在改变活动上下文之前返回 `FALSE`。

<!-- PTO-READER-BLOCK: arch-trap-context-related-owners role=related-owners-navigation -->
## 相关所有者

- [程序计数器](program-counter.md)拥有保存和恢复期间使用的 TPC 与 BPC 访问函数。
- [访问控制](../system-registers/access-control.md)拥有 ACR 状态和陷阱目标选择。
- [内存排序](../memory-model/ordering.md)是本单元声明的依赖项。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/trap-context.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-TRAP-CONTEXT","surface":"arch","classification":["state","trap-context"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ORDERING"]}
func SavePortableTrapContext(target: AccessControlRing,
                             source: AccessControlRing)
begin
    _TrapContexts[[target]].valid = TRUE;
    _TrapContexts[[target]].source_acr = source;
    _TrapContexts[[target]].tpc = ReadTPC();
    _TrapContexts[[target]].bpc = ReadBPC();
    _TrapContexts[[target]].core_state = _SystemRegisters.core_state;
    _TrapContexts[[target]].bundle_argument = _BundleArgument;
    _TrapContexts[[target]].commit_argument = _CommitArgument;
    _TrapContexts[[target]].bundle_active = _BundleActive;
    _TrapContexts[[target]].bundle_body_active = _BundleBodyActive;
    _TrapContexts[[target]].bundle_commit_target_set =
        _BundleCommitTargetSet;
    _TrapContexts[[target]].bundle_condition_set =
        _BundleConditionSet;
    _TrapContexts[[target]].system_block_terminal_pending =
        _SystemBlockTerminalPending;
    _TrapContexts[[target]].barg = _BARG;
    _TrapContexts[[target]].bundle_sequential_pc = _BundleSequentialPC;
    _TrapContexts[[target]].frame_stack_return_target =
        _FrameStackReturnTarget;
    _TrapContexts[[target]].return_address = _ReturnAddress;
    _TrapContexts[[target]].bundle_argument_kind = _BundleArgumentKind;
    _TrapContexts[[target]].bundle_operation = _BundleOperation;
    _TrapContexts[[target]].bundle_dimensions = _BundleDimensions;
    _TrapContexts[[target]].bundle_dimension_present =
        _BundleDimensionPresent;
    _TrapContexts[[target]].bundle_scalar_bindings = _BundleScalarBindings;
    _TrapContexts[[target]].bundle_tile_bindings = _BundleTileBindings;
    _TrapContexts[[target]].bundle_shared_bindings = _BundleSharedBindings;
    _TrapContexts[[target]].bundle_range_group = _BundleRangeGroup;
    _TrapContexts[[target]].bundle_zero_participation_seen =
        _BundleZeroParticipationSeen;
    _TrapContexts[[target]].bundle_control_attributes =
        _BundleControlAttributes;
    _TrapContexts[[target]].bundle_data_attributes = _BundleDataAttributes;
    _TrapContexts[[target]].bundle_data_attributes_present =
        _BundleDataAttributesPresent;
    _TrapContexts[[target]].bundle_hint = _BundleHint;
    _TrapContexts[[target]].bundle_fixed_point_attributes =
        _BundleFixedPointAttributes;
    _TrapContexts[[target]].local_generations = _LocalGenerations;
    _TrapContexts[[target]].shared_generations = _SharedGenerations;
    _TrapContexts[[target]].bundle_execution_domain_token =
        _BundleExecutionDomainToken;
    _TrapContexts[[target]].memory_copy_template = _MemoryCopyTemplate;
    _TrapContexts[[target]].frame_template = _FrameTemplate;
    _TrapContexts[[target]].t_queue = _TQueue;
    _TrapContexts[[target]].t_queue_valid = _TQueueValid;
    _TrapContexts[[target]].u_queue = _UQueue;
    _TrapContexts[[target]].u_queue_valid = _UQueueValid;
    _TrapContexts[[target]].predicates = _PredicateRegisters;
end;

impdef func SaveTrapContext(target: AccessControlRing,
                            source: AccessControlRing)
begin
    SavePortableTrapContext(target, source);
end;

readonly func PortableTrapContextRecoverable(target: AccessControlRing)
    => boolean
begin
    return _TrapContexts[[target]].valid &&
           _TrapContexts[[target]].bpc[0] == '0' &&
           _TrapContexts[[target]].tpc[0] == '0';
end;

impdef func TrapContextRecoverable(target: AccessControlRing)
    => boolean
begin
    return PortableTrapContextRecoverable(target);
end;

func RecoverPortableTrapContext(target: AccessControlRing) => boolean
begin
    // This helper is the architecture-portable recovery path.  It must not
    // dispatch through the active profile override, because that override may
    // require target-specific context-register state that SavePortableTrapContext
    // deliberately does not create.
    if !PortableTrapContextRecoverable(target) then
        return FALSE;
    end;
    WriteTPC(_TrapContexts[[target]].tpc);
    WriteBPC(_TrapContexts[[target]].bpc);
    _SystemRegisters.core_state = _TrapContexts[[target]].core_state;
    _BundleArgument = _TrapContexts[[target]].bundle_argument;
    _CommitArgument = _TrapContexts[[target]].commit_argument;
    _BundleActive = _TrapContexts[[target]].bundle_active;
    _BundleBodyActive = _TrapContexts[[target]].bundle_body_active;
    _BundleCommitTargetSet =
        _TrapContexts[[target]].bundle_commit_target_set;
    _BundleConditionSet =
        _TrapContexts[[target]].bundle_condition_set;
    _SystemBlockTerminalPending =
        _TrapContexts[[target]].system_block_terminal_pending;
    _BARG = _TrapContexts[[target]].barg;
    _BundleSequentialPC = _TrapContexts[[target]].bundle_sequential_pc;
    _FrameStackReturnTarget =
        _TrapContexts[[target]].frame_stack_return_target;
    _ReturnAddress = _TrapContexts[[target]].return_address;
    _BundleArgumentKind = _TrapContexts[[target]].bundle_argument_kind;
    _BundleOperation = _TrapContexts[[target]].bundle_operation;
    _BundleDimensions = _TrapContexts[[target]].bundle_dimensions;
    _BundleDimensionPresent =
        _TrapContexts[[target]].bundle_dimension_present;
    _BundleScalarBindings = _TrapContexts[[target]].bundle_scalar_bindings;
    _BundleTileBindings = _TrapContexts[[target]].bundle_tile_bindings;
    _BundleSharedBindings = _TrapContexts[[target]].bundle_shared_bindings;
    _BundleRangeGroup = _TrapContexts[[target]].bundle_range_group;
    _BundleZeroParticipationSeen =
        _TrapContexts[[target]].bundle_zero_participation_seen;
    _BundleControlAttributes =
        _TrapContexts[[target]].bundle_control_attributes;
    _BundleDataAttributes = _TrapContexts[[target]].bundle_data_attributes;
    _BundleDataAttributesPresent =
        _TrapContexts[[target]].bundle_data_attributes_present;
    _BundleHint = _TrapContexts[[target]].bundle_hint;
    _BundleFixedPointAttributes =
        _TrapContexts[[target]].bundle_fixed_point_attributes;
    _LocalGenerations = _TrapContexts[[target]].local_generations;
    _SharedGenerations = _TrapContexts[[target]].shared_generations;
    _BundleExecutionDomainToken =
        _TrapContexts[[target]].bundle_execution_domain_token;
    _MemoryCopyTemplate = _TrapContexts[[target]].memory_copy_template;
    _FrameTemplate = _TrapContexts[[target]].frame_template;
    _TQueue = _TrapContexts[[target]].t_queue;
    _TQueueValid = _TrapContexts[[target]].t_queue_valid;
    _UQueue = _TrapContexts[[target]].u_queue;
    _UQueueValid = _TrapContexts[[target]].u_queue_valid;
    _PredicateRegisters = _TrapContexts[[target]].predicates;
    _CurrentACR = _TrapContexts[[target]].source_acr;
    _TrapContexts[[target]].valid = FALSE;
    return TRUE;
end;

impdef func RecoverTrapContext(target: AccessControlRing) => boolean
begin
    return RecoverPortableTrapContext(target);
end;
```
<!-- GENERATED-ASL-END: unit -->
