<!-- GENERATED FROM: asl/block/model/dispatch/execution-mask-schema.asl -->
# Execution Mask Schema

**Normative ASL source:** `asl/block/model/dispatch/execution-mask-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-EXECUTION-MASK-SCHEMA}

<!-- SUPPLEMENTARY-BEGIN -->

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
    => integer {0..65535}
begin
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    if ordinary != 0 then
        return _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]].valid_rows;
    end;
    let rows = UInt(_BundleDimensions[[1]]);
    return if rows == 0 then 1 else rows as integer {0..65535};
end;

readonly func BundleExecutionMaskCoordinateValidColumns(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1})
    => integer {0..65535}
begin
    let decoded = TileOperationOfIndex(operation);
    if decoded == TileOperation_TPACK || decoded == TileOperation_TUNPACK then
        let source = BundleExecutionMaskTileSourceAt(0);
        return TileCellRearrangementWordsPerRow(_Tiles[[source]])
            as integer {0..65535};
    end;
    let ordinary = BundleExecutionMaskOrdinaryTileSourceCount(operation);
    if ordinary != 0 then
        return _Tiles[[BundleExecutionMaskTileSourceAt(
            BundleExecutionMaskCoordinateSourceOrdinal(operation))]].valid_columns;
    end;
    return UInt(_BundleDimensions[[0]]) as integer {0..65535};
end;

readonly func BundleExecutionMaskCoordinateLayout(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => TileLayout
begin
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
    var consumer_layout = CurrentBundleTileLayout();
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
    let destination = _BundleTileBindings[[destination_binding]].destination;
    let destination_tile = _Tiles[[destination]];
    if _TileRelativeValid[[hand]][0] == '0' then return FALSE; end;
    let base = _TileRelativeOrder[[hand]][[0]];
    let tile = _Tiles[[base]];
    if !destination_tile.allocated || !TileCubeDescriptorLegal(destination_tile) ||
       !tile.allocated || !tile.contents_defined ||
       !TileCubeDescriptorLegal(tile) then return FALSE; end;
    if tile.layout != destination_tile.layout ||
       tile.valid_rows != destination_tile.valid_rows ||
       tile.valid_columns != destination_tile.valid_columns then
        return FALSE;
    end;
    if TileOperationOfIndex(operation) == TileOperation_TCMP ||
       TileOperationOfIndex(operation) == TileOperation_TCMPS then
        if !TilePredicateCellDescriptorLegal(base) ||
           destination_tile.storage_kind != TileStorage_PredicateCell then
            return FALSE;
        end;
    else
        if tile.storage_kind != TileStorage_Numeric ||
           destination_tile.storage_kind != TileStorage_Numeric ||
           tile.data_type != destination_tile.data_type then return FALSE; end;
    end;
    _BundleExecutionMask.merge_base = base;
    _BundleExecutionMask.merge_base_valid = TRUE;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
