<!-- GENERATED FROM: asl/block/lifecycle/BSTOP.asl -->
# BSTOP

**Normative ASL source:** `asl/block/lifecycle/BSTOP.asl`

Commits the current bundle and transfers to its selected continuation.

## Normative identity {#PTO-INST-BLOCK-BSTOP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstop-purpose role=purpose -->
## BSTOP 的作用

`BSTOP` 结束并提交当前活动 block。block（也称为指令束）由 block 启动命令打开，从头部命令收集配置，执行其主体，并在提交边界处作为一个整体生效。`BSTOP` 是该边界的显式 32 位形式；下一个 block 启动则是隐式边界。

提交时，block 所选操作被执行，`BARG`（block 参数寄存器）中记录的延续被应用，所有 block 私有状态被清除。

<!-- PTO-READER-BLOCK: block-bstop-mechanism role=mechanism -->
## 放置与执行机制

`BSTOP` 位于活动 block 主体的末尾。它以自身之后的地址作为顺序延续，调用 [提交验证](../model/commit/validation.md) 中的提交所有者。提交按以下步骤执行，并在第一次失败时停止：

1. 没有活动 block 时引发 `Fault_BundleControl`。
2. 延续为奇数，或 `BARG` 选择的下一 PC 为奇数时，引发 `Fault_InstructionPC`。
3. 在非 Tile 元素或 Tile 内存 block 上出现 `DR` 控制属性时，引发 `Fault_BundleControl`。
4. 启动命令所选的 Tile 操作执行，并带有其自身的预检与回滚。
5. [停止](../model/lifecycle/enter-stop.md)清除 block 状态并写入 `TPC`。

设计要点：停止形式 `BSTOP`、[C.BSTOP](C.BSTOP.md) 与 [L.BSTOP](L.BSTOP.md) 共用同一个处理函数 `ExecuteBundleStop`。它们只有长度不同，而长度决定顺序延续地址。位于 `P` 的 4 字节 `BSTOP` 在 block 未选择 `BPCN` 时于 `P + 4` 继续。

<!-- PTO-READER-BLOCK: block-bstop-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 载体是单个 32 位字 `0x00000001`。
- `BSTOP` 没有操作数字段。所有位都是固定的，因此没有默认值，也没有需要解释的编码零。
- 输入是累积的 block 状态：`BARG`、启动命令安装的操作描述符、头部属性、维度以及操作数绑定。

<!-- PTO-READER-BLOCK: block-bstop-effects role=effects -->
## 状态效果与顺序

对于 `DIRECT`、`CALL`、`IND`、`ICALL` 或 `RET` block，以及 `TAKEN` 标志被设置的 `COND` block，下一 PC 为 `BARG.BPCN`。否则为 `BSTOP` 之后的地址。

block 的所有架构可见内存效果都在选择延续之前提交。提交成功后，`BARG`、`BPC`、描述符、维度、操作数绑定、属性以及活动与主体标志都被清除，`TPC` 接收下一 PC。

设计要点：下一 PC 与 `B.CATR` 的 `trap` 属性在清除状态之前被捕获。若 `trap` 被设置，则在 block 退役之后以下一 PC 为地址引发 `Fault_BundlePostCommit`。因此恢复会从 block 之后继续，不会让该 block 执行两次。

<!-- PTO-READER-BLOCK: block-bstop-constraints role=constraints -->
## 合法性、故障与原子性

模式、适用性、执行或最终 PC 故障都在清除 block 私有状态之前引发。block 保持活动且头部完整，`BARG` 不被应用，因此陷阱上下文仍描述失败的那个 block。

设计要点：最终目标在提交时检查，因为主体中的 `SETC.TGT` 可能在启动命令之后替换 `BPCN`。因此错误目标会在该 block 的任何 Tile 结果发布之前被拒绝。

在系统 block 终止请求（`ACRC`）之后，只能跟随停止或 block 启动；此处允许 `BSTOP`。下方生成的异常章节具有权威性。

<!-- PTO-READER-BLOCK: block-bstop-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
BSTOP
```

一个 `COND` block 的 `BPCN = 0x2000`。其 `BSTOP` 位于 `0x1040`，因此顺序延续为 `0x1044`。若主体中没有 `SETC.*` 设置 `TAKEN`，提交选择 `0x1044`；若 `TAKEN` 被设置，则选择 `0x2000`。两种情况下头部状态都被清除，block 不再活动。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTOP
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstop_32_d25b09fdd59c | L32 | 32 | 0x00000001 / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/BSTOP.asl -->
```asl
readonly func InstructionContractMatches_BSTOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstop_32_d25b09fdd59c);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/BSTOP.asl -->
```asl
readonly func InstructionContractHandler_BSTOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStop;
end;

pure func InstructionContractCommitsActiveBundle_BSTOP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractClearsHeaderState_BSTOP()
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

- BSTOP
