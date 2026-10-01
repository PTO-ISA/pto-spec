<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-mscatter.asl -->
# TLSU Mscatter

**Normative ASL source:** `asl/block/model/dispatch/tlsu-mscatter.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-purpose role=purpose-scope -->
## 用途与范围

本单元是普通 `MSCATTER` 的指令束级处理程序。`MSCATTER` 是按索引存储：把 Local 源 Tile 的每个元素写到由索引 Tile 形成的全局内存地址。

`BundleMSCATTERSelected` 识别该指令束：有效的 `TileMemory` 操作描述符，其选择器功能号（位 `4:0`）为 `5`。`ExecuteBundleMSCATTEROperation` 校验完整指令束并调用 Tile 级 `MSCATTER` 效果。scatter 不产生 Tile，因此本处理程序从不解析目标。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-concepts role=concepts-state -->
## 概念与可见状态

`BundleMSCATTERBindingsLegal` 定义 Tile 绑定 schema。

- 第一个 `B.IOT` 没有目标，目标大小为零。它在 `source0` 中携带数据 Tile，在 `source1` 中携带索引 Tile。
- 没有谓词 Tile 执行掩码时，第一个绑定是唯一的绑定，并带 `last`。
- 有谓词 Tile 执行掩码时，第一个绑定不带 `last`。第二个 `B.IOT` 在 `source0` 中携带掩码 Tile，无 `source1`，无目标，并带 `last`。
- 必须有一条 `B.IOR` 记录。其 `source0` 选择为当前内存代理保存基地址的 GPR。
- `B.DIM` 给出有效列数、有效行数和物理列数。它们必须等于数据 Tile 自身的值。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-rules role=rules-interactions -->
## 规则与交互

当 `SelectedBundleTileMaskIsZero` 成立时，处理程序首先无效果地返回成功。ASL 注释把这一步放在 schema、源、GPR、维度、地址、权限、事件和内存检查之前。

未知的 TLSU 操作码引发 `Fault_IllegalInstruction`。下列其他检查失败时引发 `Fault_TileLegality`，且都在第一次内存探测之前进行。

- 无 `B.IOS` 绑定、存在且合法的 `B.IOR`、PE 掩码一致、维度被 `BundleMGATHERDimensionsLegal` 接受，以及上述绑定 schema。
- 数据 Tile 和索引 Tile 内容已定义并具有指令束布局。数据 Tile 具有操作数据类型，该类型必须通过 `IndexedTLSUOrdinaryTransferDataTypeLegal`。索引 Tile 为 S32、U32、S64 或 U64。
- 数据形状与索引形状匹配，数据 Tile 的有效行数、有效列数和物理列数等于 `B.DIM` 的值，且物理形状合法。
- `TileOperandsLegal_MSCATTER` 成立。

成功时处理程序调用 `FinalizeBundleTileAttempt`。`MSCATTER` 的内存故障返回失败；没有需要回滚的目标。

设计要点：Tile 级 `MSCATTER` 在提交任何存储之前，先对每个活动通道做写权限探测。因此探测中发现的转换或权限故障会在本次 scatter 的任何存储之前返回。

设计要点：数据 Tile 必须与 `B.DIM` 完全一致，包括物理列数。scatter 读取已有 Tile 而不是创建 Tile，因此 `B.DIM` 重述该 Tile 的形状，而不是描述新目标。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-boundaries role=boundaries -->
## 架构边界

只有当 `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` 未找到更靠前的专用选择器时，本单元才运行。`BundleMSCATTERSelected` 在普通 `MGATHER` 之后、`MSCATTER.MASK` 之前测试。

对同一地址的多个 scatter 存储以何种顺序变为可见，由 Tile gather 与 scatter 所有者中的 `CommitIndexedScatterTransactions` 负责。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设数据 Tile 为 BF16、RowMajor，有 2 个有效行、16 个有效列和 16 个物理列。指令束把 `LB0` 设为 16、`LB1` 设为 2、`LB2` 设为 16，索引 Tile 为 S32，2 行 16 列。没有执行掩码时，唯一的 `B.IOT` 先指定数据 Tile 再指定索引 Tile，并带 `last`。先探测全部 32 个通道，然后提交 32 次存储。

如果 `LB2` 为 32 而数据 Tile 只有 16 个物理列，指令束引发 `Fault_TileLegality`，且不做任何探测。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-related role=related-owners-navigation -->
## 相关所有者

- [MGATHER 分派](tlsu-mgather.md) 定义共用的维度检查。
- [MSCATTER.MASK 分派](tlsu-mscatter-mask.md) 处理带谓词的形式。
- [Gather 与 scatter 内存](../../../tile/model/memory/gather-scatter.md) 定义 `MSCATTER`。
- [BSTART.MSCATTER](../../execution/BSTART.MSCATTER.md) 是该起始形式的指令页。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-mscatter.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER","surface":"block","classification":["model","dispatch","tlsu-mscatter"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"]}

readonly func BundleMSCATTERSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 5;
end;

readonly func BundleMSCATTERBindingsLegal() => boolean
begin
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if BundleTileBindingCount() != (if execution_mask_tile then 2 else 1) then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    if !binding.valid || binding.destination_valid ||
       binding.destination_size != 0 || !binding.source0_valid ||
       !binding.source1_valid || (binding.last == execution_mask_tile) then
        return FALSE;
    end;
    if !execution_mask_tile then return TRUE; end;
    let mask_binding = _BundleTileBindings[[1]];
    return mask_binding.valid && !mask_binding.destination_valid &&
           mask_binding.destination_size == 0 &&
           mask_binding.source0_valid && !mask_binding.source1_valid &&
           mask_binding.last;
end;

func ExecuteBundleMSCATTEROperation() => boolean
begin
    // PE_MASK=0000 is a strict no-op before schema, source, GPR, dimension,
    // address, permission, event, and memory checks.
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 ||
       !_BundleScalarBindings[[0]].valid ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       !BundleMGATHERDimensionsLegal() ||
       !BundleMSCATTERBindingsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let source = binding.source0;
    let indices = binding.source1;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if !IndexedTLSUExecutionMaskContentsDefined(source) ||
       !IndexedTLSUExecutionMaskContentsDefined(indices) ||
       _Tiles[[source]].data_type != data_type ||
       !IndexedTLSUMemoryIndexDataTypeLegal(_Tiles[[indices]].data_type) ||
       !IndexedTLSUOrdinaryTransferDataTypeLegal(data_type) ||
       !IndexedTLSUDataShapeMatchesIndex(
           _Tiles[[source]].valid_rows, _Tiles[[source]].valid_columns,
           _Tiles[[indices]].valid_rows, _Tiles[[indices]].valid_columns,
           data_type) ||
       _Tiles[[source]].valid_rows != valid_rows ||
       _Tiles[[source]].valid_columns != valid_columns ||
       _Tiles[[source]].columns != columns ||
       !IndexedTLSUPhysicalShapeLegal(CurrentBundleTileLayout(), data_type,
           valid_rows, valid_columns, columns) ||
       _Tiles[[source]].layout != CurrentBundleTileLayout() ||
       _Tiles[[indices]].layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    if !TileOperandsLegal_MSCATTER(
           Zeros{PTO_XLEN}, source, indices) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    MSCATTER(base_address, source, indices);
    if _LastFault != Fault_None then return FALSE; end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
