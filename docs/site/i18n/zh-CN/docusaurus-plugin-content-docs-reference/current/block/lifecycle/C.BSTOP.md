<!-- GENERATED FROM: asl/block/lifecycle/C.BSTOP.asl -->
# C.BSTOP

**Normative ASL source:** `asl/block/lifecycle/C.BSTOP.asl`

Commits the current bundle and transfers to its selected continuation.

## Normative identity {#PTO-INST-BLOCK-C-BSTOP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-bstop-purpose role=purpose -->
## C.BSTOP 的作用

`C.BSTOP` 是 Block 完成边界；它先验证并提交活动描述符，再选择下一架构 PC。

<!-- PTO-READER-BLOCK: block-c-bstop-mechanism role=mechanism -->
## 放置与执行机制

`C.BSTOP` 不是 Block 体属性；它完成已经活动的 Block，没有兼容活动 Block 时属于非法。

已接受载体使用 `C16` 编码类别；命令在读取绑定或改变状态前，会先解析所有显示字段。

命令会在第一个可见效果前快照所有必需源，随后遵循归属单元定义的提交或重启边界。

<!-- PTO-READER-BLOCK: block-c-bstop-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 该指令没有编码操作数字段。
- 所有操作数都来自已接受载体或命名架构状态；命令不会创建 Block 体私有的隐藏操作数流。
- 编码零仍是已分配值或明确规定的拒绝值；它不会静默表示省略操作数。

<!-- PTO-READER-BLOCK: block-c-bstop-effects role=effects -->
## 状态效果与顺序

完成操作会先执行选定的活动操作，再清除 Block 私有描述符、绑定、属性与活动状态字段。

只有 Block 提交后才发布通过验证的后继地址；被拒绝的完成会保留故障契约要求的状态。

<!-- PTO-READER-BLOCK: block-c-bstop-constraints role=constraints -->
## 合法性、故障与原子性

固定比特、保留值、选择器取值域与必需的 Block 放置关系都在架构效果之前检查。

当前归属单元通过 `Fault_BundleControl` 报告无效模式、状态、地址或后继条件；本页说明文字不创建额外故障规则。

除非当前归属单元明确规定带保留进度的重启边界，否则拒绝发生在效果之前；完成顺序始终采用 ASL 顺序。

<!-- PTO-READER-BLOCK: block-c-bstop-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
C.BSTOP
```

此处完成指令作用于已经活动且兼容的 Block；若没有该活动状态，相同编码会在提交前引发故障。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
C.BSTOP
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstop_16_ca4743d8a95e | C16 | 16 | 0x0000 / 0xffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/C.BSTOP.asl -->
```asl
readonly func InstructionContractMatches_C_BSTOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstop_16_ca4743d8a95e);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/C.BSTOP.asl -->
```asl
readonly func InstructionContractHandler_C_BSTOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStop;
end;

pure func InstructionContractCommitsActiveBundle_C_BSTOP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractClearsHeaderState_C_BSTOP()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The instruction has no encoded operand field and therefore no operand default.

## Legality

- All bit patterns not excluded by the form decode are assigned by this instruction contract.

## State effects

- Commits the active block, selects BARG.BPCN for DIRECT/CALL/IND/ICALL/RET or taken COND, otherwise selects the sequential PC.
- After successful commit, clears BARG, BPC, descriptor fields, dimensions, operand bindings, attributes, and active/body state.

## Memory effects and ordering

### Memory effects

- Commits every architecture-visible memory effect of the active block before selecting its continuation.

### Ordering

- Validate the active block and final BARG continuation, execute the selected block operation, then select BARG.BPCN or the sequential PC and clear block-private state.

## Exceptions

- No active block raises Fault_BundleControl.
- Schema, applicability, execution, or final-PC faults reject before block-private state is cleared.

## Examples

- C.BSTOP
