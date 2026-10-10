---
{
  "id": "ADR-SCALAR-0007",
  "title": "SYNC.CORE collective architectural phase barrier",
  "title_zh": "SYNC.CORE 集合式架构阶段屏障",
  "status": "accepted",
  "authors": [
    "ckwllawliet <641433195@qq.com>"
  ],
  "approvers": [
    "ckwllawliet <641433195@qq.com>"
  ],
  "created": "2026-10-08",
  "accepted": "2026-10-08",
  "rejected": null,
  "superseded": null,
  "baseline": "e182c9b70d54a3a264bac54af9b915a0e43bb519",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-SYNC-CORE-DECISION-BINDING-001",
    "PTO-ARCH-PE-EXECUTION-CONTEXT-001",
    "PTO-ARCH-CORE-SYNCHRONIZATION-001",
    "PTO-ARCH-KERNEL-LIFECYCLE-001",
    "PTO-ARCH-GM-OBLIGATIONS-001",
    "PTO-ARCH-MEMORY-MODEL-COLLECTIVE-SYNC-001",
    "PTO-ARCH-MEMORY-MODEL-TRAP-RESTORE-001",
    "PTO-ARCH-MEMORY-MODEL-REPLAY-001",
    "PTO-REQ-STATE-001",
    "PTO-REQ-TILE-001",
    "PTO-B-ASSEMBLE-SHARED-STANDALONE-001",
    "PTO-B-ASSEMBLE-SHARED-GENERATION-001",
    "PTO-B-ASSEMBLE-SPECULATION-001",
    "PTO-B-SHARED-WHOLE-PARENT-READY-001",
    "PTO-TLOAD-MEMORY-001",
    "PTO-TMOV-CONTRACT-001",
    "PTO-BSTART-TLOAD-WEIGHT-COOPERATIVE-001",
    "PTO-BSTART-TIMG2COL-COOPERATIVE-001"
  ],
  "affected_units": [
    "PTO-SCALAR-SYNC-CORE",
    "PTO-ARCH-DATA-TYPES-MEMORY-MODEL",
    "PTO-ARCH-DATA-TYPES-TRAP-CONTEXT",
    "PTO-ARCH-DISPATCH-TOP-LEVEL",
    "PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION",
    "PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS",
    "PTO-ARCH-MEMORY-MODEL-MEMORY-EVENTS",
    "PTO-ARCH-MEMORY-MODEL-ORDERING",
    "PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY",
    "PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT",
    "PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS",
    "PTO-ARCH-STATE-PE-EXECUTION-CONTEXT",
    "PTO-ARCH-STATE-CORE-SYNCHRONIZATION",
    "PTO-ARCH-STATE-KERNEL-LIFECYCLE",
    "PTO-ARCH-STATE-TRAP-CONTEXT",
    "PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING",
    "PTO-BLOCK-MODEL-COMMIT-VALIDATION",
    "PTO-BLOCK-MODEL-DISPATCH-START",
    "PTO-BLOCK-MODEL-LIFECYCLE-RESET",
    "PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS",
    "PTO-BLOCK-MODEL-STATE-CONTROL-STATE",
    "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
    "PTO-SCALAR-MODEL-DISPATCH-DECODE",
    "PTO-SCALAR-MODEL-DISPATCH-SYS",
    "PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL",
    "PTO-SCALAR-MODEL-SYS-SEMANTICS",
    "PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS",
    "PTO-TILE-MODEL-STATE-LOCAL-REGISTERS",
    "PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP",
    "PTO-BLOCK-MODEL-DISPATCH-GM-OBLIGATION",
    "PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-SQUASH",
    "PTO-TILE-MODEL-MEMORY-LOAD-STORE",
    "PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU",
    "PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV",
    "PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION-PE-REQUESTS",
    "PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR",
    "PTO-BLOCK-MODEL-STATE-SHARED-GENERATION",
    "PTO-BLOCK-MODEL-DISPATCH-WEIGHT-SHARED-EXEC",
    "PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-EXECUTION",
    "PTO-BLOCK-MODEL-STATE-TYPES",
    "PTO-SCALAR-MODEL-AGU-MEMORY",
    "PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT",
    "PTO-TILE-TLOAD",
    "PTO-TILE-TMOV",
    "PTO-TILE-MODEL-STATE-SHARED-REGISTERS",
    "PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS",
    "PTO-BLOCK-MODEL-DISPATCH-TIMG2COL-SCHEMA"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/360",
  "release_impact": "required",
  "release_boundary": false,
  "interface_change": true,
  "amendments": [],
  "legacy_ids": []
}
---

