<!-- GENERATED FROM: asl/arch/state/functional-model.asl -->
# Functional Model

**Normative ASL source:** `asl/arch/state/functional-model.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-FUNCTIONAL-MODEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-functional-state-purpose role=purpose-scope -->
## Purpose and scope

This unit declares profile-only state used by functional initialization, deterministic step observation, and the resumable host-request handshake. These fields are separate from the portable PTO architectural-state requirement.

<!-- PTO-READER-BLOCK: arch-functional-state-concepts role=concepts-state -->
## State groups

- Initialization and started flags constrain when entry/GPR injection is legal.
- Pending, token, next-token, origin PE, request type/argument, result GPR, and resume TPC form one request snapshot.
- `_FunctionalProfileSequence` provides deterministic observation order for reset, initialization, steps, request creation, and completion.

<!-- PTO-READER-BLOCK: arch-functional-state-rules role=rules-interactions -->
## Reset behavior

`ResetFunctionalModelState` clears initialization, started, pending request payload, and sequence. It deliberately preserves `_FunctionalHostRequestNextToken`, so a stale completion from before reset cannot gain authority over a later request in the same model instance.

<!-- PTO-READER-BLOCK: arch-functional-state-boundaries role=boundaries -->
## Snapshot boundary

The open snapshot requirement records that a versioned deterministic envelope is still needed. This page does not authorize copying C structs, exposing implementation pointers, or merging profile state into portable architectural state.

<!-- PTO-READER-BLOCK: arch-functional-state-example role=example-usage -->
## Non-normative lifecycle example

After reset, initialization sets the entry and sequence, a step marks the model started, and a host request freezes its origin/type/argument/result/resume fields until matching completion. A second request cannot coexist with the first.

<!-- PTO-READER-BLOCK: arch-functional-state-related role=related-owners-navigation -->
## Related owners

- [Functional-model profile](../profile/functional-model.md) updates these fields.
- [Functional-model result types](../data-types/functional-model.md) expose the immutable observation record.
- [Execution context](../programming-model/execution-context.md) owns portable PC/BPC and GPR state referenced by the profile.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/functional-model.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-STATE-FUNCTIONAL-MODEL","surface":"arch","classification":["state","functional-model"],"depends_on":["PTO-ARCH-DATA-TYPES-FUNCTIONAL-MODEL","PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-FUNCTIONAL-MODEL-PROFILE","classification":["profile","functional-model"],"scope":"system","owner":"PTO-ARCH-STATE-FUNCTIONAL-MODEL","members":["_FunctionalModelInitialized","_FunctionalModelStarted","_FunctionalHostRequestPending","_FunctionalHostRequestToken","_FunctionalHostRequestNextToken","_FunctionalHostRequestOriginPE","_FunctionalHostRequestType","_FunctionalHostRequestArgument0","_FunctionalHostRequestResultGPR","_FunctionalHostRequestResumeTPC","_FunctionalProfileSequence"],"depends_on":["PTO-STATE-ARCH-GPR","PTO-STATE-ARCH-PROGRAM-CONTROL"]}

// NDF-BEGIN: PTO-REQ-FUNCTIONAL-STATE-SNAPSHOT-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// PTO architecture MUST NOT define a snapshot instruction, architectural
// action, state member, serialized envelope, compatibility rule, or digest.
// Architectural meaning remains owned by [[PTO-REQ-STATE-001]] and named PTO
// profile state. A generated functional model MAY expose a non-architectural
// checkpoint interface over its representation of those owners, but that
// interface MUST NOT add state or change any PTO transition. Physical-memory
// bytes remain governed by PTO memory semantics; checkpoint ownership of host
// byte storage is a model-and-caller contract outside PTO architecture.
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
