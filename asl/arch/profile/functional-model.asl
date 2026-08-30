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
