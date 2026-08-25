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

`HL.QPOP` 是独立的通用队列管理命令；队列更新、状态结果与可选事件构成一个有序指令效果。

<!-- PTO-READER-BLOCK: block-hl-qpop-mechanism role=mechanism -->
## 放置与执行机制

`HL.QPOP` 作为独立的 `48` 位命令执行，不要求放在 `BSTART`/`BSTOP` Block 体内。

已接受载体使用 `HL48` 编码类别；命令在读取绑定或改变状态前，会先解析所有显示字段。

命令会在第一个可见效果前快照所有必需源，随后遵循归属单元定义的提交或重启边界。

<!-- PTO-READER-BLOCK: block-hl-qpop-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 编码操作数：`SrcL` — 提供队列地址的 Reg5 源; `RegDst0` — 接收弹出数据的 Reg5 目的端; `RegDst1` — 接收操作结果的 Reg5 目的端; `e` — 成功事件选择器; `r` — relaxed 顺序选择器。
- 所有操作数都来自已接受载体或命名架构状态；命令不会创建 Block 体私有的隐藏操作数流。
- 编码零仍是已分配值或明确规定的拒绝值；它不会静默表示省略操作数。

<!-- PTO-READER-BLOCK: block-hl-qpop-effects role=effects -->
## 状态效果与顺序

源验证与快照发生在所有寄存器、队列、栈帧、内存、事件或控制流效果之前。

命令把状态与结果作为一个有序指令效果发布，再按归属单元规定前移或转移控制。

<!-- PTO-READER-BLOCK: block-hl-qpop-constraints role=constraints -->
## 合法性、故障与原子性

固定比特、保留值、选择器取值域与必需的 Block 放置关系都在架构效果之前检查。

当前归属单元通过 `Fault_IllegalInstruction` 报告无效模式、状态、地址或后继条件；本页说明文字不创建额外故障规则。

除非当前归属单元明确规定带保留进度的重启边界，否则拒绝发生在效果之前；完成顺序始终采用 ASL 顺序。

<!-- PTO-READER-BLOCK: block-hl-qpop-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
hl.qpop a0, ->a1, a2
```

所示已接受拼写从当前载体解析字段，快照必需源，再执行归属单元规定的状态与顺序转换。
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
