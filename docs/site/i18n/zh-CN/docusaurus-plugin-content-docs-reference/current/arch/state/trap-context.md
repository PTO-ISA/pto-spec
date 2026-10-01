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

`asl/arch/state/trap-context.asl` 拥有六个函数：`SavePortableTrapContext`、`SaveTrapContext`、`PortableTrapContextRecoverable`、`TrapContextRecoverable`、`RecoverPortableTrapContext` 与 `RecoverTrapContext`。它们作用于 `_TrapContexts`，该状态在 `asl/arch/programming-model/execution-context.asl` 中声明为 `array [[PTO_ACR_COUNT]] of TrapContext`，其中 `PTO_ACR_COUNT` 为 `16`；它们还作用于目标环的上下文寄存器组。

元素类型 `TrapContext` 声明在 `asl/arch/data-types/trap-context.asl`，共有 `41` 个字段；保存束控制状态、内存重放状态、队列与谓词寄存器，才使陷阱能够在束内部恢复执行，而不只是在束边界恢复。

<!-- PTO-READER-BLOCK: arch-trap-context-concepts-state role=concepts-state -->
## 两条保存路径记录什么

`SavePortableTrapContext(target, source)` 把目标槽位标记为有效，记录 `source_acr`，把活动上下文的全部 `41` 个字段赋值给 `_TrapContexts[[target]]`，并且不写任何上下文寄存器。

`SaveTrapContext(target, source)` 赋值同一组字段，但不含 `memory_replay_state`，然后通过 `WriteContextRegister` 写目标环的上下文寄存器。寄存器 `0x0f00` 收到 `core_state`，其中位 `3:0` 被替换为 `AccessControlRingBits(source)`；寄存器 `0x0f40` 收到一个控制字，它把位 `4` 标记为 `1`，并携带源环、`_BundleActive`、`_BundleBodyActive`、`BundleKindCode(_BARG.block_type)`、`BundleTransferCode(_BARG.transfer_type)` 与 `_BARG.taken`。

队列循环让 `index` 从 `0` 到 `PTO_TEMPORARY_QUEUE_DEPTH - 1`（即 `3`，因为 `PTO_TEMPORARY_QUEUE_DEPTH` 为 `4`），把 `_TQueue[[index]]` 写到 `0x0f45 + index`、`_UQueue[[index]]` 写到 `0x0f49 + index`，因此 T 队列覆盖 `0x0f45` 到 `0x0f48`，U 队列覆盖 `0x0f49` 到 `0x0f4c`；最后两次写入把 `Zeros{PTO_XLEN}` 存入 `0x0f4d` 和 `0x0f4e`。

Design point：`SavePortableTrapContext` 记录了 `memory_replay_state`，但 `RecoverPortableTrapContext` 从不读取它；而 `RecoverTrapContext` 会从槽位给 `_MemoryReplayState` 赋值，尽管 `SaveTrapContext` 从未写入该字段。因此可移植保存之后再执行可移植恢复，会让活动的 `_MemoryReplayState` 保持运行上下文当时的值。

<!-- PTO-READER-BLOCK: arch-trap-context-rules-interactions role=rules-interactions -->
## 可恢复性与恢复

`PortableTrapContextRecoverable(target)` 要求三个条件：槽位为 `valid`，已保存的 `bpc[0]` 位为 `'0'`，已保存的 `tpc[0]` 位为 `'0'`。`TrapContextRecoverable(target)` 读取上下文寄存器 `0x0f40`、`0x0f00`、`0x0f41` 与 `0x0f43`，并额外要求 `control[4]` 为 `'1'`、`EBARGControlLegal(control)` 成立、`control[3:0]` 等于 `ecstate[3:0]`，然后对从 `0x0f41` 与 `0x0f43` 读回的值施加同样的两项位测试。

两个恢复函数在各自的门失败时都会在任何赋值之前返回 `FALSE`。成功时，可移植路径写入 `WriteTPC` 与 `WriteBPC`，从槽位恢复 `core_state`、束状态、队列与谓词寄存器，把 `_CurrentACR` 设为已保存的 `source_acr`，清除 `valid` 并返回 `TRUE`。

上下文寄存器路径从控制字、已保存的寄存器以及 `BundleKindOf` 与 `BundleTransferOf` 解码器重建 `_BundleActive`、`_BundleBodyActive`、四个 `_BARG` 字段、`_ReturnAddress` 与队列条目；它用 `ecstate[3:0]` 设置 `_CurrentACR`，从槽位给 `_MemoryReplayState` 赋值，在 `0x0f40` 中清除 `control[4]`，清除 `valid` 并返回 `TRUE`。

