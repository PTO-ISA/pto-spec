<!-- GENERATED FROM: asl/block/lifecycle/HL.QPOP.asl -->
# HL.QPOP

**Normative ASL source:** `asl/block/lifecycle/HL.QPOP.asl`

Atomically pops one 64-bit head entry from a General Queue Management queue.

## Normative identity {#PTO-INST-BLOCK-HL-QPOP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-hl-qpop-purpose role=purpose -->
## HL.QPOP 的作用

`HL.QPOP` 取出通用队列管理（GQM）队列的队头条目。它把条目写入一个寄存器，把结果字写入第二个寄存器，并在该结果中报告队列为空或缺失，而不是进入陷阱。条目通过 [HL.QPUSH](HL.QPUSH.md) 进入；队列行为定义见 [通用队列管理](../../arch/programming-model/general-queue-management.md)。

<!-- PTO-READER-BLOCK: block-hl-qpop-mechanism role=mechanism -->
## 放置与执行机制

`HL.QPOP` 是独立的 48 位命令。它不打开、不要求也不提交 block，并把 `TPC` 推进 6。

合法性检查之后，它从 `SrcL` 读取队列地址并验证队列。若存在条目，它移除队头，若 `e=1` 则广播事件，然后依次把条目写入 `RegDst0`、把结果字写入 `RegDst1`。

设计要点：两次写入是有序的。若 `RegDst0` 与 `RegDst1` 指同一个绝对寄存器，该寄存器最终保存结果字。若二者都推入同一个相对队列，则先推入数据，再推入结果。

<!-- PTO-READER-BLOCK: block-hl-qpop-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `RegDst1`，位 `15:11`：结果字的目标。
- `RegDst0`，位 `27:23`：弹出条目的目标。
- `SrcL`，位 `35:31`：队列地址的来源。
- `e`（位 41）、`r`（位 42）：标志。全部四种组合都已分配。
- 位 `40:36` 是固定的保留零位，不是操作数。

每个寄存器字段都是 Reg5 选择器，见 [标量操作数](../../scalar/model/types/operands.md)。代码 0 至 23 指 R0 至 R23；作为源时，代码 24 至 31 读取 `T#1` 至 `T#4` 与 `U#1` 至 `U#4`。作为目标时，代码 30 推入 U 队列，代码 31 推入 T 队列，代码 24 至 29 丢弃该值。

设计要点：裸形式具有 acquire 顺序且不带事件。`e=0` 抑制事件，`r=0` 选择 acquire，因此编码零保持有序的默认值。目标为 R0 时丢弃其值，程序因此可以弹出而不保留数据。

<!-- PTO-READER-BLOCK: block-hl-qpop-effects role=effects -->
## 状态效果与顺序

- 成功的弹出移除队头条目，把其值写入 `RegDst0`，并在 `RegDst1` 中写入状态 `00`，位 `12:0` 为剩余条目数。即使队列已挂起，弹出也会成功。
- 空队列写入状态 `01` 与计数 0；缺失或损坏的队列写入状态 `10` 与计数 0。两种情况下 `RegDst0` 都接收零，队列保持不变。状态 3 保留。

只有 `e=1` 的成功弹出才会广播事件。队列更新与两次写入构成一个指令效果。

设计要点：当 `r=0` 时，成功的弹出是一次 acquire。若该条目以 release 顺序推入，弹出会 acquire 该推入之前排序的内存操作。当 `r=1` 时，不记录 acquire 边。`HL.QPOP` 本身不直接访问内存。

<!-- PTO-READER-BLOCK: block-hl-qpop-constraints role=constraints -->
## 合法性、故障与原子性

- 位 `40:36` 中的非零值不会译码为 `HL.QPOP`，并引发 `Fault_IllegalInstruction`。
- 相对 `SrcL` 源所指队列条目无效时，引发 `Fault_IllegalInstruction`。
- 两种故障都发生在源读取、队列观察、事件、目标写入或 `TPC` 推进之前。

空、缺失与损坏的队列在 `RegDst1` 中报告，不会进入陷阱。下方生成的合法性与异常章节具有权威性。

