<!-- GENERATED FROM: asl/arch/profile/functional-model.asl -->
# Functional Model

**Generated-model harness ASL source:** `asl/arch/profile/functional-model.asl`

This page is a generated reference view of non-architectural model harness ASL. Its model NDF is owned by the downstream model repository; PTO architecture remains owned by the architectural ASL/NDF it invokes.

## ASL unit identity {#PTO-ARCH-PROFILE-FUNCTIONAL-MODEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-functional-profile-purpose role=purpose-scope -->
## Purpose and scope

This file implements the generated-model lifecycle overlay consumed by the downstream model repository. PE0 initialization, pending tokens, completion, and hosted request meanings are model/ABI behavior owned by the the downstream model repository model NDF, not PTO architecture.

<!-- PTO-READER-BLOCK: arch-functional-profile-concepts role=concepts-state -->
## Initialization and request state

`InitializeFunctionalModel` performs the complete profile reset, selects PE0, installs an even entry TPC, and starts the profile sequence. Before the first step, `InitializeFunctionalModelGPR` may initialize PE0 absolute GPRs. Request observers expose the frozen pending token, origin PE, type, and scalar argument.

<!-- PTO-READER-BLOCK: arch-functional-profile-rules role=rules-interactions -->
## Request lifecycle

`BeginFunctionalModelHostRequest` validates model state, result GPR, even resume TPC, and monotonic token availability before publishing one request. Matching completion writes the captured origin-PE result GPR and resume TPC exactly once. Stale or duplicate tokens are rejected without effects, and reset does not reuse the next-token counter.

The overlay implements the architecture-owned close-request hook. Its bring-up binding recognizes ACRC request type 1 with `a7=94`, while the portable hook default is false and every nonmatching ACRC retains PTO service-request behavior. The request-94 meaning is hosted ABI, not PTO architecture.

<!-- PTO-READER-BLOCK: arch-functional-profile-boundaries role=boundaries -->
## Boundaries

Only request type 94 has a hosted meaning in this bring-up. Memory response payloads, other syscalls, startup, TLS, file descriptors, barriers, multi-Core execution, and general process recovery remain unspecified by the model NDF. PTO assigns none of these meanings.

<!-- PTO-READER-BLOCK: arch-functional-profile-example role=example-usage -->
## Non-normative host sequence

A runner resets the model with entry/SP, calls `ExecuteOnePTOStep` until it receives `HostRequest`, performs the supported host action, and calls the matching completion entrypoint. While pending, repeated steps return the same immutable request without fetch or time advance.

<!-- PTO-READER-BLOCK: arch-functional-profile-related role=related-owners-navigation -->
## Related owners

- [Functional-model state](../state/functional-model.md) declares the backing fields.
- [Functional step](../dispatch/functional-step.md) observes pending state and executes instructions.
- [Reset](reset.md) supplies the complete reference reset used at initialization.
<!-- SUPPLEMENTARY-END -->

## Model-harness ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/profile/functional-model.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-FUNCTIONAL-MODEL","surface":"arch","classification":["profile","functional-model"],"depends_on":["PTO-ARCH-PROFILE-RESET","PTO-ARCH-PROFILE-SERVICE-REQUEST-INTERCEPT","PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}

// Non-architectural generated-model lifecycle and hosted-ABI overlay.  Their
// model NDF is owned by the downstream model repository
// docs/pto-asl-functional-model-ndf-v1.json.

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

implementation func InterceptArchitectureCloseRequest(
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
