---
{
  "id": "ADR-GOV-0012",
  "title": "Remove the reference and target profile concept",
  "title_zh": "移除参考与目标 Profile 概念",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-09-21",
  "accepted": "2026-09-21",
  "rejected": null,
  "superseded": null,
  "baseline": "5745b128dfff63942d6238e999c96418ba216be1",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-EXTENSION-FIRST-USE-001",
    "PTO-TCVT-E8M0-001",
    "PTO-COMMON-CONVERSION-001",
    "PTO-MATRIX-POSTPROCESS-BITEXACT-001",
    "PTO-MATRIX-QUANT-BITEXACT-001",
    "PTO-REQ-PHYSICAL-MEMORY-BINDING-001",
    "PTO-B-HINT-LIFECYCLE-001"
  ],
  "affected_units": [
    "PTO-ARCH-FEATURES-EXTENSION-FIRST-USE",
    "PTO-TILE-MODEL-NUMERIC-E8M0-CONVERSION",
    "PTO-TILE-MODEL-NUMERIC-REFERENCE-CONVERSION",
    "PTO-TILE-MODEL-EXECUTION-MATRIX-QUANTIZATION",
    "PTO-BLOCK-B-HINT",
    "PTO-BLOCK-MODEL-SCHEMA-BUNDLE-ENCODING",
    "PTO-SCALAR-MODEL-FSU-REFERENCE-QUANTIZATION",
    "PTO-SCALAR-MODEL-FSU-REFERENCE-SCALAR-FP-SPECIALS",
    "PTO-TILE-MODEL-NUMERIC-PACKED-CONVERSION",
    "PTO-TILE-MODEL-NUMERIC-TCVT-CONVERSION",
    "PTO-SCALAR-MODEL-SYS-REGISTERS",
    "PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR",
    "PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE",
    "PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH",
    "PTO-ARCH-STATE-TRAP-CONTEXT",
    "PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING",
    "PTO-SCALAR-MODEL-AGU-MEMORY",
    "PTO-SCALAR-MODEL-AMO-SEMANTICS",
    "PTO-SCALAR-MODEL-FSU-ARITHMETIC",
    "PTO-SCALAR-MODEL-FSU-SCALAR-FP",
    "PTO-SCALAR-MODEL-SYS-SEMANTICS",
    "PTO-TILE-MODEL-EXECUTION-COMPARISON",
    "PTO-TILE-MODEL-EXECUTION-CUBE",
    "PTO-TILE-MODEL-EXECUTION-ELEMENTWISE",
    "PTO-TILE-MODEL-EXECUTION-EXPANSION",
    "PTO-TILE-MODEL-EXECUTION-FUSED-MULTIPLY-ADD",
    "PTO-TILE-MODEL-EXECUTION-MATRIX-SCALE",
    "PTO-TILE-MODEL-EXECUTION-MATRIX-POSTPROCESS",
    "PTO-TILE-MODEL-EXECUTION-REDUCTION",
    "PTO-TILE-MODEL-EXECUTION-UNARY",
    "PTO-TILE-MODEL-NUMERIC-FORMATS"
  ],
  "resolves": [],
  "supersedes": [
    "ADR-GOV-0002",
    "ADR-GOV-0011"
  ],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/282",
  "release_impact": "required",
  "release_boundary": false,
  "interface_change": true,
  "amendments": [],
  "legacy_ids": []
}
---

# ADR-GOV-0012: Remove the reference and target profile concept

## Summary

PTO has no architecture-defined target. `pto-v0` was a selected
implementation profile, not an architectural requirement, and the profile
layer mixed downstream target and implementation choices into the portable
specification. This record removes the profile concept: the concrete
reference behavior becomes ordinary owning ASL, and no `impdef` hook keeps a
separately selected implementation.

## Context

ADR-GOV-0002 selected `pto-v0` as the active implementation profile and
required exactly one `implementation func` for every registered `impdef`
hook, so the executable model stayed deterministic. ADR-GOV-0011 added a
separate opt-in runtime compatibility profile. Neither profile is an
architecture-defined target, yet `specification.toml`, `spec/profile-hooks.json`,
the numeric identity catalog, and the A2A3/A5 evidence materialized them as if
they were portable PTO interfaces.

## Decision

1. Delete the profile declaration layer: the `[profile]` and
   `[architecture].profile` sections, `spec/profile-hooks.json`, and the
   hardware conformance profile.
2. Fold every selected `implementation func` body into the owning ASL unit as
   an ordinary `func`. Remove the `impdef` hook and its portable default where
   a selected implementation existed; keep `impdef` only for genuinely
   host- or extension-provided hooks with a portable default body.