Design point：一次成功的恢复会消耗该槽位：`RecoverTrapContext` 在控制字中清除 `control[4]` 并把它写回，两条恢复路径都会清除 `valid`，因此对同一目标的重复调用会停在 `control[4] == '1'` 或 `valid` 上，并且不恢复任何内容。

<!-- PTO-READER-BLOCK: arch-trap-context-boundaries role=boundaries -->
## 架构边界

`RecoverPortableTrapContext` 测试的是 `PortableTrapContextRecoverable`，而不是 `TrapContextRecoverable`，因为可移植保存不写任何上下文寄存器：要求 `control[4]` 为 `'1'` 的门并不能描述该保存所创建的上下文。

`TrapContextRecoverable` 通过 `asl/block/model/schema/bundle-encoding.asl` 中的 `EBARGControlLegal` 重新校验重建出的控制字：位 `63:15` 为零、束种类编号至多为 `2` 或介于 `5` 与 `8` 之间、传送编号至多为 `6`，并且 `control[6]` 为 `'0'` 或 `control[5]` 为 `'1'`。

在 `asl/` 内，可移植辅助函数没有调用者；`tests/asl/arch/state/trap-context/arch-fault-trap-portable-004.asl` 覆盖它们。`SaveTrapContext` 由 `asl/arch/memory-model/fault-precision.asl` 与 `asl/block/model/lifecycle/lifetime.asl` 调用；`RecoverTrapContext` 由 `asl/block/model/lifecycle/lifetime.asl` 与 `asl/scalar/model/sys/semantics.asl` 调用。

<!-- PTO-READER-BLOCK: arch-trap-context-example-usage role=example-usage -->
## 非规范恢复演练

`tests/asl/arch/state/trap-context/arch-fault-trap-portable-004.asl` 中的可移植测试在 `SetCurrentACR(15)` 之后用 `SavePortableTrapContext(2, 15)` 保存，清除已保存的参数、帧与返回目标取值，并表明 `RecoverPortableTrapContext(2)` 会把它们恢复回来并把 `_CurrentACR` 设回 `15`。

故障走另一条保存路径：`SetFaultWithCause` 把在环 `15` 为当前环时发生的故障经 `TrapTargetForFault(15)` 路由到环 `1`，`SaveTrapContext(1, 15)` 既填充槽位 `1`，也写环 `1` 的上下文寄存器。这些寄存器在复位之后为零，因此对只由可移植保存填充的槽位，`TrapContextRecoverable(2)` 为 `FALSE`，而 `RecoverPortableTrapContext(2)` 对它返回 `TRUE`。

<!-- PTO-READER-BLOCK: arch-trap-context-related-owners role=related-owners-navigation -->
## 相关所有者

- [程序计数器](program-counter.md)拥有 `ReadTPC`、`ReadBPC`、`WriteTPC` 与 `WriteBPC`。
- [访问控制](../system-registers/access-control.md)拥有 `AccessControlRingBits`、`CurrentACR` 与 `TrapTargetForFault`。
- [上下文寄存器](../system-registers/context.md)拥有 `0x0f00` 到 `0x0f4e` 写入背后的寄存器辅助函数。
- [内存定序](../memory-model/ordering.md)是第 1 行给出的依赖。
- [故障精确性](../memory-model/fault-precision.md)在故障、服务请求与中断进入时调用上下文寄存器保存。
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
    _TrapContexts[[target]].memory_replay_state = _MemoryReplayState;
    _TrapContexts[[target]].t_queue = _TQueue;
    _TrapContexts[[target]].t_queue_valid = _TQueueValid;
    _TrapContexts[[target]].u_queue = _UQueue;
    _TrapContexts[[target]].u_queue_valid = _UQueueValid;
    _TrapContexts[[target]].predicates = _PredicateRegisters;
end;

