<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-mgather-mask.asl -->
# TLSU Mgather Mask

**Normative ASL source:** `asl/block/model/dispatch/tlsu-mgather-mask.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-mask-purpose role=purpose-scope -->
## 用途与范围

本单元是 `MGATHER.MASK` 的指令束级处理程序。`MGATHER.MASK` 是按索引加载，只对谓词 Tile 位已置位的通道读取全局内存。

`BundleMGATHERMASKSelected` 识别该指令束：有效的 `TileMemory` 操作描述符，其选择器功能号（位 `4:0`）为 `6`。`ExecuteBundleMGATHERMASKOperation` 校验完整指令束，解析目标，并调用 Tile 级 `MGATHER_MASK` 效果。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-mask-concepts role=concepts-state -->
## 概念与可见状态

操作数为基地址、索引 Tile 和掩码 Tile。掩码 Tile 是该操作自身的谓词操作数，与可选的执行掩码不同。

- 必须有一条 `B.IOR` 记录。其 `source0` 选择为当前内存代理保存基地址的 GPR。
- 没有谓词 Tile 执行掩码时，一个 `B.IOT` 携带目标、位于 `source0` 的索引 Tile、位于 `source1` 的掩码 Tile 以及 `last`。
- 有谓词 Tile 执行掩码时，第一个 `B.IOT` 携带索引和掩码 Tile，但不带目标也不带 `last`。第二个 `B.IOT` 携带目标、一个源、无 `source1`，并带 `last`。
- `B.DIM` 给出目标的有效列数、有效行数和物理列数，由 `BundleMGATHERDimensionsLegal` 检查。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-mask-rules role=rules-interactions -->
## 规则与交互

当 `SelectedBundleTileMaskIsZero` 成立时，处理程序首先无效果地返回成功。ASL 注释把这一步放在所有 schema、源、GPR、维度、分配、谓词、地址和故障检查之前。

未知的 TLSU 操作码引发 `Fault_IllegalInstruction`。下列其他检查都在解析目标之前进行，失败时引发 `Fault_TileLegality`。

- 无 `B.IOS` 绑定、存在 `B.IOR`、`B.IOR` 取值完整合法、PE 掩码一致、维度合法，以及 `BundleMGATHERMASKBindingsLegal` 规定的绑定布局。
- 索引 Tile 内容已定义，类型为 S32、U32、S64 或 U64，并具有指令束布局。
- 掩码 Tile 通过 `IndexedTLSUPredicateValuesLegal`，并具有指令束布局。
- 数据形状与索引形状匹配，掩码具有目标的有效行数和索引的有效列数，且物理形状合法。

这些检查之后，处理程序解析目标并校验 Local 生成写者。在谓词 Tile 执行掩码下，目标取自第二个绑定。之后的失败或 `MGATHER_MASK` 内部的内存故障会调用 `RollBackBundleTileDestinations`。成功时调用 `FinalizeBundleTileAttempt`。

设计要点：掩码 Tile 在形成任何地址之前就用谓词值辅助函数检查。随后 `MGATHER_MASK` 只探测在执行掩码下活动且谓词位已置位的通道。谓词位清零的通道不发出内存访问，保留来自 `CurrentBundlePadValue` 的填充值。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-mask-boundaries role=boundaries -->
## 架构边界

只有当 `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` 未找到更靠前的专用选择器时，本单元才运行。`BundleMGATHERMASKSelected` 在 `MGATHER.CAS` 和原子或归约选择器之后、普通 `MGATHER` 之前测试。

谓词位的含义、字节位移地址规则以及加载事件顺序属于 Tile gather 与 scatter 所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-mask-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设一个无执行掩码的指令束把 U16 值 gather 到 RowMajor 目标，`LB0` 为 16，`LB1` 为 2，`LB2` 为 16。唯一的 `B.IOT` 指定一个 U32 索引 Tile 和一个掩码 Tile，二者都是 2 乘 16。若掩码置位了 32 个通道中的 20 个，gather 探测并加载 20 个地址。其余 12 个目标元素保存填充值。

如果掩码 Tile 有 3 个有效行，指令束会在分配目标之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-mask-related role=related-owners-navigation -->
## 相关所有者

- [MGATHER 分派](tlsu-mgather.md) 定义共用的维度检查。
- [Tile 执行分派](tile-execution.md) 排定各专用选择器的顺序。
- [Gather 与 scatter 内存](../../../tile/model/memory/gather-scatter.md) 定义 `MGATHER_MASK`。
- [BSTART.MGATHER.MASK](../../execution/BSTART.MGATHER.MASK.md) 是该起始形式的指令页。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-mgather-mask.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-MASK","surface":"block","classification":["model","dispatch","tlsu-mgather-mask"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"]}

readonly func BundleMGATHERMASKSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 6;
end;

readonly func BundleMGATHERMASKBindingsLegal() => boolean
begin
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if BundleTileBindingCount() != (if execution_mask_tile then 2 else 1) then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    if !binding.valid || !binding.source0_valid ||
       !binding.source1_valid then return FALSE; end;
    if !execution_mask_tile then
        return binding.destination_valid && binding.last;
    end;
    if binding.destination_valid || binding.last then return FALSE; end;
    let mask_binding = _BundleTileBindings[[1]];
    return mask_binding.valid && mask_binding.destination_valid &&
           mask_binding.source0_valid && !mask_binding.source1_valid &&
           mask_binding.last;
end;

func ExecuteBundleMGATHERMASKOperation() => boolean
begin
    // PE_MASK=0000 is a strict no-op before every schema, source, GPR,
    // dimension, allocation, predicate, address, and fault check.
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
       !BundleMGATHERMASKBindingsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let indices = binding.source0;
    let mask = binding.source1;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !IndexedTLSUExecutionMaskContentsDefined(indices) ||
       !IndexedTLSUPredicateValuesLegal(mask) ||
       !IndexedTLSUMemoryIndexDataTypeLegal(_Tiles[[indices]].data_type) ||
       !IndexedTLSUOrdinaryTransferDataTypeLegal(data_type) ||
       _Tiles[[indices]].layout != CurrentBundleTileLayout() ||
       _Tiles[[mask]].layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if !IndexedTLSUDataShapeMatchesIndex(
           valid_rows, valid_columns,
           _Tiles[[indices]].valid_rows, _Tiles[[indices]].valid_columns,
           data_type) ||
       _Tiles[[mask]].valid_rows != valid_rows ||
       _Tiles[[mask]].valid_columns != _Tiles[[indices]].valid_columns ||
       !IndexedTLSUPhysicalShapeLegal(CurrentBundleTileLayout(), data_type,
           valid_rows, valid_columns, columns) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    if !ResolveBundleTileDestinationsWithShapeAndType(TRUE, valid_rows,
           valid_columns, columns, TRUE, data_type) then return FALSE; end;
    if !ValidateBundleLocalGenerationWriters() then
        RollBackBundleTileDestinations(); return FALSE;
    end;
    let destination = if _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile
        then _BundleTileBindings[[1]].destination
        else _BundleTileBindings[[0]].destination;
    let pad_value = CurrentBundlePadValue();
    if !TileOperandsLegal_MGATHER_MASK(destination, Zeros{PTO_XLEN},
           indices, mask, pad_value) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    MGATHER_MASK(destination, base_address, indices, mask, pad_value);
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
