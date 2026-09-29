<!-- GENERATED FROM: asl/scalar/model/dispatch/top-level.asl -->
# Top Level

**Normative ASL source:** `asl/scalar/model/dispatch/top-level.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-model-dispatch-top-level-purpose role=purpose-scope -->
## 用途与范围

本单元是单条 16、32 或 48 位标量指令的唯一入口。`ExecuteScalarInstruction` 译码指令字，按固定顺序运行合法性检查，调用一个族分派器，然后推进 TPC 或报告拒绝。

架构级[分派顶层](../../../arch/dispatch/top-level.md)对每个不是已接受命令形式的非 64 位字调用它。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-top-level-concepts role=concepts-state -->
## 概念与可见状态

指令尝试是对入口的一次调用。它以 `BeginArchitecturalInstructionAttempt` 开始，该函数清除 `_LastFault` 和 `_FaultAddress`，并把架构时间推进一。每次尝试都推进一次时间，无论成功与否。

结果为 `ScalarExecution_Executed` 或 `ScalarExecution_Rejected`。被拒绝的尝试会让 `_LastFault` 保持已设置状态。

族是 AGU、ALU、AMO、BRU、FSU 或 SYS 之一。`ScalarFamilyOfForm` 为已译码形式返回其族。

本单元的元数据列出三处经审查的编码重叠。每处中，`SETRET` 类形式占用 `RegDst == 10`，而更宽的 `ADDTPC` 或 `C.MOVI` 形式通过不等约束排除该值。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-top-level-rules role=rules-interactions -->
## 规则与交互

`ExecuteScalarInstruction` 按顺序执行以下步骤。任一检查失败都会引发故障并立即返回 `ScalarExecution_Rejected`。

1. 开始本次尝试。
2. 用 `DecodeScalarForm` 译码形式。未知字引发 `Fault_IllegalInstruction`。
3. 如果指令束处于活动状态但其体尚未进入，则用 `EnterBundleBody` 进入体。
4. 检查 `ScalarOperationApplicable`。失败时引发 `Fault_BundleControl`。
5. 依次检查 `ScalarFormOperandsLegal`（保留字段值）、`ScalarRegisterOperandsLegal`（T/U 源可用性）和 `ScalarImplicitSourceOperandsLegal`（隐式 T#1）。每项失败都引发 `Fault_IllegalInstruction`。
6. 调用族分派器。
7. 如果 `_LastFault` 已设置，返回拒绝。
8. 除非处理函数自行安装 TPC，否则把以字节计的指令长度加到 TPC 上。

设计要点：操作适用性检查和由目录生成的合法性检查在族分派器之前运行。因此不适用的操作、受目录约束的保留字段或不可用的队列源都无法到达处理函数的寄存器、内存或标志效果；仅有的变化是时间推进、`SetFault` 执行的陷阱进入，以及可能的指令束体进入。

设计要点：体进入发生在适用性检查之前。NDF 条款 PTO-REQ-SCALAR-BODY-ENTRY-001 要求如此，并规定之后的标量故障保留体活动转换。未知字在第 2 步被拒绝，因此永远不会进入体。

设计要点：只有在处理函数无故障返回后才推进 TPC。故障会调用 `SetFault`，它用此刻的 TPC 保存陷阱上下文，然后把 TPC 写为陷阱向量入口，因此再加上指令长度会使 TPC 偏离该入口。对于在处理函数改变 TPC 之前引发的故障，保存的 TPC 就是故障指令，PTO-ARCH-MEMORY-MODEL-REPLAY-001 把它规定为重启点。`ScalarHandlerWritesTPC` 列出的三个处理函数跳过第 8 步，因为它们自行设置 TPC。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-top-level-boundaries role=boundaries -->
## 架构边界

本单元不译码字段，也不计算结果。掩码与匹配表以及合法性函数由目录生成；族语义位于各族分派单元中。

形式按目录译码顺序匹配，即按掩码位数从多到少排序。因此较窄的形式优先于可能匹配同一字的较宽形式。

族处理函数内部引发的故障（例如数据故障）同样报告为拒绝。该处理函数较早的效果是否保留，由该族自身的契约决定。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-top-level-example role=example-usage -->
## 非规范阅读示例

两个 32 位字只在位 11:7 上不同。

| 字 | 位 11:7 | 译码形式 | TPC 为 0x400 时的效果 |
| --- | --- | --- | --- |
| 0x00001507 | 10 | `SETRET`（掩码 0xFFF） | GPR 10 得到 0x402 |
| 0x00001587 | 11 | `ADDTPC`（掩码 0x7F） | GPR 11 得到 0x1400 |

`SETRET` 的掩码位更多，因此先被尝试，并占用 `RegDst == 10` 编码。每个字在 TPC 0x400 处执行都会成功，并使 TPC 变为 0x404。

如果该字换成 `ADD` 0x0F818F85，且 T#1 无效，则第 5 步会引发 `Fault_IllegalInstruction`，不会向 T 压入任何值。

<!-- PTO-READER-BLOCK: scalar-model-dispatch-top-level-related role=related-owners-navigation -->
## 相关所有者

- [标量译码辅助函数](decode.md)在合法性检查通过后解释字段。
- [SYS 语义](../sys/semantics.md)拥有 `BeginArchitecturalInstructionAttempt` 和 `ScalarOperationApplicable`。
- [指令束进入与停止](../../../block/model/lifecycle/enter-stop.md)拥有 `EnterBundleBody`。
- [故障精确性](../../../arch/memory-model/fault-precision.md)拥有 `SetFault` 和陷阱包络。
- 各族分派器：[AGU](agu.md)、[ALU](alu.md)、[AMO](amo.md)、[BRU](bru.md)、[FSU](fsu.md) 和 [SYS](sys.md)。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/scalar/model/dispatch/top-level.asl -->
```asl
// PTO-UNIT: {"id":"PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL","surface":"scalar","classification":["model","dispatch","top-level"],"depends_on":["PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP","PTO-SCALAR-MODEL-DISPATCH-ALU","PTO-SCALAR-MODEL-DISPATCH-BRU","PTO-SCALAR-MODEL-DISPATCH-SYS","PTO-SCALAR-MODEL-DISPATCH-AMO","PTO-SCALAR-MODEL-DISPATCH-AGU","PTO-SCALAR-MODEL-DISPATCH-FSU"],"catalog_projection":{"catalog":"scalar-forms","family_constraints":[],"isa":"PTO Instruction Set Architecture","schema_version":2,"reviewed_encoding_overlaps":[{"broad_form_id":"addtpc_32_e5aa0f0abca3","narrow_form_id":"setret_32_72003dcf3b59","reason":"narrow form occupies RegDst == 10, which the broad form excludes via its not-equal constraint"},{"broad_form_id":"c_movi_16_2c84faf1bc72","narrow_form_id":"c_setret_16_335651ef6c27","reason":"narrow form occupies RegDst == 10, which the broad form excludes via its not-equal constraint"},{"broad_form_id":"hl_addtpc_48_2e8e692eea09","narrow_form_id":"hl_setret_48_302bb793a800","reason":"narrow form occupies RegDst == 10, which the broad form excludes via its not-equal constraint"}]}}

// NDF-BEGIN: PTO-REQ-SCALAR-BODY-ENTRY-001
// ndf: kind=contract level=L1 layer=scalar status=accepted
// After a scalar form decodes successfully, scalar dispatch MUST enter any
// active body-inactive bundle, including a Tile block, before operation
// applicability or operand legality. An unmatched carrier MUST reject without
// entering the body. Once decoded, a later scalar fault preserves the
// body-active transition and the active block kind.
// NDF-END: PTO-REQ-SCALAR-BODY-ENTRY-001

func ExecuteScalarInstruction(instruction: bits(48),
                              length_bits: integer {16,32,48})
                              => ScalarExecutionStatus
begin
    BeginArchitecturalInstructionAttempt();
    let decoded = DecodeScalarForm(instruction, length_bits);
    if decoded == PTO_SCALAR_FORM_COUNT then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    let form = decoded as integer {0..PTO_SCALAR_FORM_COUNT-1};
    let operation = ScalarOperationOfForm(form);
    if BundleIsActive() && !BundleBodyIsActive() then
        EnterBundleBody();
    end;
    if !ScalarOperationApplicable(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarFormOperandsLegal(instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarRegisterOperandsLegal(instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    if !ScalarImplicitSourceOperandsLegal(operation) then
        SetFault(Fault_IllegalInstruction, ReadPC());
        return ScalarExecution_Rejected;
    end;
    case ScalarFamilyOfForm(form) of
        when ScalarSemantic_AGU => ExecuteDecodedAGUForm(instruction, form);
        when ScalarSemantic_ALU => ExecuteDecodedALUForm(instruction, form);
        when ScalarSemantic_AMO => ExecuteDecodedAMOForm(instruction, form);
        when ScalarSemantic_BRU => ExecuteDecodedBRUForm(instruction, form);
        when ScalarSemantic_FSU => ExecuteDecodedFSUForm(instruction, form);
        when ScalarSemantic_SYS => ExecuteDecodedSYSForm(instruction, form);
        otherwise => unreachable;
    end;
    if _LastFault != Fault_None then
        return ScalarExecution_Rejected;
    end;
    if !ScalarHandlerWritesTPC(ScalarHandlerOfForm(form)) then
        WriteTPC(ReadTPC() + NaturalToWord(length_bits DIV 8));
    end;
    return ScalarExecution_Executed;
end;
```
<!-- GENERATED-ASL-END: unit -->
