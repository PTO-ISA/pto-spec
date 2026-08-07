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
    "shared_functions": [9, 10, 11, 12]
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
| Insert | 9 | Local→Shared masked atomic update | Shared `S = L` |
| Publish | 10 | Local→Shared masked atomic update | Shared `S = L` |
| Broadcast | 11 | Shared→selected Local quarters | Local logical `L = S` |
| Extract | 12 | Shared→selected Local quarters | Local logical `L = S` |

`L` is the Local operand's `B.IOT.TSize`; `S` is `B.IOS.TSize`. For
Local-to-Shared, the destination size is carried by `B.IOS`; for
Shared-to-Local, the Local destination capacity is carried by `B.IOT`.

```asm
BSTART.TLSU TMOV.L2S.INSERT, FP16
B.IOS       mask=1100, ->S17<4KB>
B.IOT       T#1, mask=1100, last

BSTART.TLSU TMOV.S2L.BROADCAST, FP16
B.IOS       S17, mask=0101
B.IOT       mask=0101, last, ->T<4KB>
```

## Register Semantics

Insert/Publish perform atomic descriptor-plus-payload RMW. A first nonzero
write establishes the descriptor and immutable allocation mask; later writes
require descriptor compatibility, may select only a subset of that mask, and
preserve unselected PE regions. Expansion requires a newly allocated `Sx`.
Broadcast/Extract read selected fixed-offset PE regions; uninitialized selected
data follows undefined-register semantics.

## 约束与合法性

- Shared→Shared TMOV is absent in v5; copy/transform through Local Tile.
- Runtime mode, owner or size is illegal.
- `PE_MASK` is a four-bit quarter predicate; multiple bits are allowed and
  `0000` is a no-op.
- Absolute Shared registers are compiler-managed; C++ cannot specify `Sx`.
- `RecordEvent` is reused; there is no `SharedEvent`, and event completion is not a cross-PE GM fence.

## Lowering 摘要

The verifier resolves operand storage and mode, derives size/mask relations,
allocates/binds an absolute Shared register and emits Function 9–12 with
direction-correct `B.IOS+B.IOT`. The binder is consumed once.
