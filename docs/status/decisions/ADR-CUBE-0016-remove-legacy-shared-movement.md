---
{
  "id": "ADR-CUBE-0016",
  "title": "Remove legacy Shared movement Functions",
  "title_zh": "移除旧式 Shared 搬运 Function",
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
    "PTO-ISA-LEGACY-SHARED-MOVEMENT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-BSTART-TMOV",
    "PTO-BLOCK-BSTART-TSTORE",
    "PTO-TILE-TMOV",
    "PTO-TILE-TSTORE",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/159",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0107"
  ]
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
