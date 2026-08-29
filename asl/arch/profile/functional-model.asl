// PTO-UNIT: {"id":"PTO-ARCH-PROFILE-FUNCTIONAL-MODEL","surface":"arch","classification":["profile","functional-model"],"depends_on":["PTO-ARCH-PROFILE-RESET","PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS"]}

// NDF-BEGIN: PTO-REQ-FUNCTIONAL-HOST-REQUEST-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// A functional-model instance MUST expose at most one pending host request.
// Repeated step while pending MUST return the same immutable token and request
// without fetch, time advance, or architectural effect. Only a matching token
// MAY complete a request; completion MUST write the captured origin PE result
// GPR and shared resume TPC exactly once. A stale or duplicate completion MUST
// be rejected without any state effect.
// NDF-END: PTO-REQ-FUNCTIONAL-HOST-REQUEST-001

// NDF-BEGIN: PTO-REQ-FUNCTIONAL-RESET-001
// ndf: kind=contract level=L1 layer=state status=accepted
// InitializeFunctionalModel MUST perform the complete reference reset, select
// PE0, install the supplied even entry TPC, and leave PE1 through PE3 reset.
// Before the first step, InitializeFunctionalModelGPR MAY initialize only PE0
// absolute GPRs; GPR0 MUST retain its architectural zero behavior.
// NDF-END: PTO-REQ-FUNCTIONAL-RESET-001

// NDF-BEGIN: PTO-REQ-FUNCTIONAL-PROFILE-IDENTITY-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// A generated functional model MUST identify the exact PTO source commit and
// tree, ASLRef pin, encoding ABI, functional profile, generator version, MIR
// schema, and normalized input hashes. A consumer MUST fail closed when its
// required identity does not match that descriptor.
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

    _FunctionalHostRequestPending = TRUE;
    _FunctionalHostRequestToken = _FunctionalHostRequestNextToken;
    if _FunctionalHostRequestNextToken == Ones{PTO_XLEN} then
        _FunctionalHostRequestNextToken = Zeros{PTO_XLEN} + 1;
    else
        _FunctionalHostRequestNextToken = _FunctionalHostRequestNextToken + 1;
    end;
    _FunctionalHostRequestOriginPE = _CurrentMemoryAgent;
    _FunctionalHostRequestType = request_type;
    _FunctionalHostRequestArgument0 = argument0;
    _FunctionalHostRequestResultGPR = result_gpr as GPRIndex;
    _FunctionalHostRequestResumeTPC = resume_tpc;
    _FunctionalProfileSequence = _FunctionalProfileSequence + 1;
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
