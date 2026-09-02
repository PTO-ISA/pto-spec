---
{
  "id": "ADR-GOV-0002",
  "title": "PTO v0 concrete reference profile",
  "title_zh": "PTO v0 具体参考 Profile",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-28",
  "accepted": "2026-07-28",
  "rejected": null,
  "superseded": null,
  "baseline": "b04318ee75b253157a792b9d08f75e9e95eacf0f",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ARCH-EXTENSION-FIRST-USE-PROFILE-001",
    "PTO-MATRIX-POSTPROCESS-BITEXACT-001",
    "PTO-MATRIX-QUANT-BITEXACT-001",
    "PTO-TCVT-E8M0-PROFILE-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-APPLICABILITY",
    "PTO-ARCH-PROFILE-E8M0-CONVERSION",
    "PTO-ARCH-PROFILE-EXTENSION-FIRST-USE",
    "PTO-ARCH-PROFILE-MATRIX-POSTPROCESS",
    "PTO-ARCH-PROFILE-MATRIX-QUANTIZATION",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE",
    "PTO-ARCH-PROFILE-REFERENCE-QUANTIZATION",
    "PTO-ARCH-PROFILE-RESET",
    "PTO-ARCH-PROFILE-TRAP-CONTEXT-RECOVERY"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0005"
  ]
}
---
# ADR-GOV-0002: PTO v0 concrete reference profile


## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

The executable model had named implementation-defined hooks but no single selected implementation. That prevented the repository from proving a deterministic, total reference configuration and risked inheriting accidental host or backend behavior for numeric operations, translation, reset, access control, and architectural time.

可执行模型虽然包含具名的 implementation-defined 钩子，却没有为这些钩子选择一套完整实现。这使仓库无法证明一个确定且全域的参考配置，并可能在数值运算、地址转换、复位、访问控制和架构时间方面意外继承宿主或后端行为。

### Detailed decision / 详细决策

The record selects `pto-v0` as the active implementation profile and requires an exact one-to-one match among the hook registry, declarations, implementations, and direct conformance calls. It fixes deterministic reference choices for numeric behavior, identity translation and permissions, ACR state, the execution-attempt clock, and reset while retaining the implementation interface.

本记录选择 `pto-v0` 作为活动实现 Profile，并要求钩子注册表、声明、实现和直接一致性调用的名称集合完全一一对应。它为数值行为、恒等地址转换与权限、ACR 状态、指令尝试时钟和复位确定可复现的参考选择，同时保留实现接口。

### What changed / 改动内容

#### English

- Provided one implementation for every registered `impdef` hook.
- Made reset, translation, access-control, time, and selected numeric behavior reproducible.
- Limited the evidence so the reference cannot be cited as IEEE-754 or target-hardware conformance.

#### 中文

- 为每个已注册的 `impdef` 钩子提供一项实现。
- 使复位、地址转换、访问控制、时间和选定数值行为可复现。
- 限制证据含义，禁止将该参考配置作为 IEEE-754 或目标硬件符合性证明。

### Scope and boundaries / 范围与边界

The decision applies only to the listed profile, reset, numeric, extension-first-use, and trap-recovery owners. It does not erase implementation-defined boundaries, define a hardware implementation, or authorize IEEE-754 conformance claims.

该决策仅适用于所列的 Profile、复位、数值、扩展首次使用和陷阱恢复 owner。它不消除 implementation-defined 边界，不定义硬件实现，也不授权 IEEE-754 符合性声明。
- Date: 2026-07-28
- Requirement: PTO-REQ-PROFILE-001

## Context

Named `impdef` interfaces make target-dependent choices visible, but an
interface without a selected implementation leaves the executable repository
unable to prove one complete architecture configuration. Numeric behavior,
translation and permissions, reset values, access-control rings, and architectural time
must be reproducible without inheriting host-language or backend behavior.

The present model is intended to establish a deterministic formal reference.
Available public evidence is not sufficient to claim IEEE-754 or any target's
exact numeric implementation.

## Decision

The repository selects `pto-v0` as its active implementation profile. It keeps
the portable `impdef` boundary and supplies exactly one `implementation func`
for every registered hook. The registry, declarations, implementations, and
direct conformance calls must have identical name sets.

PTO v0 defines:

- deterministic typed reference numeric operations. Finite scalar FP32/FP64
  and the shared scalar/TCVT conversion subset use their accepted mathematical
  rules; remaining raw-carrier or delegated hooks do not claim IEEE-754 or
  target-hardware conformance;
- identity address translation with full bounded-memory access for ACR0 and
  ACR1 and a protected upper region for ACR2 through ACR15;
- explicit ACR0..ACR15 state and ACR0-only extended system-register families;
- one architectural time tick per decoded scalar or tile execution attempt;
  and
- a deterministic reset of observable scalar, tile-descriptor, memory,
  reservation, ordering, fault, system, time, and access-control-ring state.

The profile does not remove the implementation interface. A future IEEE or
hardware profile must use a distinct identity, implement the complete registry,
and add its own conformance evidence.

## Consequences

- The assembled ASL model is total under one named, reproducible configuration.
- CI can reject missing, extra, or untested profile hooks.
- Reviewers can distinguish PTO v0's formal-reference choices from portable PTO
  rules and target behavior.
- PTO v0 results must not be cited as IEEE-754 or hardware conformance evidence.
