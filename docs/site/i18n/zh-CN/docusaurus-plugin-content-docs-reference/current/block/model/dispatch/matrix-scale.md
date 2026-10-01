<!-- GENERATED FROM: asl/block/model/dispatch/matrix-scale.asl -->
# Matrix Scale

**Normative ASL source:** `asl/block/model/dispatch/matrix-scale.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-MATRIX-SCALE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-matrix-scale-purpose role=purpose-scope -->
## 用途与范围

本单元为使用 `CScale` 的 CUBE 矩阵指令束提供一项别名检查。`CScale` 是累加矩阵乘积的一个可选附加源：一个每个结果行一个值的 `U8` Tile。它由 `B.FPATR` 的 `CScaleEn` 字段启用。

当 `CScale` 源的索引不与指令束中任何目标的 hand 相同时，函数 `BundleMatrixCScaleDestinationIndicesDistinct` 返回 true。hand 是 `B.IOT` 目标所指定的两位 `DstTile` 值。

<!-- PTO-READER-BLOCK: block-model-dispatch-matrix-scale-concepts role=concepts-state -->
## 概念与可见状态

该函数接收一个序号：`CScale` 源在 Local 源槽有序列表中的位置。源槽按绑定逐个计数，`source0` 在 `source1` 之前。

它读取两类指令束状态，不写任何状态。

- `BundleMatrixArchitecturalSourceAt(ordinal)` 返回 `CScale` 源索引。对子视图源，它返回父 Tile，因此检查针对的是架构 Tile。
- 对每个带目标的有效 `B.IOT` 绑定，它读取 `_BundleTileBindings[[binding]].destination_hand`。

一旦某个目标 hand 等于 `CScale` 索引，该函数就返回 false，否则返回 true。它自身不引发故障。

<!-- PTO-READER-BLOCK: block-model-dispatch-matrix-scale-rules role=rules-interactions -->
## 规则与交互

唯一的调用者是 `ExecuteBundleTMATMULOperation`，且仅在 `c_scale_en` 置位时调用。此前调用者已经要求函数为 2 或 6（`TMATMUL_ACC` 或 `TMATMUL_MX_ACC`），且结果类型为 `FP32`。

调用者传入最后一个数学源的序号：包括 `CScale` 在内的 Local 数学源数量减一。因此 `CScale` 是最后一个数学源，位于累加器、左右矩阵以及任何 MX 缩放之后。

调用者在对累加器的对应检查 `BundleMatrixAccumulatorDestinationIndicesDistinct` 之后立即运行本检查。检查失败时引发 `Fault_TileLegality`。两项检查都在 `PrepareSelectedBundleStage2` 之后运行，并且在分配目标组和快照任何源之前运行。

设计要点：该检查与每个目标 hand 比较，而不只是主结果 `D`。指令束还可以发布 `RowMaxOut` 和 `GroupMaxOut` 目标，循环会访问每个带目标的有效绑定。相比之下，累加器检查只与主目标 hand 比较。

设计要点：该检查是预检拒绝。它与其他别名、布局和形状检查一起在分配之前运行。未通过检查的指令束没有分配任何目标，也没有改变任何源。

<!-- PTO-READER-BLOCK: block-model-dispatch-matrix-scale-boundaries role=boundaries -->
## 架构边界

本单元不检查 `CScale` 是否启用、函数是否允许它，也不检查源是否是形状为 M 乘 1 的合法 `U8` `CUBE_M32` Tile。这些由 `ExecuteBundleTMATMULOperation` 和矩阵源合法性所有者完成。它不应用缩放；缩放由矩阵执行所有者完成。

比较使用的是调用时 `BundleMatrixArchitecturalSourceAt` 返回的值，此时 `PrepareSelectedBundleStage2` 已经解析了相对源选择子。

<!-- PTO-READER-BLOCK: block-model-dispatch-matrix-scale-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

```text
TMATMUL_ACC <M=16, N=16, K=16, FP16, CScale>, T#1, T#2, T#3, T#4, ->T<1KB>
```

累加器 `C` 是 `T#1`，左矩阵是 `T#2`，右矩阵是 `T#3`，`CScale` 源是 `T#4`。共有四个数学源，因此调用者传入序号 3。该指令束有一个目标 `D`。函数将第四个源槽的架构索引与该目标的 hand 比较。若二者不同，预检继续。若二者相等，指令束引发 `Fault_TileLegality`，且不发布任何内容。

<!-- PTO-READER-BLOCK: block-model-dispatch-matrix-scale-related role=related-owners-navigation -->
## 相关所有者

- [CUBE TMATMUL](cube-tmatmul.md) 调用本检查，并拥有累加器别名检查。
- [矩阵后处理合法性](../../../tile/model/legality/matrix-postprocess.md) 定义 `BundleMatrixArchitecturalSourceAt`。
- [Tile 绑定](../operands/tile-bindings.md) 记录每个绑定的目标 hand。
- [B.FPATR](../../attributes/B.FPATR.md) 承载 `CScaleEn` 字段。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/matrix-scale.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-MATRIX-SCALE","surface":"block","classification":["model","dispatch","matrix-scale"],"depends_on":["PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS"]}

readonly func BundleMatrixCScaleDestinationIndicesDistinct(
    c_scale_ordinal: integer {0..8}) => boolean
begin
    let c_scale = BundleMatrixArchitecturalSourceAt(c_scale_ordinal);
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           c_scale == UInt(_BundleTileBindings[[binding]].destination_hand) then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
