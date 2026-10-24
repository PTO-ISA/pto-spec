<!-- GENERATED FROM: asl/tile/model/execution/comparison-value.asl -->
# Comparison Value

**Normative ASL source:** `asl/tile/model/execution/comparison-value.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-COMPARISON-VALUE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/comparison-value.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-COMPARISON-VALUE","surface":"tile","classification":["model","execution","comparison-value"],"depends_on":["PTO-TILE-MODEL-EXECUTION-COMPARISON","PTO-TILE-MODEL-EXECUTION-MASK-COMPARISON","PTO-TILE-MODEL-EXECUTION-PREDICATE-CARRIERS","PTO-TILE-MODEL-STATE-TYPES"]}

func ExecuteTileCompareAsToValue(
    destination: TileOutputValueTarget, source_left: TileIndex,
    source_right: TileIndex, comparison: TileComparison,
    operation_type: TileDataType) => TileInfo
begin
    let left_tile = _Tiles[[source_left]];
    if TileLayoutIsCube(left_tile.layout) then
        return ExecuteTileCompareCellAsToValue(
            destination, source_left, source_right, comparison, operation_type);
    end;
    let right_tile = _Tiles[[source_right]];
    var result = destination.value;
    var flags = Zeros{5};
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to left_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(left_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let (predicate, element_flags) = TileCompareElement(
                comparison, operation_type,
                TileReadLogicalElement(left_tile, element),
                TileReadLogicalElement(right_tile, element));
            result = TileInfoWithPredicateBit(result,
                row as integer {0..65535}, column as integer {0..65535},
                predicate);
            flags = flags OR element_flags;
        end;
    end;
    result = PredicateTileWithPadding(result, CurrentBundlePadValue());
    RecordNumericStatusFlags(flags);
    return result;
end;

func ExecuteTileCompareToValue(
    destination: TileOutputValueTarget, source_left: TileIndex,
    source_right: TileIndex, comparison: TileComparison) => TileInfo
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source_left]].data_type);
    assert operation_type_valid;
    return ExecuteTileCompareAsToValue(destination, source_left, source_right,
        comparison, operation_type);
end;

func ExecuteTileCompareScalarAsToValue(
    destination: TileOutputValueTarget, source: TileIndex, scalar: Word,
    comparison: TileComparison, operation_type: TileDataType) => TileInfo
begin
    let source_tile = _Tiles[[source]];
    if TileLayoutIsCube(source_tile.layout) then
        return ExecuteTileCompareCellScalarAsToValue(
            destination, source, scalar, comparison, operation_type);
    end;
    var result = destination.value;
    let normalized_scalar = TileRawElementValue(scalar, operation_type);
    var flags = Zeros{5};
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let (predicate, element_flags) = TileCompareElement(
                comparison, operation_type,
                TileReadLogicalElement(source_tile, element),
                normalized_scalar);
            result = TileInfoWithPredicateBit(result,
                row as integer {0..65535}, column as integer {0..65535},
                predicate);
            flags = flags OR element_flags;
        end;
    end;
    result = PredicateTileWithPadding(result, CurrentBundlePadValue());
    RecordNumericStatusFlags(flags);
    return result;
end;

func ExecuteTileCompareScalarToValue(
    destination: TileOutputValueTarget, source: TileIndex, scalar: Word,
    comparison: TileComparison) => TileInfo
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    assert operation_type_valid;
    return ExecuteTileCompareScalarAsToValue(destination, source, scalar,
        comparison, operation_type);
end;

func ExecuteTileSelectToValue(
    destination: TileOutputValueTarget, mask: TileIndex,
    source_true: TileIndex, source_false: TileIndex) => TileInfo
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(destination.value.data_type);
    assert operation_type_valid;
    let true_tile = _Tiles[[source_true]];
    let false_tile = _Tiles[[source_false]];
    let mask_tile = _Tiles[[mask]];
    var result = destination.value;
    if TileLayoutIsCube(true_tile.layout) then
        for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
            for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
                let source_element = TileLogicalLinearIndex(true_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                let destination_element = TileLogicalLinearIndex(result,
                    row as integer {0..65535}, column as integer {0..65535});
                var value = Zeros{PTO_XLEN};
                if BundleExecutionMaskActiveAt(true_tile.layout,
                       row as integer {0..65535},
                       column as integer {0..65535}) then
                    let predicate_element = TileLogicalLinearIndex(mask_tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    value = if TileReadLogicalElement(
                        mask_tile, predicate_element)[7:0] == '00000001' then
                        TileReadLogicalElement(true_tile, source_element)
                        else TileReadLogicalElement(false_tile, source_element);
                else
                    value = BundleExecutionMaskDestinationValue(
                        true_tile.layout, row as integer {0..65535},
                        column as integer {0..65535}, Zeros{PTO_XLEN});
                end;
                result = TileInfoWithLogicalElement(
                    result, destination_element, value);
            end;
        end;
    else
        for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
            for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
                let element = TileLogicalLinearIndex(true_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                let value = if TilePredicateBitFromInfo(mask_tile,
                    row as integer {0..65535}, column as integer {0..65535}) then
                    TileReadLogicalElement(true_tile, element)
                    else TileReadLogicalElement(false_tile, element);
                result = TileInfoWithLogicalElement(result, element, value);
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    return TileWithPadding(result, CurrentBundlePadValue());
end;

func ExecuteTileSelectScalarToValue(
    destination: TileOutputValueTarget, mask: TileIndex,
    source_true: TileIndex, scalar_false: Word) => TileInfo
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(destination.value.data_type);
    assert operation_type_valid;
    let true_tile = _Tiles[[source_true]];
    let mask_tile = _Tiles[[mask]];
    let normalized_scalar = TileRawElementValue(scalar_false, operation_type);
    var result = destination.value;
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var value = Zeros{PTO_XLEN};
            if BundleExecutionMaskActiveAt(true_tile.layout,
                   row as integer {0..65535},
                   column as integer {0..65535}) then
                var selected = FALSE;
                if TileLayoutIsCube(true_tile.layout) then
                    let mask_element = TileLogicalLinearIndex(mask_tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    selected = TileReadLogicalElement(mask_tile,
                        mask_element)[7:0] == '00000001';
                else
                    selected = TilePredicateBitFromInfo(mask_tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                end;
                value = if selected then TileReadLogicalElement(
                    true_tile, element) else normalized_scalar;
            else
                value = BundleExecutionMaskDestinationValue(
                    true_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
            result = TileInfoWithLogicalElement(result, element, value);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    return TileWithPadding(result, CurrentBundlePadValue());
end;
```
<!-- GENERATED-ASL-END: unit -->
