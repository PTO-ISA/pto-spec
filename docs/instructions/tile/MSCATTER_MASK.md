---
{
  "schema_version": 1,
  "id": "intrinsic.mscatter_mask",
  "kind": "intrinsic",
  "title": "MSCATTER_MASK Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": { "davincioo": "MSCATTER_MASK.md" },
  "opcode": "MSCATTER_MASK",
  "family": "memory-tlsu",
  "bundle": "BSTART.MSCATTER.MASK DataType\nB.IOT\nB.IOR base_address",
  "operands": {
    "output": "indexed memory locations",
    "input0": "source tile\nindices tile",
    "input1": "mask tile",
    "input2": null
  },
  "dtypes": ["TLSU data types accepted by BSTART.MSCATTER.MASK"],
  "encoding": { "block": "TLSU", "function": 7 },
  "xlsx": {
    "include": true,
    "category": "Tile Memory Operation\nTile级访存操作",
    "subcategory": "不规则访存",
    "order": 82,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# MSCATTER_MASK Intrinsic

## PTO 语义来源

`MSCATTER_MASK` scatters source elements to indexed memory locations for
nonzero mask lanes. Zero mask lanes have no memory side effect. All selected
addresses are probed before the scatter commit phase so a failing footprint
does not produce a partial event prefix.

```asm
BSTART.MSCATTER.MASK U32
B.IOT                T#1, T#2, T#3, mask=1111, last
B.IOR                a0, zero
```

## 约束与合法性

- Source, index, and mask Tiles must have equal logical shape and defined
  contents.
- Selected lanes obey the current bundle memory-order attribute.
- Conflicting selected addresses follow the architectural scatter commit
  policy; programmers must not infer a stronger lane order.
- `BSTART.MSCATTER.MASK` is an accepted PTO ISA 0.58.0 command form.