<!-- PTO-READER-BLOCK: block-hl-qpop-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
hl.qpop a0, ->a1, a2
```

假设 `a0` 指向一个队列，其队头为 `0x55`，其后还有一个条目。弹出写入 `a1 = 0x55`，并在 `a2` 中写入状态 `00` 与计数 1。第二次弹出移除最后一个条目并报告计数 0。第三次弹出发现队列为空：`a1` 接收 0，`a2` 接收状态 `01`，不产生故障。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.qpop SrcL, ->RegDst0, RegDst1
hl.qpop.e SrcL, ->RegDst0, RegDst1
hl.qpop.r SrcL, ->RegDst0, RegDst1
hl.qpop.er SrcL, ->RegDst0, RegDst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_qpop_48_a2c57f5bc27b | HL48 | 48 | 0x0000207d000e / 0xf9f0707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_qpop_48_a2c57f5bc27b | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_qpop_48_a2c57f5bc27b | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_qpop_48_a2c57f5bc27b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_qpop_48_a2c57f5bc27b | e | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |
| hl_qpop_48_a2c57f5bc27b | r | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_qpop_48_a2c57f5bc27b | RegDst0 | 5 | 0–31 | none | none | Reg5 destination for popped data | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qpop_48_a2c57f5bc27b | RegDst1 | 5 | 0–31 | none | none | Reg5 destination for the operation result | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qpop_48_a2c57f5bc27b | SrcL | 5 | 0–31 | none | none | Reg5 source of the queue address | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qpop_48_a2c57f5bc27b | e | 1 | 0–1 | none | none | success-event selector | Zero suppresses event notification. |
| hl_qpop_48_a2c57f5bc27b | r | 1 | 0–1 | none | none | relaxed-ordering selector | Zero selects acquire ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source of the queue address |
| RegDst0 | Reg5 destination for popped data |
| RegDst1 | Reg5 destination for the operation result |
| e | success-event selector |
| r | relaxed-ordering selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/HL.QPOP.asl -->
```asl
readonly func InstructionContractMatches_HL_QPOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qpop_48_a2c57f5bc27b);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/HL.QPOP.asl -->
```asl
readonly func InstructionContractHandler_HL_QPOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueuePop;
end;

func ExecuteHLQPOP(destination0: Reg5Selector,
                   destination1: Reg5Selector,
                   address: Word,
                   flags: bits(4))
begin
    ExecuteQueueManagerPop(
        destination0,
        destination1,
        address,
        flags);
end;

pure func InstructionContractChangesQueueManagerState_HL_QPOP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSnapshotsSourcesBeforeWrite_HL_QPOP()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The bare form has acquire semantics and publishes no event.
- e=0 suppresses notification and r=0 selects acquire ordering.
- Bits [40:36] are fixed reserved-zero bits and are never an operand.

## Legality

- Reg5 values 0..23 select absolute R0..R23 and 24..31 select the block-relative T#1..T#4 or U#1..U#4 entries; unavailable relative sources and invalid relative destinations reject before queue state changes.
- All four e/r flag combinations are assigned.
- Any nonzero value in bits [40:36] is reserved and raises Fault_IllegalInstruction before source reads or effects.

## State effects

- A successful pop removes the head entry even while the queue is suspended, writes its value to RegDst0, and reports status zero.
- RegDst1[12:0] holds the post-attempt remaining entry count and [63:62] holds status; unused bits are zero. Status 1 is empty, 2 is missing or corrupt, and 3 is reserved.
- Only a successful pop with e=1 broadcasts an event. The queue update and both destination writes are one instruction effect.

## Memory effects and ordering

### Memory effects

- No direct memory access. A non-relaxed successful pop acquires memory operations released by the observed entry's non-relaxed push.

### Ordering

- Queue validation and data selection precede the atomic head removal. A successful removal precedes optional event notification and the ordered RegDst0 then RegDst1 writes.
- r=0 establishes the acquire edge; r=1 is relaxed and records no acquire edge. Destination aliases follow ordered multi-destination write rules.

## Exceptions

- Nonzero reserved bits [40:36] and selector failures raise Fault_IllegalInstruction before source reads, queue observation, events, destination writes, or TPC advance.
- Empty, missing, and corrupt queues report status in RegDst1 and do not trap.

## Examples

- hl.qpop a0, ->a1, a2
- hl.qpop.e t#1, ->t#2, u#1
- hl.qpop.r sp, ->zero, a0
