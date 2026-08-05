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
  "bundle": "Local form\nBSTART.TLSU TLOAD\nB.DATR/B.DIM\nB.IOT\nB.IOR\nShared form\nBSTART.TLSU TLOAD\nB.DATR/B.DIM\nC.B.IOS\nB.IOR",
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

The source is a full logical `GlobalTensor` descriptor. The compiler combines its static distribution and `thread_id` to derive each participating PE's fragment address. Logical size is 512 B–32 KB and each PE writes one fixed quarter fragment.

```asm
BSTART.TLSU TLOAD, FP16
B.DIM       rValidCol, 0, ->LB0
B.DIM       rValidRow, 0, ->LB1
B.DIM       rCol, 0, ->LB2
B.IOT       mask=1111, last, ->T<4KB>
B.IOR       a0, a1, 0
```

## GM-to-Shared Full Form

Exactly one statically selected PE issues the full operation using its GM pointer. The Core sequencer automatically divides each 512 B stripe into four 128 B regions and creates one fully-defined Shared version.

```asm
BSTART.TLSU TLOAD, FP16
B.DIM       rValidCol, 0, ->LB0
B.DIM       rValidRow, 0, ->LB1
B.DIM       rCol, 0, ->LB2
C.B.IOS     S#17
B.IOR       a0, a1, 0, ->SharedTSize<4KB>
```

`B.IOR.RegDst[11:9]` carries nonzero SharedTSize only in this schema. No `B.IOT` destination exists.

## Header Expansion

| Header | Role |
| --- | --- |
| `BSTART.TLSU` | Function 0 and main dtype |
| `B.DATR/B.DIM` | pad/layout and ValidCol/ValidRow/Col |
| `B.IOT` | Local destination, logical TSize and PE mask |
| `C.B.IOS` | Shared destination ID for GM→Shared form |
| `B.IOR` | base, row stride and SharedTSize when applicable |

## 约束与合法性

- Local and Shared destinations are distinguished by static type; no runtime storage switch is allowed.
- Shared supports only the full exactly-one-issuer load; `TLOAD<pe_scope>`, partition load, gather/scatter and prefetch-to-Shared are illegal.
- The issuer pointer addresses the full object; it is not a per-PE fragment pointer.
- SharedTSize is 512 B–32 KB and cannot be implicit.
- GM alignment, dtype, layout, shape and valid-region constraints remain those of PTO TLOAD and the TLSU target.
- `RecordEvent` completion controls operation readiness but is not a cross-PE GM visibility fence.

## Lowering 摘要

The verifier first resolves destination storage. Local form emits `B.IOT+B.IOR` on distributed PE paths. Shared form proves exactly one issuer, allocates a compiler-managed Shared ID/version and emits `C.B.IOS+B.IOR`. Hardware waits/captures according to the ordinary event contract and publishes the Shared version only after all defined regions are ready.
