<!-- GENERATED FROM: asl/block/model/dispatch/tile-schema.asl -->
# Tile Schema

**Normative ASL source:** `asl/block/model/dispatch/tile-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tile-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit holds the shared bundle checks for Tile operations and the closed schemas for three operation groups. A closed schema is the exact set of bindings, dimensions, and types that a bundle must carry for one operation.

It defines:

- `SelectedBundleTileDataAttributesLegal`, which checks the `B.DATR` data attributes against the selected operation and raises `Fault_TileLegality` itself on failure.
- `SelectedBundleTileMasksLegal` and `SelectedBundleTileMaskIsZero`, which check the PE masks of the Tile bindings.
- The closed schemas for the binary operations `TADD`, `TSUB`, `TMUL`, `TDIV`, `TREM`, `TMAX`, `TMIN`, and `TEXPDIF`, for the unary operations `TABS`, `TNOT`, `TNEG`, and `TRELU`, and for `TFMA`.
- Counting helpers such as `BundleTileBindingCount` and `BundleTileBindingStreamTerminated`.

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-schema-concepts role=concepts-state -->
## Concepts and visible state

- A PE mask is the 4-bit set of processing elements a binding writes to. Mask `0000` means zero participation.
- `B.DATR` is the optional data-attribute command. Its fields include comparison mode, pad value, saturating, canonicalize, data type, rounding mode, and data layout.
- An explicit field value is the value from a present `B.DATR`. When `B.DATR` is absent, the explicit values used for applicability are zero or false.

These functions read binding state, dimensions, data attributes, the execution mask, and the fixed-point attributes. Only `SelectedBundleTileDataAttributesLegal` writes state, and only the fault record.

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-schema-rules role=rules-interactions -->
## Rules and interactions

`SelectedBundleTileDataAttributesLegal` rejects, with `Fault_TileLegality`:

- an execution mask together with any Shared binding;
- an explicit weight-load data layout when the bundle is not a weight `TLOAD`;
- any field the operation does not accept, from `TileOperationDATRFieldsLegal`, or for a matrix operation any failure of `BundleFPATRDATRFieldsLegal`;
- for `CUBE` `TCI`, a missing `B.DATR`, a data type other than `DTYPE_NONE`, any nonzero pad, comparison, or rounding field, or saturating or canonicalize set; for non-CUBE `TCI`, an explicit layout or data type;
- for `TGPR2T`, a rounding field with bit 2 set;
- a nonzero pad value for an operation whose pad union is must-zero;
- a nonzero explicit pad for `TLOAD` or `TSTORE` unless the layout is a CUBE conversion layout.

Design point: the ASL comment says inherited or default values are operation inputs, not explicitly encoded nonzero fields. Applicability therefore looks at field values only when `B.DATR` was present. An operation that rejects a nonzero pad is not rejected because of a default it never encoded.

`SelectedBundleTileMasksLegal` requires every valid Tile binding to carry the same PE mask. `SelectedBundleTileMaskIsZero` is true when every valid binding has mask `0000`, or when there are no bindings and a zero-participation binder was seen.

The binary schema requires one binding with a destination, `source0`, and `source1`, marked last. With a predicate-Tile execution mask it instead requires two bindings: the first carries both sources and is not last, the second carries the destination and the mask as `source0`, and the mask is source ordinal 2. The unary schema requires one binding with a destination and `source0`, plus the mask as `source1` when present. `TFMA` requires two bindings: the multiplicands first, then the destination and addend. All three require dimensions in `1..65535`, a supported data type, and a supported elementwise layout. `TEXPDIF` additionally needs an explicit dimension 0.

Design point: each schema requires that the destination binding is not yet `destination_allocated_by_bundle`. The tile-execution owner runs the closed schemas before `ResolveBundleTileDestinationsForOperation`, so the shape is proved before any destination Tile is allocated, and a failed schema leaves no allocation to roll back.

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-schema-boundaries role=boundaries -->
## Architectural boundaries

Except for the data-attribute check, these functions return booleans and the caller chooses the fault. Other closed schemas, such as comparison, reduction, TCVT, and Tile-scalar, live in their own units. The per-element value checks and the arithmetic belong to the Tile model.

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A `TADD` bundle has FP16 data type and one `B.IOT` with a destination, left source, and right source, marked last, with mask `1111`. The dimensions are 64, 16, and 64. There is no `B.DATR`. The data-attribute check sees all explicit fields as zero and passes. The binary schema sees one binding, legal dimensions, and FP16 with a RowMajor layout, and passes. If the bundle added a predicate-Tile execution mask but kept one binding, the schema would fail because it then needs two bindings.

<!-- PTO-READER-BLOCK: block-model-dispatch-tile-schema-related role=related-owners-navigation -->
## Related owners

- [Tile execution](tile-execution.md) calls these checks in commit order.
- [Tile-scalar schema](tile-scalar-schema.md) holds the Tile-scalar closed schemas.
- [Command data attributes](command-data-attributes.md) defines how `B.DATR` is recorded.
- [Execution-mask schema](execution-mask-schema.md) defines the mask carriers.
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
