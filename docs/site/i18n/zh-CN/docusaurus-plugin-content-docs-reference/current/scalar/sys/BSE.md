<!-- GENERATED FROM: asl/scalar/sys/BSE.asl -->
# BSE

**Normative ASL source:** `asl/scalar/sys/BSE.asl`

BSE publishes a legacy SendEvent request when MSGB is disabled; enabled contexts use atomic message admission.

## Normative identity {#PTO-INST-SCALAR-BSE}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-bse-purpose role=purpose -->
## BSE 的作用

`BSE` 有两种由当前上下文选择的模式。MSGB 未启用时，它发布旧有的 `ExecutionControl_SendEvent` 请求，并把源值作为请求操作数。MSGB 启用后，源值是消息控制字，BSE 尝试原子接纳消息。

两种模式都不等待远端消费者。未启用模式在发布请求后退休；启用模式在记录本地接纳结果后退休。队列背压或更早的可故障 GM obligation 可能阻止立即接纳。

<!-- PTO-READER-BLOCK: scalar-bse-mechanism role=mechanism -->
## 指令如何放置与执行

本指令是活动 SYS 块体中的一个标量操作。标量分派器先检查是否存在活动指令束，以及其块体是否活动且块类型为 System；处于这种块之外的 SYS 形式会以 `Fault_BundleControl` 被拒绝，这发生在任何编码字段检查之前，也发生在任何架构效果之前。

随后检查编码合法性与源可用性，之后处理程序才运行。

通用检查完成后，分派器检查当前 MSGB 绑定。未启用模式调用旧有执行控制辅助函数；启用模式调用[消息发送所有者](../../arch/state/message-buffer-send.md)，在接纳前检查 kernel 上下文、Block 属性、更早的可故障工作、目标绑定、队列容量和控制字段。

设计要点：显式启用让现有软件继续使用旧的仅请求契约。启用模式在不改变 BSE 编码的前提下增加可观察消息状态。控制字的位 31:0 是目标端点，位 35:32 是 0 到 10 个有效暂存 word，位 63:36 保留为零。

<!-- PTO-READER-BLOCK: scalar-bse-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供完整的 XLEN 旧请求操作数或启用模式消息控制字。
- 源选择器 `0`..`23` 读取 GPR，`24`..`27` 读取 `T#1`..`T#4`，`28`..`31` 读取 `U#1`..`U#4`。读取临时队列不会消费或重排它。
- 源选择器 `0` 读取 XLEN 零。未启用模式记录该操作数；启用模式把它解释为发往端点零的零 word 消息。
- 没有目的字段，因此该指令绝不写 GPR，也绝不压入 `T` 或 `U`。

<!-- PTO-READER-BLOCK: scalar-bse-effects role=effects -->
## 架构效果

未启用模式记录请求类型和操作数，并把架构请求纪元推进一。启用后的接纳把选中的暂存 word 复制到目标拥有的队列，只分配一次传输消息身份，并记录发送结果。精确重放返回保留的身份，不再次入队。

执行成功后，`TPC` 前进 `4` 字节。接纳会复制消息 word，但不会为无关的 GM payload 建立可见性。源寄存器及其引用的临时队列表项保持不变。

<!-- PTO-READER-BLOCK: scalar-bse-constraints role=constraints -->
## 放置与拒绝

无效的块放置首先被拒绝，以 `Fault_BundleControl` 报出，此时连编码字段都还没有被考虑。

每个已分配的 Reg5 源选择器都遵循通用标量源可用性规则：`0`..`23` 始终可用，而 `T` 或 `U` 选择器只有在对应队列槽保存了值时才可用。不可用的选择器会在任一模式产生效果前引发 `Fault_IllegalInstruction`。

未启用模式没有额外的逐请求权限测试。启用模式要求当前已绑定的 kernel 上下文，拒绝 `atomic` 或 `far` SYS envelope、保留控制字段和无效目标；目标队列或重放回执表已满时返回 `BUSY`，不分配身份。

<!-- PTO-READER-BLOCK: scalar-bse-example role=example -->
## 非规范示例

MSGB 未启用时，`bse a0` 用 `a0` 的值发布 `ExecutionControl_SendEvent`。MSGB 启用后，`a0 = 0x0000000200000010` 选择端点 16 和两个暂存 word；接纳复制这些 word，后续接收 claim 和 ACK 仍是独立操作。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
bse SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bse_32_883b5167edbc | L32 | 32 | 0x0000002b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bse_32_883b5167edbc | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bse_32_883b5167edbc | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BSE.asl -->
```asl
readonly func InstructionContractOperation_BSE()
    => ScalarOperation
begin
    return ScalarOperation_BSE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSE executes as one scalar operation in the body of an active SYS block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BSE.asl -->
```asl
readonly func InstructionContractHandler_BSE()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;

pure func InstructionContractRequiresSystemBlock_BSE()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractControlRequest_BSE()
    => ExecutionControlRequest
begin
    return ExecutionControl_SendEvent;
end;

readonly func InstructionContractControlRequestIsNonblocking_BSE()
    => boolean
begin
    return !MessageBufferEnabledForCurrentContext();
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.
- MSGB contexts reset disabled; disabled BSE retains the legacy nonblocking SendEvent request.

## Legality

- Every fixed bit and explicit field constraint is checked before operation semantics.
- Every assigned Reg5 source selector follows the common scalar-source availability rule.
- Enabled MSGB uses PTO-ARCH-MSGB-SEND-001: control bits 31:0 select the destination endpoint, bits 35:32 give 0..10 valid words, and bits 63:36 are reserved zero.
- Enabled MSGB requires the current bound kernel context and rejects atomic/far envelopes before effects.

## State effects

- When MSGB is disabled, snapshot SrcL, publish ExecutionControl_SendEvent and the exact XLEN operand, increment the architecture-request epoch, then advance TPC.
- When MSGB is enabled, the message-buffer owner preflights and atomically captures staging data, allocates a transport message identity, and publishes the exact admission result.
- Retries of an admitted dynamic occurrence preserve the captured message identity without another enqueue; queue backpressure and invalid controls do not allocate an identity.

## Memory effects and ordering

### Memory effects

- No direct GM payload access. Message admission alone does not make unrelated data visible to a consumer.

### Ordering

- Check block placement and encoded legality before source reads or architectural effects.
- Snapshot every scalar source before the selected system effect, then advance TPC only after success.
- Enabled irreversible admission waits while earlier same-PE GM obligations may fault; this is not a payload visibility fence.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- bse SrcL
