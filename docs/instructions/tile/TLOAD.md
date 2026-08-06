---
{
  "schema_version": 1,
  "id": "intrinsic.tload",
  "kind": "intrinsic",
  "title": "TLOAD Intrinsic",
  "status": "mapped",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "TLOAD.md",
    "pto": "tile/ops/memory-and-data-movement/tload.md"
  },
  "opcode": "TLOAD",
  "family": "memory-tlsu",
  "bundle": "Local form\nBSTART.TLSU TLOAD\nB.DATR/B.DIM\nB.IOT\nB.IOR\nShared form\nBSTART.TLSU TLOAD\nB.DATR/B.DIM\nB.IOS\nB.IOR",
  "operands": {
    "output": "Local tile or SharedTile destination",
    "input0": "full logical GlobalTensor/partition-view source",
    "input1": "base, row stride, pad/layout attributes",
    "input2": "Shared full form requires exactly-one issuer"
  },
  "dtypes": [
    "PTO TLOAD dtype/layout combinations supported by the v5 TLSU profile"
  ],
  "encoding": {
    "block": "TLSU",
    "function": 0
  },
  "xlsx": {
    "include": true,
    "category": "Tile Memory Operation\nTile级访存操作",
    "subcategory": "规则访存",
    "order": 76,
    "description_section": "PTO 语义来源",
    "constraints_section": "约束与合法性"
  }
}
---
# TLOAD Intrinsic

## PTO 语义来源

- PTO source: `tile/ops/memory-and-data-movement/tload.md`

```cpp
template <typename TileData, typename GlobalData, typename... WaitEvents>
PTO_INST RecordEvent TLOAD(TileData &dst, GlobalData &src, WaitEvents &... events);
```

PTO `TLOAD` asynchronously transfers the destination valid rectangle from a `GlobalTensor`. DavinciOO v5 keeps this name and adds `SharedTile` as a destination storage class; it does not add `TLOAD_SHARED`.

```cpp
TLOAD(localDst, fullLogicalTensor);
TLOAD(sharedDst, fullLogicalTensor); /* exactly-one issuer */
```

## Local Logical-Tile Form

The source is a full logical `GlobalTensor` descriptor. The compiler combines
its static distribution and `thread_id` to derive each selected PE's fragment
address. `B.IOT.TSize=001..111` encodes 128 B–8 KiB per selected PE; core
allocation is `popcount(PE_MASK)` times that size.

```asm
BSTART.TLSU TLOAD, FP16
B.DIM       rValidCol, 0, ->LB0
B.DIM       rValidRow, 0, ->LB1
B.DIM       rCol, 0, ->LB2
B.IOT       mask=1111, last, ->T<4KB>
B.IOR       a0, a1, 0
```

## GM-to-Shared Full Form

The destination is one absolute Core-local Shared register. `B.IOS` carries the
per-PE size and `PE_MASK` fixed-offset PE predicate. `0000` is a strict no-op;
there is no mask-only `B.IOT` companion.

```asm
BSTART.TLSU TLOAD, FP16
B.DIM       rValidCol, 0, ->LB0
B.DIM       rValidRow, 0, ->LB1
B.DIM       rCol, 0, ->LB2
B.IOS       mask=0101, ->S17<4KB>
B.IOR       a0, a1, 0, ->0
```

`B.IOR` carries only the ordinary address operands in this schema;
`B.IOR.RegDst` is zero.

## Header Expansion

| Header | Role |
| --- | --- |
| `BSTART.TLSU` | Function 0 and main dtype |
| `B.DATR/B.DIM` | pad/layout and ValidCol/ValidRow/Col |
| `B.IOT` | Local destination, logical TSize and PE mask |
| `B.IOS` | Shared destination ID, per-PE TSize, and PE mask for GM→Shared form |
| `B.IOR` | base and row stride; RegDst is zero for Shared form |

## 约束与合法性

- Local and Shared destinations are distinguished by static type; no runtime storage switch is allowed.
- Shared TLOAD updates selected PE regions atomically. A first nonzero write
  establishes the descriptor and immutable allocation mask. Later writes must
  use a subset of that mask and a compatible descriptor; expansion requires a
  newly allocated `Sx`.
- The issuer pointer addresses the full object; it is not a per-PE fragment pointer.
- Shared `TSize` is 128 B–8 KiB per selected PE and cannot be implicit.
- GM alignment, dtype, layout, shape and valid-region constraints remain those of PTO TLOAD and the TLSU target.
- `RecordEvent` completion controls operation readiness but is not a cross-PE GM visibility fence.

## Lowering 摘要

The verifier first resolves destination storage. Local form emits
`B.IOT+B.IOR`. Shared form allocates a compiler-managed absolute S register and
emits destination `B.IOS+B.IOR`. The descriptor and selected payload PE regions
become visible at one atomic commit.