# ADR-SCALAR-0007: SYNC.CORE collective architectural phase barrier

## Summary

Introduce one ordinary Scalar SYS collective synchronization interface. Its current meaning belongs to the named ASL/NDF owners, not this decision record. [Issue #360’s accepted r2 design comment](https://github.com/PTO-ISA/pto-spec/issues/360#issuecomment-6052737773) records the immutable baseline, decisions, executable witnesses, compatibility, and remaining downstream obligations.

## Context and baseline

The baseline has a local FENCE.D interface and operation-specific Tile collectives, but no general four-PE execution rendezvous. Four PE-private GPR files coexist with a singleton executable program-control/trap context. That carrier cannot alone prove independent peer arrival, waiting, interrupt return, or repeated-generation release. The user confirmed shared program code and an identical initial entry, with independent subsequent PE execution contexts.

## Decision and ownership

Select the new SYNC.CORE interface and exact encoding in the linked accepted design. Complete independent PE context, shared Core synchronization, kernel lifecycle, earlier GM obligations, and cross-agent memory relation owners together. Existing single-selected-context helpers may remain compatibility accessors only when they operate on the selected PE's authoritative context.

This is one new Scalar public decision boundary with secondary state, Block, and memory impacts. ADR-SCALAR-0006 remains the owner of pre-existing local fences and other Scalar operations; it does not acquire collective fence semantics. No duplicate STATE/MEM ADR is allocated for this interface. ADR-GOV-0012 remains protected: do not restore a target-profile selection layer. Downstream V5 lowering is an integration mapping, not an architecture applicability switch.

The executable representation uses four PE contexts in each finite verification Core instance. The request-obligation ledger and progress scheduler live outside instruction bodies; its default is immediate progress. Deferred TSTORE evidence advances captured requests through the same producer, probe, store, event, replay, and completion path. A completed collective's ordering provenance is stamped into retained memory events with Core, invocation, and origin identity plus a monotonic completed-collective sequence, so reuse of active generation records cannot erase established memory history. Selective replay discard retains peer event indices and read-from links; scoped Local-generation squash retains peer writers and shares a Core-wide token allocator.

Actual independently executed Shared B.ASSEMBLE contributions use a Core-owned candidate matched by Core, invocation, producer site, dynamic ordinal, target and existing descriptor metadata, while each contribution captures only its actual eligible PE's private source. Existing INIT/LAST/CELL coverage and atomic publication rules remain the owner; direct singleton operations retain their immediate whole-parent path. An execution-domain squash invalidates only the exact incomplete candidate and marks its retained live, PE-bank and trap copies so restoring an old frame cannot revive it. A legal replay is an architectural saved-context redirect followed by encoded BSTART with a fresh token. Successful End and Abort retire invocation-owned candidate/release metadata while preserving published Shared payloads, committed effects and the next operation ordinal. These are model representations of the accepted contract, not new software-visible state, publication conditions, or scheduling controls.

The approved interrupt, exception, invocation, and abort rules are part of the linked design. Preserve existing memory atomicity, shareability, fault precision, committed effects, Local/Shared Tile ownership, FENCE.D/FENCE.I encodings, and unrelated scheduling-request behavior.

## Alternatives and rationale

- Local fences plus a software barrier remain available but do not supply this instruction's rendezvous or preceding unissued-GM obligations.
- FENCE.D.CORE4 with variable predecessor/successor operands and a dsb.core4 alias were rejected: one operand-free exact form expresses the accepted phase boundary without introducing a second interface.
- Already-issued-request draining was rejected because it omits earlier program-order work still waiting for a producer.
- Speculative arrival with rollback was rejected because released peers cannot be undone.
- Target-profile gating and a new selectable Core4 architecture were rejected; this is an ordinary Scalar SYS instruction.
- Multiple active kernels, kernel switching, and migration remain outside V1.

## Compatibility and release boundary

The instruction allocation is additive. Independent PE-context closure corrects the baseline model's missing multi-PE carrier; an existing single selected PE run retains its behavior. Any conflict with a prior accepted clause must be reported and reconciled explicitly, rather than hidden in a generated projection. This is a V1 specification PR with release impact required, not release verification, tagging, or publication. No ASLRef pin or external runtime/backend change is authorized by this ADR.

## Evidence and residuals

Focused executable evidence must exercise encoded dispatch and actual context transitions, not only a barrier helper. Cover four-way arrival, older not-issued and outstanding GM work, independent cross-agent memory rejection, precise faults, interrupt return, handler exclusion, reservations, generations, abort/quiescence, next invocation, and illegal placement/encoding. The ring-reuse witness proves the original event relation after its active record is evicted, after Core selection, and after a later invocation; new-invocation, cross-Core, and handler events remain excluded. Model bounds are verification bounds. Generate direct documentation, decode/catalog/witness, AVS, ADR/NDF, coverage, and traceability projections after final sources.

LLVM, SuperScalarModel, benchmark adoption, and ASL-MODEL compile/link integration remain downstream obligations; this PR cannot claim their completion. Acceptance recorded here comes from the user's design review, not an authenticated GitHub approval or a PR validation receipt.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** A program-order phase boundary must wait for every participating PE and all preceding GM effects, including requests not yet issued. An agent-local fence or an empty request queue cannot establish that contract.

**中文。** 程序顺序上的阶段边界必须等待四个参与 PE 和全部前序 GM 效果，包括尚未发出的请求。本地 fence 或瞬时空队列不足以表达该契约。

### Detailed decision / 详细决策

**English.** Use one ordinary Scalar SYS interface with secondary executable state and memory owners. Encoded Shared generation participants contribute from their real per-PE private contexts to the existing Core-owned INIT/LAST candidate, which publishes under its existing coverage and atomic-commit rules. Squash cancels only the matching incomplete request identity, including saved trap copies; an explicit architectural restart and a new encoded BSTART establish a fresh request. Lifecycle cleanup reclaims matching active/release bookkeeping without erasing a published parent or its history. The linked issue design owns the accepted decision inventory; current semantics remain in the named ASL/NDF units. No target-profile selection layer is introduced.

**中文。** 使用一个普通 Scalar SYS 接口，并补全相关可执行状态及内存 owner。编码执行的 Shared 代次由真实 PE 私有上下文提供贡献，并遵守现有 Core INIT/LAST 候选、coverage 与原子提交规则。撤销仅取消匹配的未完成请求身份，包括已保存的 trap 副本；显式架构重启及新的编码 BSTART 才建立新请求。生命周期清理回收匹配的活动/释放元数据，同时保留已发布父对象及其历史。关联 issue 记录已接受的决策清单；当前语义由列出的 ASL/NDF 单元负责。不新增 target profile 选择层。

### What changed / 改动内容

#### English

- Added the accepted `SYNC.CORE` interface and identified its connected architectural owners without introducing a target-profile switch.
- Completed the PE-context, Core synchronization, invocation lifecycle, GM obligation, memory-history, and actual-PE Shared candidate/replay owner inventory, with encoded execution evidence and generated projections.
- Recorded the finite verification-model boundary and downstream compiler/simulator integration obligations; the published release version, manifest, and ABI remain unchanged.

#### 中文

- 增加已接受的 `SYNC.CORE` 接口，并明确关联的架构 owner，不引入 target profile 开关。
- 完成 PE context、Core synchronization、invocation lifecycle、GM obligation、memory history 及实际 PE Shared candidate/replay 的 owner 盘点，并补齐编码执行证据与生成投影。
- 记录有限验证模型边界及下游编译器/模拟器集成义务；已发布的版本、manifest 和 ABI 保持不变。

### Scope and boundaries / 范围与边界

**English.** V1 covers the specification, its tests and projections. Preserve existing local fences, memory/recovery contracts, and Tile collectives. External compiler/simulator changes and exact-commit release validation remain separate.

**中文。** V1 范围为规范、测试和直接投影。保留既有本地 fence、内存和恢复契约及 Tile collective。外部编译器或模拟器修改以及精确提交的发布验证另行处理。
