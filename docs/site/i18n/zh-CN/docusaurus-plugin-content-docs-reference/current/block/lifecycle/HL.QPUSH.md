<!-- GENERATED FROM: asl/block/lifecycle/HL.QPUSH.asl -->
# HL.QPUSH

**Normative ASL source:** `asl/block/lifecycle/HL.QPUSH.asl`

Atomically pushes one 64-bit entry at the tail or head of a General Queue Management queue.

## Normative identity {#PTO-INST-BLOCK-HL-QPUSH}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-hl-qpush-purpose role=purpose -->
## HL.QPUSH 的作用

`HL.QPUSH` 向通用队列管理（GQM）队列添加一个 64 位条目，默认加在队尾，使用 `.h` 时加在队头。它在结果寄存器中报告结果，而不是进入陷阱。队列由 [HL.QMT](HL.QMT.md) 创建，由 [HL.QPOP](HL.QPOP.md) 取出；其行为定义见 [通用队列管理](../../arch/programming-model/general-queue-management.md)。

<!-- PTO-READER-BLOCK: block-hl-qpush-mechanism role=mechanism -->
## 放置与执行机制

`HL.QPUSH` 是独立的 48 位命令。它不打开、不要求也不提交 block，并把 `TPC` 推进 6。

合法性检查之后，它从 `SrcL` 读取队列地址，从 `SrcR` 读取条目。随后验证队列。若队列接受该条目，则插入条目，若 `e=1` 则广播事件，并把结果字写入 `RegDst`。否则只写入结果字。

设计要点：两个源都在写入 `RegDst` 之前读取。因此即使目标与某个源是同一寄存器，也不会改变推入所使用的地址或条目。

<!-- PTO-READER-BLOCK: block-hl-qpush-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `RegDst`，位 `27:23`：结果字的目标。
- `SrcL`，位 `35:31`：队列地址的来源。
- `SrcR`，位 `40:36`：64 位条目的来源。
- `e`（位 41）、`r`（位 42）、`h`（位 43）：标志。全部八种组合都已分配，由后缀拼写，例如 `.her`。

每个寄存器字段都是 Reg5 选择器，见 [标量操作数](../../scalar/model/types/operands.md)。代码 0 至 23 指 R0 至 R23。作为源时，代码 24 至 31 读取 `T#1` 至 `T#4` 与 `U#1` 至 `U#4`。作为目标时，代码 30 推入 U 队列，代码 31 推入 T 队列，代码 24 至 29 丢弃结果。

设计要点：裸形式是不带事件、具有 release 顺序的队尾插入。每个标志的编码零都选择对应默认值：`h=0` 为队尾，`e=0` 为无事件，`r=0` 为 release。置位 `r` 请求 relaxed 顺序，因此顺序边是需要显式放弃的，而不是需要显式请求的。

<!-- PTO-READER-BLOCK: block-hl-qpush-effects role=effects -->
## 状态效果与顺序

- 成功的推入存储条目，在位 `9:0` 返回推入后的剩余容量，并在位 `63:62` 写入状态 `00`。
- 已满或已挂起的队列以当前剩余容量返回状态 `01`；不存储任何内容。
- 缺失或损坏的队列返回状态 `10`；不存储任何内容。状态 3 保留。

只有 `e=1` 的成功推入才会广播事件。队列更新、事件与结果写入是一个原子指令效果。

设计要点：当 `r=0` 时，成功的推入是一次 release。条目记录一个 release 纪元，取出该条目的非 relaxed 弹出会 acquire 推入之前排序的内存操作。当 `r=1` 时，条目不记录 release 边。`HL.QPUSH` 本身不直接访问内存。

<!-- PTO-READER-BLOCK: block-hl-qpush-constraints role=constraints -->
## 合法性、故障与原子性

相对 `SrcL` 或 `SrcR` 源所指队列条目无效时，在源读取、队列观察、事件、目标写入或 `TPC` 推进之前引发 `Fault_IllegalInstruction`。

已满、已挂起、缺失与损坏的队列在 `RegDst` 中报告，不会进入陷阱。容量为 0 的队列总是已满，因此向其推入会返回状态 `01`。

事件后缀是 `e`；`b` 不是别名。下方生成的合法性与异常章节具有权威性。

