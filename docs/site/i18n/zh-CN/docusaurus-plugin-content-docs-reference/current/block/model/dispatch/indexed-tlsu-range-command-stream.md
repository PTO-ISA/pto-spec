<!-- GENERATED FROM: asl/block/model/dispatch/indexed-tlsu-range-command-stream.asl -->
# Indexed TLSU Range Command Stream

**Normative ASL source:** `asl/block/model/dispatch/indexed-tlsu-range-command-stream.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-COMMAND-STREAM}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-command-stream-purpose role=purpose-scope -->
## 用途与范围

本单元强制双 GPR indexed TLSU range descriptor 的命令流相邻关系，避免把无关命令误当成 descriptor 的第二个边界。

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-command-stream-concepts role=concepts-state -->
## 待接收的第二边界

第一个合格 B.IOR record 之后，第二个标量绑定槽记录后续 B.IOR 是否可完成连续 range 对。该标记只适用于存在 range descriptor 的 indexed TLSU 操作。

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-command-stream-rules role=rules-interactions -->
## 命令流规则

索引一处连续出现的第二个标量绑定合法。无关命令插入时会清除标记；之后再出现第二个 B.IOR，会在绑定和操作 effect 前触发 Fault_BundleControl。

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-command-stream-boundaries role=boundaries -->
## 边界

只有第一个 descriptor 仍然合法。不使用 indexed range 的操作，以及不在相关第二绑定位置的命令，保持既有命令流行为。

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-command-stream-example role=example-usage -->
## 示例

indexed gather range 使用两个相邻 B.IOR record 表示 minimum 与 maximum。在两者之间插入其他命令，会使后一个 B.IOR 不能作为第二边界。

<!-- PTO-READER-BLOCK: block-model-dispatch-indexed-tlsu-range-command-stream-related role=related-owners-navigation -->
## 相关 owner

- [Indexed TLSU range schema](indexed-tlsu-range-schema.md) 识别适用操作与 descriptor。
- [Scalar schema](scalar-schema.md) 拥有 B.IOR 绑定索引。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/indexed-tlsu-range-command-stream.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-COMMAND-STREAM","surface":"block","classification":["model","dispatch","indexed-tlsu-range-command-stream"],"depends_on":["PTO-ARCH-STATE-TRAP-CONTEXT","PTO-BLOCK-MODEL-DISPATCH-INDEXED-TLSU-RANGE-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-BLOCK-MODEL-STATE-TYPES"]}
func BundleMarkIndexedTLSURangeMaskSecondPending(first_record: boolean)
begin
    if !first_record || !_BundleScalarBindings[[0]].valid ||
       _BundleScalarBindings[[0]].execution_mask_present ||
       !_BundleOperation.valid ||
       !BundleExecutionMaskGPRStreamSelected() then
        return;
    end;
    let operation = DecodeTileOperation(
        BundleTileDecodeFamily(_BundleOperation.operation_class),
        BundleOperationDecodeCode(_BundleOperation));
    if operation != PTO_TILE_OPERATION_COUNT &&
       BundleOperationUsesIndexedTLSU(operation as
           integer {0..PTO_TILE_OPERATION_COUNT-1}) &&
       BundleIndexedTLSURangeDescriptorPresent(operation as
           integer {0..PTO_TILE_OPERATION_COUNT-1}) then
        _BundleScalarBindings[[1]].indexed_tlsu_mask_second_contiguous = TRUE;
    end;
end;

func BundleIndexedTLSURangeMaskCommandAllowed(
    next_is_scalar_binding: boolean) => boolean
begin
    if !_BundleScalarBindings[[0]].valid ||
       _BundleScalarBindings[[1]].valid ||
       !_BundleOperation.valid then
        return TRUE;
    end;
    let operation = DecodeTileOperation(
        BundleTileDecodeFamily(_BundleOperation.operation_class),
        BundleOperationDecodeCode(_BundleOperation));
    if operation == PTO_TILE_OPERATION_COUNT ||
       !BundleOperationUsesIndexedTLSU(operation as
           integer {0..PTO_TILE_OPERATION_COUNT-1}) ||
       !BundleIndexedTLSURangeDescriptorPresent(operation as
           integer {0..PTO_TILE_OPERATION_COUNT-1}) then
        return TRUE;
    end;
    if next_is_scalar_binding && BundleMultiIORBindingIndex() == 1 then
        if !_BundleScalarBindings[[1]].indexed_tlsu_mask_second_contiguous then
            SetFault(Fault_BundleControl, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if !next_is_scalar_binding then
        // A lone descriptor remains legal after an unrelated command. If a
        // second B.IOR later appears, this marker makes that pair fail before
        // the second binding or any operation effect.
        _BundleScalarBindings[[1]].indexed_tlsu_mask_second_contiguous = FALSE;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
