---
{
  "schema_version": 1,
  "id": "intrinsic.thistogram",
  "kind": "intrinsic",
  "title": "THISTOGRAM Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "THISTOGRAM.md",
    "pto": "tile/ops/irregular-and-complex/thistogram.md"
  },
  "opcode": "THISTOGRAM",
  "family": "complex-special",
  "bundle": "BSTART.TEPL THISTOGRAM, DataType\nB.DATR selected_byte\nB.IOT",
  "operands": {
    "output": "per-row cumulative 256-bin histogram",
    "input0": "U16 or U32 source tile",
    "input1": "filter/index tile",
    "input2": "selected_byte 0..3"
  },
  "dtypes": [
    "source: U16",
    "U32"
  ],
  "encoding": {
    "block": "TEPL",
    "mode": 3,
    "function": 8,
    "tile_op": "0x68"
  },
  "xlsx": {
    "include": true,
    "category": "Complex Layout Transformation\n复杂变换操作",
    "subcategory": "直方图",
    "order": 84,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# THISTOGRAM Intrinsic

## PTO 语义来源

`THISTOGRAM` selects one byte from each U16 or U32 source element, optionally
filters higher bytes through the index Tile, counts 256 byte values per row,
and writes the cumulative bin counts to the destination. `selected_byte` is
encoded through the `B.DATR.PadValueOrByteId` union for this operation.

```asm
BSTART.TEPL THISTOGRAM, U32
B.DATR      ByteId.0
B.IOT       T#1, T#2, mask=1111, last, ->T<1KB>
```

## 约束与合法性

- Destination and source row counts must match; destination valid columns must
  be at least 256.
- U16 sources allow byte 0 or 1. U32 sources allow byte 0 through 3.
- The index Tile must supply the filter rows required by the selected byte.
- The destination valid region becomes defined after successful completion.
