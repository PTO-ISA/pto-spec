---
{
  "schema_version": 1,
  "id": "intrinsic.mgather_cas",
  "kind": "intrinsic",
  "title": "MGATHER_CAS Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": { "davincioo": "MGATHER_CAS.md" },
  "opcode": "MGATHER_CAS",
  "family": "memory-tlsu",
  "bundle": "BSTART.MGATHER.CAS DataType\nB.IOT\nB.IOR base_address",
  "operands": {
    "output": "old-value destination tile",
    "input0": "base address\nindices tile",
    "input1": "expected tile",
    "input2": "replacement tile"
  },
  "dtypes": ["TLSU atomic data types accepted by BSTART.MGATHER.CAS"],
  "encoding": { "block": "TLSU", "function": 8 },
  "xlsx": {
    "include": true,
    "category": "Tile Memory Operation\nTile级访存操作",
    "subcategory": "原子不规则访存",
    "order": 83,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# MGATHER_CAS Intrinsic

## PTO 语义来源

`MGATHER_CAS` performs an atomic compare-and-swap for every indexed lane. The
old memory value is always returned in the destination Tile. Memory is replaced
only when the old value equals the lane's expected value, and an atomic event is
recorded for both successful and failed comparisons.

```asm
BSTART.MGATHER.CAS U32
B.IOT              T#1, T#2, T#3, mask=1111, last, ->T<1KB>
B.IOR              a0, zero
```

## 约束与合法性

- Destination and index Tiles must have equal logical shape.
- Expected and replacement Tiles must match the destination shape and dtype.
- Read and write translation must resolve to the same address for each lane;
  otherwise the operation raises a precise data-page fault.
- Each lane is an atomic read-modify-write using the current bundle memory-order
  attribute. No stronger order between different lanes or PEs is guaranteed.
- `BSTART.MGATHER.CAS` is an accepted PTO ISA 0.58.0 command form.
