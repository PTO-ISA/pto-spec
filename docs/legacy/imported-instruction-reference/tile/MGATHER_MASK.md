---
{
  "schema_version": 1,
  "id": "intrinsic.mgather_mask",
  "kind": "intrinsic",
  "title": "MGATHER_MASK Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": { "davincioo": "MGATHER_MASK.md" },
  "opcode": "MGATHER_MASK",
  "family": "memory-tlsu",
  "bundle": "BSTART.MGATHER.MASK DataType\nB.DATR PadValue (optional)\nB.IOT\nB.IOR base_address",
  "operands": {
    "output": "destination tile",
    "input0": "base address\nindices tile",
    "input1": "mask tile",
    "input2": "masked-off pad value"
  },
  "dtypes": ["TLSU data types accepted by BSTART.MGATHER.MASK"],
  "encoding": { "block": "TLSU", "function": 6 },
  "xlsx": {
    "include": true,
    "category": "Tile Memory Operation\nTile级访存操作",
    "subcategory": "不规则访存",
    "order": 81,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# MGATHER_MASK Intrinsic

## PTO 语义来源

`MGATHER_MASK` gathers indexed memory elements for nonzero mask lanes. A zero
mask lane performs no memory access and writes the current bundle pad value to
the corresponding destination element. All selected addresses are probed
before any load event or destination update, preserving precise faults.

```asm
BSTART.MGATHER.MASK U32
B.DATR              PadValue.Zero
B.IOT               T#1, T#2, mask=1111, last, ->T<1KB>
B.IOR               a0, zero
```

## 约束与合法性

- Destination, index, and mask Tiles must have equal logical shape.
- Index and mask contents must be defined before execution.
- Masked-off lanes do not access memory; selected lanes use the current bundle
  memory-order attribute.
- `BSTART.MGATHER.MASK` is an accepted PTO ISA 0.58.0 command form, not a
  future-reserved encoding.
