<!-- GENERATED FROM: asl/block/model/dispatch/indexed-tlsu-range-schema.asl -->
# Indexed TLSU Range Schema

**Normative ASL source:** `asl/block/model/dispatch/indexed-tlsu-range-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-schema-purpose role=purpose-scope -->
## 用途与范围

本单元识别 indexed TLSU 操作并解释可选的有符号 range descriptor。参与 PE 可在 memory effect 前拒绝顺序错误的最小值和最大值。

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-schema-concepts role=concepts-state -->
## Descriptor 状态

第一个标量绑定在有效且不是 execution-mask 绑定时提供两个 GPR selector。Tile 绑定决定当前 PE 是否参与。

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-schema-rules role=rules-interactions -->
## Range 规则

参与 PE 把所选 GPR 解释为有符号 minimum 和 maximum，并要求 minimum 小于或等于 maximum。未参与 PE 不执行该比较。

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-schema-boundaries role=boundaries -->
## 边界

操作集合限于 MGATHER 与 MSCATTER form，包括 mask、atomic 和 reduction 变体。descriptor 不存在时不施加 range 顺序检查。

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-schema-example role=example-usage -->
## 示例

参与 PE 提供 minimum -8、maximum 15 时顺序检查通过；minimum 16、maximum 15 时检查失败。

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-schema-related role=related-owners-navigation -->
## 相关 owner

- [Range command stream](indexed-tlsu-range-command-stream.md) 强制两个绑定相邻。
- [Predicate carriers](../../../tile/model/execution/predicate-carriers.md) 拥有 execution-mask carrier。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/indexed-tlsu-range-schema.asl -->
```asl
// PTO-UNIT: {"classification":["model","dispatch","indexed-tlsu-range-schema"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY","PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-BLOCK-MODEL-STATE-TYPES","PTO-SCALAR-MODEL-TYPES-OPERANDS","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","PTO-TILE-MODEL-STATE-TYPES"],"id":"PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-SCHEMA","surface":"block"}
readonly func BundleOperationUsesIndexedTLSU(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    case TileOperationOfIndex(operation) of
        when TileOperation_MGATHER, TileOperation_MSCATTER,
             TileOperation_MGATHER_MASK, TileOperation_MSCATTER_MASK,
             TileOperation_MGATHER_CAS, TileOperation_MGATHER_EXCH,
             TileOperation_MGATHER_MAX, TileOperation_MGATHER_MIN,
             TileOperation_MGATHER_ADD, TileOperation_MGATHER_INC,
             TileOperation_MGATHER_DEC, TileOperation_MGATHER_AND,
             TileOperation_MGATHER_OR, TileOperation_MGATHER_XOR,
             TileOperation_MSCATTER_MAX, TileOperation_MSCATTER_MIN,
             TileOperation_MSCATTER_ADD, TileOperation_MSCATTER_INC,
             TileOperation_MSCATTER_DEC, TileOperation_MSCATTER_AND,
             TileOperation_MSCATTER_OR, TileOperation_MSCATTER_XOR,
             TileOperation_MSCATTER_POPC => return TRUE;
        otherwise => return FALSE;
    end;
end;

readonly func BundleIndexedTLSURangeDescriptorPresent(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return BundleOperationUsesIndexedTLSU(operation) &&
           _BundleScalarBindings[[0]].valid &&
           !_BundleScalarBindings[[0]].execution_mask_present &&
           (_BundleScalarBindings[[0]].source1 != 0 ||
            _BundleScalarBindings[[0]].source2 != 0);
end;

readonly func BundleIndexedTLSUCurrentPEParticipates() => boolean
begin
    let current_bit = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    var seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            seen = TRUE;
            if _BundleTileBindings[[binding]].pe_mask[current_bit] != '1' then
                return FALSE;
            end;
        end;
    end;
    return seen;
end;

readonly func BundleIndexedTLSUCurrentPEBoundsOrdered(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !BundleIndexedTLSURangeDescriptorPresent(operation) ||
       !BundleIndexedTLSUCurrentPEParticipates() then
        return TRUE;
    end;
    let minimum = SInt(ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source1));
    let maximum = SInt(ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source2));
    return minimum <= maximum;
end;

readonly func BundleIndexedTLSURangeMaskSecondPending() => boolean
begin
    if !_BundleScalarBindings[[1]].indexed_tlsu_mask_second_contiguous ||
       !_BundleScalarBindings[[0]].valid ||
       _BundleScalarBindings[[1]].valid ||
       _BundleScalarBindings[[0]].execution_mask_present ||
       !_BundleOperation.valid then
        return FALSE;
    end;
    let operation = DecodeTileOperation(
        BundleTileDecodeFamily(_BundleOperation.operation_class),
        BundleOperationDecodeCode(_BundleOperation));
    return operation != PTO_TILE_OPERATION_COUNT &&
           BundleOperationUsesIndexedTLSU(operation as
               integer {0..PTO_TILE_OPERATION_COUNT-1}) &&
           BundleIndexedTLSURangeDescriptorPresent(operation as
               integer {0..PTO_TILE_OPERATION_COUNT-1});
end;
```
<!-- GENERATED-ASL-END: unit -->