<!-- PTO-READER-BLOCK: block-hl-qpush-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
hl.qpush a0, a1, ->a2
```

假设 `a0` 指向一个已有 3 个条目的 16 条目队列，`a1` 保存 `0x55`。推入把 `0x55` 追加到队尾，并以状态 `00` 写入 `a2 = 12`。若使用 `hl.qpush.h`，`0x55` 会被插入到当前队头之前，因此下一次弹出会先返回它。若队列已挂起，`a2` 会接收状态 `01`，位 `9:0` 为 13，队列保持不变。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.qpush SrcL, SrcR, ->RegDst
hl.qpush.h SrcL, SrcR, ->RegDst
hl.qpush.e SrcL, SrcR, ->RegDst
hl.qpush.r SrcL, SrcR, ->RegDst
hl.qpush.he SrcL, SrcR, ->RegDst
hl.qpush.hr SrcL, SrcR, ->RegDst
hl.qpush.er SrcL, SrcR, ->RegDst
hl.qpush.her SrcL, SrcR, ->RegDst
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_qpush_48_3eab8e05d61a | HL48 | 48 | 0x0000107d000e / 0xf000707fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_qpush_48_3eab8e05d61a | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_qpush_48_3eab8e05d61a | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_qpush_48_3eab8e05d61a | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_qpush_48_3eab8e05d61a | e | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |
| hl_qpush_48_3eab8e05d61a | h | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |
| hl_qpush_48_3eab8e05d61a | r | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_qpush_48_3eab8e05d61a | RegDst | 5 | 0–31 | none | none | Reg5 destination for the operation result | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qpush_48_3eab8e05d61a | SrcL | 5 | 0–31 | none | none | Reg5 source of the queue address | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qpush_48_3eab8e05d61a | SrcR | 5 | 0–31 | none | none | Reg5 source of the 64-bit entry | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qpush_48_3eab8e05d61a | e | 1 | 0–1 | none | none | success-event selector | Zero suppresses event notification. |
| hl_qpush_48_3eab8e05d61a | h | 1 | 0–1 | none | none | head-insertion selector | Zero appends at the queue tail. |
| hl_qpush_48_3eab8e05d61a | r | 1 | 0–1 | none | none | relaxed-ordering selector | Zero selects release ordering. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source of the queue address |
| SrcR | Reg5 source of the 64-bit entry |
| RegDst | Reg5 destination for the operation result |
| h | head-insertion selector |
| e | success-event selector |
| r | relaxed-ordering selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/HL.QPUSH.asl -->
```asl
readonly func InstructionContractMatches_HL_QPUSH(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qpush_48_3eab8e05d61a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/HL.QPUSH.asl -->
```asl
readonly func InstructionContractHandler_HL_QPUSH() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueuePush;
end;

func ExecuteHLQPUSH(destination: Reg5Selector,
                    address: Word,
                    entry: Word,
                    flags: bits(4))
begin
    ExecuteQueueManagerPush(
        destination,
        address,
        entry,
        flags);
end;

pure func InstructionContractChangesQueueManagerState_HL_QPUSH()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSnapshotsSourcesBeforeWrite_HL_QPUSH()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The bare form appends at the tail, publishes no event, and has release semantics.
- h=0 selects tail insertion, e=0 suppresses notification, and r=0 selects release ordering.

## Legality

- Reg5 values 0..23 select absolute R0..R23 and 24..31 select the block-relative T#1..T#4 or U#1..U#4 entries; unavailable relative sources and invalid relative destinations reject before queue state changes.
- All eight h/e/r flag combinations are assigned; the event suffix is e and b is not an alias.

## State effects

- h=0 appends one entry at the tail; h=1 inserts one entry at the head. The queue update, optional event, and destination result are atomic.
- Result bits [9:0] hold post-push remaining capacity and [63:62] hold status; unused bits are zero. Status 0 is success, 1 is full or suspended, 2 is missing or corrupt, and 3 is reserved.
- Only a successful push with e=1 broadcasts an event.

## Memory effects and ordering

### Memory effects

- No direct memory access. A non-relaxed successful push releases memory operations ordered before it to an acquiring pop that observes the entry.

### Ordering

- Queue validation precedes insertion. A successful insertion precedes optional event notification and result publication.
- r=0 establishes the release edge; r=1 is relaxed and records no release edge.

## Exceptions

- Selector failures raise Fault_IllegalInstruction before source reads, queue observation, events, destination writes, or TPC advance.
- Full, suspended, missing, and corrupt queues report status in RegDst and do not trap.

## Examples

- hl.qpush a0, a1, ->a2
- hl.qpush.he t#1, u#1, ->t#2
- hl.qpush.r sp, zero, ->u#1
