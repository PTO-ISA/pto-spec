<!-- GENERATED FROM: asl/tile/model/dispatch/top-level.asl -->
# Top Level

**Normative ASL source:** `asl/tile/model/dispatch/top-level.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-DISPATCH-TOP-LEVEL}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/dispatch/top-level.asl -->
```asl
// PTO-UNIT: {"catalog_projection":{"catalog":"tile-operations","deleted_names":["ACCCVT","TADDC","TADDSC","TALLOC","TAXPY","TCONCAT","TDEINTERLEAVE","TDEQUANT","TFILLPAD","TFMOD","TFMODS","TFREE","TEXTRACT","TGATHERB","THISTOGRAM","TINSERT","TINTERLEAVE","TLRELU","TPARTADD","TPARTARGMAX","TPARTARGMIN","TPARTMAX","TPARTMIN","TPARTMUL","TPOP","TPRELU","TPUSH","TQUANT","TRESHAPE","TSORT","TSORT32","TTRANS","TMRGSORT"],"isa":"PTO Instruction Set Architecture","rejected_names":["TEXRACT","TFILL/TEXPANDS","TPOW","TPOWS"],"rejected_review_only_codes":{"CUBE":[],"TEPL":["0x060","0x062","0x063","0x068","0x06A","0x06B","0x06C","0x06D"],"TLSU":[]},"reserved":{"cube_functions_without_named_alias":[3,7,8,[9,15],19,[23,31]],"tepl_selector_ranges":[["0x005","0x005"],["0x00E","0x00E"],["0x018","0x019"],["0x01D","0x01F"],["0x025","0x025"],["0x02E","0x039"],["0x03C","0x03F"],["0x04E","0x04F"],["0x05E","0x05F"],["0x061","0x061"],["0x065","0x065"],["0x069","0x069"],["0x06E","0x06E"],["0x071","0x074"],["0x079","0x07D"],["0x07F","0x07F"]],"tlsu_functions":[[28,31]]},"schema_version":3},"classification":["model","dispatch","top-level"],"depends_on":["PTO-TILE-MODEL-DISPATCH-ELEMENTWISE-TILE-TILE","PTO-TILE-MODEL-DISPATCH-TILE-SCALAR-AND-IMMEDIATE","PTO-TILE-MODEL-DISPATCH-REDUCE-AND-EXPAND","PTO-TILE-MODEL-DISPATCH-MEMORY-AND-DATA-MOVEMENT","PTO-TILE-MODEL-DISPATCH-MATRIX-AND-MATRIX-VECTOR","PTO-TILE-MODEL-DISPATCH-LAYOUT-AND-REARRANGEMENT","PTO-TILE-MODEL-DISPATCH-IRREGULAR-AND-COMPLEX"],"id":"PTO-TILE-MODEL-DISPATCH-TOP-LEVEL","surface":"tile"}
// The block dispatcher selects exactly one catalog-bound tile operation class.
```
<!-- GENERATED-ASL-END: unit -->
