---
{
  "schema_version": 1,
  "id": "intrinsic.tstore",
  "kind": "intrinsic",
  "title": "TSTORE Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TSTORE.md",
    "pto": "tile/ops/memory-and-data-movement/tstore.md"
  },
  "opcode": "TSTORE",
  "family": "memory-tlsu",
  "bundle": "Local form\nBSTART.TLSU TSTORE\nB.DATR/B.DIM\nB.IOT\nB.IOR\nShared form\nBSTART.TLSU Function 1\nB.IOS\nB.IOR",
  "operands": {
    "output": "GlobalTensor/partition-view destination",
    "input0": "Local tile or SharedTile source",
    "input1": "base-byte-address GPR\nbyte-row-stride GPR\nordinary quantized-store scalar (optional)",
    "input2": null
  },
  "dtypes": [
    "PTO TSTORE dtype/layout combinations supported by the v5 TLSU profile"
  ],
  "encoding": {
    "text": "TLSU Function 1"
  },
  "xlsx": {
    "include": true,
    "category": "Tile Memory Operation\nTile级访存操作",
    "subcategory": "规则访存",
    "order": 77,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TSTORE Intrinsic

## PTO 语义来源

- PTO source: `tile/ops/memory-and-data-movement/tstore.md`

```cpp
template <typename TileData, typename GlobalData, AtomicType atomicType = AtomicType::AtomicNone,
          typename... WaitEvents>
PTO_INST RecordEvent TSTORE(GlobalData &dst, TileData &src, WaitEvents &... events);
```

PTO `TSTORE` writes the source valid rectangle to a `GlobalTensor`. DavinciOO
v5 retains the same family and allows Local or Shared source storage:

```cpp
TSTORE(fullLogicalTensor, localSrc);
TSTORE(fullLogicalTensor, sharedSrc);
```

## Local Logical-Tile Form

The compiler derives each PE's fragment address from the full logical descriptor and static distribution.

```asm
BSTART.TLSU TSTORE, FP16
B.DIM       rValidCol, 0, ->LB0
B.DIM       rValidRow, 0, ->LB1
B.DIM       rCol, 0, ->LB2
B.IOT       T#1, mask=1111, last
B.IOR       a0, a1, 0
```

## Shared Full/Core Form

The Shared overload uses TLSU Function 1. Size comes from the bound Shared
descriptor; `B.IOR.RegDst` is zero. Each participating PE uses its own GPR
base byte address and byte row-stride registers.

```asm
BSTART.TLSU TSTORE, FP16
B.IOS       S17, mask=0101
B.IOR       a0, a1, 0
```

## Completion And Ordering

Shared store completion means the request has been accepted and the source has been captured or pinned. It does not mean another PE's later GM load must observe the data. Use `SYNCALL<core_scope>()` when a cross-PE GM happens-before relation is required.

For byte-sized or wider elements, coordinate `(row, column)` accesses
`base + row * stride_bytes + column * element_size_bytes`. Packed four-bit
elements use `base + row * stride_bytes + floor(column / 2)` and preserve the
sibling nibble. Omitted B.IOR selects the dense physical row width in bytes;
encoded zero stride remains zero.

## 约束与合法性

- Each selected PE uses its own private GPR base and row stride. Programs must
  ensure the resulting GM byte ranges do not conflict; the architecture does
  not impose an order between participating PEs.
- Shared stores use zero `B.IOR.RegDst`; source size comes from the descriptor.
- Reading an uninitialized selected quarter is legal and produces an
  undefined-register value without modifying the Shared descriptor.
- Source storage and scope are compile-time. Unsupported combinations are diagnostics, not runtime modes.
- GM alignment, dtype, layout, shape, atomic and ordinary quantized-store rules remain PTO/target-specific.

## Lowering 摘要

Local form emits `B.IOT+B.IOR`. Shared form emits source `B.IOS+B.IOR`.
Programs must prevent overlapping concurrent
stores; the architecture provides no conflict detector or total order.
