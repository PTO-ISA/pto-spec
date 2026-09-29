<!-- GENERATED FROM: asl/block/model/dispatch/destination-shape.asl -->
# Destination Shape

**Normative ASL source:** `asl/block/model/dispatch/destination-shape.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-destination-shape-purpose role=purpose-scope -->
## 用途与范围

本单元拥有为 Tile 指令束分配 Local 目标的共享解析函数：`ResolveBundleTileDestinationsWithShapeAndType`，以及它的两个包装 `ResolveBundleTileDestinationsWithShape` 和 `ResolveBundleTileDestinations`。它还拥有把指令束维度转换为目标形状的默认形状读取函数。

Local 目标是写作 `->DstTile<Size>` 的 `B.IOT` 目标。它给出一个相对 hand（0 到 3）和一个大小编码，而不是绝对 Tile 寄存器。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-shape-concepts role=concepts-state -->
## 概念与可见状态

默认形状读取函数使用指令束维度槽位。`BundleDestinationValidRows` 读取 `LB1`，`BundleDestinationValidColumns` 读取 `LB0`。`BundleDestinationPhysicalColumns` 在 `B.DIM` 设置过 `LB2` 时读取 `LB2`。未设置 `LB2` 时，它返回有效列数；对于 CUBE 布局的 `TCI`，它把该数向上取整到 CUBE 单元宽度。大于 65535 的值读作 0。

解析函数对其分配的每个目标写入以下状态：

- 通过 `ConfigureBundleTileDestination` 写入 `_Tiles` 中的绝对 Tile 寄存器描述符及其分配掩码；
- 绑定的 `destination` 字段，它从 hand 变为绝对寄存器索引；
- 绑定的 `destination_allocated_by_bundle` 标志。

若目标所在绑定已设置 `destination_allocated_by_bundle` 或 `destination_reused_by_generation`，则不会再次分配。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-shape-rules role=rules-interactions -->
## 规则与交互

解析函数分四步工作。

1. 它解析有效数据类型。若不存在，则引发 `Fault_TileLegality`。
2. 它为每个新目标选择寄存器。hand `h` 拥有寄存器 `16h` 到 `16h+15`，解析函数取其中未分配且在本指令束中尚未被选中的最小编号。若没有空闲寄存器，则引发 `Fault_TileAllocation`。随后它检查：对每个目标 PE 掩码中的每个 PE，已用 Tile 容量加上新目标的容量都不超过 `TileCapacityLimitBytes`。检查失败同样引发 `Fault_TileAllocation`。
3. 它计算并检查每个目标描述符。形状放不进大小编码时，新目标引发 `Fault_TileAllocation`，重用目标引发 `Fault_TileLegality`。重用目标还必须在容量、有效形状、类型和布局上与其现有描述符一致，且其分配掩码必须覆盖绑定的 PE 掩码；不一致时引发 `Fault_TileLegality`。
4. 只有此时，它才配置每个新目标。

目标类型取决于其位置。第一个目标获得主类型：对归约而言，返回索引时为 `U32`，否则为有效数据类型；否则若调用者给出显式类型则取该类型；否则在矩阵指令束中为矩阵输出类型，在其他情况下为有效数据类型。后续目标在矩阵指令束中获得矩阵输出类型，否则为 `U32`。在矩阵指令束中，RowMax 输出有 1 列，GroupMax 输出的列数为列数除以组大小并向上取整。

设计要点：步骤 1 到 3 不改变任何 Tile 状态。ASL 注释说明了用意：B.IOT 分配是全有或全无的，因此大小编码对形状过小时，会在分配任何目标之前故障。对于这种失败，该目标组中的任何目标都不会被分配。

设计要点：重用目标是某个打开的 generation 的现有 Tile。步骤 2 和 4 会跳过它，因此本解析函数从不分配它。当其推导形状放不下或与该 Tile 不一致时，解析函数引发 `Fault_TileLegality`；步骤 3 只对它将要分配的目标引发 `Fault_TileAllocation`。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-shape-boundaries role=boundaries -->
## 架构边界

形状和类型由调用者决定。目标路由函数为大多数封闭 schema 操作传入显式形状，`GMOV`、`MGATHER` 和 Shared TLSU 等专用路径也会调用这些解析函数。Tile 矩阵指令束的主目标由 CUBE 矩阵处理程序解析，而不经过路由函数。

本单元只在 assemble 的 `INIT` 阶段把目标发布为相对源。后续故障之后对已分配目标的回滚由故障回滚单元拥有。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-shape-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

```text
TADD <Row=8, Col=64, FP32>, T#1, T#2, ->T<2KB>
```

目标 hand 为 0，因此解析函数扫描寄存器 0 到 15。若寄存器 0 和 1 已分配，它选择寄存器 2。形状为 8 个有效行乘 64 个有效列，物理列数为 64。2 KB 容量共 16384 位，一行 64 个 `FP32` 元素占 2048 位，因此推导出的行数为 8。8 个有效行可以放下，寄存器 2 被配置。

若写作 `->T<1KB>`，推导出的行数为 4。步骤 3 会引发 `Fault_TileAllocation`，且不会分配任何寄存器。

<!-- PTO-READER-BLOCK: block-model-dispatch-destination-shape-related role=related-owners-navigation -->
## 相关所有者

- [目标操作](destination-operation.md) 选择形状和类型参数。
- [目标辅助](destination-auxiliary.md) 拥有 `ConfigureBundleTileDestination` 和 GroupMax 列规则。
- [Tile 分配](../../../tile/model/state/allocation.md) 定义配置寄存器的分配转换。
- [故障回滚](../faults/rollback.md) 在后续故障之后撤销已分配的目标。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/destination-shape.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","surface":"block","classification":["model","dispatch","destination-shape"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-CELL-REARRANGEMENT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-DESTINATION-AUXILIARY","PTO-BLOCK-MODEL-DISPATCH-EXPANSION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-NUMERIC-CONTROL","PTO-BLOCK-MODEL-DISPATCH-PREDICATE-DESTINATION","PTO-BLOCK-MODEL-DISPATCH-REDUCTION-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TCVT-DESTINATION","PTO-BLOCK-MODEL-DISPATCH-TCVT-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-SCALAR-SCHEMA","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
readonly func BundleDestinationValidRows(
    shape_source_valid: boolean, shape_source: TileIndex) => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB1);
    if UInt(_BundleDimensions[[index]]) <= 65535 then
        return UInt(_BundleDimensions[[index]]) as integer {0..65535};
    end;
    return 0;
end;
readonly func BundleDestinationValidColumns(
    shape_source_valid: boolean, shape_source: TileIndex) => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB0);
    if UInt(_BundleDimensions[[index]]) <= 65535 then
        return UInt(_BundleDimensions[[index]]) as integer {0..65535};
    end;
    return 0;
end;
readonly func BundleDestinationPhysicalColumns(
    shape_source_valid: boolean, shape_source: TileIndex) => integer {0..65535}
begin
    let index = BundleDimensionIndexOfRegister(BundleDimension_LB2);
    if !_BundleDimensionPresent[[index]] && _BundleOperation.valid then
        let decoded = DecodeTileOperation(
            BundleTileDecodeFamily(_BundleOperation.operation_class),
            BundleOperationDecodeCode(_BundleOperation));
        if decoded != PTO_TILE_OPERATION_COUNT &&
           TileOperationOfIndex(
               decoded as integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
               TileOperation_TCI &&
           (CurrentBundleTileLayout() == TileLayout_CUBE_M16 ||
            CurrentBundleTileLayout() == TileLayout_CUBE_M32) then
            let (type_valid, data_type) = ResolveBundleEffectiveDataType();
            if type_valid then
                let cell_columns = TileCubeCellColumns(CurrentBundleTileLayout(), data_type);
                if cell_columns != 0 then
                    return TileCubeAlignedExtent(
                        BundleDestinationValidColumns(shape_source_valid,
                            shape_source),
                        cell_columns as integer {1..65535});
                end;
            end;
        end;
        return BundleDestinationValidColumns(shape_source_valid, shape_source);
    end;
    if UInt(_BundleDimensions[[index]]) <= 65535 then
        return UInt(_BundleDimensions[[index]]) as integer {0..65535};
    end;
    return 0;
end;
readonly func BundleReusedDestinationDescriptorMatches(
    binding: BundleTileBindingIndex, capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
    columns: integer {0..65535}, data_type: TileDataType,
    layout: TileLayout, cube: boolean, exact_cube_columns: boolean,
    preserve_physical_rows: boolean, expected_physical_rows: integer {0..65535}) => boolean
begin
    let index = _BundleTileBindings[[binding]].destination;
    let destination = _Tiles[[index]];
    let mask_legal = (_TileAllocationMasks[[index]] AND
        _BundleTileBindings[[binding]].pe_mask) ==
        _BundleTileBindings[[binding]].pe_mask;
    if cube then
        return TileCubeDescriptorLegal(destination) &&
               destination.capacity_bytes == capacity_bytes &&
               destination.valid_rows == valid_rows &&
               destination.valid_columns == valid_columns &&
               (!exact_cube_columns || destination.columns == columns) &&
               destination.data_type == data_type &&
               destination.layout == layout && mask_legal;
    end;
    return TileDescriptorLegal(index) &&
           destination.storage_kind == TileStorage_Numeric &&
           destination.capacity_bytes == capacity_bytes &&
           destination.rows == (if preserve_physical_rows then expected_physical_rows else DerivedTileRows(capacity_bytes, columns, data_type)) &&
           destination.columns == columns &&
           destination.valid_rows == valid_rows &&
           destination.valid_columns == valid_columns &&
           destination.data_type == data_type &&
           destination.layout == layout && mask_legal;
end;
readonly func BundleLocalDestinationCapacityGroupFits() => boolean
begin
    var additional0: integer = 0;
    var additional1: integer = 0;
    var additional2: integer = 0;
    var additional3: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           !_BundleTileBindings[[binding]].destination_allocated_by_bundle &&
           !_BundleTileBindings[[binding]].destination_reused_by_generation then
            let capacity_bytes = BundleLocalDestinationAllocationBytes(
                binding as BundleTileBindingIndex);
            let mask = _BundleTileBindings[[binding]].pe_mask;
            if mask[PTOPEMaskBitOfPEIdentity(0)] == '1' then
                additional0 = additional0 + capacity_bytes;
            end;
            if mask[PTOPEMaskBitOfPEIdentity(1)] == '1' then
                additional1 = additional1 + capacity_bytes;
            end;
            if mask[PTOPEMaskBitOfPEIdentity(2)] == '1' then
                additional2 = additional2 + capacity_bytes;
            end;
            if mask[PTOPEMaskBitOfPEIdentity(3)] == '1' then
                additional3 = additional3 + capacity_bytes;
            end;
        end;
    end;
    return TileCapacityInUseForPE(0) + additional0 <=
               TileCapacityLimitBytes() &&
           TileCapacityInUseForPE(1) + additional1 <=
               TileCapacityLimitBytes() &&
           TileCapacityInUseForPE(2) + additional2 <=
               TileCapacityLimitBytes() &&
           TileCapacityInUseForPE(3) + additional3 <=
               TileCapacityLimitBytes();
end;
func ResolveBundleTileDestinationsWithShapeAndType(
    explicit_shape: boolean,
    explicit_valid_rows: integer {0..65535},
    explicit_valid_columns: integer {0..65535},
    explicit_columns: integer {0..65535},
    explicit_primary_type: boolean,
    primary_type: TileDataType) => boolean
begin
    let (effective_type_valid, selected_type) =
        ResolveBundleEffectiveDataType();
    if !effective_type_valid then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    var reserved: array [[PTO_TILE_REGISTER_COUNT]] of boolean;
    var resolved: array [[PTO_BUNDLE_TILE_BINDING_COUNT]] of TileIndex;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        reserved[[index]] = FALSE;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        resolved[[binding]] = 0;
        if _BundleTileBindings[[binding]].valid &&
            _BundleTileBindings[[binding]].destination_valid &&
            !_BundleTileBindings[[binding]].destination_allocated_by_bundle &&
            !_BundleTileBindings[[binding]].destination_reused_by_generation then
            let hand =
                UInt(_BundleTileBindings[[binding]].destination_hand);
            var found = FALSE;
            for offset = 0 to 15 do
                let raw_index: integer = hand * 16 + offset;
                if !found && !_Tiles[[raw_index]].allocated &&
                   !reserved[[raw_index]] then
                    resolved[[binding]] = raw_index as TileIndex;
                    reserved[[raw_index]] = TRUE;
                    found = TRUE;
                end;
            end;
            if !found then
                SetFault(Fault_TileAllocation, ReadTPC());
                return FALSE;
            end;
        end;
    end;
    if !BundleLocalDestinationCapacityGroupFits() then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    let matrix = _BundleOperation.valid &&
        _BundleOperation.operation_class == BundleOperation_TileMatrix;
    let decoded_operation = DecodeTileOperation(BundleTileDecodeFamily(_BundleOperation.operation_class), BundleOperationDecodeCode(_BundleOperation));
    let reduction_operation = if decoded_operation != PTO_TILE_OPERATION_COUNT then
        TileOperationUsesClosedReductionSchema(decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1})
        else FALSE;
    let reduction_row = if decoded_operation != PTO_TILE_OPERATION_COUNT then
        TileOperationUsesClosedRowReductionSchema(decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1})
        else FALSE;
    let accumulator_type = TileMatrixAccumulatorDataType(selected_type);
    let matrix_output_type = if matrix then
        BundleFPATREffectiveDataType(
            _BundleFixedPointAttributes.pre_quant_mode, accumulator_type)
    else selected_type;
    let primary_output_type = if reduction_operation then
        if TileReductionOperationReturnsIndex(
               decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1})
        then TileDataType_U32 else selected_type
    else if explicit_primary_type then
        primary_type
    else
        matrix_output_type;
    var shape_source_valid = FALSE;
    var shape_source: TileIndex = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if !shape_source_valid && _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                shape_source = BundleTileSourceIndex(
                    binding as BundleTileBindingIndex, FALSE);
                shape_source_valid = TRUE;
            elsif _BundleTileBindings[[binding]].source1_valid then
                shape_source = BundleTileSourceIndex(
                    binding as BundleTileBindingIndex, TRUE);
                shape_source_valid = TRUE;
            end;
        end;
    end;
    // Validate every derived descriptor before allocating; preserve precise all-or-nothing B.IOT allocation when a size code is too small for its logical shape.
    var destination_ordinal: integer = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            let valid_rows = if explicit_shape then explicit_valid_rows else
                BundleDestinationValidRows(shape_source_valid, shape_source);
            let valid_columns = if explicit_shape then
                explicit_valid_columns else BundleDestinationValidColumns(
                    shape_source_valid, shape_source);
            let columns = if explicit_shape then explicit_columns else
                BundleDestinationPhysicalColumns(
                    shape_source_valid, shape_source);
            let destination_layout = if decoded_operation != PTO_TILE_OPERATION_COUNT &&
                TileOperationOfIndex(decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) == TileOperation_TGPR2T then
                if valid_rows == 32 then TileLayout_CUBE_M32 else TileLayout_CUBE_M16
            else CurrentBundleTileLayout();
            let destination_type = if destination_ordinal == 0 then
                primary_output_type else if matrix then matrix_output_type
                else TileDataType_U32;
            let auxiliary_row = matrix &&
                _BundleFixedPointAttributes.row_max_en &&
                destination_ordinal == 1;
            let auxiliary_group = matrix &&
                _BundleFixedPointAttributes.group_max_en &&
                ((!_BundleFixedPointAttributes.row_max_en &&
                  destination_ordinal == 1) ||
                 (_BundleFixedPointAttributes.row_max_en &&
                  destination_ordinal == 2));
            let auxiliary_columns = if auxiliary_row then 1
                else if auxiliary_group then
                    BundleGroupMaxColumns(columns)
                else columns;
            let auxiliary_valid_columns = if auxiliary_row then 1
                else if auxiliary_group then
                    BundleGroupMaxColumns(valid_columns)
                else valid_columns;
            let capacity_bytes = BundleLocalDestinationAllocationBytes(binding as BundleTileBindingIndex);
            let reused = _BundleTileBindings[[binding]].destination_reused_by_generation;
            let cube_destination = destination_layout == TileLayout_CUBE_M16 ||
                destination_layout == TileLayout_CUBE_M32;
            let ordinary_tcvt = BundleDestinationIsOrdinaryTCVT(decoded_operation, cube_destination);
            let exact_cube_columns = cube_destination &&
                decoded_operation != PTO_TILE_OPERATION_COUNT &&
                TileOperationOfIndex(
                    decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
                    TileOperation_TCI;
            let source_geometry = if shape_source_valid then _Tiles[[shape_source]] else _Tiles[[0]];
            let physical_rows = if cube_destination then
                if reduction_operation && !reduction_row then source_geometry.rows
                else TileCubeStorageRows(destination_layout, valid_rows,
                    destination_type)
            else if ordinary_tcvt then source_geometry.rows else 0;
            let physical_columns = if cube_destination then
                if exact_cube_columns then auxiliary_columns
                else if reduction_operation && reduction_row then
                    source_geometry.columns
                else TileCubeStorageColumns(destination_layout,
                    auxiliary_valid_columns, destination_type)
            else auxiliary_columns;
            let rows = if ordinary_tcvt then source_geometry.rows else DerivedTileRows(capacity_bytes, auxiliary_columns, destination_type);
            let shape_legal = if cube_destination then
                TileCubeDescriptorShapeAndPhysicalLegal(capacity_bytes,
                    physical_rows, physical_columns, valid_rows,
                    auxiliary_valid_columns, destination_type,
                    destination_layout)
            else if ordinary_tcvt then
                TileDescriptorPhysicalShapeLegal(capacity_bytes, source_geometry.rows, auxiliary_columns, valid_rows, auxiliary_valid_columns, destination_type)
            else
                TileDescriptorShapeLegal(capacity_bytes, auxiliary_columns,
                    valid_rows, auxiliary_valid_columns, destination_type);
            if exact_cube_columns &&
               !TileCubeGeometryLegalWithColumns(valid_rows,
                   auxiliary_valid_columns, auxiliary_columns,
                   destination_type, destination_layout) then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            if !shape_legal ||
               (!cube_destination && rows * auxiliary_columns >
                   TileLogicalElementCapacity(capacity_bytes,
                       destination_type)) then
                if reused then SetFault(Fault_TileLegality, ReadTPC());
                else SetFault(Fault_TileAllocation, ReadTPC()); end;
                return FALSE;
            end;
            if reused && !BundleReusedDestinationDescriptorMatches(
                   binding as BundleTileBindingIndex, capacity_bytes,
                   valid_rows, auxiliary_valid_columns, auxiliary_columns,
                   destination_type, destination_layout, cube_destination,
                   exact_cube_columns, ordinary_tcvt, source_geometry.rows) then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            destination_ordinal = destination_ordinal + 1;
        end;
    end;
    destination_ordinal = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            if !_BundleTileBindings[[binding]].destination_allocated_by_bundle &&
               !_BundleTileBindings[[binding]].destination_reused_by_generation then
                let valid_rows = if explicit_shape then explicit_valid_rows else
                    BundleDestinationValidRows(shape_source_valid, shape_source);
                let valid_columns = if explicit_shape then
                    explicit_valid_columns else BundleDestinationValidColumns(
                        shape_source_valid, shape_source);
                let destination_layout = if decoded_operation != PTO_TILE_OPERATION_COUNT &&
                    TileOperationOfIndex(decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) == TileOperation_TGPR2T then
                    if valid_rows == 32 then TileLayout_CUBE_M32 else TileLayout_CUBE_M16
                else CurrentBundleTileLayout();
                let columns = if explicit_shape then explicit_columns else
                    BundleDestinationPhysicalColumns(
                        shape_source_valid, shape_source);
                let destination_type = if destination_ordinal == 0 then
                    primary_output_type else if matrix then matrix_output_type
                    else TileDataType_U32;
                let auxiliary_row = matrix &&
                    _BundleFixedPointAttributes.row_max_en &&
                    destination_ordinal == 1;
                let auxiliary_group = matrix &&
                    _BundleFixedPointAttributes.group_max_en &&
                    ((!_BundleFixedPointAttributes.row_max_en &&
                      destination_ordinal == 1) ||
                     (_BundleFixedPointAttributes.row_max_en &&
                      destination_ordinal == 2));
                let auxiliary_columns = if auxiliary_row then 1
                    else if auxiliary_group then
                        BundleGroupMaxColumns(columns)
                    else columns;
                let auxiliary_valid_columns = if auxiliary_row then 1
                    else if auxiliary_group then
                        BundleGroupMaxColumns(valid_columns)
                    else valid_columns;
                let capacity_bytes = BundleLocalDestinationAllocationBytes(binding as BundleTileBindingIndex);
                let tgpr2t = (decoded_operation != PTO_TILE_OPERATION_COUNT &&
                    TileOperationOfIndex(decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) == TileOperation_TGPR2T) ||
                    destination_layout == TileLayout_CUBE_M16 ||
                    destination_layout == TileLayout_CUBE_M32;
                let exact_cube_columns = tgpr2t &&
                    decoded_operation != PTO_TILE_OPERATION_COUNT &&
                    TileOperationOfIndex(
                        decoded_operation as integer {0..PTO_TILE_OPERATION_COUNT-1}) ==
                        TileOperation_TCI;
                let source_geometry = if shape_source_valid then _Tiles[[shape_source]] else _Tiles[[0]];
                let ordinary_tcvt = BundleDestinationIsOrdinaryTCVT(decoded_operation, tgpr2t);
                let physical_rows = if destination_layout == TileLayout_CUBE_M16 ||
                    destination_layout == TileLayout_CUBE_M32 then
                    if reduction_operation && !reduction_row then
                        source_geometry.rows
                    else TileCubeStorageRows(destination_layout, valid_rows,
                        destination_type)
                else if ordinary_tcvt then source_geometry.rows else 0;
                let physical_columns = if destination_layout == TileLayout_CUBE_M16 ||
                    destination_layout == TileLayout_CUBE_M32 then
                    if exact_cube_columns then auxiliary_columns
                    else if reduction_operation && reduction_row then
                        source_geometry.columns
                    else TileCubeStorageColumns(destination_layout,
                        auxiliary_valid_columns, destination_type)
                else auxiliary_columns;
                if !ConfigureBundleTileDestination(resolved[[binding]],
                        capacity_bytes, physical_rows, physical_columns,
                        valid_rows, auxiliary_columns,
                        auxiliary_valid_columns, destination_type,
                        destination_layout, _BundleTileBindings[[binding]].pe_mask,
                        tgpr2t, exact_cube_columns, ordinary_tcvt) then
                    SetFault(Fault_TileAllocation, ReadTPC());
                    return FALSE;
                end;
                _BundleTileBindings[[binding]].destination = resolved[[binding]];
                _BundleTileBindings[[binding]].destination_allocated_by_bundle = TRUE;
                if _BundleTileBindings[[binding]].destination_assemble.valid &&
                   _BundleTileBindings[[binding]].destination_assemble.init then
                    PublishRelativeTileDestination(resolved[[binding]]);
                end;
            end;
            destination_ordinal = destination_ordinal + 1;
        end;
    end;
    return TRUE;
end;
func ResolveBundleTileDestinationsWithShape(
    explicit_shape: boolean,
    explicit_valid_rows: integer {0..65535},
    explicit_valid_columns: integer {0..65535},
    explicit_columns: integer {0..65535}) => boolean
begin
    return ResolveBundleTileDestinationsWithShapeAndType(
        explicit_shape,
        explicit_valid_rows,
        explicit_valid_columns,
        explicit_columns,
        FALSE,
        TileDataType_FP64);
end;
func ResolveBundleTileDestinations() => boolean
begin
    return ResolveBundleTileDestinationsWithShape(FALSE, 0, 0, 0);
end;
```
<!-- GENERATED-ASL-END: unit -->
