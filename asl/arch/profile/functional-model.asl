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
