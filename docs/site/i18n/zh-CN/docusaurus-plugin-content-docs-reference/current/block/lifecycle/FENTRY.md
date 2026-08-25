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

`FENTRY` 是独立的栈帧生命周期命令；发布栈帧或控制流效果前，会先验证寄存器范围与栈状态。

<!-- PTO-READER-BLOCK: block-fentry-mechanism role=mechanism -->
## 放置与执行机制

`FENTRY` 作为独立的 `32` 位命令执行，不要求放在 `BSTART`/`BSTOP` Block 体内。

已接受载体使用 `L32` 编码类别；命令在读取绑定或改变状态前，会先解析所有显示字段。

命令会在第一个可见效果前快照所有必需源，随后遵循归属单元定义的提交或重启边界。

<!-- PTO-READER-BLOCK: block-fentry-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 编码操作数：`SrcBegin` — R2..R23 闭环范围中的首个寄存器; `SrcEnd` — R2..R23 闭环范围中的最后一个寄存器; `uimm` — 以八字节倍数编码的栈帧字节数。
- 所有操作数都来自已接受载体或命名架构状态；命令不会创建 Block 体私有的隐藏操作数流。
- 编码零仍是已分配值或明确规定的拒绝值；它不会静默表示省略操作数。

<!-- PTO-READER-BLOCK: block-fentry-effects role=effects -->
## 状态效果与顺序

源验证与快照发生在所有寄存器、队列、栈帧、内存、事件或控制流效果之前。

命令按内存契约规定的重启边界提交；只有归属单元明确允许保存重启进度时，先前已提交步骤才保持可见。

<!-- PTO-READER-BLOCK: block-fentry-constraints role=constraints -->
## 合法性、故障与原子性

固定比特、保留值、选择器取值域与必需的 Block 放置关系都在架构效果之前检查。

当前归属单元通过 `Fault_IllegalInstruction` 报告无效模式、状态、地址或后继条件；本页说明文字不创建额外故障规则。

除非当前归属单元明确规定带保留进度的重启边界，否则拒绝发生在效果之前；完成顺序始终采用 ASL 顺序。

<!-- PTO-READER-BLOCK: block-fentry-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
FENTRY [RegSrc0 ~ RegSrcn], sp!, uimm
```

所示已接受拼写从当前载体解析字段，快照必需源，再执行归属单元规定的状态与顺序转换。
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
| fentry_32_a47584ec13b6 | uimm | 15 | unsigned | [{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fentry_32_a47584ec13b6 | SrcBegin | 5 | 2–23 | none | 0–1, 24–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fentry_32_a47584ec13b6 | SrcEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fentry_32_a47584ec13b6 | uimm | 15 | 0–32767 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

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
- uimm is always present and represents a byte count in multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.
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
