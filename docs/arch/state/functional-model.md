<!-- GENERATED FROM: asl/arch/state/functional-model.asl -->
# Functional Model

**Normative ASL source:** `asl/arch/state/functional-model.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-FUNCTIONAL-MODEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

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
