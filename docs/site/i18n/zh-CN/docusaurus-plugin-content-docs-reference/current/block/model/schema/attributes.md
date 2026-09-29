<!-- GENERATED FROM: asl/block/model/schema/attributes.asl -->
# Attributes

**Normative ASL source:** `asl/block/model/schema/attributes.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-schema-attributes-purpose role=purpose-scope -->
## 用途与范围

本单元定义两条头部属性命令的状态写入器。`B.CATR` 设置指令束控制属性。`B.FPATR` 设置矩阵指令束的定点后处理属性。

命令分派器先检查放置位置，然后调用这些写入器。

<!-- PTO-READER-BLOCK: block-model-schema-attributes-concepts role=concepts-state -->
## 概念与可见状态

`SetBundleControlAttributeState` 设置 `present` 和六个标志：`trap_enabled`、`atomic`、`acquire`、`release`、`far` 和 `dimension_reduction`。

`SetBundleFixedPointAttributeState` 设置 `valid` 和十个字段：`pre_quant_mode`、`relu_mode`、`group_n_code`、`row_max_en`、`group_max_en`、`row_max_init`、`max_abs_en`、`trans_a`、`trans_b` 和 `c_scale_en`。

另有两个更短的重载。九参数形式把 `c_scale_en` 设为 false。七参数形式还把 `trans_a` 和 `trans_b` 设为 false。

<!-- PTO-READER-BLOCK: block-model-schema-attributes-rules role=rules-interactions -->
## 规则与交互

`B.CATR` 只在活动指令束的头部被接受，并且只能出现一次。第二条 `B.CATR`，或出现在主体中的 `B.CATR`，会引发 `Fault_BundleControl`。

`B.FPATR` 只在头部被接受，只能出现一次，只能位于任何标量、Tile 或 Shared 绑定之前，并且只在操作描述符无效或其类别为 `TileMatrix` 时被接受。否则它引发 `Fault_BundleControl`。随后其字段必须通过 `BundleFPATRFieldsLegal`，否则它引发 `Fault_TileLegality` 且不写入任何内容。例如，`row_max_init` 要求 `row_max_en`，并且 `group_n_code` 恰好在 `group_max_en` 置位时非零。

设计要点：`B.FPATR` 字段检查在描述符变为可见之前运行。ASL 注释说明了这一顺序。非法的 `B.FPATR` 使 `valid` 保持 false，因此提交永远不会看到写了一部分的后处理描述符。

设计要点：每条属性记录都有自己的存在标志。第二次写入依据 `present` 或 `valid` 检测，而不是依据字段值，因此所有标志都清零的 `B.CATR` 仍算作已写入。

设计要点：`trap` 在这里被记录，但只在提交成功之后以 `Fault_BundlePostCommit` 的形式起作用。其他标志在操作运行时读取；例如，acquire 和 release 选择指令束的内存顺序。

<!-- PTO-READER-BLOCK: block-model-schema-attributes-boundaries role=boundaries -->
## 架构边界

这里不检查 `dimension_reduction`。提交会在 `TileElement` 或 `TileMemory` 以外的块上拒绝它。

非矩阵操作上的 `B.FPATR` 描述符也会在提交时以 `Fault_BundleControl` 被拒绝。`B.DATR` 在控制状态单元中有自己的写入器。

<!-- PTO-READER-BLOCK: block-model-schema-attributes-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个矩阵指令束写入 `B.FPATR None, None, 0, 0, 0, 0, 0, 0, 0, 0`。字段合法，因此 `valid` 变为 true，且每个字段都为零。同一头部中之后的 `B.FPATR` 引发 `Fault_BundleControl`，因为 `valid` 已经置位。

<!-- PTO-READER-BLOCK: block-model-schema-attributes-related role=related-owners-navigation -->
## 相关所有者

- [B.CATR](../../attributes/B.CATR.md) 和 [B.FPATR](../../attributes/B.FPATR.md) 是指令页面。
- [命令分派](../dispatch/commands.md)强制执行放置规则。
- [提交验证](../commit/validation.md)检查 `dimension_reduction` 并运行操作。
- [进入与停止](../lifecycle/enter-stop.md)引发提交后陷阱。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/schema/attributes.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES","surface":"block","classification":["model","schema","attributes"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-HEADER"]}
func SetBundleControlAttributeState(trap_enabled: boolean, atomic: boolean,
                                   acquire: boolean, release: boolean,
                                   far: boolean,
                                   dimension_reduction: boolean)
begin
    _BundleControlAttributes.present = TRUE;
    _BundleControlAttributes.trap_enabled = trap_enabled;
    _BundleControlAttributes.atomic = atomic;
    _BundleControlAttributes.acquire = acquire;
    _BundleControlAttributes.release = release;
    _BundleControlAttributes.far = far;
    _BundleControlAttributes.dimension_reduction = dimension_reduction;
end;

func SetBundleFixedPointAttributeState(pre_quant_mode: bits(6),
                                       relu_mode: bits(3),
                                       group_n_code: bits(4),
                                       row_max_en: boolean,
                                       group_max_en: boolean,
                                       row_max_init: boolean,
                                       max_abs_en: boolean,
                                       trans_a: boolean,
                                       trans_b: boolean,
                                       c_scale_en: boolean)
begin
    // Header-local field checks happen before the descriptor becomes visible.
    if !BundleFPATRFieldsLegal(pre_quant_mode, relu_mode, group_n_code,
                               row_max_en, group_max_en, row_max_init,
                               max_abs_en) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    _BundleFixedPointAttributes.valid = TRUE;
    _BundleFixedPointAttributes.pre_quant_mode = pre_quant_mode;
    _BundleFixedPointAttributes.relu_mode = relu_mode;
    _BundleFixedPointAttributes.group_n_code = group_n_code;
    _BundleFixedPointAttributes.row_max_en = row_max_en;
    _BundleFixedPointAttributes.group_max_en = group_max_en;
    _BundleFixedPointAttributes.row_max_init = row_max_init;
    _BundleFixedPointAttributes.max_abs_en = max_abs_en;
    _BundleFixedPointAttributes.trans_a = trans_a;
    _BundleFixedPointAttributes.trans_b = trans_b;
    _BundleFixedPointAttributes.c_scale_en = c_scale_en;
end;

func SetBundleFixedPointAttributeState(pre_quant_mode: bits(6),
                                       relu_mode: bits(3),
                                       group_n_code: bits(4),
                                       row_max_en: boolean,
                                       group_max_en: boolean,
                                       row_max_init: boolean,
                                       max_abs_en: boolean,
                                       trans_a: boolean,
                                       trans_b: boolean)
begin
    SetBundleFixedPointAttributeState(
        pre_quant_mode, relu_mode, group_n_code,
        row_max_en, group_max_en, row_max_init, max_abs_en,
        trans_a, trans_b, FALSE);
end;

func SetBundleFixedPointAttributeState(pre_quant_mode: bits(6),
                                       relu_mode: bits(3),
                                       group_n_code: bits(4),
                                       row_max_en: boolean,
                                       group_max_en: boolean,
                                       row_max_init: boolean,
                                       max_abs_en: boolean)
begin
    SetBundleFixedPointAttributeState(
        pre_quant_mode, relu_mode, group_n_code,
        row_max_en, group_max_en, row_max_init, max_abs_en,
        FALSE, FALSE, FALSE);
end;
```
<!-- GENERATED-ASL-END: unit -->
