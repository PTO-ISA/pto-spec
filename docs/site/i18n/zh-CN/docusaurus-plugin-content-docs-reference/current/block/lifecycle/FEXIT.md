<!-- GENERATED FROM: asl/block/lifecycle/FEXIT.asl -->
# FEXIT

**Normative ASL source:** `asl/block/lifecycle/FEXIT.asl`

Destroys a restartable stack frame and restores one inclusive callee-save register-ring range.

## Normative identity {#PTO-INST-BLOCK-FEXIT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-fexit-purpose role=purpose -->
## FEXIT 的作用

`FEXIT` 是独立的栈帧生命周期命令；发布栈帧或控制流效果前，会先验证寄存器范围与栈状态。

<!-- PTO-READER-BLOCK: block-fexit-mechanism role=mechanism -->
## 放置与执行机制

`FEXIT` 作为独立的 `32` 位命令执行，不要求放在 `BSTART`/`BSTOP` Block 体内。

已接受载体使用 `L32` 编码类别；命令在读取绑定或改变状态前，会先解析所有显示字段。

命令会在第一个可见效果前快照所有必需源，随后遵循归属单元定义的提交或重启边界。

<!-- PTO-READER-BLOCK: block-fexit-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 编码操作数：`DstBegin` — R2..R23 闭环范围中的首个寄存器; `DstEnd` — R2..R23 闭环范围中的最后一个寄存器; `uimm` — 以八字节倍数编码的栈帧字节数。
- 所有操作数都来自已接受载体或命名架构状态；命令不会创建 Block 体私有的隐藏操作数流。
- 编码零仍是已分配值或明确规定的拒绝值；它不会静默表示省略操作数。

<!-- PTO-READER-BLOCK: block-fexit-effects role=effects -->
## 状态效果与顺序

源验证与快照发生在所有寄存器、队列、栈帧、内存、事件或控制流效果之前。

命令按内存契约规定的重启边界提交；只有归属单元明确允许保存重启进度时，先前已提交步骤才保持可见。

<!-- PTO-READER-BLOCK: block-fexit-constraints role=constraints -->
## 合法性、故障与原子性

固定比特、保留值、选择器取值域与必需的 Block 放置关系都在架构效果之前检查。

当前归属单元通过 `Fault_IllegalInstruction` 报告无效模式、状态、地址或后继条件；本页说明文字不创建额外故障规则。

除非当前归属单元明确规定带保留进度的重启边界，否则拒绝发生在效果之前；完成顺序始终采用 ASL 顺序。

<!-- PTO-READER-BLOCK: block-fexit-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
FEXIT [RegDst0 ~ RegDstn], sp!, uimm
```

所示已接受拼写从当前载体解析字段，快照必需源，再执行归属单元规定的状态与顺序转换。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
FEXIT [RegDst0 ~ RegDstn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fexit_32_37b663f2a34d | L32 | 32 | 0x00001041 / 0x0000707f | [{"field":"DstBegin","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"DstEnd","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fexit_32_37b663f2a34d | DstBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fexit_32_37b663f2a34d | DstEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fexit_32_37b663f2a34d | uimm | 15 | unsigned | [{"instruction_lsb":25,"value_lsb":3,"width":7},{"instruction_lsb":7,"value_lsb":10,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fexit_32_37b663f2a34d | DstBegin | 5 | 2–23 | none | 0–1, 24–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fexit_32_37b663f2a34d | DstEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fexit_32_37b663f2a34d | uimm | 15 | 0–32767 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

- `fexit_32_37b663f2a34d.DstBegin` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `fexit_32_37b663f2a34d.DstEnd` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstBegin | first register in the inclusive R2..R23 ring range |
| DstEnd | last register in the inclusive R2..R23 ring range |
| uimm | frame byte count, encoded in multiples of eight |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FEXIT.asl -->
```asl
readonly func InstructionContractMatches_FEXIT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fexit_32_37b663f2a34d);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FEXIT.asl -->
```asl
readonly func InstructionContractHandler_FEXIT() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameExit;
end;

func ExecuteFEXIT(begin_reg: Reg5Selector,
                  end_reg: Reg5Selector,
                  frame_size: Word)
begin
    ExitFrame(begin_reg, end_reg, frame_size);
end;

pure func InstructionContractUsesInclusiveRegisterRange_FEXIT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRejectsInvalidFrameRange_FEXIT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The inclusive register range is the ring R2..R23. Singleton, full-ring, and wraparound ranges are assigned.
- uimm is always present and represents a byte count in multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.

## Legality

- DstBegin and DstEnd select the inclusive R2..R23 callee-save ring; every endpoint outside 2..23 is reserved before effects.
- If the range contains N registers, uimm must be at least 8*N bytes. The encoding supplies only multiples of eight.

## State effects

- The accepted start records instruction PC, endpoints, count, frame size, reconstructed caller sp, and zero progress.
- After the final load, decrement nonzero frame depth, publish the last-frame tuple, clear active progress, and retire once.

## Memory effects and ordering

### Memory effects

- Load one aligned eight-byte value per selected destination from caller_sp-8, caller_sp-16, and subsequent descending slots.

### Ordering

- Add uimm to sp first, then load descending caller-frame slots in inclusive register-ring order.
- Each load, destination write, and progress advance commit as one restart event; recovery does not add sp twice or repeat earlier loads.

## Exceptions

- Reserved endpoints or an insufficient frame size raise Fault_IllegalInstruction before sp, register, memory, target, progress, or TPC effects.
- Each eight-byte stack access is a restart boundary. A recoverable access fault preserves earlier committed events and retries exactly the first uncommitted event from trap-preserved template state.

## Examples

- FEXIT [RegDst0 ~ RegDstn], sp!, uimm
