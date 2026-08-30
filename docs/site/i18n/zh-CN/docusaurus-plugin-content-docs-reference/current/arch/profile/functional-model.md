<!-- GENERATED FROM: asl/arch/profile/functional-model.asl -->
# Functional Model

**Executable model-contract ASL source:** `asl/arch/profile/functional-model.asl`

This page is a generated reference view of a non-architectural functional-model contract. PTO architecture remains owned by the architectural ASL/NDF that this model contract invokes.

## ASL unit identity {#PTO-ARCH-PROFILE-FUNCTIONAL-MODEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-functional-profile-purpose role=purpose-scope -->
## 用途与范围

此命名配置档把可移植 PTO 状态变为可重置、可单步执行的功能模型实例。它拥有 PE0 初始化和生成式模型库使用的单待处理请求握手；它不定义通用的宿主操作系统 ABI。

<!-- PTO-READER-BLOCK: arch-functional-profile-concepts role=concepts-state -->
## 初始化与请求状态

`InitializeFunctionalModel` 执行完整配置档重置、选择 PE0、安装偶数入口 TPC，并启动配置档序号。首次步骤前，`InitializeFunctionalModelGPR` 可初始化 PE0 绝对 GPR。请求观测函数公开被冻结的待处理 token、来源 PE、类型和标量参数。

<!-- PTO-READER-BLOCK: arch-functional-profile-rules role=rules-interactions -->
## 请求生命周期

`BeginFunctionalModelHostRequest` 在发布一个请求前验证模型状态、结果 GPR、偶数恢复 TPC 和单调 token 可用性。匹配完成只写一次已捕获来源 PE 的结果 GPR 和恢复 TPC。陈旧或重复 token 被无效果拒绝，重置不会复用 next-token 计数器。

功能退出绑定只拦截已初始化配置档中 `a7=94` 的 ACRC 请求类型 1。它捕获 `a0` 作为请求参数/结果 GPR，并把下一条四字节 TPC 作为恢复点；所有不匹配的 ACRC 保留可移植 service-request 行为。

<!-- PTO-READER-BLOCK: arch-functional-profile-boundaries role=boundaries -->
## 边界

本次 bring-up 仅为请求类型 94 赋予宿主含义。内存响应载荷、其他 syscall、启动、TLS、文件描述符、屏障、多 Core 执行和通用进程恢复仍未指定。模型描述符与快照要求各有独立所有者，不从请求 API 推断。

<!-- PTO-READER-BLOCK: arch-functional-profile-example role=example-usage -->
## 非规范宿主序列

运行器以入口/SP 重置模型，反复调用 `ExecuteOnePTOStep` 直到得到 `HostRequest`，执行受支持宿主动作，再调用匹配完成入口。请求待处理期间，重复步骤返回同一不可变请求，不取指也不推进时间。

<!-- PTO-READER-BLOCK: arch-functional-profile-related role=related-owners-navigation -->
## 相关所有者

- [功能模型状态](../state/functional-model.md)声明后备字段。
- [功能步骤](../dispatch/functional-step.md)观测待处理状态并执行指令。
- [重置](reset.md)提供初始化使用的完整参考重置。
<!-- SUPPLEMENTARY-END -->

## Model-contract ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/functional-model.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-FUNCTIONAL-MODEL","surface":"arch","classification":["profile","functional-model"],"depends_on":["PTO-ARCH-PROFILE-RESET","PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}

// PTO-MODEL-CONTRACT-BEGIN: PTO-REQ-FUNCTIONAL-HOST-REQUEST-001
// contract: layer=model status=accepted
// A functional-model instance MUST expose at most one pending host request.
// Repeated step while pending MUST return the same immutable token, origin PE,
// request type, and scalar argument without fetch, time advance, or state
// effect. Only a matching token MAY complete the current generic scalar
// request; completion MUST write the captured origin-PE result GPR and shared
// resume TPC exactly once. Stale and duplicate completion MUST have no effect.
// Tokens MUST NOT be reused during a model-instance lifetime; model reset MUST
// preserve the next-token counter and exhaustion MUST fail closed.
// Memory response payloads and hosted ABI request meanings remain unspecified.
// PTO-MODEL-CONTRACT-END: PTO-REQ-FUNCTIONAL-HOST-REQUEST-001

// PTO-MODEL-CONTRACT-BEGIN: PTO-REQ-FUNCTIONAL-EXIT-GROUP-001
// contract: layer=abi status=accepted
// In an initialized functional-model profile only, ACRC request type 1 with
// PE-local a7 equal to Linux exit_group request 94 MUST open host request 94
// before ordinary service-request routing.  The immutable argument MUST be
// a0, the captured result GPR MUST be a0, and the resume TPC MUST be the next
// four-byte instruction.  Every other ACRC input MUST retain portable service
// request semantics.  A matched request that cannot allocate a unique token
// MUST fail closed with ExecutionStateCheck and no pending request.
// This binding is a freestanding hosted ABI convention, not PTO architecture.
// PTO-MODEL-CONTRACT-END: PTO-REQ-FUNCTIONAL-EXIT-GROUP-001

