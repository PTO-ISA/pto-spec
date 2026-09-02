---
{
  "id": "ADR-NUM-0003",
  "title": "Numeric rounding selector ownership",
  "title_zh": "数值舍入选择器归属",
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
    "PTO-FCVTA-DECISION-BINDING-001",
    "PTO-FCVTM-DECISION-BINDING-001",
    "PTO-FCVTN-DECISION-BINDING-001",
    "PTO-FCVTP-DECISION-BINDING-001",
    "PTO-FCVTZ-DECISION-BINDING-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-ROUNDING",
    "PTO-BLOCK-B-DATR",
    "PTO-SCALAR-FCVT",
    "PTO-SCALAR-FCVTA",
    "PTO-SCALAR-FCVTM",
    "PTO-SCALAR-FCVTN",
    "PTO-SCALAR-FCVTP",
    "PTO-SCALAR-FCVTZ"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0039"
  ]
}
---
# ADR-NUM-0003: Numeric rounding selector ownership

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Decision scope

Semantic-selection and domain-rule portions are superseded by ADR 0047.
The mappings recorded below describe the pre-ADR-NUM-0008 inventory state. They are
not current semantics: scalar values 4–7 now resolve to RNE, and `FCVTA` now
selects RNA (nearest with ties away), as specified by ADR 0047.

## Context

`ADR 0047` requires one exact account of rounding taxonomy, selector encodings,
operation-local overrides, tie behavior, and rounding-versus-saturation order.
The existing PTO surface contains several different selector namespaces:

- scalar active rounding in `CORE_STATE[39:37]`;
- fixed rounding selected by `FCVTA`, `FCVTM`, `FCVTN`, `FCVTP`, and `FCVTZ`;
- the three-bit `RMode` field retained by `B.DATR`;
- public conversion modes, target matrix precision controls, quantization
  stochastic controls, and backend-only cast/part controls.

Shared widths or similar names do not prove that these namespaces have the
same encoding or result rule. PTO therefore defines each selector namespace
and every explicit mapping between namespaces in its own ASL.

## Decision

The generated
`spec/evidence/numeric-rounding-selector-contract.json` is the fail-closed
selector and owner inventory for `ADR 0047`.

1. Scalar FRM, scalar fixed conversion overrides, bundle `RMode`, public API
   modes, matrix controls, stochastic controls, and backend cast/part controls
   are distinct namespaces unless an accepted PTO rule maps them.
2. The portable mathematical core names RNE as nearest with ties to even, RTM
   as toward negative infinity, RTP as toward positive infinity, and RTZ as
   toward zero. RTA names away from zero for the fixed `FCVTA` override.
3. The five fixed scalar conversion mnemonics have closed selector ownership:
   `FCVTN` selects RNE, `FCVTM` selects RTM, `FCVTP` selects RTP, `FCVTZ`
   selects RTZ, and `FCVTA` selects RTA. Their operation/type results, range
   handling, and flags remain profile rules.
4. The current PTO-v0 scalar active path passes codes 0 through 4 to its
   profile hook and normalizes codes 5 through 7 to RNE. Whether code 4 is a
   globally selectable mode and whether codes 5 through 7 reject instead of
   falling back remain explicit `ADR 0047` decisions; this checkpoint does not
   silently choose either rule.
5. `B.DATR.RMode` has a closed three-bit encoding and state binding for all
   eight values. No numeric meaning is inferred from that binding. Each value
   requires a named profile rule before a numeric consumer may use it.
6. Every one of the 18 affected numeric domains, 102 operations, and 25 hooks
   has an explicit rounding-rule owner row. All domain rounding and
   saturation-order fields remain null until accepted rules exist.
7. Unknown or unmapped selectors and missing delegated rules reject before
   effects under ADR 0037. Backend fallback behavior cannot define a PTO
   result.

## Consequences

Selector discovery, namespace separation, fixed-override ownership, bundle
state binding, and affected-domain ownership are closed. Positive and negative
halfway tests cover the five mathematical rounding functions in PTO-v0.

At the time of this decision, `ADR 0047` remained open. Closure required an accepted disposition for
active FRM codes 4 through 7, exact mappings for public and target selector
classes, an accepted rule for all 18 domains, rounding-before-saturation
vectors, and any stochastic state or bounded-result contract. This decision
does not increment the `S5-T2-A2` accepted-decision count or promote maturity
beyond M4.

ADR 0047 subsequently accepts those rounding-selection and rounding-point
rules. The historical inventory and namespace-separation rationale in this
decision remain valid.

## Evidence

- `spec/evidence/numeric-rounding-selector-contract.json`
- `scripts/generate-numeric-rounding-selector-contract`
- `spec/evidence/numeric-profile-decision-inputs.json`
- `spec/evidence/scalar-fsu-totality.json`
- `spec/catalog/command-forms.json`
- `asl/scalar/floating.asl`
- `asl/scalar/dispatch.asl`
- `asl/bundle/state.asl`
- `asl/bundle/dispatch.asl`
- `tests/asl/arch/data-types/rounding/arch-static-rounding-contract-001.asl`
- `docs/status/decisions/ADR-SCALAR-0004-scalar-fsu-totality-and-profile-boundary.md`
- `docs/status/decisions/ADR-NUM-0001-numeric-profile-identity-and-variation-framework.md`

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Several three-bit or similarly named rounding selectors exist,
but equal widths and names do not imply equal encodings. Explicit ownership
prevents accidental cross-namespace interpretation.

**中文。** 仓库存在多个三位或名称相似的舍入 selector，但相同宽度和名称不表示
相同编码。显式归属可避免跨命名空间误解释。

### Detailed decision / 详细决策

**English.** Scalar FRM, fixed conversion mnemonics, bundle RMode, public modes,
matrix controls, stochastic controls, and backend controls are distinct. The
record inventories their owners and mappings; later ADR-NUM-0008 supersedes
the historical semantic-selection portions.

**中文。** Scalar FRM、固定转换 mnemonic、bundle RMode、公开 mode、矩阵控制、
随机控制与 backend 控制彼此独立。本记录盘点其 owner 与映射；后续 ADR-NUM-0008
替代其中历史性的语义选择部分。

### What changed / 改动内容

#### English

- Separated all rounding selector namespaces.
- Assigned explicit mapping and domain-owner rows.
- Preserved historical inventory while pointing to superseding semantics.

#### 中文

- 分离全部舍入 selector 命名空间。
- 指定显式映射与 domain owner 行。
- 保留历史清单并指向后续替代语义。

### Scope and boundaries / 范围与边界

**English.** Current rounding results come from ADR-NUM-0008 and owning ASL;
this inventory does not independently redefine them.

**中文。** 当前舍入结果来自 ADR-NUM-0008 与 owning ASL；本清单不独立重定义它们。
