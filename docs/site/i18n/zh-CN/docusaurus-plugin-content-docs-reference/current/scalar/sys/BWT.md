<!-- GENERATED FROM: asl/scalar/sys/BWT.asl -->
# BWT

**Normative ASL source:** `asl/scalar/sys/BWT.asl`

BWT publishes the WaitTimeout nonblocking execution-control request.

## Normative identity {#PTO-INST-SCALAR-BWT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bwt-purpose role=purpose -->
## BWT 的作用

`BWT` 向架构发布一次执行控制请求，并把它的源值作为请求操作数一并携带。该请求是 `ExecutionControl_WaitTimeout`。

它是非阻塞请求：指令发布请求后就退休。它不挂起线程，也不在下一个指令之前等待唤醒。

<!-- PTO-READER-BLOCK: scalar-bwt-mechanism role=mechanism -->
## 指令如何放置与执行

本指令是活动 SYS 块体中的一个标量操作。标量分派器先检查是否存在活动指令束，以及其块体是否活动且块类型为 System；处于这种块之外的 SYS 形式会以 `Fault_BundleControl` 被拒绝，这发生在任何编码字段检查之前，也发生在任何架构效果之前。

随后检查编码合法性与源可用性，之后处理程序才运行。

处理程序读取 `SrcL`，然后通过共享的执行控制规则发布该请求。该规则保存请求类型、保存精确的 XLEN 操作数，并把架构请求纪元推进一。它不查询任何权限表，因此在放置检查与操作数检查通过之后，请求会被无条件发布。

设计要点：只记录请求类型及其操作数，模型不为该请求定义任何睡眠、邮箱、超时计数器或待唤醒状态。这正是该请求在可测试意义下非阻塞的原因：不存在后续指令可以观察到的额外架构状态，因此立即退休就是完整的行为。

<!-- PTO-READER-BLOCK: scalar-bwt-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 是源选择器，提供完整的 XLEN 请求操作数。
- 源选择器 `0`..`23` 读取 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`。读取临时队列不会消费或重排它。
- 源选择器 `0` 始终读到 XLEN 零，而零是合法的操作数值：它被记录为操作数，而不是被当作省略。
- 没有目的字段，因此该指令绝不写 GPR，也绝不压入 `T` 或 `U`。

<!-- PTO-READER-BLOCK: scalar-bwt-effects role=effects -->
## 架构效果

发布的效果是记录下来的请求类型、记录下来的操作数，以及架构请求纪元加一。源寄存器以及它指名的队列表项（如果有）保持不变，因为该指令只读取它们。

`TPC` 前进 `4` 字节。该指令不进行内存访问，也不留下保留状态，因此它本身不可能是后续原子操作或链接加载操作失败的原因。

<!-- PTO-READER-BLOCK: scalar-bwt-constraints role=constraints -->
## 放置与拒绝

无效的块放置首先被拒绝，以 `Fault_BundleControl` 报出，此时连编码字段都还没有被考虑。

每个已分配的 Reg5 源选择器都遵循通用标量源可用性规则：`0`..`23` 始终可用，而 `T` 或 `U` 选择器只有在对应队列槽保存了值时才可用。不可用的选择器会在请求发布之前引发 `Fault_IllegalInstruction`，因此被拒绝的 `BWT` 不记录任何内容，也不推进请求纪元。

处理程序中没有逐请求的权限测试，因此操作数取值本身绝不会导致拒绝。

<!-- PTO-READER-BLOCK: scalar-bwt-example role=example -->
## 非规范示例

`bwt a0` 从 `a0` 读取操作数，把 `ExecutionControl_WaitTimeout` 与该操作数一起发布，把架构请求纪元推进一，并让 `TPC` 前进 `4` 字节。执行不等待，直接继续下一条指令。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bwt SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bwt_32_5a0fe4a8e61f | L32 | 32 | 0x0030002b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bwt_32_5a0fe4a8e61f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bwt_32_5a0fe4a8e61f | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BWT.asl -->
```asl
readonly func InstructionContractOperation_BWT()
    => ScalarOperation
begin
    return ScalarOperation_BWT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BWT executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BWT.asl -->
```asl
readonly func InstructionContractHandler_BWT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;

pure func InstructionContractRequiresSystemBlock_BWT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractControlRequest_BWT()
    => ExecutionControlRequest
begin
    return ExecutionControl_WaitTimeout;
end;

pure func InstructionContractControlRequestIsNonblocking_BWT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Every assigned Reg5 source selector follows the common scalar-source availability rule.

## State effects

- Snapshot SrcL, publish ExecutionControl_WaitTimeout and the exact XLEN operand, increment the architecture-request epoch, then advance TPC.
- PTO defines no additional asleep, mailbox, timeout-counter, or pending-wake state for this nonblocking request.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- bwt SrcL
