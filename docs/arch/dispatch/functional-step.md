<!-- GENERATED FROM: asl/arch/dispatch/functional-step.asl -->
# Functional Step

**Normative ASL source:** `asl/arch/dispatch/functional-step.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DISPATCH-FUNCTIONAL-STEP}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/dispatch/functional-step.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DISPATCH-FUNCTIONAL-STEP","surface":"arch","classification":["dispatch","functional-step"],"depends_on":["PTO-ARCH-DISPATCH-TOP-LEVEL","PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH","PTO-ARCH-PROFILE-FUNCTIONAL-MODEL"]}

// NDF-BEGIN: PTO-REQ-FUNCTIONAL-STEP-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// ExecuteOnePTOStep MUST process pending host state before alignment or fetch,
// then validate TPC alignment, probe two bytes, determine length, probe the
// complete instruction, fetch little-endian bytes, and invoke the unique PTO
// instruction dispatcher. Pending and predecode fault paths MUST NOT advance
// architectural time. A decoded path MUST advance time exactly once and MUST
// report the resulting precise trap rather than interpreting rejection as exit.
// NDF-END: PTO-REQ-FUNCTIONAL-STEP-001

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

readonly func EmptyFunctionalStepResult(
    status: PTOFunctionalStepStatus,
    pre_tpc: Word,
    pre_bpc: Word,
    origin_pe: MemoryAgentId) => PTOFunctionalStepResult
begin
    var result: PTOFunctionalStepResult;
    result.status = status;
    result.pre_tpc = pre_tpc;
    result.post_tpc = ReadTPC();
    result.pre_bpc = pre_bpc;
    result.post_bpc = ReadBPC();
    result.raw_instruction = Zeros{64};
    result.length_bits = 0;
    result.fault = _LastFault;
    result.fault_address = _FaultAddress;
    result.origin_pe = origin_pe;
    result.request_token = Zeros{PTO_XLEN};
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
            PTOFunctionalStep_HostRequest, pre_tpc, pre_bpc, origin_pe);
        pending.request_token = FunctionalModelHostRequestToken();
        return pending;
    end;

    if pre_tpc[0] == '1' then
        SetFault(Fault_InstructionPC, pre_tpc);
        return EmptyFunctionalStepResult(
            PTOFunctionalStep_Trap, pre_tpc, pre_bpc, origin_pe);
    end;

    if !ProbeInstructionAccess(pre_tpc, 2) then
        SetFault(Fault_InstructionPage, pre_tpc);
        return EmptyFunctionalStepResult(
            PTOFunctionalStep_Trap, pre_tpc, pre_bpc, origin_pe);
    end;

    let prefix_instruction = FetchPTOInstruction(pre_tpc, 16);
    let first_halfword = prefix_instruction[15:0];
    let length_bits = DeterminePTOInstructionLength(first_halfword);
    let size_bytes = (length_bits DIV 8) as integer {2,4,6,8};
    if !ProbeInstructionAccess(pre_tpc, size_bytes) then
        SetFault(Fault_InstructionPage, pre_tpc);
        var fault_result = EmptyFunctionalStepResult(
            PTOFunctionalStep_Trap, pre_tpc, pre_bpc, origin_pe);
        fault_result.length_bits = length_bits;
        return fault_result;
    end;

    let instruction = FetchPTOInstruction(pre_tpc, length_bits);
    _FunctionalModelStarted = TRUE;
    _FunctionalProfileSequence = _FunctionalProfileSequence + 1;
    let execution = ExecutePTOInstruction(instruction, length_bits);

    var result = EmptyFunctionalStepResult(
        PTOFunctionalStep_Executed, pre_tpc, pre_bpc, origin_pe);
    result.raw_instruction = instruction;
    result.length_bits = length_bits;
    if FunctionalModelHostRequestPending() then
        result.status = PTOFunctionalStep_HostRequest;
        result.request_token = FunctionalModelHostRequestToken();
    elsif execution == PTOInstruction_Rejected ||
          _LastFault != Fault_None then
        result.status = PTOFunctionalStep_Trap;
    end;
    result.post_tpc = ReadTPC();
    result.post_bpc = ReadBPC();
    result.fault = _LastFault;
    result.fault_address = _FaultAddress;
    return result;
end;
```
<!-- GENERATED-ASL-END: unit -->
