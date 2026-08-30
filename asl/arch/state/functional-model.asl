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
