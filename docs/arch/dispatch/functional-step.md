<!-- GENERATED FROM: asl/arch/dispatch/functional-step.asl -->
# Functional Step

**Executable model-contract ASL source:** `asl/arch/dispatch/functional-step.asl`

This page is a generated reference view of a non-architectural functional-model contract. PTO architecture remains owned by the architectural ASL/NDF that this model contract invokes.

## ASL unit identity {#PTO-ARCH-DISPATCH-FUNCTIONAL-STEP}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-functional-step-purpose role=purpose-scope -->
## Purpose and scope

`ExecuteOnePTOStep` is the model-owned functional execution boundary. It owns pending-request observation and the immutable result returned to a consumer while invoking PTO-owned alignment, fetch, length, decode, legality, execution, PC, and fault semantics without redefining them.

<!-- PTO-READER-BLOCK: arch-functional-step-concepts role=concepts-state -->
## Ordered step pipeline

The step first snapshots TPC, BPC, and origin PE. It then handles uninitialized or already-pending profile state, checks even TPC alignment, probes the first two bytes, determines 16/32/48/64-bit length, probes the complete range, fetches little-endian bytes, and finally invokes `ExecutePTOInstruction`.

<!-- PTO-READER-BLOCK: arch-functional-step-rules role=rules-interactions -->
## Observation and sequencing rules

Predecode exits do not advance `_FunctionalProfileSequence` and report `NotAttempted`. A fetched path advances this model-only sequence once before dispatch. The result then distinguishes an executed form, rejected form, ASL-produced trap, or host request and snapshots the post-instruction control/fault/request fields.

<!-- PTO-READER-BLOCK: arch-functional-step-boundaries role=boundaries -->
## Fault and runner boundaries

Odd TPC and inaccessible fetch ranges are PTO architectural predecode traps. An accepted instruction may still finish as a trap or model host request. Rejection is never interpreted as process exit. The step envelope itself is model architecture; ELF policy, stop-PC, step limits, process status, and result-file publication remain runner or hosted-ABI concerns.

<!-- PTO-READER-BLOCK: arch-functional-step-example role=example-usage -->
## Non-normative trace example

For a 16-bit instruction at `0x100`, the result records `pre_tpc=0x100`, the fetched low halfword in `raw_instruction`, `length_bits=16`, and the post-dispatch TPC. A pending request on the next call returns the same request snapshot without fetching another instruction.

<!-- PTO-READER-BLOCK: arch-functional-step-related role=related-owners-navigation -->
## Related owners

- [Instruction fetch](../memory-model/instruction-fetch.md) owns probe and byte assembly.
- [Functional-model result types](../data-types/functional-model.md) define the returned record.
- [Functional-model profile](../profile/functional-model.md) owns reset and host-request state.
<!-- SUPPLEMENTARY-END -->

## Model-contract ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/dispatch/functional-step.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DISPATCH-FUNCTIONAL-STEP","surface":"arch","classification":["dispatch","functional-step"],"depends_on":["PTO-ARCH-DISPATCH-TOP-LEVEL","PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH","PTO-ARCH-PROFILE-FUNCTIONAL-MODEL"]}

// PTO-MODEL-CONTRACT-BEGIN: PTO-REQ-FUNCTIONAL-STEP-001
// contract: layer=model status=accepted
// ExecuteOnePTOStep MUST process pending host state before alignment or fetch,
// then validate TPC alignment, probe two bytes, determine length, probe the
// complete instruction, fetch little-endian bytes, and invoke the unique PTO
// instruction dispatcher. Pending and predecode fault paths MUST NOT advance
// architectural time. A decoded path MUST advance time exactly once and MUST
// report whether the instruction was not attempted, executed, or rejected,
// together with the resulting precise trap cause rather than interpreting
// rejection as exit. A host-request result MUST snapshot the immutable request
// token, origin, type, and scalar argument. This step envelope is functional-
// model control; it does not add an instruction or architectural state.
// PTO-MODEL-CONTRACT-END: PTO-REQ-FUNCTIONAL-STEP-001

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
```
<!-- GENERATED-ASL-END: unit -->
