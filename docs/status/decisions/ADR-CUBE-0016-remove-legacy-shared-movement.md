---
{
  "id": "ADR-CUBE-0016",
  "title": "Remove legacy Shared movement Functions",
  "title_zh": "\u79fb\u9664\u65e7\u5f0f Shared \u642c\u8fd0 Function",
  "status": "accepted",
  "authors": [
    "PTO ISA maintainers"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-08-26",
  "accepted": "2026-08-26",
  "rejected": null,
  "superseded": null,
  "baseline": "5114fb699fa510abd9a3c42bcfa5c592cd724961",
  "target_releases": [
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-ISA-LEGACY-SHARED-MOVEMENT-001",
    "PTO-BSTART-TMOV-SHARED-001",
    "PTO-TMOV-CONTRACT-001",
    "PTO-INST-BLOCK-BSTART-TMOV",
    "PTO-B-DATR-FIELDS-001",
    "PTO-CUBE-CELL-TRANSPORT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-BSTART-TMOV",
    "PTO-BLOCK-BSTART-TSTORE",
    "PTO-TILE-TMOV",
    "PTO-TILE-TSTORE",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES",
    "PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION-PE-REQUESTS",
    "PTO-BLOCK-MODEL-STATE-SHARED-GENERATION",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TMOV-CUBE-TO-ND",
    "PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA",
    "PTO-BLOCK-MODEL-STATE-CONTROL-STATE",
    "PTO-TILE-MODEL-MEMORY-SHARED-CUBE-TO-ND"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/159",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0107"
  ],
  "amendments": [
    {
      "date": "2026-10-20",
      "baseline": "b0165320a4b575b18d2f4d93faf40178f661ab49",
      "approvers": [
        "ckwllawliet <641433195@qq.com>"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/395",
      "affected_ndf": [
        "PTO-TMOV-CONTRACT-001",
        "PTO-BSTART-TMOV-SHARED-001",
        "PTO-ISA-LEGACY-SHARED-MOVEMENT-001",
        "PTO-INST-BLOCK-BSTART-TMOV",
        "PTO-CUBE-CELL-TRANSPORT-001",
        "PTO-B-DATR-FIELDS-001"
      ],
      "affected_units": [
        "PTO-BLOCK-B-DATR",
        "PTO-BLOCK-BSTART-TMOV",
        "PTO-BLOCK-MODEL-DISPATCH-COMMAND-DATA-ATTRIBUTES",
        "PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY",
        "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
        "PTO-BLOCK-MODEL-DISPATCH-TLSU-LAYOUT-CONVERSION",
        "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
        "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION-PE-REQUESTS",
        "PTO-BLOCK-MODEL-STATE-SHARED-GENERATION",
        "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
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

# ADR-CUBE-0016: Remove legacy Shared movement Functions

## Decision

The independent Shared movement Functions 9, 10, 11, 12, and 14 are removed
from the accepted ISA/TLSU operation set. Their encodings are reserved and
raise `Fault_IllegalInstruction` in the 0.58.5 candidate.

Canonical lowering is:

- Shared to GM: `TSTORE` with optional `B.SUBVIEW`.
- Local to Shared: ordinary `TMOV` with optional `B.ASSEMBLE`.
- Shared to Local: ordinary `TMOV` with optional `B.SUBVIEW`.
- Function 13 `GMOV` remains unchanged.

A source-level frontend may retain sugar only when it lowers mechanically to
these canonical forms without quarter selection, defined-mask semantics, or
independent readiness/publication behavior.

## Consequences

Operation identity, decoder witnesses, catalogs, documentation, and AVS
closure must no longer accept the removed variants. The canonical forms share
the parent-level readiness and explicit range rules above.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Independent legacy Shared movement functions duplicated ordinary
TSTORE/TMOV paths and carried incompatible quarter and readiness assumptions.
One canonical lowering keeps movement under the parent-level rules.

**中文。** 独立旧式 Shared 搬运 Function 与普通 TSTORE/TMOV 重复，并携带不兼容
的 quarter 与就绪假设。统一 canonical lowering 可让搬运遵循父对象级规则。

### Detailed decision / 详细决策

**English.** Functions 9, 10, 11, 12, and 14 become reserved-illegal. Shared
to GM lowers to TSTORE plus optional SUBVIEW; Local to Shared and Shared to
Local lower to TMOV plus ASSEMBLE or SUBVIEW. Function 13 GMOV remains.

**中文。** Function 9、10、11、12、14 改为保留非法。Shared-to-GM 降低为
TSTORE 加可选 SUBVIEW；Local-to-Shared 与 Shared-to-Local 降低为 TMOV 加
ASSEMBLE 或 SUBVIEW。Function 13 GMOV 保持不变。

### What changed / 改动内容

#### English

- Removed five operation identities from accepted decode and catalogs.
- Defined canonical movement sequences using ordinary TSTORE and TMOV.
- Required frontend sugar to preserve explicit range and readiness semantics.

#### 中文

- 从接受 decode 与目录中移除五个操作标识。
- 用普通 TSTORE/TMOV 定义 canonical 搬运序列。
- 要求前端语法糖保持显式范围与就绪语义。

### Scope and boundaries / 范围与边界

**English.** The removal does not change GMOV and creates no new quarter,
defined-mask, or publication behavior. It also does not define new payload,
readiness, allocation, or fault semantics beyond the referenced canonical
TSTORE and TMOV paths.

**中文。** 此移除不改变 GMOV，也不创建新的 quarter、defined-mask 或发布行为。
它也不在所引用的 canonical TSTORE 与 TMOV 路径之外定义新的 payload、就绪、
分配或故障语义。

## Accepted amendment: issue #395 — Canonical TMOV layout extension with explicit assembly

Accepted on 2026-10-20 by ISA owner `ckwllawliet`, through explicit answers
in the contract-freeze review, against baseline `b0165320a4b575b18d2f4d93faf40178f661ab49`.
Linked requirement: [issue #395](https://github.com/PTO-ISA/pto-spec/issues/395).

**English — rationale and scope.** The owner accepted Local M16/M32 to Shared ND conversion through canonical Function-2 TMOV with Layout M162ND/M322ND and explicit B.ASSEMBLE ranges, one mode per generation and existing atomic parent publication. Reusing existing operation and layout selectors avoids reviving removed Shared Functions. Exact-capacity geometry is implemented first as a separately reviewable change under issue #395, followed by the TMOV extension; no separate predecessor issue or already-landed PR is required.

**中文 — 原因与范围。** Owner 已确认通过 canonical Function-2 TMOV、M162ND/M322ND Layout 与显式 B.ASSEMBLE range 实现 Local M16/M32 到 Shared ND 转换，同一 generation 使用同一模式并沿用父对象原子发布。复用既有 operation/layout selector，不恢复已移除 Shared Function。精确容量几何先作为 #395 下可单独审查的变化实施，再实现 TMOV；不要求额外前置 issue 或已落地 PR。

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
