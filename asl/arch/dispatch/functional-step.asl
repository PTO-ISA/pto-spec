// PTO-UNIT: {"id":"PTO-ARCH-DISPATCH-FUNCTIONAL-STEP","surface":"arch","classification":["dispatch","functional-step"],"depends_on":["PTO-ARCH-DISPATCH-TOP-LEVEL","PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH","PTO-ARCH-PROFILE-FUNCTIONAL-MODEL"]}

// Non-architectural generated-model harness.  Its model NDF is owned by
// the downstream model repository docs/pto-asl-functional-model-ndf-v1.json.

pure func DeterminePTOInstructionLength(
    first_halfword: bits(16)) => integer {16,32,48,64}
begin
    if first_halfword[3:1] == '111' then
        if first_halfword[0] == '0' then return 48;
        else return 64;
        end;
    elsif first_halfword[0] == '0' then
        return 16;
    else
        return 32;
    end;
end;

readonly func CurrentFunctionalStepFaultCause() => bits(24)
begin
    if _LastFault == Fault_None then return Zeros{24}; end;
    return _ACRTrapCause[[CurrentACR()]];
end;

readonly func EmptyFunctionalStepResult(
    status: PTOFunctionalStepStatus,
    pre_tpc: Word,
    pre_bpc: Word,
    origin_pe: MemoryAgentId) => PTOFunctionalStepResult
begin
    var result: PTOFunctionalStepResult;
    result.status = status;
    result.instruction_status = PTOFunctionalInstruction_NotAttempted;
    result.pre_tpc = pre_tpc;
    result.post_tpc = ReadTPC();
    result.pre_bpc = pre_bpc;
    result.post_bpc = ReadBPC();
    result.raw_instruction = Zeros{64};
    result.length_bits = 0;
    result.fault = _LastFault;
    result.fault_address = _FaultAddress;
    result.fault_cause = CurrentFunctionalStepFaultCause();
    result.origin_pe = origin_pe;
    result.request_token = Zeros{PTO_XLEN};
    result.request_type = Zeros{16};
    result.request_argument0 = Zeros{PTO_XLEN};
    result.sequence = _FunctionalProfileSequence;
    return result;
end;

func ExecuteOnePTOStep() => PTOFunctionalStepResult
begin
    let pre_tpc = ReadTPC();
    let pre_bpc = ReadBPC();
    let origin_pe = _CurrentMemoryAgent;

    if !_FunctionalModelInitialized then
        return EmptyFunctionalStepResult(
            PTOFunctionalStep_Unsupported, pre_tpc, pre_bpc, origin_pe);
    end;

    if FunctionalModelHostRequestPending() then
        var pending = EmptyFunctionalStepResult(
            PTOFunctionalStep_HostRequest,
            pre_tpc,
            pre_bpc,
            FunctionalModelHostRequestOriginPE());
        pending.request_token = FunctionalModelHostRequestToken();
        pending.request_type = FunctionalModelHostRequestType();
        pending.request_argument0 = FunctionalModelHostRequestArgument0();
        return pending;
    end;

    if pre_tpc[0] == '1' then
        SetFault(Fault_InstructionPC, pre_tpc);
        return EmptyFunctionalStepResult(
            PTOFunctionalStep_Trap, pre_tpc, pre_bpc, origin_pe);
    end;

    let prefix_probe = ProbeInstructionAccess(pre_tpc, 2);
    if !prefix_probe.permitted then
        SetFault(Fault_InstructionPage, pre_tpc);
        return EmptyFunctionalStepResult(
            PTOFunctionalStep_Trap, pre_tpc, pre_bpc, origin_pe);
    end;

    let prefix_instruction = FetchPTOInstruction(prefix_probe, 16);
    let first_halfword = prefix_instruction[15:0];
    let length_bits = DeterminePTOInstructionLength(first_halfword);
    let size_bytes = (length_bits DIV 8) as integer {2,4,6,8};
    let full_probe = ProbeInstructionAccess(pre_tpc, size_bytes);
    if !full_probe.permitted ||
       full_probe.translated_address != prefix_probe.translated_address then
        SetFault(Fault_InstructionPage, pre_tpc);
        var fault_result = EmptyFunctionalStepResult(
            PTOFunctionalStep_Trap, pre_tpc, pre_bpc, origin_pe);
        fault_result.length_bits = length_bits;
        return fault_result;
    end;

    let instruction = FetchPTOInstruction(full_probe, length_bits);
    _FunctionalModelStarted = TRUE;
    _FunctionalProfileSequence = _FunctionalProfileSequence + 1;
    let execution = ExecutePTOInstruction(instruction, length_bits);

    var result = EmptyFunctionalStepResult(
        PTOFunctionalStep_Executed, pre_tpc, pre_bpc, origin_pe);
    result.raw_instruction = instruction;
    result.length_bits = length_bits;
    result.instruction_status =
        if execution == PTOInstruction_Executed then
            PTOFunctionalInstruction_Executed
        else
            PTOFunctionalInstruction_Rejected;
    if FunctionalModelHostRequestPending() then
        result.status = PTOFunctionalStep_HostRequest;
        result.request_token = FunctionalModelHostRequestToken();
        result.request_type = FunctionalModelHostRequestType();
        result.request_argument0 = FunctionalModelHostRequestArgument0();
    elsif execution == PTOInstruction_Rejected ||
          _LastFault != Fault_None then
        result.status = PTOFunctionalStep_Trap;
    end;
    result.post_tpc = ReadTPC();
    result.post_bpc = ReadBPC();
    result.fault = _LastFault;
    result.fault_address = _FaultAddress;
    result.fault_cause = CurrentFunctionalStepFaultCause();
    return result;
end;
