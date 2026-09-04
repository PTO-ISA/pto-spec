---
{
  "id": "ADR-BLOCK-0007",
  "title": "Complete-Bundle GPR Operand Resolution",
  "title_zh": "完整 Bundle 的 GPR 操作数解析",
  "status": "accepted",
  "authors": [
    "ckwllawliet <641433195@qq.com>"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-08-10",
  "accepted": "2026-08-10",
  "rejected": null,
  "superseded": null,
  "baseline": "3b8cd26c600f0939a143422f175a19cc3ed2999b",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-B-IOR-BINDING-001",
    "PTO-TCI-CONTRACT-001",
    "PTO-TTRI-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-IOR",
    "PTO-TILE-TCI",
    "PTO-TILE-TTRI"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/60",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0058"
  ]
}
---
# ADR-BLOCK-0007: Complete-Bundle GPR Operand Resolution

- **Date**: 2026-08-10
- **Deciders**: PTO ISA maintainers
- **Issue**: [#60](https://github.com/PTO-ISA/pto-spec/issues/60)

## Context

ADR 0055 established complete-bundle `B.IOR` omission and encoded-zero
semantics, but its consumer description did not close the operation controls
advertised by `TCI`, `TTRI`, `TSORT`, and `TMRGSORT`. The bridge therefore left
`flag0` and `diagonal` at their operation defaults even when a complete bundle
encoded those inputs, and field-name membership could report an operation as
representable without proving a resolver.

## Decision

The complete-bundle bridge packs consumed B.IOR GPR inputs in this fixed
logical order: `address`, `scalar0`, `scalar1`, `diagonal`, `flag0`. Fields not
present in the selected operation are removed before packing into `RegSrc0`
through `RegSrc2`. The affected mappings are:

| Operation | `RegSrc0` | `RegSrc1` |
| --- | --- | --- |
| TCI | `start` | `descending` |
| TTRI | `diagonal` | `upper` |
| TSORT | `descending` | — |
| TMRGSORT | `descending` | — |

`start` is an XLEN Word. `diagonal` is decoded as an XLEN two-complement
signed value and is legal only in `-65535..65535`. `descending` and `upper`
accept exactly raw zero or one. Other raw boolean values and out-of-range
diagonals fault with `Fault_TileLegality` before destination resolution or any
Tile effect. The operation defaults remain TCI `(0,FALSE)`, TTRI `(0,FALSE)`,
and FALSE for both sorting operations.

The bridge is fail-closed: every accepted operand must have a concrete
resolver or explicit default and a raw-value decode policy. Nonzero surplus
B.IOR fields and `RegDst` reject; an encoded zero remains a real zero selector;
a second B.IOR faults without replacing the first. `PE_MASK=0000` exits before
all GPR reads, validation, allocation, faults, and Tile updates.

The representability gate derives and records the concrete dense slot for each
GPR field. It rejects duplicate operand fields, duplicate assigned slots, and
any accepted operation requiring more than three GPR inputs; it never reports
such an operation as representable. Independent evidence executes the decoded
bundle through `BSTART`, `B.IOR`, `B.IOT`, and `BSTOP` so fault identity,
destination preservation, zero-mask suppression, and observable operation
results are covered at the architectural commit boundary.

TSORT and TMRGSORT retain their v0.58 direct-binary ordering contracts:
TSORT ties remain stable, TMRGSORT ties select the left source first, and both
require sources pre-sorted in the selected direction without adding payload
sortedness validation.

## Consequences

The ASL bundle schema resolves and validates raw controls before constructing
constrained `TileInstructionOperands` or allocating destinations. Catalog,
Markdown, independent AVS, totality evidence, and release traceability remain
projected from the existing four-surface owners; operation count, selectors,
and the reviewed binary ABI are unchanged.

ADR 0055 remains authoritative for B.IOR presence, encoded-zero rendering,
field encoding, and omission defaults except for this narrow consumer-resolution
refinement.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Several complete-Bundle consumers needed a precise rule for resolving GPR selectors after the common `B.IOR` schema was established. Without a consumer-specific resolution point, omission, aliasing, and preflight could differ between operations.

在通用 `B.IOR` 模式确定后，若干完整 Bundle 消费者仍需要精确的 GPR selector 解析规则。缺少面向消费者的解析点时，各操作对省略、别名和预检的处理可能不一致。

### Detailed decision / 详细决策

The affected `TCI`, `TSORT`, `TMRGSORT`, and `TTRI` contracts resolve their declared GPR operands through the complete operation schema. Resolution occurs within preflight, uses the existing absolute selector and encoded-zero rules, and preserves bindings on rejection. The common B.IOR encoding and ABI remain unchanged.

受影响的 `TCI`、`TSORT`、`TMRGSORT` 和 `TTRI` 契约通过完整操作模式解析其声明的 GPR 操作数。解析发生在预检中，沿用既有绝对 selector 与编码零规则，并在拒绝时保留绑定。通用 B.IOR 编码和 ABI 不变。

### What changed / 改动内容

#### English

- Bound the listed Tile consumers to one explicit GPR-resolution path.
- Closed rejection and binding-preservation behavior without changing encoding.

#### 中文

- 将所列 Tile 消费者绑定到唯一明确的 GPR 解析路径。
- 在不改变编码的情况下闭合拒绝与绑定保留行为。

### Scope and boundaries / 范围与边界

ADR-BLOCK-0005 still owns B.IOR presence, field encoding, and omission defaults. This refinement changes only how the listed consumers use that established contract.

ADR-BLOCK-0005 仍管理 B.IOR 的存在性、字段编码和省略默认值；本细化仅改变所列消费者如何使用该既有契约。
