---
{
  "id": "ADR-CUBE-0005",
  "title": "GM/Local CUBE Layout Transport",
  "title_zh": "GM/Local CUBE \u5e03\u5c40\u4f20\u8f93",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-20",
  "accepted": "2026-08-20",
  "rejected": null,
  "superseded": null,
  "baseline": "e9e9934f3cd4e857f44482f5e86779fd726d1733",
  "target_releases": [
    "0.58.3",
    "0.59.0"
  ],
  "affected_ndf": [
    "PTO-B-DATR-FIELDS-001",
    "PTO-BSTART-TLOAD-CUBE-001",
    "PTO-BSTART-TLOAD-MEMORY-001",
    "PTO-BSTART-TSTORE-CUBE-001",
    "PTO-BSTART-TSTORE-MEMORY-001",
    "PTO-CUBE-AUX-CELLREG-001",
    "PTO-CUBE-CELL-STATE-001",
    "PTO-CUBE-CELL-TRANSPORT-001",
    "PTO-CUBE-M32-B64-DOUBLE-CELL-001",
    "PTO-TLOAD-CUBE-001",
    "PTO-TLOAD-MEMORY-001",
    "PTO-TSTORE-CUBE-001",
    "PTO-TSTORE-MEMORY-001",
    "PTO-INST-BLOCK-BSTART-TMOV",
    "PTO-BSTART-TMOV-SHARED-001",
    "PTO-TMOV-CONTRACT-001",
    "PTO-ISA-LEGACY-SHARED-MOVEMENT-001",
    "PTO-TMOV-CUBE-TO-SHARED-ND-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-BSTART-TLOAD",
    "PTO-BLOCK-BSTART-TSTORE",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS",
    "PTO-TILE-MODEL-SHAPE-CUBE-CELL",
    "PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TSTORE",
    "PTO-BLOCK-BSTART-TMOV",
    "PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES",
    "PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION-PE-REQUESTS",
    "PTO-BLOCK-MODEL-STATE-SHARED-GENERATION",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
    "PTO-TILE-TMOV",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TMOV-CUBE-TO-ND",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
    "PTO-BLOCK-MODEL-STATE-CONTROL-STATE",
    "PTO-TILE-MODEL-MEMORY-SHARED-CUBE-TO-ND"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/103",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0070"
  ],
  "amendments": [
    {
      "date": "2026-09-22",
      "baseline": "01445483d778b1bcfccba1641f71c20f00e39385",
      "approvers": [
        "ckwllawliet"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/339",
      "affected_ndf": [
        "PTO-CUBE-CELL-TRANSPORT-001",
        "PTO-CUBE-AUX-CELLREG-001"
      ],
      "affected_units": [
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION",
        "PTO-BLOCK-B-DATR",
        "PTO-TILE-MODEL-LEGALITY-MATRIX-POSTPROCESS"
      ]
    },
    {
      "date": "2026-10-03",
      "baseline": "e182c9b70d54a3a264bac54af9b915a0e43bb519",
      "approvers": [
        "Kevin Zhou <zhoubot@gmail.com>"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/371",
      "affected_ndf": [
        "PTO-CUBE-M32-B64-DOUBLE-CELL-001"
      ],
      "affected_units": [
        "PTO-TILE-MODEL-SHAPE-CUBE-CELL",
        "PTO-TILE-MODEL-SHAPE-CUBE-DOUBLE-CELL"
      ]
    },
    {
      "date": "2026-10-20",
      "baseline": "b0165320a4b575b18d2f4d93faf40178f661ab49",
      "approvers": [
        "ckwllawliet <641433195@qq.com>"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/395",
      "affected_ndf": [
        "PTO-CUBE-CELL-TRANSPORT-001",
        "PTO-B-DATR-FIELDS-001",
        "PTO-BSTART-TLOAD-CUBE-001",
        "PTO-TLOAD-CUBE-001",
        "PTO-INST-BLOCK-BSTART-TMOV",
        "PTO-BSTART-TMOV-SHARED-001",
        "PTO-TMOV-CONTRACT-001",
        "PTO-ISA-LEGACY-SHARED-MOVEMENT-001",
        "PTO-TMOV-CUBE-TO-SHARED-ND-001"
      ],
      "affected_units": [
        "PTO-BLOCK-B-DATR",
        "PTO-BLOCK-BSTART-TLOAD",
        "PTO-BLOCK-BSTART-TMOV",
        "PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES",
        "PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY",
        "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION",
        "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
        "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION-PE-REQUESTS",
        "PTO-BLOCK-MODEL-STATE-SHARED-GENERATION",
        "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
        "PTO-TILE-TLOAD",
        "PTO-TILE-TMOV",
        "PTO-BLOCK-MODEL-DISPATCH-SHARED-TMOV-CUBE-TO-ND",
        "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
        "PTO-BLOCK-MODEL-STATE-CONTROL-STATE",
        "PTO-TILE-MODEL-MEMORY-SHARED-CUBE-TO-ND"
      ]
    }
  ],
  "interface_change": true
}
---
# ADR-CUBE-0005: GM/Local CUBE Layout Transport

- Issue: [#103](https://github.com/PTO-ISA/pto-spec/issues/103)
- Umbrella: [#72](https://github.com/PTO-ISA/pto-spec/pull/72)
- Baseline: `15dcfc52b2710c28cf7a50da23057b0fcb9fd7c3`
- Requirement: `PTO-CUBE-CELL-TRANSPORT-001`
- Depends on: accepted `PTO-CUBE-CELL-STATE-001`

## Decision

`B.DATR.Layout` assigns six explicit GM/Local CUBE transformations:

| Code | Spelling | Legal operation | Direction |
| ---: | --- | --- | --- |
| 21 | `ND2M32` | `TLOAD` | GM ordinary to Local `CUBE_M32` |
| 22 | `ND2M16` | `TLOAD` | GM ordinary to Local `CUBE_M16` |
| 23 | `ND2N8` | `TLOAD` | GM ordinary to Local `CUBE_N8` |
| 24 | `M322ND` | `TSTORE` | Local `CUBE_M32` to GM ordinary |
| 25 | `M162ND` | `TSTORE` | Local `CUBE_M16` to GM ordinary |
| 26 | `N82ND` | `TSTORE` | Local `CUBE_N8` to GM ordinary |

Codes 21 through 23 are illegal for TSTORE. Codes 24 through 26 are illegal
for TLOAD. Shared TLOAD and TSTORE remain outside these Local-CUBE conversion
forms. Function-2 TMOV may use codes 24 and 25 to normalize a Local CUBE_M32 or
CUBE_M16 source into RowMajor ND Shared storage; code 26 has no Shared form.
Function-1 TSTORE with codes 24 and 25 retains its GM behavior. A recognized
but direction-incompatible conversion raises Tile legality before allocation,
source consumption, or memory effects.

## Raw representation

Conversion preserves the concrete Tile dtype and every valid element's raw
representation. It is a layout transform, not TCVT: it performs no numerical
rounding, saturation, canonicalization, widening, narrowing, or type change.

Every dtype with an assigned CUBE b32, b16, b8, or b4 mapping may use the
matching conversion when the operation's own dtype profile permits it.
`HiF4X2` and every b64 dtype reject because they have no legal CUBE CELL state.

## TLOAD behavior

GM-to-Local TLOAD derives the persistent destination layout from the selected
ND2* code and consumes logical dimensions from the operation's existing
dimension schema. Before the first effect it validates:

- exact conversion direction and Local destination form;
- dtype and CELL mapping;
- positive valid dimensions;
- derived CELL geometry and per-PE TSize capacity;
- base, byte row stride, and the complete valid GM footprint; and
- destination availability.

TLOAD reads GM only for valid logical elements. Physical CELL positions outside
the valid region receive the resolved PadValue and do not cause GM reads.
After all reads succeed, it atomically publishes the Local CUBE descriptor,
payload, and definedness state.

## TSTORE behavior

Local-to-GM TSTORE requires the source descriptor to match the selected M*2ND
or N82ND code. It preflights the complete valid destination footprint before
the first write. It writes only valid logical elements in ordinary GM order;
physical CELL padding positions never write memory.

TSTORE does not change the persistent Local descriptor, payload, or lifetime.

## Fault and restart ordering

Wrong direction, Shared participation, unsupported dtype, descriptor mismatch,
invalid dimensions, insufficient capacity, undefined valid source data, and
invalid memory footprints reject before effects. A recoverable memory fault
retries the first uncommitted access and does not duplicate allocation, source
effects, or preceding memory writes.

## Defaults and protected behavior

- Layout code zero retains the existing ordinary non-converting transfer.
- Omission never infers a CUBE conversion.
- GM/Shared remains ordinary base-plus-byte-row-stride transport.
- Existing byte-row-stride and packed-memory rules remain unchanged.
- PE mask zero remains a strict no-op before conversion and memory legality.

## Explicit exclusions

This decision defines no GM/Shared conversion, Local/Shared conversion,
in-place payload reinterpretation, CUBE-to-CUBE conversion, Matrix execution,
or new dimension command.

## Acceptance criteria

The accepted ASL, generated documentation, and independent decoded tests prove:

1. all six exact encodings and direction restrictions;
2. b32/b16/b8/b4 raw-bit round trips, including M16-b4 interleave;
3. multi-CELL K/N ordering and partial-tail PadValue behavior;
4. no GM access outside the valid region;
5. `HiF4X2`, b64, Shared, and wrong-direction rejection before effects;
6. first, middle, and last memory-fault rollback and exact restart; and
7. unchanged ordinary TLOAD/TSTORE behavior.

## Binary envelope consequence

The common encoded-form envelope remains exactly 540 forms. The only changed
fingerprinted input is the assigned-value constraint of the existing B.DATR
Layout field, which adds codes 21 through 26. No form identity, instruction
length, mask, match, field position, BSTART.TLOAD selector, or BSTART.TSTORE
selector changes.

The reviewed encoded-form fingerprint is rebound from
`129cb7812264b7e4c5edd088b5aedcc528966eb69c06879dc1919c85106e21b4` to
`b19b0cc84c9e033f0d74bddcaea82aa935f4000682ed184340481ebb34f46004`.
The release encoding projection is correspondingly rebound from
`9738fbfb67c90b90dacdae926c6ee206a2d517691ae27e5e5fc019702cc0e447` to
`882cdc54d00ff7670159f86942f4a4f48e637be4a04975813fda15dacc46f522`.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Software must move valid matrix elements between ordinary GM and
Local CUBE layouts without reinterpreting values or exposing padding.
Direction-specific codes make an accidental inverse transform reject.

**中文。** 软件必须在普通 GM 与 Local CUBE 布局之间搬运有效矩阵元素，且不重解释
数值或暴露 padding。区分方向的编码使误用反向转换时明确拒绝。

### Detailed decision / 详细决策

**English.** Six `B.DATR.Layout` values pair three ND-to-CUBE TLOAD transforms
with three CUBE-to-ND TSTORE transforms. They preserve raw representations,
preflight geometry and memory footprints, initialize only padding on load,
and never store padding. Precise memory restart rules remain in force.

**中文。** 六个 `B.DATR.Layout` 值由三种 ND-to-CUBE TLOAD 与三种 CUBE-to-ND
TSTORE 转换组成。它们保持原始表示，预检几何与内存 footprint；load 仅初始化
padding，store 从不写出 padding，并沿用精确内存重启规则。

### What changed / 改动内容

#### English

- Assigned layout codes 21 through 26 with exact directions.
- Added raw-bit GM/Local transport and valid-region-only access.
- Updated assigned-value encoding evidence without changing form identities.

#### 中文

- 分配布局编码 21 至 26 并规定精确方向。
- 增加保持 raw bit 的 GM/Local 传输及仅访问有效区域规则。
- 更新 assigned-value 编码证据，但不改变 form 标识。

### Scope and boundaries / 范围与边界

**English.** The transforms do not change dtype or numeric value and do not
define Shared or CUBE-to-CUBE conversion or Matrix execution.

**中文。** 转换不改变 dtype 或数值，也不定义 Shared、CUBE-to-CUBE 转换或矩阵执行。


## Amendment — 2026-09-22 (Issue #339)

The existing `ND2N8` TLOAD path accepts U64 and constructs a raw
representation-preserving Local `CUBE_N8/U64` parameter Tile. `ND2M16`,
`ND2M32`, `N82ND`, `M162ND`, and `M322ND` remain illegal for U64. No encoding
or other transport capability changes.


## Accepted amendment: issue #371 M32 double-CELL b64 storage

The maintainer selected explicit CUBE_M32 double-CELL storage for 64-bit Local elements under [issue #371](https://github.com/PTO-ISA/pto-spec/issues/371). The current geometry, low/high-word mapping, capacity, complete-pair views and publication are owned by `PTO-CUBE-M32-B64-DOUBLE-CELL-001` in the CUBE shape ASL. This amendment records the interface change and does not duplicate the executable contract.

It preserves the 128-byte physical CELL and 32-row M axis while making element width independent of logical lane identity. Existing M16/N8 and primary Matrix arithmetic contracts keep their own owners. Applicable Local instruction families must close their datatype, transport, predicate and effect behavior against this storage contract. Compatibility impact is newly accepted M32 b64 tuples; release impact is required, with commit-scoped AVS and downstream adoption obligations.

议题 #371 在既有 M32 行域和 128 字节 CELL 上引入 64 位 Local 元素的双 CELL 存储。低／高字、容量、完整配对视图和发布由 owning ASL/NDF 唯一规定；各 Local 指令族须闭合对应类型与效果。该变更不定义新的 M64 布局，也不替代既有 Matrix 运算合同。

## Accepted amendment: issue #395 — Canonical Local CUBE to Shared ND conversion

Accepted on 2026-10-20 by ISA owner `ckwllawliet`, through explicit answers
in the contract-freeze review, against baseline `b0165320a4b575b18d2f4d93faf40178f661ab49`.
Linked requirement: [issue #395](https://github.com/PTO-ISA/pto-spec/issues/395).

**English — rationale and scope.** The owner accepted canonical Function-2 TMOV with assigned M322ND/M162ND selectors. BSTART selects the carrier-compatible operation type; explicit DATR DataType is DTYPE_NONE. Source backing dtype and raw bits are retained. Implicit GM-load destination geometry adopts the exact-capacity owner, while existing GM transfer effects and stricter GM type preflight remain distinct. The behavior is owned by `PTO-TMOV-CONTRACT-001` and `PTO-BSTART-TMOV-SHARED-001`; APPLY implements normalized Shared fragments through the existing generation publisher.

**中文 — 原因与范围。** Owner 已确认 canonical Function-2 TMOV 使用既有 M322ND/M162ND selector。操作类型由 BSTART 选择，显式 DATR DataType 为 DTYPE_NONE，允许既有 carrier-compatible backing/operation 类型差异并保留源 backing 与原始位。隐式 GM load 目的几何遵循精确容量 owner，GM 搬运效果及其严格类型预检仍独立保留。该行为由 `PTO-TMOV-CONTRACT-001` 与 `PTO-BSTART-TMOV-SHARED-001` 约束；APPLY 通过既有 generation publisher 发布已归一化的 Shared fragment。

This is an accepted design for implementation. Current executable meaning
remains in the owning ASL/NDF until APPLY; this design record does not claim
implementation, AVS, PR or release validation. Compatibility is breaking for
formerly accepted M16/M32 allocation-slack inputs and changed producer/parent
physical geometry. TMOV adds legal forms without a new opcode. Release
impact is required after the review baseline; publication is not authorized.

**Type-code closure confirmed in the same owner review.** BSTART.TMOV adds
E6M2=15 and RCPE6M2=21 under existing carrier-compatible/source-only rules.
This expands the canonical command's legal DataType set, including otherwise
legal NORM carrier forms; it does not change fixed encoding fields or other
BSTART commands. New Local-CUBE-to-Shared forms keep DATR DataType=DTYPE_NONE
and retain source backing; RCPE6M2 is not persistent descriptor backing.

**同轮 owner 已确认的类型编码补全。** BSTART.TMOV 新增 E6M2=15 和
RCPE6M2=21，沿用既有 carrier-compatible/source-only 约束，并包含其余条件
合法的 NORM carrier 形态。此变化扩展该 canonical command 的合法 DataType
集合，不改变固定编码字段或其他 BSTART。新 Local CUBE 到 Shared 形态的
DATR DataType 仍为 DTYPE_NONE，保留源 backing；RCPE6M2 不作为持久 descriptor
backing。实现须更新 owner 白名单及派生 decoder/镜像/正反例。
