<!-- GENERATED FROM: asl/arch/dispatch/top-level.asl -->
# Top Level

**Normative ASL source:** `asl/arch/dispatch/top-level.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-DISPATCH-TOP-LEVEL}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-dispatch-top-level-purpose-scope role=purpose-scope -->
## 目的与范围

`ExecutePTOInstruction` 是本页唯一的已解码指令入口。它接收已完成取指的载体 `instruction: bits(64)` 以及 `length_bits: integer {16,32,48,64}`，并返回两个 `PTOInstructionExecutionStatus` 取值之一：`PTOInstruction_Executed` 或 `PTOInstruction_Rejected`。

`ExecuteNextPTOInstruction` 是取指侧：它读取程序计数器、预检并取指相应字节，然后调用 `ExecutePTOInstruction`。

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-concepts-state role=concepts-state -->
## 判定顺序

分派器首先只问一个问题：`DecodeCommandForm(instruction, length_bits)`。该结果在检查 `length_bits` 之前就被判定，凡是能给出形式的长度都会连同完整的 `bits(64)` 载体和原始长度交给 `ExecuteCommandInstruction`。

- `length_bits != 64`：低 `48` 位即 `instruction[47:0]` 交给 `ExecuteScalarInstruction`，`length_bits` 收窄为 `16`、`32` 或 `48`。
- `length_bits == 64`：不再运行第二个解码器。分派器调用 `BeginArchitecturalInstructionAttempt()`，随后调用 `SetFault(Fault_IllegalInstruction, ReadTPC())`，并返回 `PTOInstruction_Rejected`。
- 在两个委托分支中，所有非 `Executed` 的归属单元状态都会变成 `PTOInstruction_Rejected`；这个二值结果不提供关于原因的更多信息。

设计要点：即使 `ExecuteScalarInstruction` 会接受 `48` 位切片，无法匹配的 `64` 位情形也与标量情形分开处理。其后果是没有命令形式的 `64` 位值无法进入标量解码，因此绝不会被静默地按低 `48` 位解码。

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-rules-interactions role=rules-interactions -->
## 规则与交互

`ExecuteNextPTOInstruction` 只读取一次 `ReadTPC()` 存入 `instruction_pc`，并在任何内存预检之前拒绝奇数地址：若 `instruction_pc[0] == '1'`，它在该地址抛出 `Fault_InstructionPC` 并返回 `PTOInstruction_Rejected`。

否则它预检 `2` 字节，取指 `16` 位前缀，并通过 `DeterminePTOInstructionLength` 从 `prefix[15:0]` 判定长度：位 `3:1` 等于 `'111'` 时，位 `0` 为 `'0'` 选取 `48`，为 `'1'` 选取 `64`；其他情况下位 `0` 为 `'0'` 选取 `16`，为 `'1'` 选取 `32`。

第二次预检覆盖整个所选范围，`size_bytes = length_bits DIV 8`，取值为 `2`、`4`、`6` 或 `8` 之一。它必须被允许，并且必须报告与前缀预检相同的 `physical_address`；否则取指在原始 TPC 处抛出 `Fault_InstructionPage`。`TranslateInstructionAddress` 原样返回其参数，因此在本模型中地址相等总是成立，该分支只能通过“完整范围不被允许”到达。

设计要点：完整范围预检发生在 `16` 位前缀读取之后、其余字节之前。`FetchPTOInstruction` 断言 `probe.permitted`，并且只把已预检的 `size_bytes` 组装进一个 `Zeros{64}` 载体，因此第二次预检失败的范围会在原始 TPC 处产生页故障，而不会从模型内存中多读任何字节。

设计要点：每次调用只开始一次架构尝试。`ExecuteCommandInstruction` 与 `ExecuteScalarInstruction` 各自在函数体内开始自己的尝试，而分派器只在无法匹配的 `64` 位路径上开始一次。可观察的后果是：每次分派架构时间只前进一个单位，且在被选中的归属单元运行前 `_LastFault` 只被清除一次。

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-boundaries role=boundaries -->
## 架构边界

`ExecutePTOInstruction` 自身不做任何操作数、寄存器或状态合法性检查。匹配到的命令形式由 `ExecuteCommandInstruction` 检查：当 `CommandFormOperandsLegal` 失败时抛出 `Fault_IllegalInstruction`，当待处理的终止块状态禁止所选处理程序时抛出 `Fault_BundleControl`。匹配到的标量形式由 `ExecuteScalarInstruction` 检查：对不可用的操作抛出 `Fault_BundleControl`，对形式、寄存器与隐式源合法性失败抛出 `Fault_IllegalInstruction`。

标量归属单元用 `ReadPC()` 报告其非法指令故障，分派器用 `ReadTPC()` 报告无法匹配的 `64` 位故障。这两个函数读取同一个 `_PC` 变量，因此两种途径报告的地址是同一个程序计数器值。

设计要点：对一个匹配到的命令形式，`DecodeCommandForm` 会被调用两次：一次在分派器中，一次在 `ExecuteCommandInstruction` 内部。它是载体与长度的纯函数，两次调用返回相同的形式；因此分派器无需传递已解码的形式，而命令归属单元在被直接进入时也依然正确。

保持不变的部分：分派器自身不写任何寄存器。在无法匹配的 `64` 位路径上，状态变化来自它调用的两个函数：`BeginArchitecturalInstructionAttempt` 清除 `_LastFault` 与 `_FaultAddress` 并推进架构时间，`SetFault` 记录每环陷阱字段、切换当前 ACR，并把 TPC 重定向到陷阱向量入口。

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-example-usage role=example-usage -->
## 非规范阅读示例

长度规则有四个角，每个角决定完整预检覆盖多少字节。

| 首半字 | 所选长度 | 预检字节数 |
| --- | --- | --- |
| 位 `3:1` 为 `'111'`，位 `0` 为 `'1'` | `64` | `8` |
| 位 `3:1` 为 `'111'`，位 `0` 为 `'0'` | `48` | `6` |
| 位 `3:1` 不为 `'111'`，位 `0` 为 `'0'` | `16` | `2` |
| 位 `3:1` 不为 `'111'`，位 `0` 为 `'1'` | `32` | `4` |

对于 `16` 位长度，载体被组装进一个 `Zeros{64}` 值，因此位 `15:0` 保存取到的两个字节，位 `63:16` 保持为 `0`。如果命令解码器对该载体报告无形式，`ExecutePTOInstruction` 会收到 `instruction[47:0]`，并以长度 `16` 把它分派给 `ExecuteScalarInstruction`。

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-related-owners role=related-owners-navigation -->
## 相关归属单元

- [指令取指](../memory-model/instruction-fetch.md) 拥有两次预检、长度规则与字节读取。
- [命令分派归属单元](../../block/model/dispatch/top-level.md) 拥有命令形式合法性与指令束效果。
- [标量分派归属单元](../../scalar/model/dispatch/top-level.md) 拥有标量解码、适用性与 TPC 前进。
- [程序计数器](../state/program-counter.md) 定义 `ReadTPC()`、`ReadPC()` 及其共享的 `_PC` 变量。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/dispatch/top-level.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DISPATCH-TOP-LEVEL","surface":"arch","classification":["dispatch","top-level"],"depends_on":["PTO-ARCH-MEMORY-MODEL-INSTRUCTION-FETCH","PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL","PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL"]}

// NDF-BEGIN: PTO-REQ-INSTRUCTION-DISPATCH-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// ExecutePTOInstruction is the unique encoded-instruction entry point. It MUST
// prefer an accepted 64-bit command form, dispatch non-64-bit input to scalar
// decoding, and reject an otherwise unmatched 64-bit value with
// Fault_IllegalInstruction after beginning exactly one architectural attempt.
// ExecuteNextPTOInstruction MUST fetch through PTO-REQ-INSTRUCTION-FETCH-001
// and then invoke this encoded entry point without adding another decoder.
// NDF-END: PTO-REQ-INSTRUCTION-DISPATCH-001

type PTOInstructionExecutionStatus of enumeration {
    PTOInstruction_Executed,
    PTOInstruction_Rejected
};

func ExecutePTOInstruction(instruction: bits(64),
                           length_bits: integer {16,32,48,64})
                           => PTOInstructionExecutionStatus
begin
    if DecodeCommandForm(instruction, length_bits) != PTO_COMMAND_FORM_COUNT then
        let command_status = ExecuteCommandInstruction(instruction, length_bits);
        if command_status == CommandExecution_Executed then
            return PTOInstruction_Executed;
        else
            return PTOInstruction_Rejected;
        end;
    elsif length_bits != 64 then
        let scalar_status = ExecuteScalarInstruction(
            instruction[47:0], length_bits as integer {16,32,48});
        if scalar_status == ScalarExecution_Executed then
            return PTOInstruction_Executed;
        else
            return PTOInstruction_Rejected;
        end;
    else
        BeginArchitecturalInstructionAttempt();
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return PTOInstruction_Rejected;
    end;
end;

func ExecuteNextPTOInstruction() => PTOInstructionExecutionStatus
begin
    let instruction_pc = ReadTPC();

    if instruction_pc[0] == '1' then
        SetFault(Fault_InstructionPC, instruction_pc);
        return PTOInstruction_Rejected;
    end;

    let prefix_probe = ProbeInstructionAccess(instruction_pc, 2);
    if !prefix_probe.permitted then
        SetFault(Fault_InstructionPage, instruction_pc);
        return PTOInstruction_Rejected;
    end;

    let prefix = FetchPTOInstruction(prefix_probe, 16);
    let length_bits = DeterminePTOInstructionLength(prefix[15:0]);
    let size_bytes = (length_bits DIV 8) as integer {2,4,6,8};
    let complete_probe = ProbeInstructionAccess(
        instruction_pc,
        size_bytes);
    if !complete_probe.permitted ||
       complete_probe.physical_address != prefix_probe.physical_address then
        SetFault(Fault_InstructionPage, instruction_pc);
        return PTOInstruction_Rejected;
    end;

    let instruction = FetchPTOInstruction(complete_probe, length_bits);
    return ExecutePTOInstruction(instruction, length_bits);
end;
```
<!-- GENERATED-ASL-END: unit -->
