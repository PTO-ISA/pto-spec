<!-- GENERATED FROM: asl/block/lifecycle/FENTRY.asl -->
# FENTRY

**Normative ASL source:** `asl/block/lifecycle/FENTRY.asl`

Creates a restartable stack frame by snapshotting and storing one inclusive callee-save register-ring range.

## Normative identity {#PTO-INST-BLOCK-FENTRY}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-fentry-purpose role=purpose -->
## FENTRY 的作用

`FENTRY` 用一条命令建立栈帧。它把栈指针降低帧大小，并把一段被调用者保存寄存器存入新帧，每个寄存器占一个 8 字节槽位。它是配对操作中的进入一半：[FEXIT](FEXIT.md)、[FRET.RA](FRET.RA.md) 与 [FRET.STK](FRET.STK.md) 撤销它。

栈指针是 GPR 1（`sp`）。这四条命令共用的帧模板见 [帧生命周期](../model/lifecycle/lifetime.md)。

<!-- PTO-READER-BLOCK: block-fentry-mechanism role=mechanism -->
## 放置与执行机制

`FENTRY` 是独立的 32 位命令。它不打开或提交 block，也不写 `BARG`。

执行按固定顺序进行：

1. 检查端点与帧大小。
2. 记录指令 PC、范围、帧大小，以及作为调用者 `sp` 的当前 `sp`，并把每个源寄存器复制到模板中。
3. 写入 `sp = caller_sp - size`。
4. 按范围顺序把保存的寄存器存到 `caller_sp - 8`、`caller_sp - 16` 等位置，每步一次存储。
5. 最后一次存储之后，递增帧深度，记录最近帧元组，并把 `TPC` 推进 4。

设计要点：源寄存器在 `sp` 改变之前被复制，重试的 `FENTRY` 存储的是这些副本，而不是寄存器的当前值。因此重启时保存的正是命令最初观察到的值。

<!-- PTO-READER-BLOCK: block-fentry-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `SrcBegin`，位 `19:15`，是范围的第一个寄存器。
- `SrcEnd`，位 `24:20`，是范围的最后一个寄存器。
- `uimm` 是 12 位字段，拆分在位 `31:25`（值位 `6:0`）与位 `11:7`（值位 `11:7`）。帧大小（字节）为 `uimm << 3`。

范围在环 `R2..R23` 上是闭区间。当 `SrcEnd` 小于 `SrcBegin` 时，范围从 R23 回绕到 R2。单个寄存器的范围与完整的 22 个寄存器的环都合法。

设计要点：每个字段都必须编码，没有默认值。`SrcBegin` 或 `SrcEnd` 的编码零指 R0，它在环之外，属于保留值。`uimm` 的编码零是真正的零字节帧，由于每个范围至少包含一个寄存器，它是非法的。

<!-- PTO-READER-BLOCK: block-fentry-effects role=effects -->
## 状态效果与顺序

每次存储是一个对齐的 8 字节 relaxed 存储事件。存储写入调用者 `sp` 之下依次递减的槽位：范围的第一个寄存器位于 `caller_sp - 8`。

完成时递增 `_FrameDepth`（在其上界处饱和），并把 `SrcBegin`、`SrcEnd` 与帧大小记录为最近帧。

设计要点：每次存储与其进度推进一同提交，因此每次存储都是一个重启边界。若某次存储发生故障，之前的存储与 `sp` 更新都保留，模板保存进度。在同一 PC 重新执行同一条 `FENTRY` 时，从第一个尚未保存的寄存器继续。它不会重读源寄存器、再次调整 `sp`，也不会重复之前的存储。

<!-- PTO-READER-BLOCK: block-fentry-constraints role=constraints -->
## 合法性、故障与原子性

- 端点不在 `2..23` 内时，在任何效果之前引发 `Fault_IllegalInstruction`。
- 帧小于每个寄存器 8 字节时，在任何效果之前引发 `Fault_IllegalInstruction`。
- 存储遵循普通数据访问故障规则。槽位未对齐或未映射时，在该步引发 `Fault_DataAlignment` 或 `Fault_DataPage`。
- 帧模板正在进行时，另一种类的帧命令，或位于另一 PC 的帧命令，会引发 `Fault_IllegalInstruction`，而不是继续该模板。