func SaveTrapContext(target: AccessControlRing,
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
    _TrapContexts[[target]].bundle_commit_target_set = _BundleCommitTargetSet;
    _TrapContexts[[target]].bundle_condition_set = _BundleConditionSet;
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

    var ecstate = _SystemRegisters.core_state;
    ecstate[3:0] = AccessControlRingBits(source);
    ecstate[4] = if _BundleBodyActive then '1' else '0';
    WriteContextRegister(target, 0x0f00, ecstate);

    var control: Word = Zeros{PTO_XLEN};
    control[3:0] = AccessControlRingBits(source);
    control[4] = '1';
    control[5] = if _BundleActive then '1' else '0';
    control[6] = if _BundleBodyActive then '1' else '0';
    control[10:7] = BundleKindCode(_BARG.block_type);
    control[13:11] = BundleTransferCode(_BARG.transfer_type);
    control[14] = if _BARG.taken then '1' else '0';
    WriteContextRegister(target, 0x0f40, control);
    WriteContextRegister(target, 0x0f41, ReadBPC());
    WriteContextRegister(target, 0x0f42, _BARG.bpcn);
    WriteContextRegister(target, 0x0f43, ReadTPC());
    WriteContextRegister(target, 0x0f44, _ReturnAddress);
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        WriteContextRegister(target, 0x0f45 + index,
            _TQueue[[index]]);
        WriteContextRegister(target, 0x0f49 + index,
            _UQueue[[index]]);
    end;
    WriteContextRegister(target, 0x0f4d, Zeros{PTO_XLEN});
    WriteContextRegister(target, 0x0f4e, Zeros{PTO_XLEN});
end;

readonly func PortableTrapContextRecoverable(target: AccessControlRing)
    => boolean
begin
    return _TrapContexts[[target]].valid &&
           _TrapContexts[[target]].bpc[0] == '0' &&
           _TrapContexts[[target]].tpc[0] == '0';
end;

func TrapContextRecoverable(target: AccessControlRing)
    => boolean
begin
    let control = ReadContextRegister(target, 0x0f40);
    let ecstate = ReadContextRegister(target, 0x0f00);
    let recovered_bpc = ReadContextRegister(target, 0x0f41);
    let recovered_tpc = ReadContextRegister(target, 0x0f43);
    return _TrapContexts[[target]].valid &&
           control[4] == '1' &&
           EBARGControlLegal(control) &&
           control[3:0] == ecstate[3:0] &&
           recovered_bpc[0] == '0' &&
           recovered_tpc[0] == '0';
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

func RecoverTrapContext(target: AccessControlRing) => boolean
begin
    if !TrapContextRecoverable(target) then
        return FALSE;
    end;
    var control = ReadContextRegister(target, 0x0f40);
    let ecstate = ReadContextRegister(target, 0x0f00);
    let recovered_bpc = ReadContextRegister(target, 0x0f41);
    let recovered_tpc = ReadContextRegister(target, 0x0f43);
    WriteTPC(recovered_tpc);
    WriteBPC(recovered_bpc);
    _SystemRegisters.core_state = ecstate;
    _BundleArgument = _TrapContexts[[target]].bundle_argument;
    _CommitArgument = _TrapContexts[[target]].commit_argument;
    _BundleActive = control[5] == '1';
    _BundleBodyActive = control[6] == '1';
    _BundleCommitTargetSet =
        _TrapContexts[[target]].bundle_commit_target_set;
    _BundleConditionSet =
        _TrapContexts[[target]].bundle_condition_set;
    _SystemBlockTerminalPending =
        _TrapContexts[[target]].system_block_terminal_pending;
    _BARG.block_type = BundleKindOf(control[10:7]);
    _BARG.transfer_type = BundleTransferOf(control[13:11]);
    _BARG.taken = control[14] == '1';
    _BARG.bpcn = ReadContextRegister(target, 0x0f42);
    _FrameStackReturnTarget =
        _TrapContexts[[target]].frame_stack_return_target;
    _ReturnAddress = ReadContextRegister(target, 0x0f44);
    _BundleArgumentKind = _TrapContexts[[target]].bundle_argument_kind;
    _BundleSequentialPC = _TrapContexts[[target]].bundle_sequential_pc;
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
    _MemoryReplayState = _TrapContexts[[target]].memory_replay_state;
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TQueue[[index]] = ReadContextRegister(target, 0x0f45 + index);
        _UQueue[[index]] = ReadContextRegister(target, 0x0f49 + index);
    end;
    _TQueueValid = _TrapContexts[[target]].t_queue_valid;
    _UQueueValid = _TrapContexts[[target]].u_queue_valid;
    _PredicateRegisters = _TrapContexts[[target]].predicates;
    _CurrentACR = UInt(ecstate[3:0]) as AccessControlRing;
    control[4] = '0';
    WriteContextRegister(target, 0x0f40, control);
    _TrapContexts[[target]].valid = FALSE;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
