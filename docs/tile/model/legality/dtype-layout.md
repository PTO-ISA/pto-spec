<!-- GENERATED FROM: asl/tile/model/legality/dtype-layout.asl -->
# Data Type Layout

**Normative ASL source:** `asl/tile/model/legality/dtype-layout.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-dtype-layout-purpose role=purpose-scope -->
## Purpose and scope

This unit holds the pure type and layout tables that Tile legality predicates consult. It answers two questions: which `TileDataType` values an operation family accepts, and when a Tile stored with one type may be read as another type.

It also defines two operation-type resolvers, `ResolveTileCarrierOperationType` and `ResolveTileSelectedOperationType`, and the descriptor match helper `TileLogicalShapeMatch`.

Nothing in this unit writes state. Every function is `pure` or `readonly`, so each answer depends only on its arguments and the current descriptors and bundle state.

<!-- PTO-READER-BLOCK: tile-model-legality-dtype-layout-concepts role=concepts-state -->
## Concepts and visible state

A backing type is the `data_type` stored in a Tile descriptor. An operation type is the type the instruction uses to interpret elements; for bundled operations it normally comes from the `BSTART` DataType.

A packed type stores two four-bit elements per byte. `TileDataTypeIsFourBit` names them: E2M1X2, E1M2X2, HiF4X2, S4X2, and U4X2.

The main type sets are:

- `TileVecArithmeticDataTypeSupported`: FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2, and the signed and unsigned 8, 16, 32, and 64-bit integers.
- `TileVecScalarIntegerDataTypeSupported`: the eight signed and unsigned integer types S8 to U64.
- `TileFloatingElementwiseDataTypeSupported`: FP64, FP32, TF32, HF32, FP16, BF16, E4M3, E5M2.
- `TileCarrierOnlyDataTypeSupported`: non-packed types of at most 4 bytes, so 64-bit types are excluded.
- `TileExpdifTypePairLegal`: FP16 to FP16 or FP32, BF16 to BF16 or FP32, and FP32 to FP32.

`TileElementwiseLayoutSupported` accepts RowMajor, CUBE_M16, and CUBE_M32.

<!-- PTO-READER-BLOCK: tile-model-legality-dtype-layout-rules role=rules-interactions -->
## Rules and interactions

`TileCarrierWidthCompatible(stored, operation)` is TRUE when the two types are identical. Otherwise, RCPE6M2 is accepted only over an E6M2 backing. For any other pair, both types must be non-packed and have the same `TileElementBits`.

Design point: a same-width, non-packed backing holds each element in a bit field of the operation type's width. The model reads that raw field and interprets it under the operation type, with no conversion step. A packed backing holds two elements per byte, so it is excluded from this relation.

`ResolveTileCarrierOperationType` returns the effective bundle DataType when one resolves. With no bundle operation and no `B.DATR` DataType, it falls back to the source backing type. In any other case it returns FALSE.

Design point: the carrier-reinterpretation NDF clause requires an active bundle with no resolvable operation type to reject rather than substitute the source backing type. The FALSE result is how callers such as `TileOperandsLegal_TMOV` and the TCMP and TSEL predicates reject.

`TileBinaryDataTypeSupported` returns FALSE for EXPDIF, uses the integer set for AND, OR, XOR, SHL, and SHR, and uses the arithmetic set for the other binary operations. EXPDIF never goes through the generic binary or Tile-scalar predicates: `TEXPDIF` and the EXPDIF expansion forms (TROWEXPANDEXPDIF, TCOLEXPANDEXPDIF) check their type pairs with `TileExpdifTypePairLegal`.

Design point: CUBE_N8 is not an elementwise layout. The source comment states it remains a matrix and transport layout, so elementwise predicates that call `TileElementwiseLayoutSupported` reject it.

<!-- PTO-READER-BLOCK: tile-model-legality-dtype-layout-boundaries role=boundaries -->
## Architectural boundaries

These tables say what legality admits. They do not promise that every admitted type has a numeric result. For example, `TileVecArithmeticDataTypeSupported` admits TF32, HF32, E4M3, and E5M2 for TADD, but the floating ADD path calls `ScalarFPBinaryProfile`, which asserts on types other than FP64, FP32, FP16, and BF16. Floating TREM calls `ReferenceTileFloatingModulo`, and the SFU unary operations call `ReferenceTileUnaryFinite`; both accept only FP32, FP16, and BF16.

Several helpers have no caller in `asl/` today: `TileF3DataTypeSupported`, `TileImg2ColDataTypeSupported`, `TileCarrierOrMove24BaselineDataTypeSupported` (and through it `TileMove24DataTypeSupported`), and `TileShapeAndTypeMatch`.

`TileOperationUsesSourceBackingDestination` is TRUE only for TMOV. Destination resolution in block dispatch uses it to give the TMOV destination the source's backing type.

<!-- PTO-READER-BLOCK: tile-model-legality-dtype-layout-example role=example-usage -->
## Non-normative reading example

A TADD bundle selects operation type FP16. The left source is stored as U16 and the right source as FP16.

- Left: U16 and FP16 are both 16 bits and neither is packed, so `TileCarrierWidthCompatible(U16, FP16)` is TRUE. The U16 bits are read as FP16 values.
- Right: identical types, so the relation is TRUE.
- If the left source were stored as FP32, 32 differs from 16 and the pair is rejected.
- If it were stored as U4X2, the packed type is rejected even as a raw carrier.

An RCPE6M2 operation type accepts an E6M2 backing but rejects a U8 backing, although both are 8 bits wide.

<!-- PTO-READER-BLOCK: tile-model-legality-dtype-layout-related role=related-owners-navigation -->
## Related owners

- [Operand schema](operand-schema.md) combines these tables into complete operand predicates.
- [Descriptor shape](descriptor-shape.md) owns `TileDescriptorLegal`, used by `TileLogicalShapeMatch`.
- [Elementwise execution](../execution/elementwise.md) shows the numeric helpers that run after legality.
- [Tile descriptors](../state/descriptors.md) defines `TileElementBits` and `TileDataTypeIsFourBit`.
- [Descriptor legality](../../../block/model/dispatch/descriptor-legality.md) owns `ResolveBundleEffectiveDataType`.
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
