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
    "output": "destination Local or Shared Tile",
    "input0": "source Local or Shared Tile",
    "input1": "compile-time SharedMoveMode when Shared participates",
    "input2": null
  },
  "dtypes": ["byte-preserving; descriptors must be compatible"],
  "encoding": {
    "block": "TLSU",
    "function": 2,
    "shared_functions": [8, 9, 10, 11]
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

Ordinary PTO `TMOV(dst,src)` remains a Local Tile move/conversion. DavinciOO v5 adds strongly typed Local↔Shared forms under the same intrinsic name; no `_SHARED` operation is introduced.

```cpp
enum class SharedMoveMode { Insert, Publish, Broadcast, Extract };

TMOV<SharedMoveMode::Insert>(sharedDst, localSrc);
TMOV<SharedMoveMode::Publish>(sharedDst, localSrc);
TMOV<SharedMoveMode::Broadcast>(localDst, sharedSrc);
TMOV<SharedMoveMode::Extract>(localDst, sharedSrc);
```

The mode is mandatory and compile-time whenever either operand is Shared.

## Ordinary Local Form

```asm
BSTART.TLSU TMOV, FP16
B.DIM       rValidCol, 0, ->LB0
B.DIM       rValidRow, 0, ->LB1
B.DIM       rCol, 0, ->LB2
B.IOT       T#1, mask=1111, last, ->T<4KB>
```

It performs four asynchronous Local fragment moves under the ordinary distributed logical-Tile contract.

## Shared Modes

| Mode | TLSU Function | Direction | Size relation |
| --- | ---: | --- | --- |
| Insert | 8 | Local→Shared partial insert | Shared `S = L` |
| Publish | 9 | Local→Shared publication | Shared `S = L` |
| Broadcast | 10 | Shared→selected Local full payload | Local logical `L = 4S` |
| Extract | 11 | Shared fixed region→Local | Local logical `L = S` |

`L` is `B.IOT.TSize`; `S` is the Shared physical-version size. Insert/Publish require nonzero `TSize` even without a Local destination.

```asm
BSTART.TLSU TMOV.L2S.INSERT, FP16
C.B.IOS     S#17
B.IOT       T#1, mask=1100, TSize=4KB, last

BSTART.TLSU TMOV.S2L.BROADCAST, FP16
C.B.IOS     S#17
B.IOT       mask=1111, last, ->T<16KB>
```

## Version Semantics

Insert/Publish create or complete a new Shared SSA/version with an immutable static `defined_mask`. Broadcast waits for a fully-defined version. Extract reads only the current PE's fixed region. A broadcast may leave equal Local payloads on multiple PEs, but this is not a `Replicated4` Tile type.

## 约束与合法性

- Shared→Shared TMOV is absent in v5; copy/transform through Local Tile.
- Runtime mode, owner or size is illegal.
- Partial Shared values may be moved or partition-stored but not used by CUBE compute or Broadcast.
- `PE_MASK` selects destination/local payloads but does not reduce Shared source-ready or collective participation requirements.
- Shared IDs and versions are compiler-managed; C++ cannot specify `S#n`.
- `RecordEvent` is reused; there is no `SharedEvent`, and event completion is not a cross-PE GM fence.

## Lowering 摘要

The verifier resolves operand storage and mode, derives static size/mask relations, allocates/binds a Shared version and emits Function 8–11 with `C.B.IOS+B.IOT`. The binder is consumed by the companion and never remains sticky.
