<!-- GENERATED FROM: asl/tile/model/execution/indexed-rearrangement.asl -->
# Indexed Rearrangement

**Normative ASL source:** `asl/tile/model/execution/indexed-rearrangement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-INDEXED-REARRANGEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-execution-indexed-rearrangement-purpose role=purpose-scope -->
## Purpose and scope

This unit defines the two index-driven row moves inside Local Tile storage. `TGATHER` reads, for each destination element, a source row chosen by an index Tile. `TSCATTER` writes each source element into a destination row chosen by an index Tile. In both, the column never changes.

The TGATHER and TSCATTER instructions call these helpers after the operand checks in [indexed rearrangement legality](../legality/indexed-rearrangement.md) have passed.

<!-- PTO-READER-BLOCK: tile-model-execution-indexed-rearrangement-concepts role=concepts-state -->
## Concepts and visible state

An index Tile holds one row selector per element. `TileIndexedRowValue` reads it as an unsigned integer from the low 16, 32, or 64 bits, according to the index type (S16, U16, S32, U32, S64, or U64).

Values move as raw carrier bits. Neither helper applies numeric conversion or rejects a value because its floating encoding is unusual.

Each helper copies the source and index `TileInfo` records at entry, builds the result in a local copy, and assigns `_Tiles` once. Before writing, it clears the destination's `defined_elements`, `packed_defined_elements`, `defined_valid_elements`, and `contents_defined`.

<!-- PTO-READER-BLOCK: tile-model-execution-indexed-rearrangement-rules role=rules-interactions -->
## Rules and interactions

`TGATHER` visits every valid destination coordinate (row, column). At an active coordinate it reads the index at the same coordinate and copies source element (index value, column); an inactive coordinate takes the ExecutionMask value. It sets `contents_defined` and a full valid-region count, and pads with `TilePad_Null`, so physical elements outside the valid region are zero and undefined.

`TSCATTER` first writes zero to every physical destination element, which also marks each one defined. It then visits every valid source coordinate and writes the source element to destination (index value, column). It sets the defined count to the valid-region size and does not call a padding helper.

Design point: every index is checked before any write. `TileGatherReferencesLegal` rejects negative, out-of-range, and undefined source references. `TileScatterReferencesLegal` rejects negative, out-of-range, and duplicate destination coordinates. A bad index produces a fault with no partial result.

Design point: duplicate scatter targets are illegal rather than ordered. Because no two source elements can name the same destination element, the result does not depend on visiting order.

Design point: `TSCATTER` zero-fills the whole physical destination. Destination rows that no index selects read as zero, and they are defined.

<!-- PTO-READER-BLOCK: tile-model-execution-indexed-rearrangement-boundaries role=boundaries -->
## Architectural boundaries

`TGATHER` requires the destination and index Tiles to share one valid shape, and the source to have at least as many valid columns. `TSCATTER` requires the source and index Tiles to share one valid shape, and the destination to have the same valid column count.

`TGATHER` tests `BundleExecutionMaskActiveAt` for each coordinate and uses `BundleExecutionMaskDestinationValue` for an inactive one. `TSCATTER` does not consult the mask. The [ExecutionMask source schema](../legality/execution-mask-source-schema.md) NDF states that neither operation has an applicable ExecutionMask form and that a mask carrier on them must reject before effects. The executable list `TileOperationExecutionMaskEligible` nevertheless still names both, so this page describes the `TGATHER` inactive branch as written without claiming it is unreachable.

Both helpers begin with an `assert` on their legality predicate, so they describe only requests that already passed that predicate.

<!-- PTO-READER-BLOCK: tile-model-execution-indexed-rearrangement-example role=example-usage -->
## Non-normative reading example

A `TGATHER` source has 3 valid rows and 2 valid columns: row 0 is 10, 11; row 1 is 20, 21; row 2 is 30, 31. The U32 index Tile has 2 rows and 2 columns: row 0 is 2, 0; row 1 is 1, 1.

1. Destination (0, 0) reads source (2, 0), which is 30.
2. Destination (0, 1) reads source (0, 1), which is 11.
3. Destination row 1 reads source (1, 0) and (1, 1), which are 20 and 21.

A `TSCATTER` source holds 5, 6 in row 0 and 7, 8 in row 1, with index rows 2, 0 and 0, 1. The destination has 3 valid rows and 2 valid columns. Column 0 receives 5 at row 2 and 7 at row 0. Column 1 receives 6 at row 0 and 8 at row 1. The result rows are 7, 6; then 0, 8; then 5, 0.

<!-- PTO-READER-BLOCK: tile-model-execution-indexed-rearrangement-related role=related-owners-navigation -->
## Related owners

- [TGATHER](../../irregular-and-complex/layout/TGATHER.md) and [TSCATTER](../../irregular-and-complex/layout/TSCATTER.md) own the instruction contracts.
- [Indexed rearrangement legality](../legality/indexed-rearrangement.md) owns index decoding and the reference checks.
- [Irregular and complex dispatch](../dispatch/irregular-and-complex.md) names the instruction class that contains TGATHER and TSCATTER; it has no executable ASL.
- [Element definedness](../definedness/elements.md) owns the padding and definedness helpers.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/indexed-rearrangement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-INDEXED-REARRANGEMENT","surface":"tile","classification":["model","execution","indexed-rearrangement"],"depends_on":["PTO-TILE-MODEL-LEGALITY-INDEXED-REARRANGEMENT","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}

func TGATHER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert TileOperandsLegal_TGATHER(destination, source, indices);
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    var result = _Tiles[[destination]];
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = zero_packed_tile_elements;
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   result.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let index_element = TileLogicalLinearIndex(
                    index_tile, row as integer {0..65535},
                    column as integer {0..65535});
                let source_row = TileIndexedRowValue(
                    TileReadLogicalElement(index_tile, index_element),
                    index_tile.data_type);
                let source_element = TileLogicalLinearIndex(
                    source_tile, source_row as integer {0..65535},
                    column as integer {0..65535});
                result = TileInfoWithLogicalElementAndDefined(
                    result, destination_element,
                    TileReadLogicalElement(source_tile, source_element), TRUE);
            else
                result = TileInfoWithLogicalElementAndDefined(
                    result, destination_element,
                    BundleExecutionMaskDestinationValue(
                        result.layout, row as integer {0..65535},
                        column as integer {0..65535}, Zeros{PTO_XLEN}), TRUE);
            end;
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns)
            as integer {0..524288};
    result.contents_defined = TRUE;
    result = TileWithPadding(result, TilePad_Null);
    _Tiles[[destination]] = result;
end;

func TSCATTER(
    destination: TileIndex,
    source: TileIndex,
    indices: TileIndex)
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert TileOperandsLegal_TSCATTER(destination, source, indices);
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    var result = _Tiles[[destination]];
    result.contents_defined = FALSE;
    result.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    result.defined_valid_elements = 0;
    result.packed_defined_elements = zero_packed_tile_elements;
    for row = 0 to result.rows - 1 looplimit 65536 do
        for column = 0 to result.columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, destination_element,
                Zeros{PTO_XLEN});
        end;
    end;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(
                source_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let index_element = TileLogicalLinearIndex(
                index_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let destination_row = TileIndexedRowValue(
                TileReadLogicalElement(index_tile, index_element),
                index_tile.data_type);
            let destination_element = TileLogicalLinearIndex(
                result,
                destination_row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, destination_element,
                TileReadLogicalElement(source_tile, source_element));
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns)
            as integer {0..524288};
    result.contents_defined = TRUE;
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->
