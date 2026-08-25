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

本单元定义完整的类型化 `TrapContext` 快照，用于在陷阱处理期间保存可恢复的执行状态。

记录结构集中定义后，捕获归属单元和恢复归属单元便可操作同一组状态。

<!-- PTO-READER-BLOCK: arch-trap-context-type-concepts-state role=concepts-state -->
## 概念与可见状态

- 快照开头保存有效性、来源 `AccessControlRing`、`tpc`、`bpc`、核状态、束实参、提交实参以及束活动标志。
- 快照还保存束描述符、维度、标量/Tile/共享绑定、范围组状态、控制/数据/定点/提示属性，以及本地/共享世代快照。
- 此外，快照还保存内存复制模板和帧模板、带有效性快照的临时 `T`/`U` 队列、谓词状态、返回目标以及束执行域令牌。

<!-- PTO-READER-BLOCK: arch-trap-context-type-rules-interactions role=rules-interactions -->
## 规则与交互

`valid` 表示记录中是否包含可恢复的上下文；记录类型本身不执行捕获或恢复。

条件、提交目标、数据属性和束维度都显式保存存在性标志，而不是根据载荷内容推断。

队列值与队列有效性数组使用独立字段，从而将就绪状态与保存的字分开记录。

<!-- PTO-READER-BLOCK: arch-trap-context-type-boundaries role=boundaries -->
## 架构边界

该类型声明不定义陷阱路由、原因值、捕获时机或恢复合法性；这些行为仍由陷阱状态与恢复归属单元定义。

不能把这条记录理解为允许嵌套束执行；它只快照现有的一层架构状态。

<!-- PTO-READER-BLOCK: arch-trap-context-type-example-usage role=example-usage -->
## 非规范阅读示例

保存的上下文可以在携带类型化数据属性字段的同时令 `bundle_data_attributes_present = FALSE`；恢复逻辑依据显式存在性位处理。

要理解故障发生时具体捕获哪些内容，应结合当前陷阱捕获/恢复 ASL 阅读该记录布局；记录本身不规定状态转换。

<!-- PTO-READER-BLOCK: arch-trap-context-type-related-owners role=related-owners-navigation -->
## 相关归属单元

- [陷阱上下文状态](../state/trap-context.md)
- [陷阱恢复配置](../profile/trap-context-recovery.md)
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
    t_queue: TemporaryQueueSnapshot,
    t_queue_valid: TemporaryQueueValiditySnapshot,
    u_queue: TemporaryQueueSnapshot,
    u_queue_valid: TemporaryQueueValiditySnapshot,
    predicates: PredicateSnapshot
};
```
<!-- GENERATED-ASL-END: unit -->
