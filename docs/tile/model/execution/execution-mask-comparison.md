<!-- GENERATED FROM: asl/tile/model/execution/execution-mask-comparison.asl -->
# Execution Mask Comparison

**Normative ASL source:** `asl/tile/model/execution/execution-mask-comparison.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MASK-COMPARISON}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/execution-mask-comparison.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-MASK-COMPARISON","surface":"tile","classification":["model","execution","execution-mask-comparison"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-COMPARISON","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
func ExecuteTileCompareCellAs(destination: TileIndex, source_left: TileIndex,
                              source_right: TileIndex, comparison: TileComparison,
                              operation_type: TileDataType)
begin
    let left = _Tiles[[source_left]];
    let right = _Tiles[[source_right]];
    var result = _Tiles[[destination]];
    var flags = Zeros{5};
    for row = 0 to left.valid_rows - 1 looplimit 65536 do
        for column = 0 to left.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   left.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let element = TileLogicalLinearIndex(left,
                    row as integer {0..65535}, column as integer {0..65535});
                let (predicate, element_flags) = TileCompareElement(
                    comparison, operation_type,
                    TileReadLogicalElement(left, element),
                    TileReadLogicalElement(right, element));
                result = TileInfoWithLogicalElement(result,
                    destination_element,
                    if predicate then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
                flags = flags OR element_flags;
            else
                result = TileInfoWithLogicalElement(result,
                    destination_element,
                    BundleExecutionMaskDestinationValue(
                        left.layout, row as integer {0..65535},
                        column as integer {0..65535}, Zeros{PTO_XLEN}));
            end;
        end;
    end;
    result = PredicateCellWithPadding(result, CurrentBundlePadValue());
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns) as integer {0..524288};
    result.contents_defined = TRUE;
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;

func ExecuteTileCompareCell(destination: TileIndex, source_left: TileIndex,
                            source_right: TileIndex, comparison: TileComparison)
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source_left]].data_type);
    assert operation_type_valid;
    ExecuteTileCompareCellAs(
        destination, source_left, source_right, comparison, operation_type);
end;

func ExecuteTileCompareCellScalarAs(destination: TileIndex, source: TileIndex,
                                    scalar: Word, comparison: TileComparison,
                                    operation_type: TileDataType)
begin
    let source_tile = _Tiles[[source]];
    let normalized_scalar = TileRawElementValue(scalar, operation_type);
    var result = _Tiles[[destination]];
    var flags = Zeros{5};
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(result,
                row as integer {0..65535}, column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let source_element = TileLogicalLinearIndex(source_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                let (predicate, element_flags) = TileCompareElement(
                    comparison, operation_type,
                    TileReadLogicalElement(source_tile, source_element),
                    normalized_scalar);
                result = TileInfoWithLogicalElement(result,
                    destination_element,
                    if predicate then Zeros{PTO_XLEN} + 1 else Zeros{PTO_XLEN});
                flags = flags OR element_flags;
            else
                result = TileInfoWithLogicalElement(result,
                    destination_element,
                    BundleExecutionMaskDestinationValue(
                        source_tile.layout, row as integer {0..65535},
                        column as integer {0..65535}, Zeros{PTO_XLEN}));
            end;
        end;
    end;
    result = PredicateCellWithPadding(result, CurrentBundlePadValue());
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns) as integer {0..524288};
    result.contents_defined = TRUE;
    RecordNumericStatusFlags(flags);
    _Tiles[[destination]] = result;
end;

func ExecuteTileCompareCellScalar(destination: TileIndex, source: TileIndex,
                                  scalar: Word, comparison: TileComparison)
begin
    let (operation_type_valid, operation_type) =
        ResolveTileCarrierOperationType(_Tiles[[source]].data_type);
    assert operation_type_valid;
    ExecuteTileCompareCellScalarAs(
        destination, source, scalar, comparison, operation_type);
end;
```
<!-- GENERATED-ASL-END: unit -->