// PTO-MODEL-CONTRACT-BEGIN: PTO-REQ-FUNCTIONAL-RESET-001
// contract: layer=model status=accepted
// InitializeFunctionalModel MUST perform the complete reference reset, select
// PE0, install the supplied even entry TPC, and leave PE1 through PE3 reset.
// Before the first step, InitializeFunctionalModelGPR MAY initialize only PE0
// absolute GPRs; GPR0 MUST retain its architectural zero behavior.
// PTO-MODEL-CONTRACT-END: PTO-REQ-FUNCTIONAL-RESET-001

// NDF-BEGIN: PTO-REQ-FUNCTIONAL-PROFILE-IDENTITY-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// PTO architecture owns its release, encoding, state, and profile semantics;
// ASL execution MUST NOT depend on a generated-model descriptor, source-tree
// identity, generator version, MIR schema, C ABI version, or implementation
// hash. A functional model MAY bind those values in a non-architectural model
// descriptor to fail closed against the wrong generated artifact. Such a
// descriptor is an implementation/interface identity and MUST NOT create or
// refine PTO architectural behavior.
// NDF-END: PTO-REQ-FUNCTIONAL-PROFILE-IDENTITY-001

readonly func FunctionalModelHostRequestPending() => boolean
begin
    return _FunctionalHostRequestPending;
end;

readonly func FunctionalModelHostRequestToken() => Word
begin
    return _FunctionalHostRequestToken;
end;

readonly func FunctionalModelHostRequestOriginPE() => MemoryAgentId
begin
    return _FunctionalHostRequestOriginPE;
end;

readonly func FunctionalModelHostRequestType() => bits(16)
begin
    return _FunctionalHostRequestType;
end;

readonly func FunctionalModelHostRequestArgument0() => Word
begin
    return _FunctionalHostRequestArgument0;
end;

func InitializeFunctionalModel(entry: Word)
begin
    assert entry[0] == '0';
    ResetProfileState();
    ResetFunctionalModelState();
    _CurrentMemoryAgent = 0;
    WriteTPC(entry);
    _FunctionalModelInitialized = TRUE;
    _FunctionalProfileSequence = Zeros{PTO_XLEN} + 1;
end;

func InitializeFunctionalModelGPR(index: integer, value: Word) => boolean
begin
    if !_FunctionalModelInitialized || _FunctionalModelStarted then
        return FALSE;
    end;
    if index < 0 || index >= PTO_ABSOLUTE_GPR_COUNT then return FALSE; end;
    WritePEGPR(0, index as GPRIndex, value);
    _FunctionalProfileSequence = _FunctionalProfileSequence + 1;
    return TRUE;
end;

func BeginFunctionalModelHostRequest(
    request_type: bits(16),
    argument0: Word,
    result_gpr: integer,
    resume_tpc: Word) => boolean
begin
    if !_FunctionalModelInitialized || _FunctionalHostRequestPending then
        return FALSE;
    end;
    if result_gpr < 0 || result_gpr >= PTO_ABSOLUTE_GPR_COUNT then
        return FALSE;
    end;
    if resume_tpc[0] == '1' then return FALSE; end;
    var next_token = _FunctionalHostRequestNextToken;
    if next_token == Zeros{PTO_XLEN} then
        next_token = Zeros{PTO_XLEN} + 1;
    end;
    if next_token == Ones{PTO_XLEN} then return FALSE; end;

    _FunctionalHostRequestPending = TRUE;
    _FunctionalHostRequestToken = next_token;
    _FunctionalHostRequestNextToken = next_token + 1;
    _FunctionalHostRequestOriginPE = _CurrentMemoryAgent;
    _FunctionalHostRequestType = request_type;
    _FunctionalHostRequestArgument0 = argument0;
    _FunctionalHostRequestResultGPR = result_gpr as GPRIndex;
    _FunctionalHostRequestResumeTPC = resume_tpc;
    _FunctionalProfileSequence = _FunctionalProfileSequence + 1;
    return TRUE;
end;

func InterceptFunctionalModelCloseRequest(
    request_type: bits(4)) => boolean
begin
    if !_FunctionalModelInitialized || request_type != '0001' ||
       ReadGPR(9) != Zeros{PTO_XLEN} + 94 then
        return FALSE;
    end;
    let started = BeginFunctionalModelHostRequest(
        Zeros{16} + 94,
        ReadGPR(2),
        2,
        ReadTPC() + (Zeros{PTO_XLEN} + 4));
    if !started then
        SetFault(Fault_ExecutionStateCheck, ReadTPC());
    end;
    return TRUE;
end;

func CompleteFunctionalModelHostRequest(
    token: Word,
    result: Word) => PTOFunctionalHostCompletionStatus
begin
    if !_FunctionalHostRequestPending ||
       token != _FunctionalHostRequestToken then
        return PTOFunctionalHostCompletion_Rejected;
    end;

    WritePEGPR(
        _FunctionalHostRequestOriginPE,
        _FunctionalHostRequestResultGPR,
        result);
    WriteTPC(_FunctionalHostRequestResumeTPC);
    _FunctionalHostRequestPending = FALSE;
    _FunctionalProfileSequence = _FunctionalProfileSequence + 1;
    return PTOFunctionalHostCompletion_Accepted;
end;
```
<!-- GENERATED-ASL-END: unit -->