下方生成的合法性与异常章节具有权威性。

<!-- PTO-READER-BLOCK: block-fentry-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm
```

取 `SrcBegin = 8`、`SrcEnd = 11`、48 字节帧（编码 `uimm` 为 6），且 `sp = 0x8000`。范围包含 4 个寄存器，因此最小帧为 32 字节，48 合法。`sp` 变为 `0x7FD0`。R8 存到 `0x7FF8`，R9 存到 `0x7FF0`，R10 存到 `0x7FE8`，R11 存到 `0x7FE0`。从 `0x7FD0` 到 `0x7FDF` 的 16 字节属于帧，但不被写入。使用相同范围与大小的 `FEXIT` 会恢复这四个寄存器，并把 `sp` 恢复为 `0x8000`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fentry_32_a47584ec13b6 | L32 | 32 | 0x00000041 / 0x0000707f | [{"field":"SrcBegin","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"SrcEnd","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fentry_32_a47584ec13b6 | SrcBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fentry_32_a47584ec13b6 | SrcEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fentry_32_a47584ec13b6 | uimm | 12 | unsigned | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fentry_32_a47584ec13b6 | SrcBegin | 5 | 2–23 | none | 0–1, 24–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fentry_32_a47584ec13b6 | SrcEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fentry_32_a47584ec13b6 | uimm | 12 | 0–4095 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

- `fentry_32_a47584ec13b6.SrcBegin` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `fentry_32_a47584ec13b6.SrcEnd` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcBegin | first register in the inclusive R2..R23 ring range |
| SrcEnd | last register in the inclusive R2..R23 ring range |
| uimm | frame byte count, encoded in multiples of eight |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FENTRY.asl -->
```asl
readonly func InstructionContractMatches_FENTRY(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fentry_32_a47584ec13b6);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FENTRY.asl -->
```asl
readonly func InstructionContractHandler_FENTRY() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameEntry;
end;

func ExecuteFENTRY(begin_reg: Reg5Selector,
                   end_reg: Reg5Selector,
                   frame_size: Word)
begin
    EnterFrame(begin_reg, end_reg, frame_size);
end;

pure func InstructionContractUsesInclusiveRegisterRange_FENTRY()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRejectsInvalidFrameRange_FENTRY()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The inclusive register range is the ring R2..R23. Singleton, full-ring, and wraparound ranges are assigned.
- uimm is always present and encodes the frame byte count scaled by eight: the semantic byte count is the encoded value shifted left by three, so the encoding supplies only multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.
- The source range is snapshotted before sp changes, so a range containing sp stores the caller sp.

## Legality

- SrcBegin and SrcEnd select the inclusive R2..R23 callee-save ring; every endpoint outside 2..23 is reserved before effects.
- If the range contains N registers, uimm must be at least 8*N bytes. The encoding supplies only multiples of eight.

## State effects

- The accepted start records instruction PC, endpoints, count, frame size, caller sp, complete source snapshot, and zero progress.
- After the final store, increment frame depth, publish the last-frame tuple, clear active progress, and retire once.

## Memory effects and ordering

### Memory effects

- Store one aligned eight-byte snapshot per selected register into consecutive descending slots below the caller sp.
- Every store records one relaxed store event and follows the ordinary PTO precise data-access fault contract.

### Ordering

- Snapshot the complete source range, subtract uimm from sp, then store snapshots in range order to caller_sp-8, caller_sp-16, and subsequent descending slots.
- Each store and progress advance commit atomically; recovery never rereads source registers or repeats an earlier store.

## Exceptions

- Reserved endpoints or an insufficient frame size raise Fault_IllegalInstruction before sp, register, memory, target, progress, or TPC effects.
- Each eight-byte stack access is a restart boundary. A recoverable access fault preserves earlier committed events and retries exactly the first uncommitted event from trap-preserved template state.

## Examples

- FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm
