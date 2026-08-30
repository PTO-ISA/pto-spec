<!-- GENERATED FROM: asl/arch/dispatch/functional-step.asl -->
# Functional Step

**Generated-model harness ASL source:** `asl/arch/dispatch/functional-step.asl`

This page is a generated reference view of non-architectural model harness ASL. Its model NDF is owned by the downstream model repository; PTO architecture remains owned by the architectural ASL/NDF it invokes.

## ASL unit identity {#PTO-ARCH-DISPATCH-FUNCTIONAL-STEP}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-functional-step-purpose role=purpose-scope -->
## 用途与范围

`ExecuteOnePTOStep` 是架构拥有的功能执行边界。它负责待处理请求观测、指令对齐、取指预检、长度选择、解码/执行分派以及返回给模型使用者的不可变结果。

<!-- PTO-READER-BLOCK: arch-functional-step-concepts role=concepts-state -->
## 有序步骤流水

步骤首先快照 TPC、BPC 和来源 PE。随后处理未初始化或已有待处理请求的配置档状态，检查 TPC 偶数对齐，探测前两个字节，确定 16/32/48/64 位长度，探测完整范围，按小端取回字节，最后调用 `ExecutePTOInstruction`。

<!-- PTO-READER-BLOCK: arch-functional-step-rules role=rules-interactions -->
## 观测与序号规则

解码前退出不会推进 `_FunctionalProfileSequence`，并报告 `NotAttempted`。已取指路径在分派前将序号推进一次。结果随后区分已执行形式、被拒绝形式、ASL 产生的陷阱或宿主请求，并快照指令后的控制/故障/请求字段。

<!-- PTO-READER-BLOCK: arch-functional-step-boundaries role=boundaries -->
## 故障与运行器边界

奇数 TPC 和不可访问取指范围属于解码前陷阱。已接受指令仍可能以陷阱或宿主请求结束。拒绝绝不被解释为进程退出。ELF 策略、停止 PC、步骤上限、进程状态和结果文件发布仍是此 ASL 结果之外的运行器职责。

<!-- PTO-READER-BLOCK: arch-functional-step-example role=example-usage -->
## 非规范 trace 示例

对于位于 `0x100` 的 16 位指令，结果记录 `pre_tpc=0x100`、`raw_instruction` 中的低半字、`length_bits=16` 以及分派后的 TPC。下一次调用若已有待处理请求，则返回同一请求快照而不再取指或推进时间。

<!-- PTO-READER-BLOCK: arch-functional-step-related role=related-owners-navigation -->
## 相关所有者

- [指令取回](../memory-model/instruction-fetch.md)拥有探测和字节组装。
- [功能模型结果类型](../data-types/functional-model.md)定义返回记录。
- [功能模型配置档](../profile/functional-model.md)拥有重置和宿主请求状态。
<!-- SUPPLEMENTARY-END -->

## Model-harness ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/dispatch/functional-step.asl -->
```asl
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
```
<!-- GENERATED-ASL-END: unit -->
