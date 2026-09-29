<!-- GENERATED FROM: asl/block/model/dispatch/start.asl -->
# Start

**Normative ASL source:** `asl/block/model/dispatch/start.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-START}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-start-purpose role=purpose-scope -->
## 用途与范围

本单元执行已译码的 `BSTART` 形式。`BSTART` 打开一个指令束：一组头部命令和主体指令，在 `BSTOP` 或下一个 `BSTART` 处作为一个整体提交。

`ExecuteDecodedBundleStartWithAcceptedApplicabilityRules` 按固定顺序完成四件事：校验操作描述符，计算候选续行目标，提交任何活动的前驱指令束，然后打开新的指令束。`ExecuteDecodedBundleStart` 是以 `NumericApplicabilityRules_None` 调用的同一函数。命令分派器针对 `CommandHandler_ExecuteBundleStart` 调用它。

<!-- PTO-READER-BLOCK: block-model-dispatch-start-concepts role=concepts-state -->
## 概念与可见状态

- 操作描述符由 `DecodeBundleOperationDescriptor` 从指令中译码。它给出指令束在提交时要执行的操作类别、选择子、数据类型以及可选的分支类型。
- 当设置了 `branch_type_valid` 时，转移种类取自描述符的分支类型，否则取自已编码的形式。
- 顺序地址是指令 PC 加上以字节计的指令长度。
- 返回目标是顺序地址；但如果该形式带有 `uimm5` 字段，则返回目标是指令 PC 加上长度减 2，再加上左移 1 位的 `uimm5`。
- 只有条件转移的 `taken` 为假。

本单元读取 `_BundleActive`、`_BARG`、`_ReturnAddress` 和 `TPC`。它通过 `CompleteBundleAtWithAcceptedApplicabilityRules`（前驱提交）、`ClearBundleHeaderState`、`BeginBundleAt` 和 `InstallBundleOperationDescriptor` 写入指令束状态，并用 `SetFault` 记录故障。

<!-- PTO-READER-BLOCK: block-model-dispatch-start-rules role=rules-interactions -->
## 规则与交互

目标按以下顺序选择：`Return` 使用 `_ReturnAddress`；`Indirect` 和 `IndirectCall` 使用即将退役指令束的 `BARG.BPCN`；`Fallthrough` 使用顺序地址；带有符号偏移的形式使用 `TPC` 加上左移 1 位的偏移；其他形式使用顺序地址。

会引发故障的检查依次为：

1. 非法描述符，或被已接受适用性规则拒绝的描述符，引发 `Fault_IllegalInstruction`。
2. 没有即将退役的 Standard 或 Floating 指令束时的间接转移，引发 `Fault_BundleControl`。
3. 位 0 置位的目标引发 `Fault_InstructionPC`。

这三项都在前驱提交之前发生，因此被拒绝的 `BSTART` 会保留活动的前驱指令束。

设计要点：间接 `BSTART` 在即将退役的指令束提交之前读取其 `BARG.BPCN`。`RetiringBundleBPCNAvailable` 要求存在活动的 Standard 或 Floating 指令束，因为只有这两类带有候选字。该值以快照形式保存在 `retiring_bpcn` 中，因此提交不会改变它。

设计要点：NDF 条款 `PTO-REQ-BSTART-PREDECESSOR-TRANSFER-001` 要求只有当前驱提交选择了本指令 PC 时才安装取到的 `BSTART`。如果前驱提交失败，或转移到其他位置，函数直接返回而不打开指令束。该 `BSTART` 位于程序未走的路径上，前驱选定的 `TPC` 被保留。

前驱步骤之后，本单元清除头部状态并调用 `BeginBundleAt`。只有未记录故障时，它才安装描述符。

<!-- PTO-READER-BLOCK: block-model-dispatch-start-boundaries role=boundaries -->
## 架构边界

本单元不译码命令形式，也不检查该形式的操作数字段；顶层命令分派器先完成这些。它不定义提交的内容，那属于提交校验所有者，它执行选定的 Tile 操作然后停止指令束。它也不直接写入 `BARG`、`BPC` 或执行域令牌；这些写入由 `BeginBundleAt` 负责。

<!-- PTO-READER-BLOCK: block-model-dispatch-start-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

假设一个 Standard 指令束处于活动状态，其 `BARG` 选择顺序续行。位于 `0x1010` 的 4 字节 `BSTART` 带有符号偏移 `0x40`。目标为 `0x1010 + 0x80 = 0x1090`，是偶数。前驱提交后续行地址为 `0x1010`，等于指令 PC。新指令束打开，`BPCN` 为 `0x1090`，`TPC` 为 `0x1014`。如果前驱选择的是 `0x2000`，该 `BSTART` 不会打开指令束，执行在 `0x2000` 继续。

<!-- PTO-READER-BLOCK: block-model-dispatch-start-related role=related-owners-navigation -->
## 相关所有者

- [Begin](../lifecycle/begin.md) 定义打开指令束的状态转换。
- [Commit validation](../commit/validation.md) 定义前驱提交。
- [Commands](commands.md) 将 `CommandHandler_ExecuteBundleStart` 路由到本单元。
- [Descriptor legality](descriptor-legality.md) 定义描述符合法性与分支类型映射。
- [BSTART](../../lifecycle/BSTART.md) 是普通启动形式的指令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/start.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-START","surface":"block","classification":["model","dispatch","start"],"depends_on":["PTO-BLOCK-MODEL-COMMIT-VALIDATION"]}

// NDF-BEGIN: PTO-REQ-BSTART-PREDECESSOR-TRANSFER-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A following BSTART MUST first commit an active predecessor.  It MUST install
// the fetched BSTART only when the predecessor-selected TPC equals the fetched
// instruction PC; otherwise it MUST preserve that selected TPC and MUST NOT
// install the BSTART from the unselected path.
// NDF-END: PTO-REQ-BSTART-PREDECESSOR-TRANSFER-001

readonly func CommandDecodedBundleTarget(
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1}) => Word
begin
    let offset = CommandSignedOffsetOfForm(instruction, form);
    return ReadTPC() + LSL(offset, 1);
end;

readonly func RetiringBundleBPCNAvailable() => boolean
begin
    return _BundleActive &&
           (_BARG.block_type == BundleKind_Standard ||
            _BARG.block_type == BundleKind_Floating);
end;

func ExecuteDecodedBundleStartWithAcceptedApplicabilityRules(
    rules: NumericApplicabilityRuleSet,
    instruction: bits(64),
    form: integer {0..PTO_COMMAND_FORM_COUNT-1},
    length_bits: integer {16,32,48,64})
begin
    let instruction_pc = ReadTPC();
    let kind = CommandBundleKindOfForm(form);
    let descriptor = DecodeBundleOperationDescriptor(instruction, form);
    if !BundleOperationDescriptorLegal(descriptor) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    if BundleOperationDescriptorRejectedByAcceptedApplicabilityRules(
        rules, descriptor) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return;
    end;
    let transfer = if descriptor.branch_type_valid then
        BundleTransferOfBranchType(descriptor.branch_type)
        else CommandBundleTransferOfForm(form);
    let fallthrough = instruction_pc +
        (Zeros{PTO_XLEN} + (length_bits DIV 8));
    let reads_retiring_bpcn =
        transfer == BundleTransfer_Indirect ||
        transfer == BundleTransfer_IndirectCall;
    if reads_retiring_bpcn && !RetiringBundleBPCNAvailable() then
        SetFault(Fault_BundleControl, instruction_pc);
        return;
    end;
    let retiring_bpcn = _BARG.bpcn;
    let target = if transfer == BundleTransfer_Return then _ReturnAddress
        else if reads_retiring_bpcn then retiring_bpcn
        else if transfer == BundleTransfer_Fallthrough then fallthrough
        else if CommandHasSignedOffset(form) then
            CommandDecodedBundleTarget(instruction, form)
        else fallthrough;
    let return_target = if CommandOperandPresent(form, CommandField_uimm5) then
        instruction_pc + (Zeros{PTO_XLEN} + ((length_bits DIV 8) - 2)) +
        LSL(CommandDecodedWord(instruction, form, CommandField_uimm5), 1)
        else fallthrough;
    let taken = transfer != BundleTransfer_Conditional;
    if target[0] == '1' then
        SetFault(Fault_InstructionPC, target);
        return;
    end;
    // A following BSTART first commits the active predecessor.  The fetched
    // BSTART is installed only when that commit selects this instruction PC;
    // otherwise it belongs to an unselected path and must not replace the
    // predecessor-selected continuation.
    if _BundleActive then
        if !CompleteBundleAtWithAcceptedApplicabilityRules(
            rules, instruction_pc) then
            return;
        end;
        if ReadTPC() != instruction_pc then
            return;
        end;
    end;
    ClearBundleHeaderState();
    BeginBundleAt(instruction_pc, kind, transfer, target, fallthrough,
        return_target, taken);
    if _LastFault == Fault_None then
        InstallBundleOperationDescriptor(descriptor);
    end;
end;

func ExecuteDecodedBundleStart(instruction: bits(64),
                              form: integer {0..PTO_COMMAND_FORM_COUNT-1},
                              length_bits: integer {16,32,48,64})
begin
    ExecuteDecodedBundleStartWithAcceptedApplicabilityRules(
        NumericApplicabilityRules_None, instruction, form, length_bits);
end;
```
<!-- GENERATED-ASL-END: unit -->
