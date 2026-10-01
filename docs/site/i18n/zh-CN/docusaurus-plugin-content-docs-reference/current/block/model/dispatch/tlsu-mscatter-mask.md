<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-mscatter-mask.asl -->
# TLSU Mscatter Mask

**Normative ASL source:** `asl/block/model/dispatch/tlsu-mscatter-mask.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-mask-purpose role=purpose-scope -->
## 用途与范围

本单元是 `MSCATTER.MASK` 的指令束级处理程序。`MSCATTER.MASK` 是按索引存储，只写谓词 Tile 位已置位的通道。

`BundleMSCATTERMASKSelected` 识别该指令束：有效的 `TileMemory` 操作描述符，其选择器功能号（位 `4:0`）为 `7`。`ExecuteBundleMSCATTERMASKOperation` 校验完整指令束并调用 Tile 级 `MSCATTER_MASK` 效果。与普通 scatter 一样，它不产生 Tile，也不解析目标。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-mask-concepts role=concepts-state -->
## 概念与可见状态

按 `BundleMSCATTERMASKBindingsLegal` 的要求，该形式总是使用两条 `B.IOT` 命令。

- 第一个 `B.IOT` 在 `source0` 中携带数据 Tile，在 `source1` 中携带索引 Tile。它没有目标，目标大小为零，也没有 `last` 标志。
- 第二个 `B.IOT` 在 `source0` 中携带操作的掩码 Tile，无目标，目标大小为零，并带 `last`。只有在谓词 Tile 执行掩码生效时才带 `source1`。
- 必须有一条 `B.IOR` 记录。其 `source0` 选择为当前内存代理保存基地址的 GPR。
- `B.DIM` 给出有效列数、有效行数和物理列数，它们必须等于数据 Tile 自身的值。

掩码 Tile 是操作的谓词操作数。它与可选的执行掩码不同，后者是额外的最后一个源。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-mask-rules role=rules-interactions -->
## 规则与交互

当 `SelectedBundleTileMaskIsZero` 成立时，处理程序首先无效果地返回成功。

未知的 TLSU 操作码引发 `Fault_IllegalInstruction`。下列其他检查都在第一次内存探测之前进行，失败时引发 `Fault_TileLegality`。

- 无 `B.IOS` 绑定、存在且合法的 `B.IOR`、PE 掩码一致、维度被 `BundleMGATHERDimensionsLegal` 接受，以及两绑定 schema。
- 数据 Tile 和索引 Tile 内容已定义，掩码 Tile 通过 `IndexedTLSUPredicateValuesLegal`。三者都具有指令束布局。
- 数据 Tile 具有操作数据类型，该类型通过 `IndexedTLSUOrdinaryTransferDataTypeLegal`。索引 Tile 为 S32、U32、S64 或 U64。
- 数据 Tile 的有效行数、有效列数和物理列数等于 `B.DIM` 的值。数据形状与索引形状匹配，掩码形状等于索引的有效形状，且物理形状合法。
- `TileOperandsLegal_MSCATTER_MASK` 成立。

成功时处理程序调用 `FinalizeBundleTileAttempt`。`MSCATTER_MASK` 的内存故障返回失败，没有需要回滚的目标。

设计要点：该形式需要数据 Tile、索引 Tile 和掩码 Tile。一个 `B.IOT` 最多容纳两个源，因此即使没有执行掩码，掩码也总是移到第二条命令。这与普通 `MSCATTER` 不同，后者只有在有执行掩码时才出现第二条命令。

设计要点：只有在执行掩码下活动且谓词位已置位的通道才会被探测和存储。谓词位清零的通道不形成地址，因此其索引值不会引发故障。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-mask-boundaries role=boundaries -->
## 架构边界

只有当 `ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` 未找到更靠前的专用选择器时，本单元才运行。`BundleMSCATTERMASKSelected` 在普通 `MSCATTER` 之后、`TPREFETCH` 之前测试。

谓词位的读取和 scatter 的提交顺序属于 Tile gather 与 scatter 所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-mask-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设数据 Tile 为 S16、RowMajor，有 4 个有效行、8 个有效列和 8 个物理列，`B.DIM` 把 `LB0` 设为 8、`LB1` 设为 4、`LB2` 设为 8。第一个 `B.IOT` 指定数据 Tile 和一个 4 乘 8 的 U32 索引 Tile。第二个指定一个 4 乘 8 的掩码 Tile，并带 `last`。若掩码置位了 32 个通道中的 10 个，scatter 探测并存储 10 个地址。

如果省略第二个 `B.IOT`，绑定数为 1，指令束引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mscatter-mask-related role=related-owners-navigation -->
## 相关所有者

- [MSCATTER 分派](tlsu-mscatter.md) 处理无谓词的形式。
- [MGATHER 分派](tlsu-mgather.md) 定义共用的维度检查。
- [Gather 与 scatter 内存](../../../tile/model/memory/gather-scatter.md) 定义 `MSCATTER_MASK`。
- [BSTART.MSCATTER.MASK](../../execution/BSTART.MSCATTER.MASK.md) 是该起始形式的指令页。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-mscatter-mask.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER-MASK","surface":"block","classification":["model","dispatch","tlsu-mscatter-mask"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-MSCATTER","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"]}

readonly func BundleMSCATTERMASKSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 7;
end;

readonly func BundleMSCATTERMASKBindingsLegal() => boolean
begin
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if BundleTileBindingCount() != 2 then return FALSE; end;
    let first = _BundleTileBindings[[0]];
    let second = _BundleTileBindings[[1]];
    return first.valid && !first.destination_valid &&
           first.destination_size == 0 && first.source0_valid &&
           first.source1_valid && !first.last &&
           second.valid && !second.destination_valid &&
           second.destination_size == 0 && second.source0_valid &&
           (second.source1_valid == execution_mask_tile) && second.last;
end;

func ExecuteBundleMSCATTERMASKOperation() => boolean
begin
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
       !BundleMSCATTERMASKBindingsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let source = _BundleTileBindings[[0]].source0;
    let indices = _BundleTileBindings[[0]].source1;
    let mask = _BundleTileBindings[[1]].source0;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if !IndexedTLSUExecutionMaskContentsDefined(source) ||
       !IndexedTLSUExecutionMaskContentsDefined(indices) ||
       !IndexedTLSUPredicateValuesLegal(mask) ||
       _Tiles[[source]].data_type != data_type ||
       !IndexedTLSUMemoryIndexDataTypeLegal(_Tiles[[indices]].data_type) ||
       !IndexedTLSUOrdinaryTransferDataTypeLegal(data_type) ||
       _Tiles[[source]].valid_rows != valid_rows ||
       _Tiles[[source]].valid_columns != valid_columns ||
       _Tiles[[source]].columns != columns ||
       !IndexedTLSUDataShapeMatchesIndex(
           _Tiles[[source]].valid_rows, _Tiles[[source]].valid_columns,
           _Tiles[[indices]].valid_rows, _Tiles[[indices]].valid_columns,
           data_type) ||
       _Tiles[[mask]].valid_rows != _Tiles[[indices]].valid_rows ||
       _Tiles[[mask]].valid_columns != _Tiles[[indices]].valid_columns ||
       !IndexedTLSUPhysicalShapeLegal(CurrentBundleTileLayout(), data_type,
           valid_rows, valid_columns, columns) ||
       _Tiles[[source]].layout != CurrentBundleTileLayout() ||
       _Tiles[[indices]].layout != CurrentBundleTileLayout() ||
       _Tiles[[mask]].layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let base_address = ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
        _BundleScalarBindings[[0]].source0);
    if !TileOperandsLegal_MSCATTER_MASK(
           Zeros{PTO_XLEN}, source, indices, mask) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    MSCATTER_MASK(base_address, source, indices, mask);
    if _LastFault != Fault_None then return FALSE; end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
