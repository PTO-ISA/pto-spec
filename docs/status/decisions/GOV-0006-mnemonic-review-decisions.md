---
{
  "id": "ADR-GOV-0006",
  "title": "PTO mnemonic review decisions",
  "title_zh": "PTO 助记符审查决策",
  "status": "superseded",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-11",
  "accepted": "2026-08-11",
  "rejected": null,
  "superseded": "2026-08-21",
  "baseline": "4d115387b8a8a3c135f78189778d38547e75c697",
  "target_releases": [
    "0.58.1",
    "0.58.2"
  ],
  "affected_ndf": [],
  "affected_units": [],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [
    "ADR-BLOCK-0012",
    "ADR-BLOCK-0013",
    "ADR-BLOCK-0014",
    "ADR-MEM-0009",
    "ADR-CUBE-0009",
    "ADR-TILE-0008",
    "ADR-TILE-0009",
    "ADR-TILE-0010",
    "ADR-TILE-0011",
    "ADR-SCALAR-0006",
    "ADR-NUM-0012"
  ],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0062"
  ]
}
---
# ADR-GOV-0006: PTO mnemonic review decisions (historical summary)


## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

The repository-wide mnemonic audit originally concentrated unrelated decisions in one record. That made ownership and later revision difficult because a change to one family appeared to reopen the entire audit.

仓库级助记符审查最初把互不相关的决策集中在一条记录中。这使所有权和后续修订难以管理，因为单个指令族的变更看起来会重新打开整个审查。

### Detailed decision / 详细决策

This record remains a historical audit summary, while operative decisions are delegated to decision-scoped successor ADRs for Block, TLSU, CUBE, Tile, Scalar/SYS/queue, and numeric postprocess families. Legacy identities remain discoverable through aliases and the generated index.

本记录保留为历史审查摘要；实际生效的决策分配给面向具体范围的后继 ADR，分别覆盖 Block、TLSU、CUBE、Tile、Scalar/SYS/queue 和数值后处理指令族。旧身份仍可通过别名和生成索引查找。

### What changed / 改动内容

#### English

- Split operative mnemonic decisions among family-specific successor records.
- Preserved legacy identities for traceability without retaining a second semantic owner.
- Made later review and supersession local to each affected family.

#### 中文

- 将生效的助记符决策拆分到各指令族专属的后继记录。
- 保留旧身份用于追踪，但不保留第二语义 owner。
- 使后续审查和替代局限于相应指令族。

### Scope and boundaries / 范围与边界

This record explains an ownership transition. It does not restate successor semantics; current meaning comes from the linked decision-scoped ADRs and their owning ASL/NDF clauses.

本记录说明所有权迁移，不重述后继记录的语义；当前含义来自所链接的决策范围 ADR 及其 owning ASL/NDF 条款。
## Historical audit provenance

The mnemonic audit was accepted on 2026-08-11. It reviewed all 634 active PTO
mnemonics and all 40 occupied extension reservations. Coverage counted a
mnemonic when either this audit or an earlier accepted architecture ADR owned
its family decision; mnemonic-local duplicate decisions were not required.

At the audit freeze, coverage was therefore 634/634 active mnemonics and 40/40
occupied reservations. The reviewed conditional-branch change moved eight
families from the active inventory to the reservation inventory without
changing total reviewed coverage. Audit coverage remained distinct from later
formal implementation closure measured by per-ASL `PTO-REVIEW` records and the
compatibility audit tooling.

The contemporaneous binary projection contained 466 Scalar forms and 74 active
Block forms, for 540 active encoded forms, plus 40 occupied extension
reservations. These totals are historical evidence, not the current release
inventory; generated catalogs and release evidence remain authoritative.

## Successor decision records

The 183 operative mnemonic decisions and their legacy identities are now owned
by the following decision-scoped records:

- [ADR 0075](BLOCK-0012-block-attributes-and-lifecycle.md) — Block attributes and lifecycle
- [ADR 0076](BLOCK-0013-block-scalar-and-tile-bindings.md) — Block scalar and tile bindings
- [ADR 0077](BLOCK-0014-block-start-and-extension-reservations.md) — Block start and extension reservations
- [ADR 0078](MEM-0009-tlsu-and-global-memory-operations.md) — TLSU and global-memory operations
- [ADR 0079](CUBE-0009-cube-and-matrix-operations.md) — CUBE and matrix operations
- [ADR 0080](TILE-0008-tile-elementwise-and-irregular-operations.md) — Tile elementwise and irregular operations
- [ADR 0081](TILE-0009-tile-scalar-and-immediate-operations.md) — Tile scalar and immediate operations
- [ADR 0082](TILE-0010-tile-reduction-expansion-and-generation.md) — Tile reduction, expansion, and generation
- [ADR 0083](TILE-0011-tile-conversion-layout-and-partial-operations.md) — Tile conversion, layout, and partial operations
- [ADR 0084](SCALAR-0006-scalar-system-and-queue-operations.md) — Scalar, system, and queue operations
- [ADR 0085](NUM-0012-numeric-postprocess-and-format-operations.md) — Numeric post-process and format operations

This record is historical provenance only and owns no current semantic impact
or legacy identifier.
