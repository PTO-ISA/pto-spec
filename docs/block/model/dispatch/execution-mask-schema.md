<!-- GENERATED FROM: asl/block/model/dispatch/execution-mask-schema.asl -->
# Execution Mask Schema

**Normative ASL source:** `asl/block/model/dispatch/execution-mask-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-execution-mask-schema-purpose role=purpose-scope -->
## Purpose and scope

This unit decides whether a Tile bundle carries an execution mask, checks the carrier's shape, and captures its value. An execution mask is a per-element activity bit: an inactive element keeps its old destination value (merge) or becomes zero, as `B.DATR` selects.

A mask has one of two carriers:

- a GPR carrier, one or two general registers bound through `B.IOR` with the execution-mask flag set;
- a predicate-Tile carrier, one extra `B.IOT` source after the operation's ordinary sources, whose storage kind is `TileStorage_PredicateCell`.

<!-- PTO-READER-BLOCK: block-model-dispatch-execution-mask-schema-concepts role=concepts-state -->
## Concepts and visible state

The unit writes `_BundleExecutionMask`: `valid`, `carrier`, the coordinate domain (`layout`, `valid_rows`, `valid_columns`), `word_count`, `predicate_tile`, `predicate_source_ordinal`, `invert`, `zero_inactive`, and at merge preparation `merge_base` and `merge_base_valid`. `invert` and `zero_inactive` are copied from the `B.DATR` `PredInv` and `Zero` fields.

The coordinate domain is the grid that the mask covers. For most operations it is the valid shape and layout of the first ordinary source. `TSEL` and `TSELS` use the second source when the first is a predicate cell. `TGATHER`, `TSCATTER`, `MSCATTER`, and `MSCATTER_MASK` use the second source. CUBE transport and closed expansion operations use `LB0` and `LB1`. `TPACK` and `TUNPACK` count activity in 32-bit words per row, preserving the raw-carrier exception in which the low and high words of a U64 result may be gated separately.

<!-- PTO-READER-BLOCK: block-model-dispatch-execution-mask-schema-rules role=rules-interactions -->
## Rules and interactions

`MarkSelectedBundleExecutionMaskCarrier` first clears the mask. If either scalar binding has its execution-mask flag set, the GPR carrier is selected. Its binding schema must be legal and its coordinate layout must be `CUBE_M16` or `CUBE_M32`. For most operations the domain must fit: at most 16 or 32 valid rows, and valid columns no more than the predicate field count times the word count. `TPACK` and `TUNPACK` use a bit-count rule instead. Otherwise, the predicate-Tile carrier is selected when the local source count is exactly one more than the ordinary count and that last source is a predicate cell. Its shape must match the domain, and its values must be 0 or 1.

`CaptureSelectedBundleExecutionMask` then records the mask value. For a predicate Tile it copies bit 0 of each element in the domain into `predicate_tile_snapshot`. For a GPR carrier it reads the register values.

`PrepareSelectedBundleExecutionMaskMerge` runs only for a valid mask with merge semantics and a destination. It takes the newest Tile on the destination's hand as the merge base. That Tile must be allocated, defined, and a legal CUBE descriptor, and must match the expected layout, valid shape, and type.

Tile execution dispatch calls marking and capture in that order for a mask-eligible operation when the PE mask is not zero, before any specialized handler or generic schema check. It calls merge preparation before a specialized memory handler runs, or on the generic path before destination allocation. A failure in any of the three raises `Fault_TileLegality`.

Design point: the mask is captured before destinations are allocated. The predicate-carrier contract requires the carrier to be snapshotted before an overlapping predicate destination is allocated or published. Activity is then read from `predicate_tile_snapshot` or the captured GPR words, not from the carrier Tile, so allocating, writing, or publishing a destination during the bundle cannot change which elements are active.

Design point: merge reads old values from the newest Tile on the destination hand, not from the new destination. A Local destination is a fresh register, so the previous value of that hand lives in the existing Tile. Merge preparation checks that Tile before allocation, and an inactive element then copies from it.

<!-- PTO-READER-BLOCK: block-model-dispatch-execution-mask-schema-boundaries role=boundaries -->
## Architectural boundaries

This unit does not decide which operations may carry a mask; `TileOperationExecutionMaskEligible` does. It does not check `B.DATR` mask fields against the carrier; `BundleExecutionMaskDataAttributesLegal` does, right after capture. Per-element use of the mask, including merge and zeroing, belongs to the Tile execution-mask owners.

<!-- PTO-READER-BLOCK: block-model-dispatch-execution-mask-schema-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A `TADD` bundle binds three local sources in `B.IOT`: left source, right source, and a predicate cell. `TADD` has 2 ordinary sources, so 3 local sources select the predicate-Tile carrier, with `predicate_source_ordinal` 2. If the left source is a `CUBE_M16` Tile with 16 valid rows and 32 valid columns, the predicate cell must also be `CUBE_M16` with 16 by 32 valid elements. Capture copies those 512 bits.

With `B.DATR` `Zero` clear, merge preparation needs the newest Tile on the destination hand to be a defined `CUBE_M16` numeric Tile of the effective data type. Its valid shape must equal the `LB1` by `LB0` shape, here 16 by 32 when `B.DIM` sets `LB1` to 16 and `LB0` to 32.

<!-- PTO-READER-BLOCK: block-model-dispatch-execution-mask-schema-related role=related-owners-navigation -->
## Related owners

- [Tile execution dispatch](tile-execution.md) calls marking, capture, and merge preparation.
- [Scalar schema](scalar-schema.md) owns the GPR carrier binding schema and word count.
- [Execution mask](../../../tile/model/execution/execution-mask.md) records the captured mask state.
- [Predicate carriers](../../../tile/model/legality/predicate-carriers.md) owns the predicate-cell shape and value checks.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/execution-mask-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA","surface":"block","classification":["model","dispatch","execution-mask-schema"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-SCALAR-SCHEMA","PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","PTO-TILE-MODEL-EXECUTION-MASK","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-PREDICATE-CARRIERS"]}
readonly func BundleExecutionMaskLocalTileSourceCount() => integer {0..32}
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

readonly func BundleExecutionMaskOrdinaryTileSourceCount(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => integer {0..9}
begin
    let decoded = TileOperationOfIndex(operation);
    let encoded_sources = BundleExecutionMaskLocalTileSourceCount();
    if decoded == TileOperation_TGPR2T then return 0; end;
    if decoded == TileOperation_TCMP then return 2; end;
    if decoded == TileOperation_TCMPS then return 1; end;
    if decoded == TileOperation_TSEL then
        if encoded_sources <= 2 then return 2; end;
        if _Tiles[[BundleTileSourceIndex(0, FALSE)]].storage_kind ==
           TileStorage_PredicateCell then return 3; end;
        return 2;
    end;
    if decoded == TileOperation_TSELS then
        if encoded_sources <= 1 then return 1; end;
        if _Tiles[[BundleTileSourceIndex(0, FALSE)]].storage_kind ==
           TileStorage_PredicateCell then return 2; end;
        return 1;
    end;
    var count: integer {0..9} = 0;
    if TileOperandPresent(operation, TileOperand_source0) then count = (count + 1) as integer {0..9}; end;
    if TileOperandPresent(operation, TileOperand_source1) then count = (count + 1) as integer {0..9}; end;
    if TileOperandPresent(operation, TileOperand_source2) then count = (count + 1) as integer {0..9}; end;
    if TileOperandPresent(operation, TileOperand_source3) then count = (count + 1) as integer {0..9}; end;
    if TileOperandPresent(operation, TileOperand_source4) then count = (count + 1) as integer {0..9}; end;
    return count;
end;

readonly func BundleExecutionMaskTileSourceAt(ordinal: integer {0..31})
    => TileIndex
begin
    var seen: integer {0..31} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(binding as BundleTileBindingIndex, FALSE);
                end;
                seen = (seen + 1) as integer {0..31};
            end;
            if _BundleTileBindings[[binding]].source1_valid then
                if seen == ordinal then
                    return BundleTileSourceIndex(binding as BundleTileBindingIndex, TRUE);
                end;
                seen = (seen + 1) as integer {0..31};
            end;
        end;
    end;
    return 0;
end;

readonly func BundleExecutionMaskCoordinateSourceOrdinal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => integer {0..31}
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TSEL || decoded == TileOperation_TSELS then
        let first = BundleExecutionMaskTileSourceAt(0);
        return if _Tiles[[first]].storage_kind == TileStorage_PredicateCell
            then 1 else 0;
    end;
    if decoded == TileOperation_TGATHER ||
       decoded == TileOperation_TSCATTER ||
       decoded == TileOperation_MSCATTER ||
       decoded == TileOperation_MSCATTER_MASK then
        return 1;
    end;
    return 0;
end;

readonly func BundleExecutionMaskCoordinateValidRows(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => integer
begin
    if BundleCubeTransportSelected() then
        return UInt(_BundleDimensions[[1]]);
    end;
    if TileOperationUsesClosedExpansionSchema(operation) then
        return UInt(_BundleDimensions[[1]]);
    end;
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    if ordinary != 0 then
        return _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]].valid_rows;
    end;
    let rows = UInt(_BundleDimensions[[1]]);
    return if rows == 0 then 1 else rows;
end;

readonly func BundleExecutionMaskCoordinateValidColumns(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => integer
begin
    let decoded = TileOperationOfIndex(operation);
    if BundleCubeTransportSelected() then
        return UInt(_BundleDimensions[[0]]);
    end;
    if decoded == TileOperation_TPACK || decoded == TileOperation_TUNPACK then
        let source = BundleExecutionMaskTileSourceAt(0);
        return TileCellRearrangementWordsPerRow(_Tiles[[source]])
            as integer {0..65535};
    end;
    if TileOperationUsesClosedExpansionSchema(operation) then
        return UInt(_BundleDimensions[[0]]);
    end;
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    if ordinary != 0 then
        return _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]].valid_columns;
    end;
    return UInt(_BundleDimensions[[0]]);
end;

readonly func BundleExecutionMaskCoordinateLayout(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => TileLayout
begin
    if BundleCubeTransportSelected() then
        return TileDataLayoutCubeLayout(_BundleDataAttributes.data_layout);
    end;
    if BundleExecutionMaskOrdinaryTileSourceCount(operation) != 0 then
        return _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]].layout;
    end;
    return CurrentBundleTileLayout();
end;

readonly func BundleExecutionMaskTileCarrierPresent(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !TileOperationExecutionMaskEligible(operation) ||
       _BundleScalarBindings[[0]].execution_mask_present ||
       _BundleScalarBindings[[1]].execution_mask_present then return FALSE; end;
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    if BundleExecutionMaskLocalTileSourceCount() != ordinary + 1 then return FALSE; end;
    return _Tiles[[BundleExecutionMaskTileSourceAt(ordinary)]]
        .storage_kind == TileStorage_PredicateCell;
end;

readonly func BundleExecutionMaskTileCarrierSchemaLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !BundleExecutionMaskTileCarrierPresent(operation) then return TRUE; end;
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    let predicate = BundleExecutionMaskTileSourceAt(ordinary);
    var consumer_layout = BundleExecutionMaskCoordinateLayout(operation);
    let valid_rows_raw = BundleExecutionMaskCoordinateValidRows(operation);
    let valid_columns_raw = BundleExecutionMaskCoordinateValidColumns(operation);
    if valid_rows_raw < 1 || valid_rows_raw > 65535 ||
       valid_columns_raw < 1 || valid_columns_raw > 65535 then return FALSE; end;
    let valid_rows = valid_rows_raw as integer {1..65535};
    let valid_columns = valid_columns_raw as integer {1..65535};
    if ordinary != 0 then
        consumer_layout = _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]].layout;
    end;
    return TileExecutionMaskPredicateCellShapeLegal(
        predicate, consumer_layout, valid_rows, valid_columns);
end;

readonly func BundleExecutionMaskGPRCarrierShapeLegal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    let coordinate_layout = BundleExecutionMaskCoordinateLayout(operation);
    if coordinate_layout != TileLayout_CUBE_M16 &&
       coordinate_layout != TileLayout_CUBE_M32 then return FALSE; end;
    let valid_rows_raw = BundleExecutionMaskCoordinateValidRows(operation);
    let valid_columns_raw = BundleExecutionMaskCoordinateValidColumns(operation);
    if valid_rows_raw < 1 || valid_rows_raw > 65535 ||
       valid_columns_raw < 1 || valid_columns_raw > 65535 then return FALSE; end;
    let valid_rows = valid_rows_raw as integer {1..65535};
    let valid_columns = valid_columns_raw as integer {1..65535};
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let words = BundleExecutionMaskGPRWordCount(operation);
    if TileOperationOfIndex(operation) == TileOperation_TPACK ||
       TileOperationOfIndex(operation) == TileOperation_TUNPACK then
        if valid_rows > TileCubePredicateRowBits(coordinate_layout) then
            return FALSE;
        end;
        let final_bit = ((valid_columns - 1) *
            TileCubePredicateRowBits(coordinate_layout) + valid_rows)
            as integer {0..4194303};
        return final_bit <= words * 64;
    end;
    if !TileCubePredicateGPRDataTypeSupported(data_type) then return FALSE; end;
    return valid_rows <= TileCubePredicateRowBits(coordinate_layout) &&
           valid_columns <= TileCubePredicateFieldCount(
               data_type, coordinate_layout) * words;
end;

func MarkSelectedBundleExecutionMaskCarrier(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    _BundleExecutionMask.valid = FALSE;
    _BundleExecutionMask.carrier = BundleExecutionMask_None;
    if _BundleScalarBindings[[0]].execution_mask_present ||
       _BundleScalarBindings[[1]].execution_mask_present then
        if !BundleExecutionMaskGPRBindingSchemaLegal(operation) ||
           !BundleExecutionMaskGPRCarrierShapeLegal(operation) then
            return FALSE;
        end;
        _BundleExecutionMask.valid = TRUE;
        _BundleExecutionMask.carrier = BundleExecutionMask_GPR;
        _BundleExecutionMask.word_count =
            BundleExecutionMaskGPRWordCount(operation);
        _BundleExecutionMask.layout =
            BundleExecutionMaskCoordinateLayout(operation);
        _BundleExecutionMask.valid_rows =
            BundleExecutionMaskCoordinateValidRows(operation) as integer {1..65535};
        _BundleExecutionMask.valid_columns =
            BundleExecutionMaskCoordinateValidColumns(operation) as integer {1..65535};
        _BundleExecutionMask.invert = _BundleDataAttributes.execution_mask_invert;
        _BundleExecutionMask.zero_inactive = _BundleDataAttributes.execution_mask_zero;
        return TRUE;
    end;
    if BundleExecutionMaskTileCarrierPresent(operation) then
        if !BundleExecutionMaskTileCarrierSchemaLegal(operation) then return FALSE; end;
        let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
        let predicate = BundleExecutionMaskTileSourceAt(ordinary);
        let tile = _Tiles[[predicate]];
        _BundleExecutionMask.valid = TRUE;
        _BundleExecutionMask.carrier = BundleExecutionMask_PredicateTile;
        _BundleExecutionMask.predicate_tile = predicate;
        _BundleExecutionMask.predicate_source_ordinal = ordinary;
        _BundleExecutionMask.word_count = 0;
        _BundleExecutionMask.layout = tile.layout;
        _BundleExecutionMask.valid_rows =
            BundleExecutionMaskCoordinateValidRows(operation) as integer {1..65535};
        _BundleExecutionMask.valid_columns =
            BundleExecutionMaskCoordinateValidColumns(operation) as integer {1..65535};
        _BundleExecutionMask.invert = _BundleDataAttributes.execution_mask_invert;
        _BundleExecutionMask.zero_inactive = _BundleDataAttributes.execution_mask_zero;
    end;
    return TRUE;
end;

func CaptureSelectedBundleExecutionMask(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !_BundleExecutionMask.valid then return TRUE; end;
    if _BundleExecutionMask.carrier == BundleExecutionMask_PredicateTile then
        let ordinal = _BundleExecutionMask.predicate_source_ordinal;
        let predicate = _BundleExecutionMask.predicate_tile;
        let layout = _BundleExecutionMask.layout;
        let rows = _BundleExecutionMask.valid_rows;
        let columns = _BundleExecutionMask.valid_columns;
        CaptureBundleExecutionMaskPredicateTile(
            predicate, layout,
            rows as integer {1..65535},
            columns as integer {1..65535});
        _BundleExecutionMask.predicate_source_ordinal = ordinal;
        return TRUE;
    end;
    let operation_sources = BundleExecutionMaskOperationGPRSourceCount(operation);
    let mask_low = ReadScalarRegisterOperand(
        BundleExecutionMaskGPRSourceSelector(operation_sources));
    let mask_high = if _BundleExecutionMask.word_count == 2 then
        ReadScalarRegisterOperand(
            BundleExecutionMaskGPRSourceSelector(
                (operation_sources + 1) as integer {0..5}))
        else Zeros{PTO_XLEN};
    let layout = _BundleExecutionMask.layout;
    let rows = _BundleExecutionMask.valid_rows;
    let columns = _BundleExecutionMask.valid_columns;
    let words = _BundleExecutionMask.word_count;
    CaptureBundleExecutionMaskGPR(
        mask_low, mask_high, words as integer {1..2}, layout,
        rows as integer {1..65535},
        columns as integer {1..65535});
    return TRUE;
end;

func PrepareSelectedBundleExecutionMaskMerge(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !_BundleExecutionMask.valid || _BundleExecutionMask.zero_inactive then
        return TRUE;
    end;
    var destination_binding: integer {0..15} = 0;
    var destination_found = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            destination_binding = binding as integer {0..15};
            destination_found = TRUE;
        end;
    end;
    if !destination_found then return TRUE; end;
    let hand = UInt(_BundleTileBindings[[destination_binding]].destination_hand)
        as integer {0..3};
    if _TileRelativeValid[[hand]][0] == '0' then return FALSE; end;
    let base = _TileRelativeOrder[[hand]][[0]];
    let tile = _Tiles[[base]];
    if !tile.allocated || !tile.contents_defined ||
       !TileCubeDescriptorLegal(tile) then return FALSE; end;

    let decoded = TileOperationOfIndex(operation);
    let coordinate_destination =
        decoded == TileOperation_TCMP || decoded == TileOperation_TCMPS ||
        decoded == TileOperation_TSEL || decoded == TileOperation_TSELS;
    let source_backed_destination =
        decoded == TileOperation_TMOV ||
        decoded == TileOperation_TPERMUTE || decoded == TileOperation_TSHUF;
    let source_layout_destination = source_backed_destination ||
        decoded == TileOperation_TCVT;
    let pack_unpack =
        decoded == TileOperation_TPACK || decoded == TileOperation_TUNPACK;
    let source = BundleExecutionMaskTileSourceAt(0);
    let source_tile = _Tiles[[source]];
    let (result_type_valid, result_type) = ResolveBundleEffectiveDataType();
    let result_elements_per_word =
        if result_type == TileDataType_U8 then 4
        else if result_type == TileDataType_U16 then 2
        else if result_type == TileDataType_U32 then 1
        else if result_type == TileDataType_U64 then 0
        else 0;
    let packed_columns_unbounded = if pack_unpack then
        (if result_type == TileDataType_U64 then
             TileCellRearrangementWordsPerRow(source_tile) DIVRM 2
         else TileCellRearrangementWordsPerRow(source_tile) *
             result_elements_per_word) as integer {0..262144}
        else 0;
    if !result_type_valid ||
       (pack_unpack &&
        ((result_elements_per_word == 0 &&
          result_type != TileDataType_U64) ||
         (result_type == TileDataType_U64 &&
          (source_tile.layout != TileLayout_CUBE_M32 ||
           TileCellRearrangementWordsPerRow(source_tile) MOD 2 != 0)) ||
         packed_columns_unbounded > 65535)) then
        return FALSE;
    end;
    let expected_rows = if coordinate_destination then
        _BundleExecutionMask.valid_rows
        else if source_backed_destination || pack_unpack then
            source_tile.valid_rows
        else BundleDestinationValidRows(FALSE, 0);
    let expected_columns = if coordinate_destination then
        _BundleExecutionMask.valid_columns
        else if source_backed_destination then source_tile.valid_columns
        else if pack_unpack then
            packed_columns_unbounded as integer {0..65535}
        else BundleDestinationValidColumns(FALSE, 0);
    let expected_layout = if coordinate_destination then
        _BundleExecutionMask.layout
        else if source_layout_destination || pack_unpack then source_tile.layout
        else BundleExecutionMaskCoordinateLayout(operation);
    if tile.layout != expected_layout ||
       tile.valid_rows != expected_rows ||
       tile.valid_columns != expected_columns then
        return FALSE;
    end;
    if decoded == TileOperation_TCMP || decoded == TileOperation_TCMPS then
        if !TilePredicateCellDescriptorLegal(base) ||
           tile.predicate_basis_type != result_type then return FALSE; end;
    else
        if tile.storage_kind != TileStorage_Numeric ||
           tile.data_type != result_type then
            return FALSE;
        end;
    end;
    _BundleExecutionMask.merge_base = base;
    _BundleExecutionMask.merge_base_valid = TRUE;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
