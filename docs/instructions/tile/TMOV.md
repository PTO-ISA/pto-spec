---
{
  "schema_version": 1,
  "id": "intrinsic.tmov",
  "kind": "intrinsic",
  "title": "TMOV Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": { "davincioo": "TMOV.md", "pto": "tile/ops/layout-and-rearrangement/tmov.md" },
  "opcode": "TMOV",
  "family": "layout-movement",
  "bundle": "BSTART.TLSU TMOV, DataType\nB.DIM LB0\nB.DIM (LB1/LB2 for 2D)\nB.IOT",
  "operands": {
    "output": "destination Local Tile",
    "input0": "source Local Tile",
    "input1": null,
    "input2": null
  },
  "dtypes": ["byte-preserving; descriptors must be compatible"],
  "encoding": {
    "block": "TLSU",
    "function": 2
  },
  "xlsx": {
    "include": true,
    "category": "Complex Layout Transformation\n复杂变换操作",
    "subcategory": "Tile搬运",
    "order": 86,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TMOV Intrinsic

## PTO 语义来源

- PTO source: `tile/ops/layout-and-rearrangement/tmov.md`

PTO `TMOV(dst,src)` is a Local Tile move/conversion. PTO does not define a
Local↔Shared overload, a Shared move mode, or a Shared TMOV encoding.

`BSTART.TMOV` additionally accepts encoded DataType `31`, spelled
`DTYPE_NONE`. When neither a concrete `B.DATR.DataType` nor a concrete
`BSTART.TMOV DataType` is present, the effective type is inherited from the
source descriptor. The resolver handles Local and Shared descriptor records;
this descriptor fallback does not by itself make an otherwise-unaccepted
Shared TMOV instruction form legal. `DTYPE_NONE` is never installed in a tile
descriptor and has no element-width or arithmetic meaning.

## Ordinary Local Form

```asm
BSTART.TLSU TMOV, FP16
B.DIM       rValidCol, 0, ->LB0
B.DIM       rValidRow, 0, ->LB1
B.DIM       rCol, 0, ->LB2
B.IOT       T#1, mask=1111, last, ->T<4KB>
```

It performs four asynchronous Local fragment moves under the ordinary distributed logical-Tile contract.

## 约束与合法性

- Any TMOV form with a Shared operand is illegal in PTO.
- A missing concrete effective DataType is a `Fault_TileLegality` rejection
  before destination allocation, source consumption, or payload effects.
- `PE_MASK` is a four-bit quarter predicate; multiple bits are allowed and
  `0000` is a no-op.
- `RecordEvent` is reused; there is no `SharedEvent`, and event completion is not a cross-PE GM fence.

## Lowering 摘要

The verifier requires two Local Tile operands and emits TLSU Function 2 with a
single `B.IOT` binding. Functions 8–12 are not TMOV encodings in PTO.
