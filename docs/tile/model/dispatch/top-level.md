<!-- GENERATED FROM: asl/tile/model/dispatch/top-level.asl -->
# Top Level

**Normative ASL source:** `asl/tile/model/dispatch/top-level.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-TOP-LEVEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-dispatch-top-level-purpose role=purpose-scope -->
## Purpose and scope

This unit is the root of the Tile dispatch classes. It contains no executable ASL. Its content is the `PTO-UNIT` metadata line and one comment: the block dispatcher selects exactly one catalog-bound tile operation class.

The metadata does two jobs. Its `depends_on` list names the seven class units. Its `catalog_projection` object supplies the envelope of the generated tile-operations catalog: the fields that are not per-operation records.

<!-- PTO-READER-BLOCK: tile-model-dispatch-top-level-concepts role=concepts-state -->
## Concepts and visible state

The unit declares no state. The seven classes are:

| Class | Family | Operations |
| --- | --- | --- |
| elementwise tile-tile | TEPL mode 0 | 26 |
| tile-scalar and immediate | TEPL mode 1 | 15 |
| reduce and expand | TEPL mode 2 | 28 |
| irregular and complex | TEPL mode 3 | 4 |
| layout and rearrangement | TEPL mode 3 and TLSU | 6 |
| memory and data movement | TLSU | 27 |
| matrix and matrix-vector | CUBE | 12 |

That is 118 operations, the `operation_count` of the catalog.

The `catalog_projection` envelope holds:

- `reserved`: TEPL selector ranges, TLSU functions 28 through 31, and CUBE functions that have no named operation;
- `rejected_review_only_codes`: eight TEPL codes, `0x060`, `0x062`, `0x063`, `0x068`, and `0x06A` through `0x06D`;
- `deleted_names`: 33 former mnemonics, such as `TSORT`, `TMRGSORT`, `TCONCAT`, and `TFILLPAD`;
- `rejected_names`: `TEXRACT`, `TFILL/TEXPANDS`, `TPOW`, and `TPOWS`.

<!-- PTO-READER-BLOCK: tile-model-dispatch-top-level-rules role=rules-interactions -->
## Rules and interactions

The catalog projector copies this envelope into `spec/catalog/tile-operations.json` and fills the `operations` list from the instruction units. `DecodeTileOperation` is generated from the operations list. A code that is not in the list, which includes every reserved and review-only code, yields `PTO_TILE_OPERATION_COUNT`. `BundleOperationDescriptorLegal` makes this check when `BSTART` is decoded, so that `BSTART` faults with `Fault_IllegalInstruction` before the bundle is installed; tile execution repeats the same decode.

Design point: reserved and rejected codes are listed explicitly instead of being left as gaps. The decoder generator emits a check that each listed code decodes to no operation, so an operation added later at a reserved code conflicts with the generated check.

Design point: deleted names are recorded, not forgotten. ADR-TILE-0013 retires `TSORT`, `TMRGSORT`, and six other operations and states that their former encodings reject with `Fault_IllegalInstruction` and have no compatibility aliases. Keeping the names in the envelope marks them as intentionally absent from the catalog.

<!-- PTO-READER-BLOCK: tile-model-dispatch-top-level-boundaries role=boundaries -->
## Architectural boundaries

This unit is not the block dispatcher. Command decode and bundle execution belong to the block model dispatch units. It also does not choose a class at run time: the decode key is the family and the 12-bit code, and the class is a catalog label on each operation.

`BSTART.TIMG2COL` uses TLSU function 28, which the envelope reserves. It is not a catalog operation. Tile execution recognizes its exact command form and skips the generic decode.

<!-- PTO-READER-BLOCK: tile-model-dispatch-top-level-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A TEPL bundle with code `0x06C` is inside the rejected review-only list, and `TSORT` is in `deleted_names`. `DecodeTileOperation` finds no row for that code, so the `BSTART` faults with `Fault_IllegalInstruction` in `BundleOperationDescriptorLegal`, before the bundle is installed. A TEPL bundle with code `0x06F` finds the `TGATHER` row, which belongs to the irregular-and-complex class.

<!-- PTO-READER-BLOCK: tile-model-dispatch-top-level-related role=related-owners-navigation -->
## Related owners

- [Elementwise tile-tile](elementwise-tile-tile.md), [tile-scalar and immediate](tile-scalar-and-immediate.md), [reduce and expand](reduce-and-expand.md), and [irregular and complex](irregular-and-complex.md) are the TEPL-only classes.
- [Layout and rearrangement](layout-and-rearrangement.md), [memory and data movement](memory-and-data-movement.md), and [matrix and matrix-vector](matrix-and-matrix-vector.md) are the other classes.
- [Tile execution](../../../block/model/dispatch/tile-execution.md) decodes and runs the selected operation.
- [Block top-level dispatch](../../../block/model/dispatch/top-level.md) is the command-level dispatcher.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/top-level.asl -->
```asl
// PTO-UNIT: {"catalog_projection":{"catalog":"tile-operations","deleted_names":["ACCCVT","TADDC","TADDSC","TALLOC","TAXPY","TCONCAT","TDEINTERLEAVE","TDEQUANT","TFILLPAD","TFMOD","TFMODS","TFREE","TEXTRACT","TGATHERB","THISTOGRAM","TINSERT","TINTERLEAVE","TLRELU","TPARTADD","TPARTARGMAX","TPARTARGMIN","TPARTMAX","TPARTMIN","TPARTMUL","TPOP","TPRELU","TPUSH","TQUANT","TRESHAPE","TSORT","TSORT32","TTRANS","TMRGSORT"],"isa":"PTO Instruction Set Architecture","rejected_names":["TEXRACT","TFILL/TEXPANDS","TPOW","TPOWS"],"rejected_review_only_codes":{"CUBE":[],"TEPL":["0x060","0x062","0x063","0x068","0x06A","0x06B","0x06C","0x06D"],"TLSU":[]},"reserved":{"cube_functions_without_named_alias":[3,7,8,[9,15],19,[23,31]],"tepl_selector_ranges":[["0x005","0x005"],["0x00E","0x00E"],["0x018","0x019"],["0x01E","0x01F"],["0x025","0x025"],["0x02F","0x039"],["0x03C","0x03F"],["0x04E","0x04F"],["0x05E","0x05F"],["0x061","0x061"],["0x065","0x065"],["0x069","0x069"],["0x06E","0x06E"],["0x071","0x074"],["0x079","0x07D"],["0x07F","0x07F"]],"tlsu_functions":[[28,31]]},"schema_version":3},"classification":["model","dispatch","top-level"],"depends_on":["PTO-TILE-MODEL-DISPATCH-ELEMENTWISE-TILE-TILE","PTO-TILE-MODEL-DISPATCH-TILE-SCALAR-AND-IMMEDIATE","PTO-TILE-MODEL-DISPATCH-REDUCE-AND-EXPAND","PTO-TILE-MODEL-DISPATCH-MEMORY-AND-DATA-MOVEMENT","PTO-TILE-MODEL-DISPATCH-MATRIX-AND-MATRIX-VECTOR","PTO-TILE-MODEL-DISPATCH-LAYOUT-AND-REARRANGEMENT","PTO-TILE-MODEL-DISPATCH-IRREGULAR-AND-COMPLEX"],"id":"PTO-TILE-MODEL-DISPATCH-TOP-LEVEL","surface":"tile"}
// The block dispatcher selects exactly one catalog-bound tile operation class.
```
<!-- GENERATED-ASL-END: unit -->
