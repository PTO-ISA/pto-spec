<!-- GENERATED FROM: asl/block/lifecycle/HL.QMT.asl -->
# HL.QMT

**Normative ASL source:** `asl/block/lifecycle/HL.QMT.asl`

Queries, initializes, notifies, suspends, or restores one General Queue Management queue.

## Normative identity {#PTO-INST-BLOCK-HL-QMT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-hl-qmt-purpose role=purpose -->
## HL.QMT 的作用

`HL.QMT` 管理一个通用队列管理（GQM）队列。GQM 队列保存 64 位条目，并以一个 64 位地址标识；其行为定义见 [通用队列管理](../../arch/programming-model/general-queue-management.md)。`HL.QMT` 有一个主要动作，以及最多两个后续动作：

- 主要动作：查询剩余容量（`i=0`），或创建或替换队列（`i=1`）。
- 后续动作：广播事件（`e`），然后挂起（`s`）或恢复（`r`）该队列。

[HL.QPUSH](HL.QPUSH.md) 与 [HL.QPOP](HL.QPOP.md) 使条目进出队列。

<!-- PTO-READER-BLOCK: block-hl-qmt-mechanism role=mechanism -->
## 放置与执行机制

`HL.QMT` 是独立的 48 位命令。它不打开、不要求也不提交 block，并把 `TPC` 推进 6。

合法性检查之后，它读取 `SrcL` 作为队列地址，仅当 `i=1` 时读取 `SrcR`。随后执行主要动作。只有主要动作成功，后续动作才会按以下顺序执行：若 `e=1` 则广播事件，然后若 `s=1` 则挂起，若 `r=1` 则恢复。最后把结果字写入 `RegDst`。

设计要点：后续动作依赖主要动作的结果。对缺失或损坏的队列进行查询会失败，因此对这种队列执行 `hl.qmt.s` 不会挂起任何队列，也不会广播事件。初始化总是成功，因此 `hl.qmt.ie` 总会广播。

<!-- PTO-READER-BLOCK: block-hl-qmt-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `RegDst`，位 `27:23`：结果字的目标。
- `SrcL`，位 `35:31`：队列地址的来源。
- `SrcR`，位 `40:36`：容量来源，仅当 `i=1` 时读取。位 `9:0` 给出 0 至 1023 个条目的容量；更高位被忽略。
- `e`（位 41）、`r`（位 42）、`s`（位 43）、`i`（位 44）：动作标志。汇编后缀列出被置位的标志，例如 `.ie`。

每个寄存器字段都是 Reg5 选择器，见 [标量操作数](../../scalar/model/types/operands.md)。代码 0 至 23 指 R0 至 R23。作为源时，代码 24 至 27 读取 `T#1` 至 `T#4`，代码 28 至 31 读取 `U#1` 至 `U#4`。作为目标时，代码 30 推入 U 队列，代码 31 推入 T 队列，代码 24 至 29 丢弃结果。

设计要点：当 `i=0` 时，`SrcR` 既不读取也不检查，规范汇编省略它。裸 `hl.qmt` 清除全部四个标志，是单纯的查询。`e`、`s` 或 `r` 的编码零抑制对应的后续动作，`i=0` 选择查询，而寄存器字段的编码零指 R0，读取为零且写入被丢弃。

<!-- PTO-READER-BLOCK: block-hl-qmt-effects role=effects -->
## 状态效果与顺序

- 对有效且未损坏的队列查询（`i=0`）时，以状态 `00` 返回以 64 位条目计的剩余容量。缺失或损坏的队列返回状态 `01`。
- 初始化（`i=1`）在该地址创建队列，或替换已有队列，并以状态 `00` 返回分配的字节数 `capacity * 8`。它清除之前的条目、损坏标记与挂起状态。容量为 0 时创建一个有效的空队列。

结果字在位 `12:0` 保存主要值，在位 `63:62` 保存状态；其余位为零。状态 2 与 3 对 `HL.QMT` 保留。

`HL.QMT` 不直接访问内存。主要动作、后续动作与结果写入构成一个指令效果。

<!-- PTO-READER-BLOCK: block-hl-qmt-constraints role=constraints -->
## 合法性、故障与原子性

- 同时置位 `s` 与 `r` 会引发 `Fault_IllegalInstruction`。其他所有标志组合都已分配，包括带有 `i` 或 `e` 的组合。
- 相对 `SrcL` 源所指队列条目无效时，引发 `Fault_IllegalInstruction`。当 `i=1` 时，同样的检查适用于 `SrcR`。
- 这些故障发生在源读取、队列观察、事件、目标写入或 `TPC` 推进之前。

设计要点：缺失或损坏的队列是运行时条件，而不是故障。它在状态位中报告，因此软件可以检查结果，而不必进入陷阱。事件标志的后缀是 `e`；`b` 不是别名。

