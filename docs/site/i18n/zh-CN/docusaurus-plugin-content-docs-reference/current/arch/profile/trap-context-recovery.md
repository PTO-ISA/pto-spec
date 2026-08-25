<!-- GENERATED FROM: asl/arch/profile/trap-context-recovery.asl -->
# Trap Context Recovery

**Normative ASL source:** `asl/arch/profile/trap-context-recovery.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROFILE-TRAP-CONTEXT-RECOVERY}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-trap-recovery-purpose role=purpose-scope -->
## 用途与范围

本单元实现 PTO v0 对已保存陷阱上下文的验证与恢复。恢复是经过检查且只能使用一次的状态转换：无效封装返回假，并且不恢复执行状态。

<!-- PTO-READER-BLOCK: arch-trap-recovery-concepts role=concepts-state -->
## 可恢复性检查

`TrapContextRecoverable` 要求保存的上下文有效、控制位 `4` 已设置、`EBARG` 控制合法、控制值与 `ECSTATE` 的低 `4` 位 ACR 相匹配，并且恢复出的 `BPC` 与 `TPC` 都是偶数。它读取上下文寄存器 `0x0f40`、`0x0f00`、`0x0f41` 与 `0x0f43`。

<!-- PTO-READER-BLOCK: arch-trap-recovery-rules role=rules-interactions -->
## 恢复顺序

`RecoverTrapContext` 首先再次执行可恢复性检查。成功后，它从保存的上下文与上下文寄存器恢复 `TPC`、`BPC`、核心状态、指令束参数与活动状态、指令束描述符与绑定、代次状态、模板、队列、谓词、返回地址以及当前 ACR。

<!-- PTO-READER-BLOCK: arch-trap-recovery-boundaries role=boundaries -->
## 单次使用与失败边界

验证失败会在恢复前返回假。成功恢复会清除控制位 `4`，写回更新后的控制寄存器，把保存的上下文置为无效，并返回真。因此第二次恢复需要重新保存的有效上下文。

<!-- PTO-READER-BLOCK: arch-trap-recovery-example role=example-usage -->
## 非规范恢复过程

本示例块只用于帮助阅读：先应用上文规则，再到规范 ASL 所有者中确认结果。它不会增加任何架构契约。

<!-- PTO-READER-BLOCK: arch-trap-recovery-related role=related-owners-navigation -->
## 相关所有者

- 参考配置档定义此处使用的 PTO v0 上下文寄存器编码辅助函数。
- 故障精度与陷阱上下文状态单元拥有恢复之前的入口和保存状态创建过程。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/trap-context-recovery.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-TRAP-CONTEXT-RECOVERY","surface":"arch","classification":["profile","trap-context-recovery"],"depends_on":["PTO-ARCH-PROFILE-REFERENCE-PROFILE"]}
implementation func TrapContextRecoverable(target: AccessControlRing)
    => boolean
begin
    let control = PTOv0ReadContextRegister(target, 0x0f40);
    let ecstate = PTOv0ReadContextRegister(target, 0x0f00);
    let recovered_bpc = PTOv0ReadContextRegister(target, 0x0f41);
    let recovered_tpc = PTOv0ReadContextRegister(target, 0x0f43);
    return _TrapContexts[[target]].valid &&
           control[4] == '1' &&
           PTOv0EBARGControlLegal(control) &&
           control[3:0] == ecstate[3:0] &&
           recovered_bpc[0] == '0' &&
           recovered_tpc[0] == '0';
end;

implementation func RecoverTrapContext(target: AccessControlRing) => boolean
begin
    if !TrapContextRecoverable(target) then
        return FALSE;
    end;
    var control = PTOv0ReadContextRegister(target, 0x0f40);
    let ecstate = PTOv0ReadContextRegister(target, 0x0f00);
    let recovered_bpc = PTOv0ReadContextRegister(target, 0x0f41);
    let recovered_tpc = PTOv0ReadContextRegister(target, 0x0f43);
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
    _BARG.block_type = PTOv0BundleKindOf(control[10:7]);
    _BARG.transfer_type = PTOv0BundleTransferOf(control[13:11]);
    _BARG.taken = control[14] == '1';
    _BARG.bpcn = PTOv0ReadContextRegister(target, 0x0f42);
    _FrameStackReturnTarget =
        _TrapContexts[[target]].frame_stack_return_target;
    _ReturnAddress = PTOv0ReadContextRegister(target, 0x0f44);
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
    for index = 0 to PTO_TEMPORARY_QUEUE_DEPTH - 1 do
        _TQueue[[index]] = PTOv0ReadContextRegister(target, 0x0f45 + index);
        _UQueue[[index]] = PTOv0ReadContextRegister(target, 0x0f49 + index);
    end;
    _TQueueValid = _TrapContexts[[target]].t_queue_valid;
    _UQueueValid = _TrapContexts[[target]].u_queue_valid;
    _PredicateRegisters = _TrapContexts[[target]].predicates;
    _CurrentACR = UInt(ecstate[3:0]) as AccessControlRing;
    control[4] = '0';
    PTOv0WriteContextRegister(target, 0x0f40, control);
    _TrapContexts[[target]].valid = FALSE;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
