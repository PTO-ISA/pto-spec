<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-layout-conversion.asl -->
# TLSU Layout Conversion

**Normative ASL source:** `asl/block/model/dispatch/tlsu-layout-conversion.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-layout-conversion-purpose role=purpose-scope -->
## 用途与范围

本单元是在普通内存布局与 Local CUBE 布局之间转换的 `TLOAD` 和 `TSTORE` 指令束的指令束级处理程序。ASL 中称之为 CUBE 传输。

`BundleCubeTransportSelected` 识别该指令束：有效的 `TileMemory` 描述符，存在 `B.DATR` 命令，且其 `Layout` 代码位于 `21..26`。`ExecuteBundleCubeTransportOperation` 校验指令束，然后要么加载到新的 CUBE Tile（功能号 `0`），要么存储已有的 CUBE Tile（功能号 `1`）。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-layout-conversion-concepts role=concepts-state -->
## 概念与可见状态

`B.DATR` 布局代码同时选择方向和 CUBE 布局。

| 代码 | 名称 | 方向 | Local 布局 |
| --- | --- | --- | --- |
| `21` | `ND2M32` | 加载 | `CUBE_M32` |
| `22` | `ND2M16` | 加载 | `CUBE_M16` |
| `23` | `ND2N8` | 加载 | `CUBE_N8` |
| `24` | `M322ND` | 存储 | `CUBE_M32` |
| `25` | `M162ND` | 存储 | `CUBE_M16` |
| `26` | `N82ND` | 存储 | `CUBE_N8` |

`B.DIM` 在 `LB0` 中给出有效列数，在 `LB1` 中给出有效行数，各自在 `1..65535` 内。`LB2` 必须为 `1`，因为 CUBE 布局自行推导物理几何。可选的 `B.IOR` 在 `source0` 中给出基地址，在 `source1` 中给出以字节计的行步长。没有它时，基址为零，步长为有效列的稠密行大小。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-layout-conversion-rules role=rules-interactions -->
## 规则与交互

当 `SelectedBundleTileMaskIsZero` 成立时，处理程序首先无效果地返回成功。ASL 注释把这一步放在所有 schema、GPR、描述符、分配和内存检查之前。

未知的 TLSU 操作码引发 `Fault_IllegalInstruction`。以下情况引发 `Fault_TileLegality`：维度非法；`B.DATR` 数据类型不是 `DTYPE_NONE`；比较或舍入模式非零；设置了饱和或规范化；功能号 `1` 配加载布局代码，或功能号 `0` 配存储代码；功能号不是 `0` 或 `1`；存在 `B.FPATR`；绑定 schema 错误。

对于加载，唯一的 `B.IOT` 携带目标和 `last`，只有作为谓词 Tile 执行掩码时才携带源。对于存储，它携带 CUBE 源 Tile 和 `last`，没有目标。

有效数据类型必须通过 `TileCubeDataTypeSupported`，且不能是 HiF4X2。按 ASL 注释，U64 只在加载到 `CUBE_N8` 时被接受。

加载通过 `ResolveBundleCubeTransportDestination` 解析目标。描述符不匹配的复用生成目标引发 `Fault_TileLegality`。非法的 CUBE 形状、某个选中 PE 的容量溢出，或目标 hand 中没有空闲 Tile 槽位，引发 `Fault_TileAllocation`。随后处理程序校验 Local 生成写者并调用 `TLOAD`。存储检查源是具有所选类型、布局和有效形状的合法且已定义的 CUBE Tile，并在每个选中 PE 上已分配，然后调用 `TSTORE`。

设计要点：加载路径在内存故障后调用 `RollBackBundleTileDestinations`。ASL 注释指出，该故障保留其之前已完成的 beat，但不得发布推测性的 Local 目标。

设计要点：本处理程序检查除填充值以外的每个 `B.DATR` 字段。Tile schema 中的通用数据属性检查指出，对于 `TLOAD` 和 `TSTORE`，只有这些 Local CUBE 转换形式可以携带非零填充值。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-layout-conversion-boundaries role=boundaries -->
## 架构边界

`ExecuteBundleTileOperationLocallyWithAcceptedApplicabilityRules` 在 TIMG2COL、权重加载和矩阵选择器之后、`GMOV` 和按索引 TLSU 选择器之前测试本选择器。由于它只依赖布局代码，功能号不同但带转换布局的 `TileMemory` 指令束也会到达这里并被拒绝。

CUBE 布局内部的元素放置属于 Tile 加载与存储所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-layout-conversion-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设一个 `TLOAD` 指令束的 `B.DATR` 布局为 `ND2M16`，操作类型为 FP16，`LB0` 为 64，`LB1` 为 16，没有 `B.IOR`。基址为零，行步长为 64 乘 2，即 128 字节。处理程序在目标 hand 的第一个空闲槽位分配一个 `CUBE_M16` 目标，并加载 16 行。

如果同一指令束还把 `LB2` 设为 64，它会在分配之前引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-layout-conversion-related role=related-owners-navigation -->
## 相关所有者

- [Tile schema 分派](tile-schema.md) 持有其他 `TLOAD` 和 `TSTORE` 指令束的填充值规则。
- [Tile 执行分派](tile-execution.md) 排定各专用选择器的顺序。
- [加载与存储内存](../../../tile/model/memory/load-store.md) 定义 `TLOAD` 和 `TSTORE`。
- [BSTART.TLOAD](../../execution/BSTART.TLOAD.md) 和 [BSTART.TSTORE](../../execution/BSTART.TSTORE.md) 是相应指令页。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-layout-conversion.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION","surface":"block","classification":["model","dispatch","tlsu-layout-conversion"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-MEMORY-LOAD-STORE"]}

readonly func BundleCubeTransportSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleDataAttributesPresent &&
           TileDataLayoutIsCubeConversion(
               _BundleDataAttributes.data_layout);
end;

pure func BundleCubeTransportDataTypeSupported(
    data_type: TileDataType, layout: TileLayout, function: integer {0..31})
    => boolean
begin
    // HiF4X2 is accepted only by the Matrix-MX input-role contract.  U64 is
    // the single descriptor-level exception, and only ND2N8 TLOAD may create
    // that Local CUBE_N8 representation.
    if data_type == TileDataType_U64 then
        return function == 0 && layout == TileLayout_CUBE_N8;
    end;
    return TileCubeDataTypeSupported(data_type) &&
           data_type != TileDataType_HiF4X2;
end;

readonly func BundleCubeTransportDimensionsLegal() => boolean
begin
    let valid_columns = UInt(_BundleDimensions[[0]]);
    let valid_rows = UInt(_BundleDimensions[[1]]);
    return 1 <= valid_columns && valid_columns <= 65535 &&
           1 <= valid_rows && valid_rows <= 65535 &&
           UInt(_BundleDimensions[[2]]) == 1;
end;

readonly func BundleCubeTransportDataAttributesLegal() => boolean
begin
    if !_BundleDataAttributesPresent ||
       _BundleDataAttributes.data_type != DTYPE_NONE ||
       !TileDataLayoutIsCubeConversion(
           _BundleDataAttributes.data_layout) ||
       _BundleDataAttributes.comparison_mode != Zeros{3} ||
       _BundleDataAttributes.rounding_mode != Zeros{3} ||
       _BundleDataAttributes.saturating ||
       _BundleDataAttributes.canonicalize then
        return FALSE;
    end;
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       !_BundleOperation.selector_valid then
        return FALSE;
    end;
    let function = UInt(_BundleOperation.selector[4:0]);
    if function == 0 then
        return TileDataLayoutConversionIsLoad(
            _BundleDataAttributes.data_layout);
    elsif function == 1 then
        return TileDataLayoutConversionIsStore(
            _BundleDataAttributes.data_layout);
    end;
    return FALSE;
end;

readonly func BundleCubeTransportBindingsLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if BundleSharedBindingCount() != 0 ||
       BundleTileBindingCount() != 1 ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationScalarBindingSchemaLegal(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() then
        return FALSE;
    end;
    let function = UInt(_BundleOperation.selector[4:0]);
    let binding = _BundleTileBindings[[0]];
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if !binding.valid || !binding.last then return FALSE; end;
    if function == 0 then
        return binding.destination_valid &&
               !binding.destination_allocated_by_bundle &&
               BundleTileDestinationSizeLegal(0) &&
               (binding.source0_valid == execution_mask_tile) &&
               !binding.source1_valid &&
               (!execution_mask_tile ||
                _BundleExecutionMask.predicate_source_ordinal == 0);
    elsif function == 1 then
        return !binding.destination_valid &&
               binding.source0_valid &&
               (binding.source1_valid == execution_mask_tile) &&
               (!execution_mask_tile ||
                _BundleExecutionMask.predicate_source_ordinal == 1);
    end;
    return FALSE;
end;

func ResolveBundleCubeTransportDestination(
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    data_type: TileDataType,
    layout: TileLayout) => boolean
begin
    let binding = _BundleTileBindings[[0]];
    let capacity_bytes = BundleTileDestinationSizeBytes(0);
    if binding.destination_reused_by_generation then
        let destination = _Tiles[[binding.destination]];
        if !TileCubeDescriptorLegal(destination) ||
           destination.capacity_bytes != capacity_bytes ||
           destination.valid_rows != valid_rows ||
           destination.valid_columns != valid_columns ||
           destination.data_type != data_type ||
           destination.layout != layout ||
           (_TileAllocationMasks[[binding.destination]] AND binding.pe_mask) !=
               binding.pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        return TRUE;
    end;
    if !TileCubeDescriptorShapeLegal(capacity_bytes, valid_rows,
           valid_columns, data_type, layout) ||
       !LocalTileAllocationFits(binding.pe_mask, capacity_bytes) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let hand = UInt(binding.destination_hand);
    var destination: TileIndex = 0;
    var found = FALSE;
    for offset = 0 to 15 do
        let raw_index: integer = hand * 16 + offset;
        if !found && !_Tiles[[raw_index]].allocated then
            destination = raw_index as TileIndex;
            found = TRUE;
        end;
    end;
    if !found || !ConfigureCubeTileForMask(
           destination, capacity_bytes, valid_rows, valid_columns,
           data_type, layout, binding.pe_mask) then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    _BundleTileBindings[[0]].destination = destination;
    _BundleTileBindings[[0]].destination_allocated_by_bundle = TRUE;
    return TRUE;
end;

func ExecuteBundleCubeTransportOperation() => boolean
begin
    // A zero Local mask is resolved before every schema, GPR, descriptor,
    // allocation, and memory check.
    if SelectedBundleTileMaskIsZero() then return TRUE; end;
    let decoded = DecodeTileOperation(
        TileDecode_TLSU, BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if !BundleCubeTransportDimensionsLegal() ||
       !BundleCubeTransportDataAttributesLegal() ||
       !BundleExecutionMaskDataAttributesLegal(operation) ||
       !BundleCubeTransportBindingsLegal(operation) ||
       _BundleFixedPointAttributes.valid then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let (type_valid, data_type) = ResolveBundleEffectiveDataType();
    let layout = TileDataLayoutCubeLayout(
        _BundleDataAttributes.data_layout);
    let function = UInt(_BundleOperation.selector[4:0]);
    if !type_valid || !BundleCubeTransportDataTypeSupported(
           data_type, layout, function) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let valid_columns = UInt(_BundleDimensions[[0]])
        as integer {1..65535};
    let valid_rows = UInt(_BundleDimensions[[1]])
        as integer {1..65535};
    let base_address = if _BundleScalarBindings[[0]].valid then
        ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source0)
        else Zeros{PTO_XLEN};
    let row_stride_bytes = if _BundleScalarBindings[[0]].valid then
        ReadScalarRegisterOperand(_BundleScalarBindings[[0]].source1)
        else TileDenseRowStrideBytes(valid_columns, data_type);
    if function == 0 then
        if !ResolveBundleCubeTransportDestination(
               valid_rows, valid_columns, data_type, layout) then
            return FALSE;
        end;
        if !ValidateBundleLocalGenerationWriters() then
            RollBackBundleTileDestinations(); return FALSE;
        end;
        let destination = _BundleTileBindings[[0]].destination;
        TLOAD(destination, base_address, row_stride_bytes);
        if _LastFault != Fault_None then
            // A memory fault retains the beats completed before it but must
            // not publish the speculative Local destination.  Release it and
            // re-synchronize the saved trap context exactly like the generic
            // destination path does.
            RollBackBundleTileDestinations();
            return FALSE;
        end;
    else
        let source = _BundleTileBindings[[0]].source0;
        let tile = _Tiles[[source]];
        if !TileCubeDescriptorLegal(tile) ||
           !TileElementwiseSourceContentsDefined(source) ||
           tile.data_type != data_type || tile.layout != layout ||
           tile.valid_rows != valid_rows ||
           tile.valid_columns != valid_columns ||
           (_TileAllocationMasks[[source]] AND
               _BundleTileBindings[[0]].pe_mask) !=
               _BundleTileBindings[[0]].pe_mask then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        TSTORE(base_address, row_stride_bytes, source);
        if _LastFault != Fault_None then
            RollBackBundleTileDestinations();
            return FALSE;
        end;
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
