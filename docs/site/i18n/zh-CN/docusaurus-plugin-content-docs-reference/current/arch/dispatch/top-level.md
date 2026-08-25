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

`ExecutePTOInstruction` 是单条已编码 `PTO` 指令的全覆盖入口，返回 `PTOInstruction_Executed` 或 `PTOInstruction_Rejected`。

它区分命令形式分派与标量分派，并为无法匹配的 64 位输入提供明确的拒绝路径。

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-concepts-state role=concepts-state -->
## 概念与可见状态

- 输入载体为 `bits(64)`，`length_bits` 只能取 `16`、`32`、`48` 或 `64`。
- 分派器首先调用 `DecodeCommandForm`；识别出的命令形式交给 `ExecuteCommandInstruction`。
- 若没有命令形式匹配且长度不是 `64`，则将低 `48` 位连同原始 `16`/`32`/`48` 长度传给 `ExecuteScalarInstruction`。

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-rules-interactions role=rules-interactions -->
## 规则与交互

命令执行状态直接映射为顶层的已执行或已拒绝状态。

命令解码器报告无匹配形式后，标量执行状态按相同方式映射。

无法匹配的 `64` 位输入会开始一次架构指令尝试，在 `ReadTPC()` 处设置 `Fault_IllegalInstruction`，并返回拒绝状态。

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-boundaries role=boundaries -->
## 架构边界

该分派器不重复定义命令或标量的合法性与操作语义，而是委托给相应的当前归属单元。

显式非法指令路径只在命令解码失败且所选长度为 `64` 时生效。

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-example-usage role=example-usage -->
## 非规范阅读示例

已识别的 48 位标量形式先无法匹配命令形式，随后进入 `ExecuteScalarInstruction`；最终状态再映射回 `PTOInstructionExecutionStatus`。

不匹配任何命令形式的随机 64 位载体不会落入标量解码，而会进入显式非法指令路径。

<!-- PTO-READER-BLOCK: arch-dispatch-top-level-related-owners role=related-owners-navigation -->
## 相关归属单元

- [命令分派归属单元](../../block/model/dispatch/top-level.md)
- [标量分派归属单元](../../scalar/model/dispatch/top-level.md)
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/dispatch/top-level.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-DISPATCH-TOP-LEVEL","surface":"arch","classification":["dispatch","top-level"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TOP-LEVEL","PTO-SCALAR-MODEL-DISPATCH-TOP-LEVEL"]}
// PTO-REQ-INSTRUCTION-DISPATCH-001: total PTO encoded-instruction entry point.

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
```
<!-- GENERATED-ASL-END: unit -->
