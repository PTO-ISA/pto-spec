<!-- GENERATED FROM: asl/arch/state/functional-model.asl -->
# Functional Model

**Normative ASL source:** `asl/arch/state/functional-model.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-FUNCTIONAL-MODEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-functional-state-purpose role=purpose-scope -->
## 用途与范围

本单元声明功能初始化、确定性步骤观测和可恢复宿主请求握手使用的配置档专属状态。这些字段独立于可移植 PTO 架构状态要求。

<!-- PTO-READER-BLOCK: arch-functional-state-concepts role=concepts-state -->
## 状态分组

- 初始化与 started 标志约束入口/GPR 注入何时合法。
- pending、token、next-token、来源 PE、请求类型/参数、结果 GPR 和恢复 TPC 构成一个请求快照。
- `_FunctionalProfileSequence` 为重置、初始化、步骤、请求创建和完成提供确定性观测顺序。

<!-- PTO-READER-BLOCK: arch-functional-state-rules role=rules-interactions -->
## 重置行为

`ResetFunctionalModelState` 清除初始化、started、待处理请求载荷和序号。它有意保留 `_FunctionalHostRequestNextToken`，使重置前的陈旧完成不能取得同一模型实例中后续请求的权限。

<!-- PTO-READER-BLOCK: arch-functional-state-boundaries role=boundaries -->
## 快照边界

开放的快照要求记录仍需定义版本化确定性封装。本页不授权复制 C struct、公开实现指针，也不把配置档状态并入可移植架构状态。

<!-- PTO-READER-BLOCK: arch-functional-state-example role=example-usage -->
## 非规范生命周期示例

重置后，初始化设置入口和序号，步骤把模型标记为 started，宿主请求冻结其来源/类型/参数/结果/恢复字段，直到匹配完成。同一时刻不能共存第二个请求。

<!-- PTO-READER-BLOCK: arch-functional-state-related role=related-owners-navigation -->
## 相关所有者

- [功能模型配置档](../profile/functional-model.md)更新这些字段。
- [功能模型结果类型](../data-types/functional-model.md)公开不可变观测记录。
- [执行上下文](../programming-model/execution-context.md)拥有配置档引用的可移植 PC/BPC 与 GPR 状态。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/functional-model.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-FUNCTIONAL-MODEL","surface":"arch","classification":["state","functional-model"],"depends_on":["PTO-ARCH-DATA-TYPES-FUNCTIONAL-MODEL","PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-FUNCTIONAL-MODEL-PROFILE","classification":["profile","functional-model"],"scope":"system","owner":"PTO-ARCH-STATE-FUNCTIONAL-MODEL","members":["_FunctionalModelInitialized","_FunctionalModelStarted","_FunctionalHostRequestPending","_FunctionalHostRequestToken","_FunctionalHostRequestNextToken","_FunctionalHostRequestOriginPE","_FunctionalHostRequestType","_FunctionalHostRequestArgument0","_FunctionalHostRequestResultGPR","_FunctionalHostRequestResumeTPC","_FunctionalProfileSequence"],"depends_on":["PTO-STATE-ARCH-GPR","PTO-STATE-ARCH-PROGRAM-CONTROL"]}

// NDF-BEGIN: PTO-REQ-FUNCTIONAL-STATE-SNAPSHOT-001
// ndf: kind=contract level=L1 layer=state status=open
// G2 and G3 are expected to define a versioned deterministic snapshot of
// [[PTO-REQ-STATE-001]] and the functional profile-state record. Functional
// profile state remains separate from portable PTO state and is not added to
// [[PTO-REQ-STATE-001]]; no snapshot encoding is accepted in G1 and this
// clause remains a draft obligation until G2/G3 define the envelope.
// NDF-END: PTO-REQ-FUNCTIONAL-STATE-SNAPSHOT-001

var _FunctionalModelInitialized : boolean;
var _FunctionalModelStarted : boolean;
var _FunctionalHostRequestPending : boolean;
var _FunctionalHostRequestToken : Word;
var _FunctionalHostRequestNextToken : Word;
var _FunctionalHostRequestOriginPE : MemoryAgentId;
var _FunctionalHostRequestType : bits(16);
var _FunctionalHostRequestArgument0 : Word;
var _FunctionalHostRequestResultGPR : GPRIndex;
var _FunctionalHostRequestResumeTPC : Word;
var _FunctionalProfileSequence : Word;

func ResetFunctionalModelState()
begin
    _FunctionalModelInitialized = FALSE;
    _FunctionalModelStarted = FALSE;
    _FunctionalHostRequestPending = FALSE;
    _FunctionalHostRequestToken = Zeros{PTO_XLEN};
    // The next-token counter is model-instance identity state. Architecture
    // reset deliberately preserves it so a stale completion can never acquire
    // authority over a later request in the same instance.
    _FunctionalHostRequestOriginPE = 0;
    _FunctionalHostRequestType = Zeros{16};
    _FunctionalHostRequestArgument0 = Zeros{PTO_XLEN};
    _FunctionalHostRequestResultGPR = 0;
    _FunctionalHostRequestResumeTPC = Zeros{PTO_XLEN};
    _FunctionalProfileSequence = Zeros{PTO_XLEN};
end;
```
<!-- GENERATED-ASL-END: unit -->
