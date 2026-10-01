<!-- GENERATED FROM: asl/block/model/dispatch/tile-schema.asl -->
# Tile Schema

**Normative ASL source:** `asl/block/model/dispatch/tile-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tile-schema-purpose role=purpose-scope -->
## 用途与范围

本单元包含 Tile 操作共用的指令束检查，以及三组操作的封闭 schema。封闭 schema 是指令束为某个操作必须携带的确切绑定、维度和类型集合。

它定义：

- `SelectedBundleTileDataAttributesLegal`，对照所选操作检查 `B.DATR` 数据属性，失败时自行引发 `Fault_TileLegality`。
- `SelectedBundleTileMasksLegal` 与 `SelectedBundleTileMaskIsZero`，检查 Tile 绑定的 PE 掩码。
- 二元操作 `TADD`、`TSUB`、`TMUL`、`TDIV`、`TREM`、`TMAX`、`TMIN` 与 `TEXPDIF`，一元操作 `TABS`、`TNOT`、`TNEG`、`TRELU` 以及 `TFMA` 的封闭 schema。
- `BundleTileBindingCount` 与 `BundleTileBindingStreamTerminated` 等计数辅助函数。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-schema-concepts role=concepts-state -->
## 概念与可见状态

- PE 掩码是绑定写入的处理单元的 4 位集合。掩码 `0000` 表示零参与。
- `B.DATR` 是可选的数据属性命令。其字段包括比较模式、填充值、饱和、规范化、数据类型、舍入模式和数据布局。
- 显式字段值是来自存在的 `B.DATR` 的值。`B.DATR` 缺省时，用于适用性判断的显式值为零或假。

这些函数读取绑定状态、维度、数据属性、执行掩码和定点属性。只有 `SelectedBundleTileDataAttributesLegal` 写入状态，且只写入故障记录。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-schema-rules role=rules-interactions -->
## 规则与交互

`SelectedBundleTileDataAttributesLegal` 以 `Fault_TileLegality` 拒绝：

- 执行掩码与任何 Shared 绑定同时出现；
- 指令束不是权重 `TLOAD` 时出现显式的权重加载数据布局；
- 操作不接受的任何字段（来自 `TileOperationDATRFieldsLegal`），或矩阵操作中 `BundleFPATRDATRFieldsLegal` 的任何失败；
- 对 `CUBE` `TCI`，缺少 `B.DATR`、数据类型不是 `DTYPE_NONE`、填充、比较或舍入字段非零，或设置了饱和或规范化；对非 CUBE `TCI`，显式布局或数据类型；
- 对 `TGPR2T`，位 2 置位的舍入字段；
- 填充联合为必须为零的操作出现非零填充值；
- `TLOAD` 或 `TSTORE` 的非零显式填充，除非布局是 CUBE 转换布局。

设计要点：ASL 注释指出，继承值或默认值是操作输入，而不是显式编码的非零字段。因此只有 `B.DATR` 存在时，适用性检查才查看字段值。拒绝非零填充的操作不会因为一个它从未编码的默认值而被拒绝。

`SelectedBundleTileMasksLegal` 要求每个有效 Tile 绑定携带相同的 PE 掩码。当每个有效绑定的掩码都是 `0000`，或者没有绑定但出现过零参与绑定器时，`SelectedBundleTileMaskIsZero` 为真。

二元 schema 要求一个带目标、`source0` 和 `source1` 并标记为最后的绑定。若执行掩码是谓词 Tile，则改为要求两个绑定：第一个携带两个源且不是最后，第二个携带目标并以 `source0` 携带掩码，掩码为源序号 2。一元 schema 要求一个带目标和 `source0` 的绑定，掩码存在时以 `source1` 携带。`TFMA` 要求两个绑定：先是乘数，再是目标与加数。三者都要求维度位于 `1..65535`、数据类型受支持以及逐元素布局受支持。`TEXPDIF` 还需要显式的维度 0。

设计要点：每个 schema 都要求目标绑定尚未处于 `destination_allocated_by_bundle` 状态。Tile 执行所有者在 `ResolveBundleTileDestinationsForOperation` 之前运行封闭 schema，因此形状在分配任何目标 Tile 之前就已得到证明，失败的 schema 不会留下需要回滚的分配。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-schema-boundaries role=boundaries -->
## 架构边界

除数据属性检查外，这些函数返回布尔值，由调用者选择故障。比较、归约、TCVT、Tile-标量等其他封闭 schema 位于各自的单元中。逐元素的值检查与算术属于 Tile 模型。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-schema-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

某 `TADD` 指令束的数据类型为 FP16，有一个带目标、左源和右源并标记为最后的 `B.IOT`，掩码为 `1111`。维度为 64、16 和 64。没有 `B.DATR`。数据属性检查看到所有显式字段为零而通过。二元 schema 看到一个绑定、合法维度以及 RowMajor 布局下的 FP16，因而通过。如果指令束增加了谓词 Tile 执行掩码却仍只有一个绑定，schema 会失败，因为此时需要两个绑定。

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-schema-related role=related-owners-navigation -->
## 相关所有者

- [Tile execution](tile-execution.md) 按提交顺序调用这些检查。
- [Tile-scalar schema](tile-scalar-schema.md) 包含 Tile-标量封闭 schema。
- [Command data attributes](command-data-attributes.md) 定义 `B.DATR` 的记录方式。
- [Execution-mask schema](execution-mask-schema.md) 定义掩码载体。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tile-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA","surface":"block","classification":["model","dispatch","tile-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-BINARY-OP-CLASSIFICATION","PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES","PTO-BLOCK-MODEL-DISPATCH-EXPDIF-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-BLOCK-MODEL-DISPATCH-TILE-INSTRUCTION-OPERANDS","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-EXECUTION-UNARY","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-EXPDIF-OPERANDS","PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"],"surface":"block"}
func SelectedBundleTileDataAttributesLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if _BundleExecutionMask.valid && BundleSharedBindingCount() != 0 then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    // Inherited/default values are operation inputs, not explicitly encoded
    // nonzero B.DATR fields.  Applicability therefore examines field values
    // only when the optional command was present.
    let explicit_c_mode = if _BundleDataAttributesPresent then
        _BundleDataAttributes.comparison_mode else Zeros{3};
    let explicit_pad = if _BundleDataAttributesPresent then
        _BundleDataAttributes.pad_value else Zeros{2};
    let explicit_saturating = _BundleDataAttributesPresent &&
        _BundleDataAttributes.saturating;
    let explicit_canonicalize = _BundleDataAttributesPresent &&
        _BundleDataAttributes.canonicalize;
    let explicit_data_type = BundleDATRDataTypeApplicabilityCode();
    let explicit_rounding = if _BundleDataAttributesPresent then
        _BundleDataAttributes.rounding_mode else Zeros{3};
    let explicit_layout = if _BundleDataAttributesPresent then
        _BundleDataAttributes.data_layout else Zeros{5};
    if _BundleDataAttributesPresent &&
       TileDataLayoutIsWeightTLOAD(TileDataLayoutOfCode(explicit_layout)) &&
       !BundleWeightTLOADSelected() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleExecutionMaskDataAttributesLegal(operation) ||
       !TileOperationDATRFieldsLegal(operation, explicit_c_mode,
           explicit_pad, explicit_saturating, explicit_canonicalize,
           explicit_data_type, explicit_rounding, explicit_layout) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let matrix = _BundleOperation.valid &&
        _BundleOperation.operation_class == BundleOperation_TileMatrix;
    let datr_legal = if matrix then
        _BundleFixedPointAttributes.valid &&
        BundleFPATRDATRFieldsLegal(
            _BundleFixedPointAttributes.pre_quant_mode,
            _BundleDataAttributes.rounding_mode,
            _BundleDataAttributes.saturating)
    else
        TileOperationDATRFieldsLegal(
            operation,
            explicit_c_mode,
            explicit_pad,
            explicit_saturating,
            explicit_canonicalize,
            explicit_data_type,
            explicit_rounding,
            explicit_layout);
    if !datr_legal then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let decoded_operation = TileOperationOfIndex(operation);
    let cube_tci = decoded_operation == TileOperation_TCI && (CurrentBundleTileLayout() == TileLayout_CUBE_M16 || CurrentBundleTileLayout() == TileLayout_CUBE_M32);
    if cube_tci && (!_BundleDataAttributesPresent || _BundleDataAttributes.data_type != DTYPE_NONE || _BundleDataAttributes.pad_value != Zeros{2} || _BundleDataAttributes.comparison_mode != Zeros{3} || _BundleDataAttributes.rounding_mode != Zeros{3} || _BundleDataAttributes.saturating || _BundleDataAttributes.canonicalize) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    elsif decoded_operation == TileOperation_TCI && !cube_tci && (explicit_layout != Zeros{5} || explicit_data_type != Zeros{5}) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if decoded_operation == TileOperation_TGPR2T &&
       !TileTGPR2TRModeLegal(_BundleDataAttributes.rounding_mode) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if _BundleDataAttributesPresent &&
       _BundleDataAttributes.pad_value != Zeros{2} &&
       TileOperationDATRPadUnion(operation) ==
           TileDATRPadUnion_MustZero then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    // Ordinary and Shared TLOAD/TSTORE require PadValue zero; only their Local
    // CUBE conversion forms, specialized before this check, carry a nonzero
    // PadValue.
    if explicit_pad != Zeros{2} &&
       (TileOperationOfIndex(operation) == TileOperation_TLOAD ||
        TileOperationOfIndex(operation) == TileOperation_TSTORE) &&
       !TileDataLayoutIsCubeConversion(explicit_layout) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    return TRUE;
end;
readonly func SelectedBundleTileMasksLegal() => boolean
begin
    var first_mask = Zeros{4};
    var first_mask_seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            let mask = _BundleTileBindings[[binding]].pe_mask;
            if first_mask_seen && mask != first_mask then return FALSE; end;
            first_mask = mask;
            first_mask_seen = TRUE;
        end;
    end;
    return TRUE;
end;
readonly func SelectedBundleTileMaskIsZero() => boolean
begin
    var seen = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            seen = TRUE;
            if _BundleTileBindings[[binding]].pe_mask != Zeros{4} then
                return FALSE;
            end;
        end;
    end;
    return seen || (_BundleZeroParticipationSeen &&
        BundleTileBindingCount() == 0 && BundleSharedBindingCount() == 0);
end;
readonly func BundleTileBindingCount() => integer {0..16}
begin
    var count: integer {0..16} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            count = (count + 1) as integer {0..16};
        end;
    end;
    return count;
end;
readonly func SelectedBundleClosedBinarySchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedBinarySchema(operation) then return TRUE; end;
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if BundleTileBindingCount() != (if execution_mask_tile then 2 else 1) ||
       BundleSharedBindingCount() != 0 then
        return FALSE;
    end;
    if execution_mask_tile then
        if _BundleExecutionMask.predicate_source_ordinal != 2 ||
           _BundleTileBindings[[0]].destination_valid ||
           !_BundleTileBindings[[0]].source0_valid ||
           !_BundleTileBindings[[0]].source1_valid ||
           _BundleTileBindings[[0]].last ||
           !_BundleTileBindings[[1]].destination_valid ||
           _BundleTileBindings[[1]].destination_allocated_by_bundle ||
           !BundleTileDestinationSizeLegal(1) ||
           !_BundleTileBindings[[1]].source0_valid ||
           _BundleTileBindings[[1]].source1_valid ||
           !_BundleTileBindings[[1]].last then
            return FALSE;
        end;
    else
        if !_BundleTileBindings[[0]].destination_valid ||
           _BundleTileBindings[[0]].destination_allocated_by_bundle ||
           !BundleTileDestinationSizeLegal(0) ||
           !_BundleTileBindings[[0]].source0_valid ||
           !_BundleTileBindings[[0]].source1_valid ||
           !_BundleTileBindings[[0]].last then
            return FALSE;
        end;
    end;
    if TileOperationOfIndex(operation) == TileOperation_TEXPDIF &&
       !_BundleDimensionPresent[[0]] then
        return FALSE;
    end;
    if UInt(_BundleDimensions[[0]]) < 1 ||
       UInt(_BundleDimensions[[0]]) > 65535 then return FALSE; end;
    for dimension = 1 to 2 looplimit 2 do
        if UInt(_BundleDimensions[[dimension]]) < 1 ||
           UInt(_BundleDimensions[[dimension]]) > 65535 then
            return FALSE;
        end;
    end;
    if TileOperationOfIndex(operation) == TileOperation_TEXPDIF then
        let (types_legal, -, -) =
            SelectedBundleExponentialDifferenceTypes();
        return types_legal &&
               TileElementwiseLayoutSupported(CurrentBundleTileLayout()) &&
               TileExpdifSourcesLegal(
                   _BundleTileBindings[[0]].source0,
                   _BundleTileBindings[[0]].source1);
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    return TileVecArithmeticDataTypeSupported(data_type) &&
           TileElementwiseLayoutSupported(CurrentBundleTileLayout());
end;
pure func TileOperationUsesClosedUnarySchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TABS ||
           decoded == TileOperation_TNOT ||
           decoded == TileOperation_TNEG ||
           decoded == TileOperation_TRELU;
end;
readonly func SelectedBundleClosedUnarySchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedUnarySchema(operation) then return TRUE; end;
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    if BundleTileBindingCount() != 1 || BundleSharedBindingCount() != 0 then
        return FALSE;
    end;
    let binding = _BundleTileBindings[[0]];
    if !binding.destination_valid || binding.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(0) ||
       !binding.source0_valid ||
       (binding.source1_valid != execution_mask_tile) || !binding.last ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal != 1) then
        return FALSE;
    end;
    if UInt(_BundleDimensions[[0]]) < 1 ||
       UInt(_BundleDimensions[[0]]) > 65535 then
        return FALSE;
    end;
    for dimension = 1 to 2 looplimit 2 do
        if UInt(_BundleDimensions[[dimension]]) < 1 ||
           UInt(_BundleDimensions[[dimension]]) > 65535 then
            return FALSE;
        end;
    end;
    let decoded = TileOperationOfIndex(operation);
    let unary = if decoded == TileOperation_TABS then TileUnary_ABS
                else if decoded == TileOperation_TNOT then TileUnary_NOT
                else if decoded == TileOperation_TNEG then TileUnary_NEG
                else TileUnary_RELU;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    return TileUnaryDataTypeSupported(unary, data_type) &&
           TileElementwiseLayoutSupported(CurrentBundleTileLayout());
end;
pure func TileOperationUsesClosedTFMASchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileOperationOfIndex(operation) == TileOperation_TFMA;
end;
readonly func SelectedBundleClosedTFMASchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationUsesClosedTFMASchema(operation) then return TRUE; end;
    let execution_mask_tile = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile;
    let execution_mask_gpr = _BundleExecutionMask.valid &&
        _BundleExecutionMask.carrier == BundleExecutionMask_GPR &&
        BundleExecutionMaskGPRBindingSchemaLegal(operation);
    if BundleTileBindingCount() != 2 ||
       BundleSharedBindingCount() != 0 ||
       (_BundleScalarBindings[[0]].valid && !execution_mask_gpr) ||
       _BundleScalarBindings[[1]].valid then
        return FALSE;
    end;
    let multiplicands = _BundleTileBindings[[0]];
    let result = _BundleTileBindings[[1]];
    if multiplicands.destination_valid ||
       !multiplicands.source0_valid ||
       !multiplicands.source1_valid ||
       multiplicands.last then
        return FALSE;
    end;
    if !result.destination_valid ||
       result.destination_allocated_by_bundle ||
       !BundleTileDestinationSizeLegal(1) ||
       !result.source0_valid ||
       (result.source1_valid != execution_mask_tile) ||
       (execution_mask_tile &&
        _BundleExecutionMask.predicate_source_ordinal != 3) ||
       !result.last then
        return FALSE;
    end;
    if UInt(_BundleDimensions[[0]]) < 1 ||
       UInt(_BundleDimensions[[0]]) > 65535 then
        return FALSE;
    end;
    for dimension = 1 to 2 looplimit 2 do
        if UInt(_BundleDimensions[[dimension]]) < 1 ||
           UInt(_BundleDimensions[[dimension]]) > 65535 then
            return FALSE;
        end;
    end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    return TileFusedMultiplyAddDataTypeSupported(data_type) &&
           TileElementwiseLayoutSupported(CurrentBundleTileLayout());
end;
readonly func BundleLocalTileSourceCount() => integer {0..32}
begin
    var count: integer {0..32} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                count = (count + 1) as integer {0..32};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                count = (count + 1) as integer {0..32};
            end;
        end;
    end;
    return count;
end;

readonly func BundleLocalTileEncodedSourceCount() => integer {0..32}
begin
    return (BundleLocalTileSourceCount() +
        BundleLocalTileParentRefCount()) as integer {0..32};
end;
readonly func BundleLocalTileDestinationCount() => integer {0..16}
begin
    var count: integer {0..16} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            count = (count + 1) as integer {0..16};
        end;
    end;
    return count;
end;
readonly func BundleTileBindingStreamTerminated() => boolean
begin
    var binding_count: integer {0..16} = 0;
    var seen_last = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if seen_last then return FALSE; end;
            binding_count = (binding_count + 1) as integer {0..16};
            if _BundleTileBindings[[binding]].last then
                seen_last = TRUE;
            end;
        end;
    end;
    return binding_count > 0 && seen_last;
end;
```
<!-- GENERATED-ASL-END: unit -->
