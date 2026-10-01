<!-- GENERATED FROM: asl/arch/data-types/trap-context.asl -->
# Trap Context

**Normative ASL source:** `asl/arch/data-types/trap-context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DATA-TYPES-TRAP-CONTEXT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-trap-context-type-purpose-scope role=purpose-scope -->
## 目的与范围

`TrapContext` 是含 41 个域的单个记录，它命名了陷阱捕获写入、陷阱恢复读取的每一个值。

本页只拥有记录形状。本单元不声明任何函数，因此它既不捕获也不恢复上下文。

设计要点：该记录只声明一次，捕获侧和恢复侧都使用它的域名。因此增加一个域会同时改变两侧看到的形状，任何一侧都无法保留另一侧不保存的状态的私有副本。

<!-- PTO-READER-BLOCK: arch-trap-context-type-concepts-state role=concepts-state -->
## 概念与可见状态

- 起始的域是 `valid`、`source_acr`、`tpc`、`bpc`、`core_state`、`bundle_argument` 和 `commit_argument`，随后是指令束标志 `bundle_active`、`bundle_body_active`、`bundle_commit_target_set`、`bundle_condition_set` 和 `system_block_terminal_pending`。
- 中间的域携带 `barg`、指令束定序取值以及类型化的指令束快照记录，其中包括 `bundle_dimensions`、`bundle_scalar_bindings`、`bundle_data_attributes` 与 `bundle_data_attributes_present`。
- 末尾的域携带 `local_generations`、`shared_generations`、`bundle_execution_domain_token`、`memory_copy_template`、`frame_template`、`memory_replay_state`、`t_queue`、`t_queue_valid`、`u_queue`、`u_queue_valid` 和 `predicates`。

设计要点：`t_queue` 与 `t_queue_valid`、`u_queue` 与 `u_queue_valid` 是四个独立域，而不是一个内嵌有效性位的数组。由于捕获的字与捕获的就绪状态分开存放，恢复可以把队列字写回却仍把某个槽标记为未就绪；就绪状态是已保存状态，绝不从存储字推导。

<!-- PTO-READER-BLOCK: arch-trap-context-type-rules-interactions role=rules-interactions -->
## 规则与交互

`valid` 是记录的一个域，也是唯一说明该记录是否保存可恢复上下文的标志。捕获会置位它，成功的可移植恢复会再次清除它。

存在的判定由与所限定值并列保存的布尔量回答，而不是由载荷内容回答：`bundle_commit_target_set`、`bundle_condition_set`、`bundle_dimension_present` 和 `bundle_data_attributes_present` 各有自己的域。

这些存放地址的域，其中包括 `tpc`、`bpc`、`core_state`、`bundle_argument` 与 `return_address`，都声明为 `Word`，因此保存的地址保持完整的架构宽度。

设计要点：由于捕获把类型化记录 `bundle_data_attributes` 与独立的 `bundle_data_attributes_present` 标志并列复制，保存的上下文可以持有 `bundle_data_attributes_present = FALSE`，而载荷记录仍携带其被捕获的域值。不检查该标志就读取载荷的恢复，可能应用从未生效过的属性。

<!-- PTO-READER-BLOCK: arch-trap-context-type-boundaries role=boundaries -->
## 架构边界

本声明不定义陷阱路由、原因值、捕获时机或恢复合法性。那些属于陷阱状态归属单元，以及调用捕获路径的内存模型归属单元。

该记录描述一个层级的架构状态。它不是启动嵌套指令束的许可，因为它保存的值都是一级架构中已经存在的状态对象。

设计要点：`PortableTrapContextRecoverable` 要求的不只是 `valid`；它还要求 `bpc[0]` 和 `tpc[0]` 为零，因此一条记录可以被标记为有效，却仍被可移植恢复路径拒绝。所以 `valid` 的含义是上下文已被写入，而不是上下文可以使用。

域类型本身属于本单元之外。指令束快照与模板来自 Block 状态类型，`MemoryReplayState` 来自内存模型数据类型，`Word` 来自整数数据类型。第 1 行只列出一个依赖，因此其余归属单元只能从域声明读取。

<!-- PTO-READER-BLOCK: arch-trap-context-type-example-usage role=example-usage -->
## 非规范阅读示例

保存的上下文可以持有 `bundle_data_attributes_present = FALSE`，而类型化记录 `bundle_data_attributes` 仍带着它被捕获的域值存在，因为捕获把 `_BundleDataAttributes` 与 `_BundleDataAttributesPresent` 并列复制。恢复逻辑必须读取该布尔量。

`RecoverPortableTrapContext` 在把保存的域写回之后会清除 `valid`。要看完整的转移过程，请把这个记录与执行捕获和恢复的陷阱状态 ASL 一起阅读；仅有该记录并不能规定其中任何一步。

<!-- PTO-READER-BLOCK: arch-trap-context-type-related-owners role=related-owners-navigation -->
## 相关归属单元

- [陷阱上下文状态](../state/trap-context.md)
- [执行上下文](../programming-model/execution-context.md)
- [内存模型数据类型](memory-model.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/data-types/trap-context.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-TRAP-CONTEXT","surface":"arch","classification":["data-types","trap-context"],"depends_on":["PTO-TILE-MODEL-STATE-TYPES"]}
type TrapContext of record {
    valid: boolean,
    source_acr: AccessControlRing,
    tpc: Word,
    bpc: Word,
    core_state: Word,
    bundle_argument: Word,
    commit_argument: Word,
    bundle_active: boolean,
    bundle_body_active: boolean,
    bundle_commit_target_set: boolean,
    bundle_condition_set: boolean,
    system_block_terminal_pending: boolean,
    barg: BundleArgumentRegister,
    bundle_sequential_pc: Word,
    frame_stack_return_target: Word,
    return_address: Word,
    bundle_argument_kind: bits(3),
    bundle_operation: BundleOperationDescriptor,
    bundle_dimensions: BundleDimensionSnapshot,
    bundle_dimension_present: BundleDimensionPresenceSnapshot,
    bundle_scalar_bindings: BundleScalarBindingSnapshot,
    bundle_tile_bindings: BundleTileBindingSnapshot,
    bundle_shared_bindings: BundleSharedBindingSnapshot,
    bundle_range_group: BundleRangeGroupState,
    bundle_zero_participation_seen: boolean,
    bundle_control_attributes: BundleControlAttributes,
    bundle_data_attributes: BundleDataAttributes,
    bundle_data_attributes_present: boolean,
    bundle_hint: BundleHintAttributes,
    bundle_fixed_point_attributes: BundleFixedPointAttributes,
    local_generations: LocalGenerationSnapshot,
    shared_generations: SharedGenerationSnapshot,
    bundle_execution_domain_token: integer,
    memory_copy_template: MemoryCopyTemplateState,
    frame_template: FrameTemplateState,
    memory_replay_state: MemoryReplayState,
    t_queue: TemporaryQueueSnapshot,
    t_queue_valid: TemporaryQueueValiditySnapshot,
    u_queue: TemporaryQueueSnapshot,
    u_queue_valid: TemporaryQueueValiditySnapshot,
    predicates: PredicateSnapshot
};
```
<!-- GENERATED-ASL-END: unit -->