3. Relocate the reference helper libraries into their owner domains and drop
   the `profile` surface. Rename `PTOv0*` identifiers, `profile_status` /
   `pto_v0_status` metadata fields, and profile-named units.
4. Remove the opt-in runtime compatibility profile and its host-memory bridge;
   restore the portable SYS-block, frame-stack, MSET, PEID, ACRC, and
   bounded-memory behavior.
5. Remove the A2A3/A5 target numeric identities and their derived evidence,
   and rename `NumericApplicabilityRules_MxRejection` without target names.

## Normative delta

- `specification.toml`: no profile selection or implementation list.
- ASL: no `implementation func`; no `asl/arch/profile/` surface; no
  `PTO-PROFILE-*` clauses; `PTOv0*` helpers renamed.
- Catalogs and evidence: no target-profile identities or active reference
  profile; no derived A2A3/A5 material.

## Externally visible interface delta

The portable instruction set is unchanged. The previously selected concrete
reference results are now the owning ASL definition rather than a selectable
profile. Encoding, operands, legality, faults, ordering, and state transitions
are preserved.

## Defaults and intentionally unspecified behavior

`impdef` remains only for host/extension hooks with portable default bodies.
Behavior that the removed profiles previously selected is now ordinary owning
ASL. No new target profile is defined.

## Compatibility and dependent-toolchain impact

Downstream toolchains that referenced the `pto-v0` profile id or the runtime compatibility
compatibility switches must consume the owning ASL definitions instead. No
opcode or descriptor encoding changes.

## Alternatives considered

- Keep the profile declarations while renaming: rejected because the
  selection boundary itself is the concept being removed.
- Remove the `impdef` mechanism entirely: rejected because host/extension
  hooks still need a portable default.

## Risks and mitigations

- Determinism: folding preserves a single in-tree definition per hook, and
  the full model typechecks and executes.
- Historical references: affected ADRs point at the successor owner units.

## Implementation obligations

Regenerate catalogs, documentation mirrors, AVS registration, coverage, and
release traceability projections from the reconciled tree.

## Verification obligations

`PR / validate`, repository closure, focused AVS points for reset, access,
numeric reference, Matrix, and inline-assembly compatibility.

## Release consequences

Release-impacting normative change; release evidence must be regenerated.

- Date: 2026-09-21
- Requirement: PTO-REQ-RESET-001

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** The profile layer turned downstream implementation and target
choices into portable specification artifacts. PTO has no architecture-defined
target, so the concept must be removed rather than renamed.

**中文。** Profile 层把下游实现与目标选择物化成了可移植规范产物。PTO 架构里
没有定义目标，因此必须移除该概念，而不是改名保留。

### Detailed decision / 详细决策

**English.** The selected reference implementation becomes the owning ASL
definition; the hook selection boundary, the profile declaration, and the
target identities disappear.

**中文。** 被选中的参考实现成为 owning ASL 定义；hook 选择边界、profile 声明
与目标身份一并消失。

### What changed / 改动内容

#### English

- Removed `[profile]`, `spec/profile-hooks.json`, and target identities.
- Folded `implementation func` bodies into owners; removed the profile surface.
- Removed the runtime compatibility and host-memory profile.
- Removed A2A3/A5 identities and derived evidence.

#### 中文

- 删除 `[profile]`、`spec/profile-hooks.json` 与目标身份。
- 将 `implementation func` 折叠进 owner，移除 profile surface。
- 移除 runtime compatibility 运行时兼容与 host memory profile。
- 移除 A2A3/A5 身份及其派生证据。

### Scope and boundaries / 范围与边界

**English.** This decision preserves every portable instruction, operand,
schema, encoding, legality rule, fault contract, ordering guarantee, and
state transition. It removes only the profile selection boundary, the two
superseded profile decisions, the target numeric identities, and the derived
A2A3/A5 evidence material. It does not define a replacement target profile,
does not erase the portable `impdef` boundary for host and extension hooks
that still carry a deterministic default body, and does not authorize any
hardware conformance claim. Work that needs target-specific behavior must
allocate a new reviewed decision instead of reviving the removed profile.

**中文。** 本决策保留全部可移植的指令、操作数、模式、编码、合法性规则、陷阱
契约、顺序保证与状态转换；只移除 profile 选择边界、两条被取代的 profile 决策、
目标数值身份以及派生的 A2A3/A5 证据材料。它不定义替代目标 profile，不删除仍带
确定性默认体的宿主与扩展钩子的可移植 `impdef` 边界，也不授权任何硬件符合性
声明。需要目标相关行为的工作必须新开一条正式评审决策，而不是复活已移除的
profile。
