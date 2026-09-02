---
{
  "id": "ADR-NUM-0004",
  "title": "Numeric format namespace ownership",
  "title_zh": "数值格式命名空间归属",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-B-DATR-FIELDS-001",
    "PTO-CUBE-CELL-TRANSPORT-001",
    "PTO-NUMERIC-FINITE-DECOMPOSITION-001",
    "PTO-NUMERIC-FORMAT-DESCRIPTOR-001",
    "PTO-TCVT-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR",
    "PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS",
    "PTO-ARCH-DATA-TYPES-TILE-DATA-TYPES",
    "PTO-BLOCK-B-DATR",
    "PTO-TILE-TCVT"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0040"
  ]
}
---
# ADR-NUM-0004: Numeric format namespace ownership

> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Decision scope

Bit-exact formats, target availability, and operation/type legality remain open.

## Context

`ADR 0087` requires a complete bit-level format table and an operation/type/profile
legality matrix before target numeric conformance can close. PTO currently has
five distinct numeric type-code namespaces:

- two-bit scalar FSU source selectors;
- five-bit scalar floating destination selectors;
- five-bit scalar integer destination selectors;
- six-bit TLSU/TALLOC tile data-type selectors; and
- five-bit bundle `DataType` selectors.

Some numeric codes coincide across namespaces and others differ. For example,
TLSU/TALLOC code 2 denotes the raw `F16` carrier while bundle code 4 denotes
`F16`; `FP4` is mapped only in the TLSU/TALLOC namespace, while `E8M0` is mapped
only in the bundle namespace. Treating the integers as one shared encoding
would therefore change architectural behavior.

The PTO type system establishes visible names and widths but does not resolve
every operation-local ASL binding. In particular, the exact `FP8`, `FPL8`,
`FP4`, `FPL4`, and `E8M0` roles remain ambiguous or profile-dependent until
their owning PTO rules are accepted.

## Decision

The generated
`spec/evidence/numeric-format-namespace-contract.json` is the fail-closed
structural checkpoint for `ADR 0087`.

1. Numeric codes are namespace-local. Equality of code values across scalar,
   TLSU/TALLOC, and bundle namespaces has no architectural meaning unless a
   later accepted PTO decision explicitly maps them.
2. All 19 `TileDataType` identities and their raw storage widths are closed.
   Width and signedness are exact for integer carriers. Floating identities
   remain raw carrier names until their bit-exact format rules are accepted.
3. Scalar source selectors 0 and 1 select 64-bit and 32-bit raw carriers;
   selectors 2 and 3 reject before effects. Scalar floating and integer
   destination selectors 0 through 14 have the Stage 4 carrier widths recorded
   in `scalar-fsu-totality.json`; selectors 15 through 31 reject before effects.
4. The TLSU/TALLOC namespace contains 18 mapped and 46 reserved six-bit codes.
   `E8M0` is intentionally unmapped there. The bundle namespace contains 18
   mapped and 14 reserved five-bit codes. `FP4` is intentionally unmapped
   there. These are separate, total encoding tables rather than a conflict to
   hide with aliases.
5. `FP4`, `FPL4`, `S4`, and `U4` use the closed packed-memory rule: the even or
   low-index element occupies bits `[3:0]`, the odd or high-index element
   occupies bits `[7:4]`, loads zero-extend the selected nibble, and stores
   preserve the sibling nibble.
6. Unmapped codes reject before architectural effects. A helper fallback after
   a failed legality predicate is unreachable and does not create an
   architectural alias.

## Consequences

Reviewers can now distinguish every structural numeric namespace, carrier
width, mapped code, reserved code, and packed-four-bit rule without inferring
target arithmetic from a backend. The generated artifact and repository
checker fail on namespace, width, mapping, source-hash, or residual drift.

`ADR 0087` remains open. Closure still requires bit-exact floating layouts,
accepted bindings for specialized eight- and four-bit types, the architectural
role of `E8M0`, the complete scalar/tile operation/type/profile legality
matrix, target availability, and positive/reserved vectors for every accepted
tuple. This checkpoint does not increment the `S5-T2-A2` accepted-decision
count or promote maturity beyond M4.

ADR 0048 subsequently closes the bit-level value-classification checkpoint for
these carriers. It does not alter this ADR's namespace separation or accept a
complete ADR 0087 result decision.

## Evidence

- `spec/evidence/numeric-format-namespace-contract.json`
- `scripts/generate-numeric-format-namespace-contract`
- `spec/evidence/scalar-fsu-totality.json`
- `spec/evidence/tlsu-totality.json`
- `asl/types.asl`
- `asl/numeric/formats.asl`
- `docs/status/decisions/NUM-0009-numeric-format-value-classification.md`
- `asl/scalar/floating.asl`
- `asl/tile/state.asl`
- `asl/tile/memory.asl`
- `asl/bundle/dispatch.asl`
- `spec/evidence/numeric-format-namespace-contract.json`
- `spec/evidence/release-traceability-readiness.json`
- `tests/asl/tile/model/memory/load-store/tile-bound-tlsu-totality-001.asl`
- `docs/status/decisions/SCALAR-0004-scalar-fsu-totality-and-profile-boundary.md`
- `docs/status/decisions/MEM-0006-tlsu-four-bit-memory-packing.md`
- `docs/status/decisions/NUM-0001-numeric-profile-identity-and-variation-framework.md`

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Scalar, TLSU/TALLOC, and bundle type codes overlap numerically but
map differently. Treating them as one encoding would silently change types and
turn backend carriers into architecture.

**中文。** Scalar、TLSU/TALLOC 与 bundle 类型编码数值上有重叠但映射不同。将其
视为同一编码会静默改变类型，并把 backend carrier 变成架构规则。

### Detailed decision / 详细决策

**English.** Five namespaces remain local and total, with explicit mapped and
reserved codes, carrier widths, and packed four-bit order. Unmapped values
reject before effects; helper fallbacks create no aliases.

**中文。** 五个命名空间保持局部且完备，明确 mapped/reserved 编码、carrier 宽度
与四位 packing 顺序。未映射值在副作用前拒绝；helper fallback 不创建 alias。

### What changed / 改动内容

#### English

- Closed namespace-local code and carrier-width inventories.
- Fixed mapped/reserved distinctions and four-bit packing.
- Prevented implicit aliases across equal numeric codes.

#### 中文

- 闭合命名空间局部编码与 carrier 宽度清单。
- 固定 mapped/reserved 区分及四位 packing。
- 禁止相同数值编码形成隐式 alias。

### Scope and boundaries / 范围与边界

**English.** Bit-exact floating values and complete operation/type legality are
owned by later decisions, not inferred here. The namespace inventory also does
not establish target availability, conversion results, special-value behavior,
or numeric conformance.

**中文。** 位精确浮点值与完整操作/类型合法性由后续决策负责，不能在此推断。
