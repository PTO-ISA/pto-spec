<!-- GENERATED FROM: asl/tile/model/execution/execution-mask-comparison.asl -->
# Execution Mask Comparison

**Normative ASL source:** `asl/tile/model/execution/execution-mask-comparison.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-MASK-COMPARISON}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-comparison-purpose role=purpose-scope -->
## Purpose and scope

This unit defines TCMP and TCMPS when the sources use a CUBE_M16 or CUBE_M32 layout and the destination is a PredicateCell. A PredicateCell is U8 CUBE predicate storage that holds `0x01` for TRUE and `0x00` for FALSE at each coordinate.

`ExecuteTileCompareAs` and `ExecuteTileCompareScalarAs` in [comparison](comparison.md) delegate here when the source layout is a CUBE layout. Those functions assert the compare legality helper before delegating. The two `As` functions here take an explicit operation type, and the two wrappers resolve it through `ResolveTileCarrierOperationType`.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-comparison-concepts role=concepts-state -->
## Concepts and visible state

The Tile-Tile form walks the left source's valid rows and columns. The scalar form walks the source's valid region and first normalizes the scalar to the operation type's width with `TileRawElementValue`.

For each coordinate the executor asks `BundleExecutionMaskActiveAt`. When no ExecutionMask is in force, every coordinate is active.

The result is built in a private copy of the destination record, and five-bit numeric status is accumulated in `flags`.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-comparison-rules role=rules-interactions -->
## Rules and interactions

An active coordinate reads both operands, calls `TileCompareElement`, writes `1` or `0` into the destination element, and ORs the element status into `flags`.

An inactive coordinate reads no source value and contributes no status. It writes `BundleExecutionMaskDestinationValue`, which is zero under the ZERO policy or the merge base's old element under MERGE.

After the loop the executor calls `PredicateCellWithPadding` with the bundle PadValue. Outside the valid region, Max writes `0x01` and marks it defined, Zero and Min write `0x00` and mark it defined, and Null writes zero and leaves it undefined.

It then sets `defined_valid_elements` to the valid area and `contents_defined` to TRUE, records the accumulated flags once, and publishes the destination.

Design point: sources are read from `left`, `right`, and `source_tile`, which are copies taken before the loop, and the destination is written only at the end. A destination that aliases a source therefore does not change the values the comparison reads.

Design point: inactive coordinates skip `TileCompareElement`. A signaling NaN at an inactive coordinate therefore cannot set NV, which matches the requirement that inactive effects contribute no numeric status.

Design point: the whole valid region becomes defined, including inactive coordinates. Under MERGE, legality has already required the merge base to be fully defined, so the copied values are defined too.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-comparison-boundaries role=boundaries -->
## Architectural boundaries

This unit only produces PredicateCell destinations. RowMajor comparisons produce a bit-packed predicate Tile in [comparison](comparison.md), and the GPR destination form is owned by `TileCompareCUBEToGPRAs` there and `TileCompareCUBEScalarToGPRAs` in [predicate carriers](predicate-carriers.md).

The unit does not check legality itself. Type, shape, encoding validity, and PredicateCell descriptor checks run before these functions are reached.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-comparison-example role=example-usage -->
## Non-normative reading example

TCMPS with CMode GE compares an S16 CUBE_M16 source against the scalar `0x00010005`. Normalization to 16 bits keeps `0x0005`, which is 5.

The valid region is 1 row by 3 columns with values 7, 5, and -2. A GPR ExecutionMask makes column 2 inactive, and B.DATR Zero is 1.

| Column | Source value | Active | Destination byte |
| --- | --- | --- | --- |
| 0 | 7 | yes | `0x01` |
| 1 | 5 | yes | `0x01` |
| 2 | -2 | no | `0x00` |

Column 2 is `0x00` because of the ZERO policy, not because -2 is less than 5. No flag is recorded, since integer comparison never sets status.

<!-- PTO-READER-BLOCK: tile-model-execution-execution-mask-comparison-related role=related-owners-navigation -->
## Related owners

- [Comparison](comparison.md) owns `TileCompareElement` and the RowMajor paths.
- [ExecutionMask state](execution-mask-state.md) owns the activity test and inactive destination values.
- [Predicate carrier legality](../legality/predicate-carriers.md) owns `PredicateCellWithPadding` and PredicateCell descriptor rules.
- [Comparison schema](../../../block/model/dispatch/comparison-schema.md) selects between the PredicateCell and GPR destination forms.
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
