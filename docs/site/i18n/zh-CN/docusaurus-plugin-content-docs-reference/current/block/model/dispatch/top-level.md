<!-- GENERATED FROM: asl/block/model/dispatch/top-level.asl -->
# Top Level

**Normative ASL source:** `asl/block/model/dispatch/top-level.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-top-level-purpose role=purpose-scope -->
## 用途与范围

本单元是单条块命令指令的入口。`ExecuteCommandInstruction` 接收原始指令位及其长度，判断它们是否构成合法命令，并把合法命令交给 `ExecuteDecodedBundleCommand`。它返回 `CommandExecution_Executed` 或 `CommandExecution_Rejected`。

命令是任何块表面指令：`BSTART` 和 `BSTOP` 形式，`B.DIM`、`B.DATR`、`B.IOT`、`B.IOR` 等头部命令，以及 `HL.QPUSH` 或 `MCOPY` 等其他命令形式。当 `DecodeCommandForm` 识别出这些位时，架构入口 `ExecutePTOInstruction` 调用本单元。

<!-- PTO-READER-BLOCK: block-model-dispatch-top-level-concepts role=concepts-state -->
## 概念与可见状态

- 命令形式是一种已接受的编码。`DecodeCommandForm` 返回其索引；没有匹配形式时返回 `PTO_COMMAND_FORM_COUNT`。
- 处理器是某个形式的语义动作，由 `CommandHandlerOfForm` 返回。
- `_SystemBlockTerminalPending` 是块控制标志。标量 `ACRC` 请求在系统块内设置它。指令束开始或头部状态被清除时它会被清除。

本单元读取 `_SystemBlockTerminalPending` 和 `TPC`。在任何检查之前，它调用 `BeginArchitecturalInstructionAttempt`，清除 `_LastFault` 与 `_FaultAddress` 并推进架构时间。

<!-- PTO-READER-BLOCK: block-model-dispatch-top-level-rules role=rules-interactions -->
## 规则与交互

本单元按顺序进行三项检查。每项检查失败时都在当前 `TPC` 处引发故障并返回 `CommandExecution_Rejected`。

1. 没有匹配的命令形式时，引发 `Fault_IllegalInstruction`。
2. 系统块终止请求挂起时，除 `CommandHandler_ExecuteBundleStop` 或 `CommandHandler_ExecuteBundleStart` 以外的任何处理器都引发 `Fault_BundleControl`。
3. 如果 `CommandFormOperandsLegal` 拒绝匹配形式的操作数字段，引发 `Fault_IllegalInstruction`。

只有通过全部三项检查的命令才会到达 `ExecuteDecodedBundleCommand`，其状态被原样返回。

设计要点：`ACRC` 把系统块标记为正在终止之后，后面只允许出现结束指令束的两种命令。其他命令在其处理器运行之前就以 `Fault_BundleControl` 被拒绝，因此无法向已在关闭的指令束添加头部状态。

设计要点：ASL 注释指出，16 位模式 `0x0800` 在普通指令束中是压缩的 `C.BSTART.STD FALL`，但在进行选择的旧式入口边界处是压缩停止，并且这一消歧保留在 ASL 中且依赖上下文。在当前文本中，`normalized_instruction` 就是未改变的输入，因此本单元不做任何改写。该注释记录的是这一选择所属的位置。

由于尝试在译码之前就已开始，被拒绝的命令仍计为一次架构尝试，其故障会取代前一条指令遗留的任何故障。

<!-- PTO-READER-BLOCK: block-model-dispatch-top-level-boundaries role=boundaries -->
## 架构边界

本单元不执行任何命令语义。放置规则、流规则、各处理器的合法性以及 `TPC` 推进属于 `ExecuteDecodedBundleCommand`。形式译码器与操作数字段合法性谓词由命令编码目录生成；本单元只调用它们。在命令与标量指令之间做出判断属于架构分派所有者。

<!-- PTO-READER-BLOCK: block-model-dispatch-top-level-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

在系统块内，程序执行 `ACRC`，设置了 `_SystemBlockTerminalPending`。下一条指令是 `B.DIM` 命令。它译码为合法形式，但其处理器是 `CommandHandler_SetBundleDimension`，因此本单元引发 `Fault_BundleControl` 并返回 `CommandExecution_Rejected`。如果下一条指令是 `BSTOP`，它会通过这项检查并到达停止处理器。

<!-- PTO-READER-BLOCK: block-model-dispatch-top-level-related role=related-owners-navigation -->
## 相关所有者

- [Architecture dispatch](../../../arch/dispatch/top-level.md) 针对已识别的命令编码调用本单元。
- [Commands](commands.md) 定义 `ExecuteDecodedBundleCommand` 以及各处理器的规则。
- [Decode](decode.md) 定义处理器映射与顺序推进。
- [ACRC](../../../scalar/sys/ACRC.md) 是设置终止标志的标量请求。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/top-level.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL","surface":"block","classification":["model","dispatch","top-level"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-COMMANDS"]}
func ExecuteCommandInstruction(instruction: bits(64),
                               length_bits: integer {16,32,48,64})
                               => CommandExecutionStatus
begin
    BeginArchitecturalInstructionAttempt();
    // 0x0800 is emitted as C.BSTART.STD FALL in ordinary fallthrough
    // bundles, but as a compressed stop at the selecting legacy entry
    // boundary. Keep the disambiguation in ASL and context-sensitive.
    let normalized_instruction = instruction;
    let decoded = DecodeCommandForm(normalized_instruction, length_bits);
    if decoded == PTO_COMMAND_FORM_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    let form = decoded as integer {0..PTO_COMMAND_FORM_COUNT-1};
    let handler = CommandHandlerOfForm(form);
    if _SystemBlockTerminalPending &&
       handler != CommandHandler_ExecuteBundleStop &&
       handler != CommandHandler_ExecuteBundleStart then
        SetFault(Fault_BundleControl, ReadTPC());
        return CommandExecution_Rejected;
    end;
    if !CommandFormOperandsLegal(normalized_instruction, form) then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return CommandExecution_Rejected;
    end;
    return ExecuteDecodedBundleCommand(normalized_instruction, form, length_bits);
end;
```
<!-- GENERATED-ASL-END: unit -->