<!-- PTO-READER-BLOCK: block-hl-qmt-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
hl.qmt a0, ->a1
```

假设 `a0` 保存一个队列地址，`a2` 保存 16。`hl.qmt.i a0, a2, ->a1` 创建一个 16 条目的队列，并以状态 `00` 写入 `a1 = 128`（16 个 8 字节条目）。三次推入之后，裸查询 `hl.qmt a0, ->a1` 写入 `a1 = 13`。若 `a0` 未指向任何队列，查询会在位 `63:62` 写入状态 `01`，在位 `12:0` 写入零，且不产生故障。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.qmt SrcL, ->RegDst
hl.qmt.e SrcL, ->RegDst
hl.qmt.s SrcL, ->RegDst
hl.qmt.r SrcL, ->RegDst
hl.qmt.es SrcL, ->RegDst
hl.qmt.er SrcL, ->RegDst
hl.qmt.i SrcL, SrcR, ->RegDst
hl.qmt.ie SrcL, SrcR, ->RegDst
hl.qmt.is SrcL, SrcR, ->RegDst
hl.qmt.ir SrcL, SrcR, ->RegDst
hl.qmt.ies SrcL, SrcR, ->RegDst
hl.qmt.ier SrcL, SrcR, ->RegDst
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_qmt_48_eb9e41958045 | HL48 | 48 | 0x0000007d000e / 0xe000707fffff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_qmt_48_eb9e41958045 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_qmt_48_eb9e41958045 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_qmt_48_eb9e41958045 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_qmt_48_eb9e41958045 | e | 1 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":1}] |
| hl_qmt_48_eb9e41958045 | i | 1 | encoding-defined | [{"instruction_lsb":44,"value_lsb":0,"width":1}] |
| hl_qmt_48_eb9e41958045 | r | 1 | encoding-defined | [{"instruction_lsb":42,"value_lsb":0,"width":1}] |
| hl_qmt_48_eb9e41958045 | s | 1 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_qmt_48_eb9e41958045 | RegDst | 5 | 0–31 | none | none | Reg5 destination for the operation result | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qmt_48_eb9e41958045 | SrcL | 5 | 0–31 | none | none | Reg5 source of the queue address | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qmt_48_eb9e41958045 | SrcR | 5 | 0–31 | none | none | Reg5 capacity source, read only when i=1 | Encoded zero names R0; reads produce zero and writes are discarded. |
| hl_qmt_48_eb9e41958045 | e | 1 | 0–1 | none | none | post-primary-operation event selector | Zero suppresses event notification. |
| hl_qmt_48_eb9e41958045 | i | 1 | 0–1 | none | none | initialize-or-replace selector | Zero selects query rather than initialization. |
| hl_qmt_48_eb9e41958045 | r | 1 | 0–1 | none | none | post-event restore selector | Zero suppresses restoration. |
| hl_qmt_48_eb9e41958045 | s | 1 | 0–1 | none | none | post-event suspend selector | Zero suppresses suspension. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source of the queue address |
| SrcR | Reg5 capacity source, read only when i=1 |
| RegDst | Reg5 destination for the operation result |
| i | initialize-or-replace selector |
| e | post-primary-operation event selector |
| s | post-event suspend selector |
| r | post-event restore selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/HL.QMT.asl -->
```asl
readonly func InstructionContractMatches_HL_QMT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_hl_qmt_48_eb9e41958045);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/HL.QMT.asl -->
```asl
readonly func InstructionContractHandler_HL_QMT() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteQueueMove;
end;

func ExecuteHLQMT(destination: Reg5Selector,
                  address: Word,
                  capacity_source: Word,
                  flags: bits(4))
begin
    ExecuteQueueManagerMove(
        destination,
        address,
        capacity_source,
        flags);
end;

pure func InstructionContractChangesQueueManagerState_HL_QMT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractSnapshotsSourcesBeforeWrite_HL_QMT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The bare form clears i, e, s, and r and queries the remaining number of 64-bit entries.
- When i=0, the encoded SrcR field is ignored and is not read; canonical assembly omits it.
- When i=1, SrcR[9:0] supplies capacity 0..1023 and higher source bits are ignored.

## Legality

- Reg5 values 0..23 select absolute R0..R23 and 24..31 select the block-relative T#1..T#4 or U#1..U#4 entries; unavailable relative sources and invalid relative destinations reject before queue state changes.
- Every flag combination is assigned except s+r, including combinations that also set i or e; s+r raises Fault_IllegalInstruction before operand reads or effects.
- The event suffix is e; b is not an alias.

## State effects

- i=0 reports remaining 64-bit entries; i=1 atomically creates or replaces the queue and returns allocated bytes.
- A successful initialization clears prior entries, corruption, and suspension. Zero capacity creates a valid empty writable queue.
- Result bits [12:0] hold the primary value and [63:62] hold status; unused bits are zero. Status 0 is success, status 1 is missing/corrupt runtime state, and 2..3 are reserved.

## Memory effects and ordering

### Memory effects

- No direct memory access. Non-relaxed queue operations carry only the GQM ordering edges defined by push and pop.

### Ordering

- For a valid queue, the primary query or initialization occurs first, then e notification, then s suspension or r restoration.
- Initialization replacement, optional event/state action, and result publication form one instruction effect.

## Exceptions

- s+r and selector failures raise Fault_IllegalInstruction before source reads, queue observation, events, destination writes, or TPC advance.
- Missing, corrupt, suspend, and restore runtime conditions are reported only in the result status and do not trap.

## Examples

- hl.qmt a0, ->a1
- hl.qmt.ie t#1, u#1, ->t#2
- hl.qmt.s sp, ->u#1
