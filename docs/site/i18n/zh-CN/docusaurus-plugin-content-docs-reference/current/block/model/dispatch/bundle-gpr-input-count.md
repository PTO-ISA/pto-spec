<!-- GENERATED FROM: asl/block/model/dispatch/bundle-gpr-input-count.asl -->
# Bundle GPR Input Count

**Normative ASL source:** `asl/block/model/dispatch/bundle-gpr-input-count.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-BUNDLE-GPR-INPUT-COUNT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-bundle-gpr-input-count-purpose role=purpose-scope -->
## 用途与范围

本单元统计完整 Tile bundle 消耗的 GPR 输入。不同操作具有不同操作数形状，该计数使命令组装仍可紧凑排列标量输入流。

<!-- PTO-READER-BLOCK: block-model-dispatch-bundle-gpr-input-count-concepts role=concepts-state -->
## 计入的输入

地址、标量、对角线和 flag 操作数只要存在，便计入总数。矩阵定点模式可增加预量化与 ReLU 标量参数；indexed TLSU range descriptor 则增加最小值和最大值两个边界。

<!-- PTO-READER-BLOCK: block-model-dispatch-bundle-gpr-input-count-rules role=rules-interactions -->
## 计数规则

每个普通输入占一个槽。只有选定模式确实使用标量值时，两个定点参数才各占一个槽。一个 range descriptor 作为有序边界对，占两个槽。

<!-- PTO-READER-BLOCK: block-model-dispatch-bundle-gpr-input-count-boundaries role=boundaries -->
## 边界

该 helper 返回零到七的计数。它不验证 GPR 中的值，也不判断操作、descriptor 或 range 是否合法。

<!-- PTO-READER-BLOCK: block-model-dispatch-bundle-gpr-input-count-example role=example-usage -->
## 示例

带地址输入和 range descriptor 的 indexed gather 消耗三个 GPR 输入：一个地址和两个有符号边界。

<!-- PTO-READER-BLOCK: block-model-dispatch-bundle-gpr-input-count-related role=related-owners-navigation -->
## 相关 owner

- [Indexed TLSU range schema](indexed-tlsu-range-schema.md) 决定双边界 descriptor 是否存在。
- [Control state](../state/control-state.md) 拥有捕获的 bundle 操作与标量绑定。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/bundle-gpr-input-count.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","bundle-gpr-input-count"],"depends_on":["PTO-BLOCK-B-FPATR","PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-SCHEMA","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-BLOCK-MODEL-STATE-TYPES","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","PTO-TILE-MODEL-STATE-TYPES"],"id":"PTO-BLOCK-MODEL-DISPATCH-BUNDLE-GPR-INPUT-COUNT","surface":"block"}
// Complete-bundle GPR inputs pack present address, scalar0, diagonal, and flag0 operands densely.
readonly func BundleOperationGPRInputCount(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => integer {0..7}
begin
    var count: integer {0..7} = 0;
    if TileOperandPresent(operation, TileOperand_address) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_scalar0) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_diagonal) then
        count = (count + 1) as integer {0..7};
    end;
    if TileOperandPresent(operation, TileOperand_flag0) then
        count = (count + 1) as integer {0..7};
    end;
    if _BundleOperation.valid &&
       _BundleOperation.operation_class == BundleOperation_TileMatrix &&
       _BundleFixedPointAttributes.valid then
        if BundleFPATRModeUsesScalarParameter(
               _BundleFixedPointAttributes.pre_quant_mode) then
            count = (count + 1) as integer {0..7};
        end;
        if BundleFPATRReluModeUsesScalarParameter(
               _BundleFixedPointAttributes.relu_mode) then
            count = (count + 1) as integer {0..7};
        end;
    end;
    if BundleIndexedTLSURangeDescriptorPresent(operation) then
        count = (count + 2) as integer {0..7};
    end;
    return count;
end;
```
<!-- GENERATED-ASL-END: unit -->
