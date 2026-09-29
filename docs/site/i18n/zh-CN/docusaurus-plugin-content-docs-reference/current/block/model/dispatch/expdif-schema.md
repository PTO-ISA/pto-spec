<!-- GENERATED FROM: asl/block/model/dispatch/expdif-schema.asl -->
# Expdif Schema

**Normative ASL source:** `asl/block/model/dispatch/expdif-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-EXPDIF-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-expdif-schema-purpose role=purpose-scope -->
## 用途与范围

本单元解析指数差指令束的两种数据类型。相关操作是 `TEXPDIF`（计算两个源元素之差的自然指数），以及扩展形式 `TROWEXPANDEXPDIF` 和 `TCOLEXPANDEXPDIF`。源操作类型是读取源时所用的类型。目标类型是所发布结果的元素类型。

本单元只有一个函数 `SelectedBundleExponentialDifferenceTypes`。它返回一个合法性标志、源操作类型和目标类型。

<!-- PTO-READER-BLOCK: block-model-dispatch-expdif-schema-concepts role=concepts-state -->
## 概念与可见状态

该函数读取三项指令束状态，不写任何状态。

- `_BundleOperation.data_type_valid` 以及 `BSTART` 形式的 `DataType` 字段。该字段始终是源操作类型。
- `_BundleDataAttributesPresent`，记录指令束中是否出现过 `B.DATR` 命令。
- `_BundleDataAttributes.data_type`，即该 `B.DATR` 的 `DataType` 字段。

结果非法时，返回的两个类型都是占位值 `FP64`。此时调用者忽略它们。

<!-- PTO-READER-BLOCK: block-model-dispatch-expdif-schema-rules role=rules-interactions -->
## 规则与交互

该函数按以下顺序执行各步骤。

1. 如果 `BSTART` 形式没有携带数据类型，返回非法。
2. 从 `BSTART` 字段解码源操作类型。目标类型初始等于它。
3. 如果 `B.DATR` 存在且其类型为 `DTYPE_NONE`，目标类型保持等于源类型。
4. 如果 `B.DATR` 存在且其类型既不是 `DTYPE_NONE` 也不是具体类型，返回非法。
5. 如果 `B.DATR` 存在且带有具体类型，则以该类型作为目标类型。
6. 返回 `TileExpdifTypePairLegal` 对该类型对的结果，以及两个类型。

`TileExpdifTypePairLegal` 恰好接受五个类型对：`FP16` 到 `FP16` 或 `FP32`，`BF16` 到 `BF16` 或 `FP32`，以及 `FP32` 到 `FP32`。

例如，该函数被三个分派所有者调用。`TEXPDIF` 的 Tile schema 检查和扩展 schema 检查在预检期间使用合法性标志。目标解析使用目标类型分配结果 Tile，并在标志为 false 时引发 `Fault_TileLegality`。所有这些调用都发生在任何源快照或载荷写入之前。

设计要点：`DTYPE_NONE` 与编码零含义不同。`DTYPE_NONE` 是代码 `11111`，表示继承。代码零是具体类型 `FP64`。因此，仅为设置 `Layout` 或 `PadValue` 而出现的 `B.DATR` 可以通过编码 `DTYPE_NONE` 保持目标类型不变。编码零选择 `FP64`，没有任何合法类型对接受它，所以它会在效果之前被拒绝，而不会被当作缺省。

设计要点：目标类型可以比源类型宽，但绝不会更窄。唯一的混合类型对是把 `FP16` 或 `BF16` 加宽到 `FP32`。因此指数结果绝不会被舍入到比读取源时更小的格式。

<!-- PTO-READER-BLOCK: block-model-dispatch-expdif-schema-boundaries role=boundaries -->
## 架构边界

本单元不检查布局、形状、绑定或源自身的描述符：对 `TEXPDIF`，这些由 Tile schema 所有者和 `TileExpdifSourcesLegal` 完成；对扩展形式，由扩展 schema 完成。它不计算指数，也不设置数值状态。

它不决定保留的 `B.DATR` 代码能否被存储。`SetBundleDataAttributeState` 在命令执行时就拒绝此类代码，因此第 4 步是防御性检查。

<!-- PTO-READER-BLOCK: block-model-dispatch-expdif-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

```text
TEXPDIF <Row=16, Col=64, FP16>, T#1, T#2, ->T<2KB>
```

这里没有写目标类型，因此不提供 `B.DATR` 数据类型，目标为 `FP16`。类型对 `FP16` 到 `FP16` 合法。一个 64 列 `FP16` 的 2 KB 目标可容纳 16 行。

如果该指令束改为携带 `DataType` 为 `FP32` 的 `B.DATR`，类型对 `FP16` 到 `FP32` 同样合法，目标按 `FP32` 分配；此时目标需要 16 x 64 x 4 = 4096 字节，因此其大小必须是 4 KB 而不是 2 KB。如果该字段为 `S32`，类型对非法，指令束在分配任何目标之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-expdif-schema-related role=related-owners-navigation -->
## 相关所有者

- [Tile schema](tile-schema.md) 检查 `TEXPDIF` 的绑定并调用该函数。
- [扩展 schema](expansion-schema.md) 为行、列扩展形式调用该函数。
- [目标操作](destination-operation.md) 使用目标类型分配结果。
- [数据类型与布局合法性](../../../tile/model/legality/dtype-layout.md) 定义 `TileExpdifTypePairLegal`。
- [TEXPDIF](../../../tile/elementwise-tile-tile/transcendental/TEXPDIF.md) 是对应的指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/expdif-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-EXPDIF-SCHEMA","surface":"block","classification":["model","dispatch","expdif-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
readonly func SelectedBundleExponentialDifferenceTypes()
    => (boolean, TileDataType, TileDataType)
begin
    let default_type = TileDataType_FP64;
    if !_BundleOperation.data_type_valid then
        return (FALSE, default_type, default_type);
    end;
    let source_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    var destination_type = source_type;
    if _BundleDataAttributesPresent then
        if _BundleDataAttributes.data_type == DTYPE_NONE then
            destination_type = source_type;
        elsif !BundleDataTypeConcrete(_BundleDataAttributes.data_type) then
            return (FALSE, default_type, default_type);
        else
            destination_type = BundleTileDataType(
                _BundleDataAttributes.data_type);
        end;
    end;
    return (
        TileExpdifTypePairLegal(source_type, destination_type),
        source_type,
        destination_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
