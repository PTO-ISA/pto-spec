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
  "bundle": "Local form\nBSTART.TLSU TSTORE\nB.DATR/B.DIM\nB.IOT\nB.IOR\nShared full form\nBSTART.TLSU Function 1\nC.B.IOS\nB.IOR\nShared pe_scope form\nBSTART.TLSU Function 12\nC.B.IOS\nB.IOR",
  "operands": {
    "output": "GlobalTensor/partition-view destination",
    "input0": "Local tile or SharedTile source",
    "input1": "base GPR\nrow-stride GPR\nordinary quantized-store scalar (optional)",
    "input2": "default full/core or compile-time pe_scope"
  },
  "dtypes": [
    "PTO TSTORE dtype/layout combinations supported by the v5 TLSU profile"
  ],
  "encoding": {
    "text": "TLSU Function 1; Shared pe_scope Function 12;"
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

PTO `TSTORE` writes the source valid rectangle to a `GlobalTensor`. DavinciOO v5 retains the same family and overloads source storage/scope:

```cpp
TSTORE(fullLogicalTensor, localSrc);
TSTORE(fullLogicalTensor, sharedSrc);            /* default full/core; exactly one issuer */
TSTORE<pe_scope>(perPeTensor, sharedSrc);         /* partition store */
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

The default Shared overload uses TLSU Function 1 and exactly one issuer. Size comes from the bound Shared descriptor; `B.IOR.RegDst` is zero.

```asm
BSTART.TLSU TSTORE, FP16
C.B.IOS     S17
B.IOT       mask=0101, last   /* optional */
B.IOR       a0, a1, 0
```

## Shared Partition Form

`TSTORE<pe_scope>` uses Function 12. The optional mask-only B.IOT chooses fixed
offset quarters; multiple bits are permitted and `0000` is a no-op. When B.IOT
is absent the effective mask is `1111`.

```asm
BSTART.TLSU TSTORE.SPART, FP16
C.B.IOS     S17
B.IOT       mask=0101, last
B.IOR       a0, a1, 0
```

## Completion And Ordering

Shared store completion means the request has been accepted and the source has been captured or pinned. It does not mean another PE's later GM load must observe the data. Use `SYNCALL<core_scope>()` when a cross-PE GM happens-before relation is required.

## 约束与合法性

- Bare Shared TSTORE is full/core and exactly-one issuer; `pe_scope` is the only partition form.
- Partition pointers are independent per PE and all written byte ranges must be non-overlapping.
- Full and partition Shared stores use zero `B.IOR.RegDst`; there is no runtime size or owner GPR.
- Reading an uninitialized selected quarter is legal and produces an
  undefined-register value without modifying the Shared descriptor.
- Source storage and scope are compile-time. Unsupported combinations are diagnostics, not runtime modes.
- GM alignment, dtype, layout, shape, atomic and ordinary quantized-store rules remain PTO/target-specific.

## Lowering 摘要

Local form emits `B.IOT+B.IOR`. Shared form emits source `C.B.IOS`, optional
mask-only `B.IOT`, and `B.IOR`. Programs must prevent overlapping concurrent
stores; the architecture provides no conflict detector or total order.
