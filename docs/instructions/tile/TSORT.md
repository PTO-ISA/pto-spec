---
{
  "schema_version": 1,
  "id": "intrinsic.tsort",
  "kind": "intrinsic",
  "title": "TSORT Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TSORT.md",
    "pto": "tile/ops/irregular-and-complex/tsort32.md"
  },
  "opcode": "TSORT",
  "family": "complex-special",
  "bundle": "BSTART.TEPL TSORT, DataType\nB.DIM sort_width -> LB0\nB.IOT",
  "operands": {
    "output": "sorted values tile\noriginal-index U32 tile",
    "input0": "source values tile",
    "input1": "sort_width 1..64",
    "input2": "descending control"
  },
  "dtypes": [
    "values: source/destination dtype match",
    "indices: U32"
  ],
  "encoding": {
    "block": "TEPL",
    "mode": 3,
    "function": 12,
    "tile_op": "0x6C"
  },
  "xlsx": {
    "include": true,
    "category": "Complex Layout Transformation\n复杂变换操作",
    "subcategory": "排序",
    "order": 96,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TSORT Intrinsic

## PTO 语义来源

`TSORT` sorts each consecutive group of `sort_width` elements from the source
Tile, writes the ordered values to `destination0`, and writes each value's
original group-relative index to the U32 `destination1` Tile. `sort_width` is
in `1..64`; the canonical bundle decoder obtains it from `LB0` and defaults to
32 when no nonzero width is supplied. The semantic `descending` operand selects
ascending or descending order; the current PTO block transport supplies the
operation default (`false`, ascending).

```asm
BSTART.TEPL TSORT, U32
B.DIM       32, 0, ->LB0
B.IOT       T#1, ->T<1KB>
B.IOT       ->U<1KB>, last
```

## 约束与合法性

- The two destinations must be distinct and must have the same element count
  as the source.
- The values destination dtype must equal the source dtype; the index
  destination dtype is U32.
- Sorting is stable only where the selected numeric profile defines equal-value
  ordering; no memory or cross-PE ordering is implied.
- `TSORT32` is not an ISA identity in PTO ISA 0.58.0. It is replaced by
  `TSORT` with explicit `sort_width`; the old PTO source page is retained only
  as provenance for the operation family.
