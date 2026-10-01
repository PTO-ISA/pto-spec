<!-- GENERATED FROM: asl/tile/model/execution/minmax.asl -->
# Minmax

**Normative ASL source:** `asl/tile/model/execution/minmax.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MINMAX}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-minmax-purpose role=purpose-scope -->
## 用途与范围

本单元定义一个纯辅助函数 `TileFloatingMinMaxValue`。它计算两个原始元素载体的浮点最小值或最大值，并报告是否发生了无效操作条件。

它是架构配置档 `HardwareNumericFloatingMinMax` 之上的 Tile 级适配器。调用者包括[逐元素执行](elementwise.md)中用于浮点 MIN 和 MAX 的 `TileProfileBinaryWithFlags`，以及 TMAX 和 TMIN 的 `InstructionContractFloatingValue_TMAX` 与 `InstructionContractFloatingValue_TMIN` 辅助函数。

<!-- PTO-READER-BLOCK: tile-model-execution-minmax-concepts role=concepts-state -->
## 概念与可见状态

该辅助函数没有状态。其输入是一个 `TileBinaryOperation`、一个数据类型和两个载体。它返回所选载体和布尔值 `invalid`。

配置档先通过 `HardwareNumericMinMaxSpecial` 处理特殊情况：

- 两个 NaN 给出该类型的规范 NaN。
- 一个 NaN 给出另一个操作数。
- 任一操作数为信号 NaN 时，`invalid` 为 TRUE。
- 任意符号的两个零：MAX 仅在两者都为 -0.0 时给出 -0.0，否则给出 +0.0。MIN 在任一为 -0.0 时给出 -0.0，否则给出 +0.0。

否则每个操作数被映射为无符号顺序键。负载体按位取反，非负载体置其符号位，因此键越大值越大。

<!-- PTO-READER-BLOCK: tile-model-execution-minmax-rules role=rules-interactions -->
## 规则与交互

该辅助函数断言操作为 MIN 或 MAX。随后它断言配置档报告结果可用。当操作数编码无效或该类型没有顺序键时，配置档报告不可用。

键相等时返回左操作数，因为 MAX 使用 `>=`，MIN 使用 `<=`。

`invalid` 是否进入粘滞状态取决于调用者。`TileProfileBinaryWithFlags` 把它转为 NV 标志。`ExecuteTileScalar`、`ExecuteTileExpand` 和 `ExecuteTileReduction` 记录它们收到的标志。TMAX 和 TMIN 使用的 `ExecuteTileBinary` 调用 `TileProfileBinary`，后者丢弃标志。

设计要点：单个静默 NaN 不会污染结果；数值操作数胜出。因此对含缺失值的数据求最大或最小，返回的是现存数值中的极值。

设计要点：带符号零被显式排序，-0.0 低于 +0.0，尽管它们比较相等。结果对每种零组合都是确定的，而不取决于操作数顺序。

<!-- PTO-READER-BLOCK: tile-model-execution-minmax-boundaries role=boundaries -->
## 架构边界

顺序键对 FP64、FP32、TF32、HF32、FP16、BF16、E4M3 和 E5M2 存在。这些正是 TMAX 和 TMIN 合法性所用 16 种 VEC 算术类型集合中的浮点成员。

整数 MIN 和 MAX 不使用本单元。它们使用[逐元素执行](elementwise.md)中的 `TileIntegerMinMaxValue`。

合法性检查在执行前验证浮点源编码，因此在合法操作上可用性断言预期不会失败。

<!-- PTO-READER-BLOCK: tile-model-execution-minmax-example role=example-usage -->
## 非规范阅读示例

所有值均为 FP32。

| 操作 | 左 | 右 | 结果 | `invalid` |
| --- | --- | --- | --- | --- |
| MAX | 1.5（`0x3fc00000`） | -2.0（`0xc0000000`） | 1.5 | FALSE |
| MAX | +0.0 | -0.0 | +0.0 | FALSE |
| MIN | +0.0 | -0.0 | -0.0 | FALSE |
| MAX | 静默 NaN | 3.0 | 3.0 | FALSE |
| MAX | 信号 NaN | 3.0 | 3.0 | TRUE |

对于第一行，1.5 的键是置符号位后的 `0x3fc00000`，即 `0xbfc00000`。-2.0 的键是其按位取反，即 `0x3fffffff`。第一个键更大，因此 MAX 返回左操作数。

<!-- PTO-READER-BLOCK: tile-model-execution-minmax-related role=related-owners-navigation -->
## 相关所有者

- [最小/最大配置档](../../../arch/features/minmax.md)拥有 `HardwareNumericFloatingMinMax` 和顺序键。
- [MX 格式](../../../arch/features/mx-formats.md)拥有 `HardwareNumericMinMaxSpecial` 和规范 NaN。
- [逐元素执行](elementwise.md)把浮点 MIN 和 MAX 路由到这里，并决定是否记录标志。
- [TMAX](../../elementwise-tile-tile/arithmetic/TMAX.md) 和 [TMIN](../../elementwise-tile-tile/arithmetic/TMIN.md) 是 Tile-Tile 指令。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/minmax.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MINMAX","surface":"tile","classification":["model","execution","minmax"],"depends_on":["PTO-ARCH-FEATURES-MINMAX","PTO-TILE-MODEL-STATE-TYPES"]}
pure func TileFloatingMinMaxValue(
    operation: TileBinaryOperation,
    data_type: TileDataType,
    left: Word,
    right: Word) => (Word, boolean)
begin
    assert operation == TileBinary_MIN || operation == TileBinary_MAX;
    let maximum = operation == TileBinary_MAX;
    let (available, result, invalid) =
        HardwareNumericFloatingMinMax(
            maximum,
            data_type,
            left,
            right);
    assert available;
    return (result, invalid);
end;
```
<!-- GENERATED-ASL-END: unit -->
