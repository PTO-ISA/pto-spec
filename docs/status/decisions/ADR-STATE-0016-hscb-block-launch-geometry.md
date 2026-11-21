---
{
  "id": "ADR-STATE-0016",
  "title": "HSCB one-dimensional block launch geometry",
  "title_zh": "HSCB 一维 block 启动几何",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["PTO-SPEC release operator (Codex session)"],
  "created": "2026-11-17",
  "accepted": "2026-11-21",
  "rejected": null,
  "superseded": null,
  "baseline": "7573753b99d9e9ffa750a0adf637eec014056f1a",
  "target_releases": ["0.59.1.0"],
  "affected_ndf": ["PTO-ARCH-HSCB-BLOCK-LAUNCH-001"],
  "affected_units": [
    "PTO-ARCH-STATE-HSCB-DISPATCH",
    "PTO-ARCH-STATE-MESSAGE-BUFFER-STATE",
    "PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS",
    "PTO-SCALAR-MODEL-SYS-SEMANTICS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/433",
  "release_impact": "required",
  "release_boundary": false,
  "interface_change": true,
  "amendments": [],
  "legacy_ids": []
}
---
# ADR-STATE-0016: HSCB one-dimensional block launch geometry

## Summary

This decision extends the accepted HSCB resident-worker protocol with
one-dimensional logical block geometry while retaining the existing four-word
LAUNCH message.

## Context

The accepted protocol identifies a worker, dispatch, kernel entry and argument,
but does not define the values observed through `BLOCKNUM` and `BLOCKID`. A host
runtime needs those values to launch one kernel over several resident workers
without making kernels depend on physical PE or hardware-thread numbering.

## Decision

`HSCBIssueBlockLaunch` binds a positive 32-bit block count and a 32-bit block ID
smaller than that count to one ACR0 worker endpoint. The binding belongs to the
outstanding dispatch and is selected by the current Core, PE, thread slot and
ACR. Other endpoints have independent bindings or observe ambient registers.
The existing `HSCBIssueLaunch` entry binds `(1, 0)`.

## Compatibility and boundaries

The LAUNCH payload remains `[2, dispatch_id, kernel_pc, argument]`. Existing
workers and transport parsers receive the same four words. The legacy launch
entry keeps its signature and changes the active worker's observable
`BLOCKNUM` default from zero to one. The proposal covers one-dimensional
homogeneous grids. Multidimensional grids, mixed engine ratios, stream ordering
and memory visibility remain outside this decision.

## Verification obligations

- Reject zero block counts, counts wider than 32 bits and IDs outside the count.
- Prove interleaved workers on sibling hardware threads retain independent
  values through the ordinary register-read instructions.
- Prove matching DONE restores only the completed worker's ambient values.
- Exercise rejected launches, unbound endpoints and invocation teardown.
- Prove the legacy entry supplies `(1, 0)`.

The release operator accepted this contract on 2026-11-21 for the
`0.59.1.0` candidate. Issue #433 records the design scope.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Logical work partitioning must remain stable when physical workers
are reused across launches. A kernel needs a launch-scoped logical identity and
participant count so its data partition is independent of PE placement,
hardware-thread selection and the order in which resident workers are reused.

**中文。** 物理 worker 会在多次启动之间复用。kernel 必须取得本次启动范围内稳定的逻辑
编号与参与者总数，使数据分片不依赖物理 PE、硬件线程选择、常驻 worker 的复用顺序或
调度服务采用的具体放置策略。

### Detailed decision / 详细决策

**English.** Admission installs an independent `(BLOCKNUM, BLOCKID)` binding
for the addressed ACR0 worker endpoint. Completion or invocation teardown
restores the ambient base-register view. A sibling worker selects its own
binding through the current execution context.

**中文。** LAUNCH 接纳时，为目标 ACR0 worker 端点安装独立的 `(BLOCKNUM, BLOCKID)`
绑定。完成派发或清理 invocation 后，恢复基础寄存器视图。同级 worker 按当前执行上下文
选择各自的绑定。

### What changed / 改动内容

#### English

- Add launch geometry to each worker's outstanding dispatch state.
- Select `BLOCKNUM` and `BLOCKID` through the current worker's execution context.
- Add a block-launch scheduler entry while preserving the existing four-word LAUNCH payload.
- Keep the legacy launch entry as the one-block, logical-ID-zero compatibility form.

#### 中文

- 在每个 worker 的未完成派发状态中记录启动几何。
- 通过当前 worker 的执行上下文选择 `BLOCKNUM` 与 `BLOCKID` 的读取值。
- 增加 block 启动调度入口，同时保持已有四字 LAUNCH 载荷不变。
- 保留旧启动入口，作为单 block、逻辑编号为零的兼容形式。

### Scope and boundaries / 范围与边界

**English.** The proposal covers one-dimensional homogeneous logical blocks.
The legacy launch keeps its signature and payload while its active
`BLOCKNUM` read returns one.
It leaves multidimensional grids, mixed-engine ratios, stream order, transport
timing and additional global-memory visibility outside this contract.

**中文。** 本提案涵盖一维同构逻辑 block。旧启动入口保留签名和载荷，派发期间读取
`BLOCKNUM` 得到一。多维 grid、混合引擎比例、stream 顺序、传输时序或额外的全局
内存可见性由各自的契约定义。
