<!-- GENERATED FROM: asl/tile/model/legality/dtype-layout.asl -->
# Data Type Layout

**Normative ASL source:** `asl/tile/model/legality/dtype-layout.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-dtype-layout-purpose role=purpose-scope -->
## 用途与范围

本单元保存 Tile 合法性谓词所查询的纯类型表与布局表。它回答两个问题：某个操作族接受哪些 `TileDataType` 值，以及以一种类型存储的 Tile 何时可以按另一种类型读取。

它还定义了两个操作类型解析器 `ResolveTileCarrierOperationType` 与 `ResolveTileSelectedOperationType`，以及描述符匹配辅助函数 `TileLogicalShapeMatch`。

本单元不写任何状态。每个函数都是 `pure` 或 `readonly`，因此每个结果只取决于其参数以及当前描述符与指令束状态。

<!-- PTO-READER-BLOCK: tile-model-legality-dtype-layout-concepts role=concepts-state -->
## 概念与可见状态

后备类型是 Tile 描述符中存储的 `data_type`。操作类型是指令解释元素时使用的类型；对于指令束操作，它通常来自 `BSTART` 的 DataType。

打包类型在每个字节中存储两个四位元素。`TileDataTypeIsFourBit` 列出了它们：E2M1X2、E1M2X2、HiF4X2、S4X2 与 U4X2。

主要的类型集合如下：

- `TileVecArithmeticDataTypeSupported`：FP64、FP32、TF32、HF32、FP16、BF16、E4M3、E5M2，以及有符号和无符号的 8、16、32、64 位整数。
- `TileVecScalarIntegerDataTypeSupported`：从 S8 到 U64 的八种有符号与无符号整数类型。
- `TileFloatingElementwiseDataTypeSupported`：FP64、FP32、TF32、HF32、FP16、BF16、E4M3、E5M2。
- `TileCarrierOnlyDataTypeSupported`：不超过 4 字节的非打包类型，因此排除 64 位类型。
- `TileExpdifTypePairLegal`：FP16 到 FP16 或 FP32，BF16 到 BF16 或 FP32，以及 FP32 到 FP32。

`TileElementwiseLayoutSupported` 接受 RowMajor、CUBE_M16 与 CUBE_M32。

<!-- PTO-READER-BLOCK: tile-model-legality-dtype-layout-rules role=rules-interactions -->
## 规则与交互

当两个类型相同时，`TileCarrierWidthCompatible(stored, operation)` 为 TRUE。否则，RCPE6M2 只能建立在 E6M2 后备之上。对其他任何类型对，两者都必须是非打包类型，且 `TileElementBits` 相同。

设计要点：同位宽、非打包的后备以操作类型的位宽为每个元素保存一个位字段。模型读取该原始字段并按操作类型解释，不经过任何转换步骤。打包后备每个字节保存两个元素，因此被排除在该关系之外。

`ResolveTileCarrierOperationType` 在能够解析出有效的指令束 DataType 时返回它。当没有指令束操作且没有 `B.DATR` DataType 时，它回退到源后备类型。其他情况下返回 FALSE。

设计要点：载体重解释 NDF 条款要求，没有可解析操作类型的活动指令束必须拒绝，而不能用源后备类型替代。FALSE 结果正是 `TileOperandsLegal_TMOV` 以及 TCMP、TSEL 谓词等调用者拒绝的方式。

`TileBinaryDataTypeSupported` 对 EXPDIF 返回 FALSE，对 AND、OR、XOR、SHL 与 SHR 使用整数集合，对其他二元操作使用算术集合。EXPDIF 从不经过通用二元或 Tile-标量谓词：`TEXPDIF` 以及 EXPDIF 扩展形式（TROWEXPANDEXPDIF、TCOLEXPANDEXPDIF）使用 `TileExpdifTypePairLegal` 检查其类型对。

设计要点：CUBE_N8 不是逐元素布局。源码注释说明它仍是矩阵与转移布局，因此调用 `TileElementwiseLayoutSupported` 的逐元素谓词会拒绝它。

<!-- PTO-READER-BLOCK: tile-model-legality-dtype-layout-boundaries role=boundaries -->
## 架构边界

这些表说明合法性接受什么，并不承诺每个被接受的类型都有数值结果。例如，`TileVecArithmeticDataTypeSupported` 为 TADD 接受 TF32、HF32、E4M3 与 E5M2，但浮点 ADD 路径调用 `ScalarFPBinaryProfile`，它对 FP64、FP32、FP16 与 BF16 以外的类型断言失败。浮点 TREM 调用 `ReferenceTileFloatingModulo`，SFU 一元操作调用 `ReferenceTileUnaryFinite`；两者都只接受 FP32、FP16 与 BF16。

若干辅助函数目前在 `asl/` 中没有调用者：`TileF3DataTypeSupported`、`TileImg2ColDataTypeSupported`、`TileCarrierOrMove24BaselineDataTypeSupported`（以及经由它的 `TileMove24DataTypeSupported`）和 `TileShapeAndTypeMatch`。

`TileOperationUsesSourceBackingDestination` 只对 TMOV 为 TRUE。指令束分派中的目标解析使用它，使 TMOV 目标采用源的后备类型。

<!-- PTO-READER-BLOCK: tile-model-legality-dtype-layout-example role=example-usage -->
## 非规范阅读示例

一个 TADD 指令束选择操作类型 FP16。左源以 U16 存储，右源以 FP16 存储。

- 左源：U16 与 FP16 都是 16 位且都不是打包类型，因此 `TileCarrierWidthCompatible(U16, FP16)` 为 TRUE。U16 的位按 FP16 值读取。
- 右源：类型相同，因此该关系为 TRUE。
- 若左源以 FP32 存储，32 不等于 16，该类型对被拒绝。
- 若它以 U4X2 存储，即使作为原始载体，打包类型也被拒绝。

RCPE6M2 操作类型接受 E6M2 后备，但拒绝 U8 后备，尽管两者都是 8 位宽。

<!-- PTO-READER-BLOCK: tile-model-legality-dtype-layout-related role=related-owners-navigation -->
## 相关所有者

- [操作数 schema](operand-schema.md) 把这些表组合成完整的操作数谓词。
- [描述符形状](descriptor-shape.md) 定义 `TileLogicalShapeMatch` 所用的 `TileDescriptorLegal`。
- [逐元素执行](../execution/elementwise.md) 展示合法性通过后运行的数值辅助函数。
- [Tile 描述符](../state/descriptors.md) 定义 `TileElementBits` 与 `TileDataTypeIsFourBit`。
- [描述符合法性](../../../block/model/dispatch/descriptor-legality.md) 定义 `ResolveBundleEffectiveDataType`。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/dtype-layout.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","surface":"tile","classification":["model","legality","dtype-layout"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE"]}
pure func TileTeplRawCarrierTypeSupported(data_type: TileDataType) => boolean
begin
    // PTO-v0 TEPL operates over the raw XLEN carrier for every architectural
    // tile type. Target numeric interpretation, rounding, saturation, and
    // exceptional values remain Stage 5 profile obligations.
    case data_type of
        when TileDataType_FP64, TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32, TileDataType_FP16, TileDataType_BF16,
             TileDataType_HiF8, TileDataType_E4M3, TileDataType_E5M2,
             TileDataType_E3M2, TileDataType_E2M3,
             TileDataType_E2M1X2, TileDataType_E1M2X2,
             TileDataType_E8M0, TileDataType_HiF4X2,
             TileDataType_S64, TileDataType_S32, TileDataType_S16,
             TileDataType_S8, TileDataType_S4X2,
             TileDataType_U64, TileDataType_U32, TileDataType_U16,
             TileDataType_U8, TileDataType_U4X2 => return TRUE;
        otherwise => return FALSE;
    end;
end;

// Operation types describe the interpretation and execution carrier for the
// selected operation.  A stored Tile descriptor may use a different dtype only
// when the physical element width is unchanged.
// NDF-BEGIN: PTO-TILE-CARRIER-REINTERPRETATION-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Cross-type source interpretation is scoped to the instruction families that
// explicitly select an operation DataType. It MUST require equal element width
// and MUST exclude packed types; exact backing/operation type identity remains
// legal. Comparison/select retain their existing operation-view rules, and
// TCVT retains its existing CUBE_M16/M32 operation-view rules.
// TROWEXPAND*/TCOLEXPAND* additionally interpret each source's unchanged raw
// backing carrier as the selected source operation DataType when widths match.
// Arithmetic/EXPDIF validate under that operation type; COPY uses raw bits.
// Expansion sources are not retagged and no numeric conversion occurs.
// The twelve TROW and TCOL reduction instructions also interpret each
// persistent numeric source backing through the selected BSTART operation
// DataType when the unchanged TileCarrierWidthCompatible relation admits it.
// Every valid source coordinate is defined and encoding-valid under the
// operation type, and every coordinate participates in the full reduction.
// Local CUBE ExecutionMask is unsupported for reductions; an encoded carrier
// or model-injected mask state rejects before effects. Reduction identities,
// numeric steps, comparisons, and status use the operation type. RCPE6M2 is
// forbidden as a reduction backing, and sources are not retagged or converted.
// An active bundle with no resolvable BSTART operation type MUST reject rather
// than substituting the source backing type. Direct semantic wrappers use
// deterministic operation-specific fallbacks: TCMP left backing, TCMPS source
// backing, TSEL/TSELS destination backing, and reductions' source backing only
// when no Local CUBE ExecutionMask state is valid.
// NDF-END: PTO-TILE-CARRIER-REINTERPRETATION-001
pure func TileCarrierWidthCompatible(
    stored_type: TileDataType, operation_type: TileDataType) => boolean
begin
    if stored_type == operation_type then return TRUE; end;
    // RCPE6M2 is a source-only derived interpretation. It may consume the
    // same raw eight-bit carrier as E6M2, but ordinary same-width carriers do
    // not acquire the reciprocal interpretation.
    if operation_type == TileDataType_RCPE6M2 then
        return stored_type == TileDataType_E6M2;
    end;
    return !TileDataTypeIsFourBit(stored_type) &&
           !TileDataTypeIsFourBit(operation_type) &&
           TileElementBits(stored_type) == TileElementBits(operation_type);
end;

readonly func ResolveTileCarrierOperationType(
    source_backing_type: TileDataType) => (boolean, TileDataType)
begin
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    if operation_type_valid then return (TRUE, operation_type); end;
    if !_BundleOperation.valid &&
       !_BundleDataAttributes.data_type_present then
        return (TRUE, source_backing_type);
    end;
    return (FALSE, source_backing_type);
end;

readonly func ResolveTileSelectedOperationType(
    direct_fallback_type: TileDataType) => (boolean, TileDataType)
begin
    if BundleTileOperationSelected() &&
       _BundleOperation.data_type_valid &&
       BundleDataTypeConcrete(_BundleOperation.data_type) then
        return (TRUE, TileDataTypeFromEncoding(
            _BundleOperation.data_type as TileDataTypeEncoding));
    end;
    if !BundleIsActive() && !_BundleOperation.valid then
        return (TRUE, direct_fallback_type);
    end;
    return (FALSE, direct_fallback_type);
end;

pure func TileOperationUsesSourceBackingDestination(
    operation: TileOperation) => boolean
begin
    return operation == TileOperation_TMOV;
end;

// Stage 4 carrier-only operations use the concrete dtype's physical byte
// width.  Packed X2 formats have a one-byte storage class but retain their
// baseline nibble semantics and are deliberately excluded here.
pure func TileCarrierOnlyDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return !TileDataTypeIsFourBit(data_type) &&
           TileElementBytes(data_type) <= 4;
end;

// These operations already have a packed-X2 baseline.  Preserve that
// baseline while admitting only the new non-packed B8/B16/B32 carrier set;
// B64 remains outside the Stage 4 extension.
pure func TileCarrierOrPackedBaselineDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileCarrierOnlyDataTypeSupported(data_type) ||
           TileDataTypeIsFourBit(data_type);
end;

// Move24 operations accept every assigned Tile DataType except HiF4X2.
// Keep that exact architectural exclusion independent of the narrower
// Stage-4 carrier helper used by other raw-carrier operations.
pure func TileCarrierOrMove24BaselineDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileMove24DataTypeSupported(data_type);
end;

pure func TileRegularTLSUDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileTeplRawCarrierTypeSupported(data_type);
end;

pure func TileVecArithmeticDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_FP64, TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32, TileDataType_FP16, TileDataType_BF16,
             TileDataType_E4M3, TileDataType_E5M2,
             TileDataType_S64, TileDataType_S32, TileDataType_S16,
             TileDataType_S8, TileDataType_U64, TileDataType_U32,
             TileDataType_U16, TileDataType_U8 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func TileA9DataTypeSupported(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_S32, TileDataType_U32,
             TileDataType_FP32, TileDataType_S16,
             TileDataType_U16, TileDataType_FP16,
             TileDataType_BF16, TileDataType_S8,
             TileDataType_U8 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func TileA7DataTypeSupported(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_S32, TileDataType_U32,
             TileDataType_FP32, TileDataType_S16,
             TileDataType_U16, TileDataType_FP16,
             TileDataType_BF16 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func TileF3DataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP16 ||
           data_type == TileDataType_FP32 ||
           data_type == TileDataType_BF16;
end;

pure func TileFloatingElementwiseDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP64 ||
           data_type == TileDataType_FP32 ||
           data_type == TileDataType_TF32 ||
           data_type == TileDataType_HF32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_BF16 ||
           data_type == TileDataType_E4M3 ||
           data_type == TileDataType_E5M2;
end;

pure func TileI6DataTypeSupported(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_S32, TileDataType_U32,
             TileDataType_S16, TileDataType_U16,
             TileDataType_S8, TileDataType_U8 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func TileTNegDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

pure func TileTReluDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

pure func TileArgReductionSourceDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileA9DataTypeSupported(data_type);
end;

pure func TileFusedMultiplyAddDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

pure func TileMove24DataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return data_type != TileDataType_HiF4X2;
end;

pure func TileFillPadDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    return TileVecArithmeticDataTypeSupported(data_type);
end;

pure func TileImg2ColDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_FP32, TileDataType_FP16,
             TileDataType_BF16, TileDataType_S32,
             TileDataType_S16, TileDataType_S8,
             TileDataType_U32, TileDataType_U16,
             TileDataType_U8 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func TileBinaryUsesClosedElementwiseContract(
    operation: TileBinaryOperation) => boolean
begin
    return operation == TileBinary_ADD ||
           operation == TileBinary_SUB ||
           operation == TileBinary_MUL ||
           operation == TileBinary_DIV ||
           operation == TileBinary_REM ||
           operation == TileBinary_MAX ||
           operation == TileBinary_MIN ||
           operation == TileBinary_AND ||
           operation == TileBinary_OR ||
           operation == TileBinary_XOR ||
           operation == TileBinary_SHL ||
           operation == TileBinary_SHR;
end;

pure func TileExpdifTypePairLegal(
    source_operation_type: TileDataType,
    destination_type: TileDataType) => boolean
begin
    return (source_operation_type == TileDataType_FP16 &&
            (destination_type == TileDataType_FP16 ||
             destination_type == TileDataType_FP32)) ||
           (source_operation_type == TileDataType_BF16 &&
            (destination_type == TileDataType_BF16 ||
             destination_type == TileDataType_FP32)) ||
           (source_operation_type == TileDataType_FP32 &&
            destination_type == TileDataType_FP32);
end;

// The closed elementwise family is also defined for Local CUBE M16/M32.
// CUBE_N8 remains a matrix/transport layout and is not an elementwise class.
pure func TileElementwiseLayoutSupported(layout: TileLayout) => boolean
begin
    return layout == TileLayout_RowMajor ||
           layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32;
end;

pure func TileVecScalarIntegerDataTypeSupported(
    data_type: TileDataType) => boolean
begin
    case data_type of
        when TileDataType_S64, TileDataType_S32, TileDataType_S16,
             TileDataType_S8, TileDataType_U64, TileDataType_U32,
             TileDataType_U16, TileDataType_U8 => return TRUE;
        otherwise => return FALSE;
    end;
end;

pure func TileBinaryDataTypeSupported(
    operation: TileBinaryOperation,
    data_type: TileDataType) => boolean
begin
    // EXPDIF belongs only to ExecuteTileExpdif and never to generic binary or
    // Tile-scalar execution.
    if operation == TileBinary_EXPDIF then return FALSE; end;
    if operation == TileBinary_AND ||
       operation == TileBinary_OR ||
       operation == TileBinary_XOR then
        return TileVecScalarIntegerDataTypeSupported(data_type);
    end;
    if operation == TileBinary_SHL || operation == TileBinary_SHR then
        return TileVecScalarIntegerDataTypeSupported(data_type);
    end;
    return TileVecArithmeticDataTypeSupported(data_type);
end;

readonly func TileLogicalShapeMatch(left: TileIndex, right: TileIndex) => boolean
begin
    return TileDescriptorLegal(left) && TileDescriptorLegal(right) &&
           _Tiles[[left]].rows == _Tiles[[right]].rows &&
           _Tiles[[left]].columns == _Tiles[[right]].columns &&
           _Tiles[[left]].valid_rows == _Tiles[[right]].valid_rows &&
           _Tiles[[left]].valid_columns == _Tiles[[right]].valid_columns &&
           _Tiles[[left]].layout == _Tiles[[right]].layout;
end;

readonly func TileShapeAndTypeMatch(left: TileIndex, right: TileIndex) => boolean
begin
    return TileLogicalShapeMatch(left, right) &&
           _Tiles[[left]].storage_kind == _Tiles[[right]].storage_kind &&
           _Tiles[[left]].data_type == _Tiles[[right]].data_type;
end;
```
<!-- GENERATED-ASL-END: unit -->
