<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-mgather.asl -->
# TLSU Mgather

**Normative ASL source:** `asl/block/model/dispatch/tlsu-mgather.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-purpose role=purpose-scope -->
## 用途与范围

本单元是普通 `MGATHER` 的指令束级处理程序。`MGATHER` 是按索引加载：每个索引从全局内存读取一个元素，写入新的 Local Tile。

`BundleMGATHERSelected` 识别该指令束：有效的 `TileMemory` 操作描述符，其选择器功能号（位 `4:0`）为 `4`。`ExecuteBundleMGATHEROperation` 校验完整指令束，解析目标，并调用 Tile 级 `MGATHER` 效果。本单元还定义 `BundleMGATHERDimensionsLegal`，供其他按索引 TLSU 处理程序复用。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-concepts role=concepts-state -->
## 概念与可见状态

`MGATHER` 指令束的 schema 如下。

- 必须有一条 `B.IOR` 记录。其 `source0` 选择保存基地址的 GPR，按当前内存代理读取。
- 一个 `B.IOT` 绑定，带目标、位于 `source0` 的索引 Tile 以及 `last` 标志。只有在谓词 Tile 执行掩码生效时才带 `source1`。不允许 `B.IOS` 绑定。
- `B.DIM` 给出目标的有效列数、有效行数和物理列数。
- 索引 Tile 必须是 S32、U32、S64 或 U64，且必须具有指令束布局。转移数据类型必须通过 `IndexedTLSUOrdinaryTransferDataTypeLegal`。

`BundleMGATHERDimensionsLegal` 要求每个维度在 `1..65535` 内，有效行数乘有效列数不超过 `PTO_MODEL_TILE_ELEMENTS`；对 RowMajor 布局，还要求有效列数不超过物理列数，且物理列数是非零的 2 的幂。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-rules role=rules-interactions -->
## 规则与交互

当 `SelectedBundleTileMaskIsZero` 成立时，处理程序首先无效果地返回成功。ASL 注释把 `B.IOT` PE 掩码 `0000` 称为严格空操作，位于 schema、源、GPR、维度、分配和内存检查之前。

未知的 TLSU 操作码引发 `Fault_IllegalInstruction`。schema、类型和形状失败引发 `Fault_TileLegality`。这些检查都在解析目标之前进行。数据形状必须通过 `IndexedTLSUDataShapeMatchesIndex` 与索引形状匹配，物理形状必须通过 `IndexedTLSUPhysicalShapeLegal`。

随后处理程序以 `B.DIM` 形状和操作数据类型解析目标，并校验 Local 生成写者。解析之后的失败会调用 `RollBackBundleTileDestinations`；`MGATHER` 内部引发的内存故障也会。成功时调用 `FinalizeBundleTileAttempt`，发布由指令束分配的目标。

设计要点：填充值来自 `CurrentBundlePadValue`，因此缺少 `B.DATR` 时得到 `TilePad_Null`。Tile 级 `MGATHER` 把它写入有效区域之外的目标元素；被执行掩码设为非活动的元素取另一个值。

设计要点：`MGATHER` 在写结果之前探测每个活动索引地址。因此转换故障使目标保持未发布，回滚会将其释放。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-boundaries role=boundaries -->
## 架构边界

只有当 `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` 未找到更靠前的专用选择器时，本单元才运行。在该顺序中，`BundleMGATHERSelected` 排在 `MGATHER.CAS`、原子或归约以及 `MGATHER.MASK` 选择器之后。处理程序返回后，由调用者提交或中止 Local 生成。

地址运算、索引到字节位移的规则以及填充属于 Tile gather 与 scatter 所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设指令束以 RowMajor 布局 gather FP32 值，`LB0` 为 32，`LB1` 为 4，`LB2` 为 32。索引 Tile 为 U32、RowMajor，有 4 个有效行和 32 个有效列。形状匹配，32 是 2 的幂，4 乘 32 为 128 个元素。目标被解析为 4 乘 32 的 FP32 Tile，并接收 128 个 gather 得到的元素。

如果索引 Tile 是 FP32，指令束会在分配任何目标之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-related role=related-owners-navigation -->
## 相关所有者

- [Tile 执行分派](tile-execution.md) 排定各专用选择器的顺序。
- [MGATHER.MASK 分派](tlsu-mgather-mask.md) 和 [MGATHER.CAS 分派](tlsu-mgather-cas.md) 复用本单元的维度检查。
- [Gather 与 scatter 内存](../../../tile/model/memory/gather-scatter.md) 定义 Tile 级 `MGATHER`。
- [BSTART.MGATHER](../../execution/BSTART.MGATHER.md) 是该起始形式的指令页。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-mgather.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER","surface":"block","classification":["model","dispatch","tlsu-mgather"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"]}

readonly func BundleMGATHERSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 4;
end;

readonly func BundleMGATHERDimensionsLegal() => boolean
begin
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        if UInt(_BundleDimensions[[dimension]]) == 0 ||
           UInt(_BundleDimensions[[dimension]]) > 65535 then
            return FALSE;
        end;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    let row_major_shape_legal =
        CurrentBundleTileLayout() != TileLayout_RowMajor ||
        (valid_columns <= columns && IsNonzeroPowerOfTwo(columns));
    return row_major_shape_legal &&
           valid_rows * valid_columns <= PTO_MODEL_TILE_ELEMENTS;
end;

func ExecuteBundleMGATHEROperation() => boolean
begin
    // B.IOT PE_MASK=0000 is a strict no-op before schema, source, GPR,
    // dimension, allocation, and memory checks.
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 || BundleTileBindingCount() != 1 ||
       !_BundleScalarBindings[[0]].valid ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       !BundleMGATHERDimensionsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.destination_valid || !binding.source0_valid ||
       (binding.source1_valid != execution_mask_tile) || !binding.last ||
       !IndexedTLSUExecutionMaskContentsDefined(binding.source0) ||
       !IndexedTLSUMemoryIndexDataTypeLegal(
           _Tiles[[binding.source0]].data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !IndexedTLSUOrdinaryTransferDataTypeLegal(data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if !IndexedTLSUDataShapeMatchesIndex(
           valid_rows, valid_columns,
           _Tiles[[binding.source0]].valid_rows,
           _Tiles[[binding.source0]].valid_columns, data_type) ||
       _Tiles[[binding.source0]].layout != CurrentBundleTileLayout() ||
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
    let destination = _BundleTileBindings[[0]].destination;
    let pad_value = CurrentBundlePadValue();
    if !TileOperandsLegal_MGATHER(destination, Zeros{PTO_XLEN},
           binding.source0, pad_value) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    MGATHER(destination, base_address, binding.source0, pad_value);
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
