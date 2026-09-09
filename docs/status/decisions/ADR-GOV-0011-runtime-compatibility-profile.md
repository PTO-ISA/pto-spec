---
{
  "id": "ADR-GOV-0011",
  "title": "Opt-in Linx runtime compatibility profile",
  "title_zh": "可选启用的 Linx 运行时兼容配置",
  "status": "accepted",
  "authors": ["jiale-wangOwO"],
  "approvers": ["zhoubot"],
  "created": "2026-09-09",
  "accepted": "2026-09-09",
  "rejected": null,
  "superseded": null,
  "baseline": "dea0b75e803cffa873982c90f9aa0cd17c6d243b",
  "target_releases": ["unassigned"],
  "affected_ndf": [
    "PTO-PROFILE-LINX-RUNTIME-COMPAT-001",
    "PTO-PROFILE-LINX-PEID-SSR-001",
    "PTO-PROFILE-LINX-NON-SYS-SYSTEM-OPS-001",
    "PTO-PROFILE-LINX-ACRC-EXIT-OBSERVATION-001",
    "PTO-PROFILE-HOST-MEMORY-001"
  ],
  "affected_units": [
    "PTO-ARCH-FEATURES-TILE-ALLOCATION",
    "PTO-ARCH-MEMORY-MODEL-ADDRESS-SPACE",
    "PTO-ARCH-PROFILE-LINX-RUNTIME-COMPAT",
    "PTO-ARCH-PROFILE-REFERENCE-PROFILE",
    "PTO-BLOCK-MODEL-COMMIT-EFFECTS",
    "PTO-BLOCK-MODEL-COMMIT-VALIDATION",
    "PTO-BLOCK-MODEL-DISPATCH-COMMANDS",
    "PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL",
    "PTO-BLOCK-MODEL-LIFECYCLE-LIFETIME",
    "PTO-SCALAR-MODEL-AGU-MEMORY",
    "PTO-SCALAR-MODEL-SYS-REGISTERS",
    "PTO-SCALAR-MODEL-SYS-SEMANTICS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/258",
  "release_impact": "required",
  "release_boundary": false,
  "interface_change": true,
  "amendments": [],
  "legacy_ids": []
}
---

# ADR-GOV-0011: Opt-in Linx runtime compatibility profile

## Summary

Accept one named, compile-time-selected Linx runtime compatibility profile for
hosted direct-boot ELF bring-up. The profile is subordinate to a master switch,
defaults completely to portable PTO behavior, and keeps all instruction
semantics in their existing ASL owners.

## Context

The portable ASL model intentionally uses a bounded local memory array, the
architectural R1 frame stack pointer, SYS-block system-operation placement, and
the published PTO encodings and lifecycle. Existing Linx direct-boot images
need a small set of target-runtime accommodations to execute through a hosted
runner. Importing those accommodations unconditionally would turn one runner's
ABI and legacy behavior into portable PTO semantics.

Issue [#258](https://github.com/PTO-ISA/pto-spec/issues/258) identifies the
immutable baseline, five new NDF contracts, defaults, affected owners, and
verification scope. No previous ADR owns this cross-cutting target-profile
boundary.

## Decision

Add `PTO_MODEL_LINX_RUNTIME_COMPAT` as the master selection for a named Linx
runtime profile. PEID SSR address `0x0802`, non-SYS system-operation placement,
host-backed data memory, configured frame-SP selection, the legacy compressed
`C.BSTOP` alias, hosted TRACE boundary completion, and a configurable effective
MSET limit take effect only when the master is enabled. Raw ASL configuration
types and loop bounds may retain their neutral compile-time bounds.

Within the selected profile, ACRC request 1 is a direct-boot exit observation
marker only in an active Standard bundle. It is valid before the body-active
latch is set. ACRC in a SYS bundle remains on the ordinary ASL service-request
path, and no-bundle or other request types do not acquire marker behavior.

Host-backed memory remains an implementation binding. If selected, the host
must implement byte reads and writes; the default impdef bodies fail closed so
an omitted bridge cannot fabricate zero reads or silently discard writes.

## Normative delta

The five affected NDF clauses become accepted and are owned by
`PTO-ARCH-PROFILE-LINX-RUNTIME-COMPAT`. Existing instruction ASL remains the
sole owner of decode, operand legality, faults, state transitions, ordering,
and completion. Profile helpers own selection and prevent direct subfeature
configuration from bypassing the master gate.

## Externally visible interface delta

The new interface is a named model profile, not a portable instruction-set
extension. A selecting runtime may expose PEID at SSR `0x0802`, execute the
listed compatibility paths, and bind data memory to host storage. Software
that does not select the profile observes the pre-decision portable behavior.

## Defaults and intentionally unspecified behavior

Every compatibility boolean defaults to `FALSE`; portable frame SP is R1 and
the portable effective MSET limit is 262144 bytes. The host address map,
storage implementation, process exit mechanism after observing ACRC, concrete
ABI value chosen for frame SP, and runner-side diagnostics are intentionally
outside PTO. The profile does not change instruction-address translation or
alter PTO memory permission, preflight, ordering, or precise-fault contracts.

## Compatibility and dependent-toolchain impact

Portable PTO consumers are compatible because the master is disabled by
default and all subordinate settings are inert without it. Hosted Linx runners
must deliberately select the master, provide host-memory callbacks when that
subfeature is selected, and consume the named helper contracts. Decoders must
not accept the legacy compressed stop outside its gated boundary. Tools must
not interpret these switches as a new encoding ABI or as permission to bypass
ASL instruction handlers.

## Alternatives considered

Making the accommodations portable defaults was rejected because it would
standardize a target runtime's ABI and legacy encodings. Scattering independent
configuration checks through instruction handlers was rejected because a
subflag could escape the master profile. Implementing ACRC exit entirely in the
host was rejected because it could skip decode, legality, and ASL-visible
terminal effects. Returning zero or dropping writes in an unimplemented host
bridge was rejected because it hides integration errors as architectural data.

## Risks and mitigations

A partially configured profile could otherwise leak target behavior into the
portable model; master-gated helpers and explicit TRUE/FALSE AVS policy cases
mitigate that risk. A broad ACRC exception could steal SYS service requests;
the exact active-Standard/request-1 predicate prevents it. A missing host
memory implementation could corrupt execution silently; fail-closed impdefs
make that omission immediate. Generated NDF, ADR, documentation, and readiness
checks prevent ownership and projection drift.

## Implementation obligations

- Keep all subordinate runtime selections behind the master helper.
- Keep ACRC request 1 execution in ASL and restrict only the exit-marker
  observation to an active Standard bundle, including its pre-body point.
- Preserve the normal SYS ACRC service-request path.
- Route memory, frame-SP, MSET, TRACE, and legacy-stop callers through the
  profile-owned helpers.
- Require a selected host-memory profile to provide functional byte callbacks.
- Preserve portable-negative AVS points and add explicit enabled-policy cases.

## Verification obligations

Run ADR graph and bilingual checks, NDF and supplement checks, affected
projection checks, strict ASL type checking, and focused AVS points for master
gating and ACRC context. Verify portable negative tests still reject the PEID
alias and Standard-block ACRC when the profile is not selected.

## Release consequences

Release impact is required because this introduces a new externally visible
target-profile boundary and changes multiple semantic units from the recorded
baseline. No target release is assigned by this decision. A future release
must bind the accepted ADR, NDF clauses, generated projections, and exact-head
validation without treating local profile execution as publication authority.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Linx direct-boot bring-up needs host and legacy-runtime behavior
that is useful for one named execution environment but is not portable PTO.
A durable decision is required to keep that boundary explicit and reviewable.

**中文。** Linx 直接启动需要宿主内存和旧运行时兼容行为；这些行为只适用于一个具名执行
环境，并非可移植 PTO 语义。必须通过持久化决策明确并可审查地维护此边界。

### Detailed decision / 详细决策

**English.** One master switch selects the profile. Every subordinate feature
is inert without it. ACRC request 1 is observable as an exit marker only in an
active Standard bundle, including before body activation; SYS ACRC continues
through normal service-request semantics. Selected host memory requires a real
host implementation and fails closed otherwise.

**中文。** 一个主开关选择该配置；未启用主开关时，所有子功能均无效。仅当 Standard
Bundle 已激活时，ACRC 请求 1 才可作为退出标记被观察，包括 Bundle body 激活之前；SYS
中的 ACRC 仍执行正常服务请求语义。启用宿主内存时必须提供真实宿主实现，否则关闭失败。

### What changed / 改动内容

#### English

- Accepted five Linx runtime profile NDF clauses under one cross-cutting owner.
- Added master-gated policies for PEID, non-SYS placement, host memory, frame
  SP, legacy compressed stop, TRACE completion, and effective MSET limit.
- Narrowed ACRC exit observation to active Standard/request-1 context.
- Required host byte callbacks to fail closed when not implemented.
- Added focused enabled and portable-negative executable evidence.

#### 中文

- 在一个跨领域 owner 下接受五项 Linx 运行时配置 NDF 条款。
- 为 PEID、非 SYS 放置、宿主内存、frame SP、旧压缩 stop、TRACE 完成和有效 MSET
  上限增加主开关门控策略。
- 将 ACRC 退出观察严格限制为已激活 Standard Bundle 的请求 1 上下文。
- 要求未实现的宿主字节回调关闭失败，禁止静默伪造读写成功。
- 增加启用策略和可移植负例的聚焦可执行证据。

### Scope and boundaries / 范围与边界

**English.** This ADR owns only profile selection, compatibility applicability,
and host-binding requirements. It does not change instruction encodings,
general ACRC service semantics, memory ordering, precise faults, Tile behavior,
or portable defaults. Host process termination and concrete sparse-memory
layout remain runtime responsibilities.

**中文。** 本 ADR 仅负责配置选择、兼容行为适用条件和宿主绑定要求；它不改变指令编码、
通用 ACRC 服务语义、内存顺序、精确故障、Tile 行为或可移植默认值。宿主进程终止方式与
稀疏内存具体布局仍由运行时负责。
