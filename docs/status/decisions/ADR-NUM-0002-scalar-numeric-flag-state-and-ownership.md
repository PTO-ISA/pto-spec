---
{
  "id": "ADR-NUM-0002",
  "title": "Scalar numeric flag state and producer ownership",
  "title_zh": "Scalar 数值标志状态与产生者归属",
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
    "PTO-FABS-DECISION-BINDING-001",
    "PTO-FCVTA-DECISION-BINDING-001",
    "PTO-FCVTM-DECISION-BINDING-001",
    "PTO-FCVTN-DECISION-BINDING-001",
    "PTO-FCVTP-DECISION-BINDING-001",
    "PTO-FCVTZ-DECISION-BINDING-001",
    "PTO-FMAX-DECISION-BINDING-001",
    "PTO-FMIN-DECISION-BINDING-001",
    "PTO-FNE-DECISION-BINDING-001",
    "PTO-FNES-DECISION-BINDING-001",
    "PTO-NUMERIC-STATUS-STICKY-001",
    "PTO-SCVTF-DECISION-BINDING-001",
    "PTO-UCVTF-DECISION-BINDING-001"
  ],
  "affected_units": [
    "PTO-ARCH-STATE-NUMERIC-STATUS",
    "PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING",
    "PTO-SCALAR-FABS",
    "PTO-SCALAR-FADD",
    "PTO-SCALAR-FCVT",
    "PTO-SCALAR-FCVTA",
    "PTO-SCALAR-FCVTM",
    "PTO-SCALAR-FCVTN",
    "PTO-SCALAR-FCVTP",
    "PTO-SCALAR-FCVTZ",
    "PTO-SCALAR-FDIV",
    "PTO-SCALAR-FEQ",
    "PTO-SCALAR-FEQS",
    "PTO-SCALAR-FEXP",
    "PTO-SCALAR-FGE",
    "PTO-SCALAR-FGES",
    "PTO-SCALAR-FLT",
    "PTO-SCALAR-FLTS",
    "PTO-SCALAR-FMADD",
    "PTO-SCALAR-FMAX",
    "PTO-SCALAR-FMIN",
    "PTO-SCALAR-FMSUB",
    "PTO-SCALAR-FMUL",
    "PTO-SCALAR-FNE",
    "PTO-SCALAR-FNES",
    "PTO-SCALAR-FNMADD",
    "PTO-SCALAR-FNMSUB",
    "PTO-SCALAR-FRECIP",
    "PTO-SCALAR-FSQRT",
    "PTO-SCALAR-FSUB",
    "PTO-SCALAR-SCVTF",
    "PTO-SCALAR-UCVTF"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0038"
  ]
}
---
# ADR-NUM-0002: Scalar numeric flag state and producer ownership

> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Decision scope

Target production rules remain open.

## Context

`ADR 0089` asks for a complete scalar numeric exception contract. PTO already
exposes five status bits in `CORE_STATE`, and the Stage 4 scalar FSU model routes
profile-returned bits into that state. The target-profile decision package did
not yet distinguish this closed state/lifecycle mechanism from the still-open
conditions under which target arithmetic produces each flag.

The PTO ASL did not yet define a complete scalar exception-flag producer table.
The missing producer conditions must remain explicit architecture gaps; tool
or implementation behavior cannot silently define them.

## Decision

The portable scalar exception-state mechanism is:

1. `CORE_STATE[36:32]` stores NV, DZ, OF, UF, and NX from low to high.
2. Reset clears all five bits.
3. A completed scalar numeric form ORs all produced bits into the old field in
   one update. The bits are independent and have no priority; a numeric form
   cannot clear an old bit.
4. A permitted full `CORE_STATE` system-register write replaces the field and
   may clear bits. This software write is distinct from numeric accumulation.
5. An illegal source type, destination type, encoding, or other rejected form
   faults before a flag update or profile-producer call.
6. Numeric exception outcomes do not themselves raise a synchronous PTO trap.
   Trap entry snapshots `CORE_STATE`; successful recovery restores the
   manager-visible ECSTATE value, including every numeric flag.

Every one of the 30 scalar FSU forms has exactly one producer owner in
`spec/evidence/scalar-numeric-flag-contract.json`:

- `FABS` produces no flags.
- `FMIN`, `FMAX`, and the four quiet comparisons produce NV exactly for a
  signaling NaN input.
- The four signaling comparisons produce NV exactly for any NaN input.
- The other 19 forms obtain an exact five-bit vector from one named numeric-
  profile hook. Each supported operation/type rule must define that vector;
  a missing rule rejects before effects under ADR 0037.

## Consequences

The flag state, lifecycle, trap envelope, and 30/30 producer-owner matrix are
closed. Eleven architecture-owned forms have complete production conditions.
Nineteen profile-owned forms still require exact conditions for NV, DZ, OF, UF,
and NX, including simultaneous production, tininess and NX coupling, special
values, conversion overflow, and rounding.

This decision does not accept `ADR 0089`, increment the `S5-T2-A2` decision count,
or establish target numeric conformance. `ADR 0089` remains open until all 19
profile-owned rows have accepted operation/type rules and independent vectors.
The repository maturity therefore remains M4 and `S5-T2` remains open.

## Evidence

- `spec/evidence/scalar-numeric-flag-contract.json`
- `scripts/generate-scalar-numeric-flag-contract`
- `asl/scalar/floating.asl`
- `asl/scalar/dispatch.asl`
- `asl/profiles/pto-v0.asl`
- `tests/asl/scalar/model/dispatch/fsu/scalar-exec-flag-and-rounding-helpers-001.asl`
- `docs/status/decisions/ADR-SCALAR-0004-scalar-fsu-totality-and-profile-boundary.md`
- `spec/evidence/numeric-profile-decision-proposals.json`

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** PTO exposed five scalar status bits but lacked a complete account
of their lifecycle and producer ownership. Separating state mechanics from
still-open production conditions prevents implementation behavior filling gaps.

**中文。** PTO 已暴露五个 scalar 状态位，但缺少完整生命周期与产生者归属说明。
将状态机制与仍开放的产生条件分离，可防止实现行为填补规范空白。

### Detailed decision / 详细决策

**English.** NV/DZ/OF/UF/NX are sticky OR-accumulated `CORE_STATE` bits, reset
to zero, replaceable by permitted system writes, and preserved through trap
snapshot/recovery. Every scalar FSU form has one producer owner; rejected forms
update neither flags nor producer hooks.

**中文。** NV/DZ/OF/UF/NX 是 `CORE_STATE` 中通过 OR 累积的 sticky 位，reset 清零，
允许的系统写可替换，并经 trap 快照/恢复保留。每个 scalar FSU form 只有一个
产生者 owner；被拒绝形式不更新标志，也不调用产生者 hook。

### What changed / 改动内容

#### English

- Closed flag state, reset, accumulation, write, and trap behavior.
- Assigned one producer owner to all 30 scalar FSU forms.
- Left exact conditions for delegated producers open.

#### 中文

- 闭合标志状态、reset、累积、写入与 trap 行为。
- 为全部 30 个 scalar FSU form 指定唯一产生者 owner。
- 保持委托产生者的精确条件开放。

### Scope and boundaries / 范围与边界

**English.** This ADR does not define all NV/DZ/OF/UF/NX production conditions
or establish target numeric conformance.

**中文。** 本 ADR 不定义全部 NV/DZ/OF/UF/NX 产生条件，也不建立目标数值符合性。
