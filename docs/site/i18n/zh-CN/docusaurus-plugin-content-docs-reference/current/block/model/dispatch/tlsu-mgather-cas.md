<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-mgather-cas.asl -->
# TLSU Mgather Cas

**Normative ASL source:** `asl/block/model/dispatch/tlsu-mgather-cas.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-cas-purpose role=purpose-scope -->
## 用途与范围

本单元是 `MGATHER.CAS` 的指令束级处理程序。`MGATHER.CAS` 是按索引的比较并交换。对每个活动通道，它读取全局内存中的旧值，当旧值等于期望值时写入替换值，并在新的 Local Tile 中返回旧值。

`BundleMGATHERCASSelected` 识别该指令束：有效的 `TileMemory` 操作描述符，其选择器功能号（位 `4:0`）为 `8`。`ExecuteBundleMGATHERCASOperation` 校验完整指令束，解析目标，并调用 Tile 级 `MGATHER_CAS` 效果。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-cas-concepts role=concepts-state -->
## 概念与可见状态

比较并交换需要三个 Tile 源，因此该 schema 使用两条 `B.IOT` 命令。`BundleMGATHERCASBindingsLegal` 要求恰好两个 Tile 绑定。

- 第一个 `B.IOT` 在 `source0` 中携带索引 Tile，在 `source1` 中携带期望值 Tile。它没有目标，目标大小为零，也没有 `last` 标志。
- 第二个 `B.IOT` 携带目标、位于 `source0` 的替换 Tile 以及 `last`。只有在谓词 Tile 执行掩码生效时才带 `source1`。
- 必须有一条 `B.IOR` 记录。其 `source0` 选择为当前内存代理保存基地址的 GPR。
- `B.DIM` 给出有效列数、有效行数和物理列数，由 `BundleMGATHERDimensionsLegal` 检查。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-cas-rules role=rules-interactions -->
## 规则与交互

当 `SelectedBundleTileMaskIsZero` 成立时，处理程序首先无效果地返回成功。

未知的 TLSU 操作码引发 `Fault_IllegalInstruction`。下列其他检查都在解析目标之前进行，失败时引发 `Fault_TileLegality`。

- 无 `B.IOS` 绑定、存在且合法的 `B.IOR`、PE 掩码一致、维度合法，以及两绑定 schema。
- 索引、期望和替换 Tile 的内容都已定义，并具有指令束布局。索引 Tile 为 S32、U32、S64 或 U64。
- 操作数据类型为 U16、U32 或 U64，期望和替换 Tile 具有该类型。
- 三个源 Tile 的有效行数和有效列数都恰好等于 `B.DIM` 的值，且物理形状合法。

随后处理程序以 `B.DIM` 形状和操作数据类型解析目标，并校验 Local 生成写者。目标取自第二个绑定。之后的失败，或 `MGATHER_CAS` 内部的内存故障，会调用 `RollBackBundleTileDestinations`。成功时调用 `FinalizeBundleTileAttempt`，发布目标。

设计要点：数据类型集合限定为无符号 16、32 和 64 位值。比较是位模式相等，本处理程序不接受浮点或有符号类型。

设计要点：`MGATHER_CAS` 在执行第一次存储之前，对每个活动地址同时做读和写探测。因此权限或转换故障发生在任何比较并交换生效之前。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-cas-boundaries role=boundaries -->
## 架构边界

`ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` 在 `BundleGMOVSelected` 之后、`BundleGMAtomRedSelected` 之前测试 `BundleMGATHERCASSelected`。原子与归约选择器也覆盖功能号 `8`，但由于该选择器先被测试，未被更早选择器（例如 CUBE 传输）认领的功能号 `8` 指令束会到达本处理程序。

比较、存储和原子事件记录属于 Tile 原子操作所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-cas-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设一个 U32 指令束把 `LB0` 设为 8、`LB1` 设为 1、`LB2` 设为 8。第一个 `B.IOT` 指定一个 U64 索引 Tile 和一个 U32 期望 Tile，二者都是 1 乘 8。第二个指定一个 1 乘 8 的 U32 替换 Tile 和一个目标。8 个通道各自读取旧字。旧字等于期望字的通道存储替换值。目标接收全部 8 个旧字。

如果期望 Tile 是 S32，指令束会在分配目标之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-mgather-cas-related role=related-owners-navigation -->
## 相关所有者

- [MGATHER 分派](tlsu-mgather.md) 定义共用的维度检查。
- [GM 原子与归约分派](tlsu-gm-atom-red.md) 处理其他原子功能。
- [原子操作内存](../../../tile/model/memory/atomics.md) 定义 `MGATHER_CAS`。
- [BSTART.MGATHER.CAS](../../execution/BSTART.MGATHER.CAS.md) 是该起始形式的指令页。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-mgather-cas.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER-CAS","surface":"block","classification":["model","dispatch","tlsu-mgather-cas"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-MGATHER","PTO-TILE-MODEL-MEMORY-ATOMICS"]}

readonly func BundleMGATHERCASSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 8;
end;

readonly func BundleMGATHERCASBindingsLegal() => boolean
begin
    if BundleTileBindingCount() != 2 then return FALSE; end;
    let first = _BundleTileBindings[[0]];
    let second = _BundleTileBindings[[1]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    return first.valid && !first.destination_valid &&
           first.source0_valid && first.source1_valid && !first.last &&
           first.destination_size == 0 &&
           second.valid && second.destination_valid &&
           second.source0_valid &&
           (second.source1_valid == execution_mask_tile) && second.last;
end;

func ExecuteBundleMGATHERCASOperation() => boolean
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
       !BundleMGATHERCASBindingsLegal() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let first = _BundleTileBindings[[0]];
    let second = _BundleTileBindings[[1]];
    let indices = first.source0;
    let expected = first.source1;
    let replacement = second.source0;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if !IndexedTLSUExecutionMaskContentsDefined(indices) ||
       !IndexedTLSUExecutionMaskContentsDefined(expected) ||
       !IndexedTLSUExecutionMaskContentsDefined(replacement) ||
       !IndexedTLSUMemoryIndexDataTypeLegal(_Tiles[[indices]].data_type) ||
       !(data_type == TileDataType_U16 ||
         data_type == TileDataType_U32 ||
         data_type == TileDataType_U64) ||
       _Tiles[[expected]].data_type != data_type ||
       _Tiles[[replacement]].data_type != data_type ||
       _Tiles[[indices]].layout != CurrentBundleTileLayout() ||
       _Tiles[[expected]].layout != CurrentBundleTileLayout() ||
       _Tiles[[replacement]].layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]]) as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]]) as integer {1..65535};
    let columns = UInt(_BundleDimensions[[2]]) as integer {1..65535};
    if _Tiles[[indices]].valid_rows != valid_rows ||
       _Tiles[[indices]].valid_columns != valid_columns ||
       _Tiles[[expected]].valid_rows != valid_rows ||
       _Tiles[[expected]].valid_columns != valid_columns ||
       _Tiles[[replacement]].valid_rows != valid_rows ||
       _Tiles[[replacement]].valid_columns != valid_columns ||
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
    let destination = _BundleTileBindings[[1]].destination;
    let pad_value = CurrentBundlePadValue();
    if !TileOperandsLegal_MGATHER_CAS(destination, Zeros{PTO_XLEN},
           indices, expected, replacement,
           pad_value) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    MGATHER_CAS(destination, base_address, indices, expected, replacement,
        pad_value);
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
