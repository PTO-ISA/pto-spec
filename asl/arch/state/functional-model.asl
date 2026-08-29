// PTO-UNIT: {"id":"PTO-ARCH-STATE-FUNCTIONAL-MODEL","surface":"arch","classification":["state","functional-model"],"depends_on":["PTO-ARCH-DATA-TYPES-FUNCTIONAL-MODEL","PTO-ARCH-PROGRAMMING-MODEL-EXECUTION-CONTEXT"]}
// PTO-STATE: {"id":"PTO-STATE-ARCH-FUNCTIONAL-MODEL-PROFILE","classification":["profile","functional-model"],"scope":"system","owner":"PTO-ARCH-STATE-FUNCTIONAL-MODEL","members":["_FunctionalModelInitialized","_FunctionalModelStarted","_FunctionalHostRequestPending","_FunctionalHostRequestToken","_FunctionalHostRequestNextToken","_FunctionalHostRequestOriginPE","_FunctionalHostRequestType","_FunctionalHostRequestArgument0","_FunctionalHostRequestResultGPR","_FunctionalHostRequestResumeTPC","_FunctionalProfileSequence"],"depends_on":["PTO-STATE-ARCH-GPR","PTO-STATE-ARCH-PROGRAM-CONTROL"]}

// NDF-BEGIN: PTO-REQ-FUNCTIONAL-STATE-SNAPSHOT-001
// ndf: kind=contract level=L1 layer=state status=accepted
// A functional-model snapshot MUST encode every member of [[PTO-REQ-STATE-001]]
// and the functional profile-state record in a versioned, deterministic
// envelope. Functional profile state MUST remain separate from portable PTO
// state and MUST NOT be added to [[PTO-REQ-STATE-001]].
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
    _FunctionalHostRequestNextToken = Zeros{PTO_XLEN} + 1;
    _FunctionalHostRequestOriginPE = 0;
    _FunctionalHostRequestType = Zeros{16};
    _FunctionalHostRequestArgument0 = Zeros{PTO_XLEN};
    _FunctionalHostRequestResultGPR = 0;
    _FunctionalHostRequestResumeTPC = Zeros{PTO_XLEN};
    _FunctionalProfileSequence = Zeros{PTO_XLEN};
end;
