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

`FEXIT` 用一条命令撤除栈帧。它把栈指针提高帧大小，并从帧中重新加载一段被调用者保存寄存器，每个寄存器占一个 8 字节槽位。它撤销匹配的 [FENTRY](FENTRY.md)，然后继续执行下一条指令。[FRET.RA](FRET.RA.md) 与 [FRET.STK](FRET.STK.md) 执行相同的恢复，并且还会返回。

栈指针是 GPR 1（`sp`）。共用的帧模板见 [帧生命周期](../model/lifecycle/lifetime.md)。

<!-- PTO-READER-BLOCK: block-fexit-mechanism role=mechanism -->
## 放置与执行机制

`FEXIT` 是独立的 32 位命令。它不打开或提交 block，也不写 `BARG`。

执行按固定顺序进行：

1. 检查端点与帧大小。
2. 以 `caller_sp = sp + size` 重建调用者栈指针，并与指令 PC、范围和帧大小一同记录。
3. 写入 `sp = caller_sp`。
4. 按范围顺序从 `caller_sp - 8`、`caller_sp - 16` 等位置加载寄存器，每步一次加载。
5. 最后一次加载之后，若帧深度非零则递减，记录最近帧元组，并把 `TPC` 推进 4。

设计要点：`sp` 在第一次加载之前恢复，模板会记录这一点已经完成。因此重试的 `FEXIT` 不会第二次把帧大小加到 `sp` 上。

<!-- PTO-READER-BLOCK: block-fexit-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `DstBegin`，位 `19:15`，是范围的第一个寄存器。
- `DstEnd`，位 `24:20`，是范围的最后一个寄存器。
- `uimm` 是 12 位字段，拆分在位 `31:25`（值位 `6:0`）与位 `11:7`（值位 `11:7`）。帧大小（字节）为 `uimm << 3`。

范围在环 `R2..R23` 上是闭区间，当 `DstEnd` 小于 `DstBegin` 时从 R23 回绕到 R2。范围中的槽位 `k` 位于 `caller_sp - 8*(k+1)`，与 `FENTRY` 对同一范围使用的槽位相同。

设计要点：每个字段都必须编码，没有默认值。端点的编码零指 R0，它在环之外，属于保留值。`uimm` 的编码零是真正的零字节帧，是非法的。

<!-- PTO-READER-BLOCK: block-fexit-effects role=effects -->
## 状态效果与顺序

每次加载以 relaxed 加载事件读取对齐的 8 字节，并写入目标寄存器。恢复 R10 时还会更新返回地址状态 `_ReturnAddress`。

设计要点：每次加载、其寄存器写入与进度推进作为一个重启事件一同提交。若某次加载发生故障，之前已恢复的寄存器与 `sp` 更新都保留。在同一 PC 重新执行同一条 `FEXIT` 时，从第一个尚未恢复的寄存器继续，不会重复之前的加载。

完成时，仅当 `_FrameDepth` 非零才递减它，并把 `DstBegin`、`DstEnd` 与帧大小记录为最近帧。

<!-- PTO-READER-BLOCK: block-fexit-constraints role=constraints -->
## 合法性、故障与原子性

- 端点不在 `2..23` 内时，在任何 `sp`、寄存器或内存效果之前引发 `Fault_IllegalInstruction`。
- 帧小于每个寄存器 8 字节时，在任何效果之前引发 `Fault_IllegalInstruction`。
- 加载遵循普通数据访问故障规则，并在其所在步精确地发生故障。
- 帧模板正在进行时，另一种类的帧命令，或位于另一 PC 的帧命令，会引发 `Fault_IllegalInstruction`，而不是继续该模板。

下方生成的合法性与异常章节具有权威性。

<!-- PTO-READER-BLOCK: block-fexit-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
FEXIT [RegDst0 ~ RegDstn], sp!, uimm
```

`FENTRY` 在 48 字节帧中保存了 R8 至 R11 之后，`sp` 为 `0x7FD0`。`DstBegin = 8`、`DstEnd = 11`、编码 `uimm` 为 6 的 `FEXIT` 计算 `caller_sp = 0x7FD0 + 48 = 0x8000` 并写入 `sp`。随后它从 `0x7FF8` 加载 R8，从 `0x7FF0` 加载 R9，从 `0x7FE8` 加载 R10，从 `0x7FE0` 加载 R11。若 R10 的加载发生故障，R8、R9 与 `sp` 已经恢复；重试只加载 R10 与 R11。
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
| fexit_32_37b663f2a34d | uimm | 12 | unsigned | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fexit_32_37b663f2a34d | DstBegin | 5 | 2–23 | none | 0–1, 24–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fexit_32_37b663f2a34d | DstEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fexit_32_37b663f2a34d | uimm | 12 | 0–4095 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

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
- uimm is always present and encodes the frame byte count scaled by eight: the semantic byte count is the encoded value shifted left by three, so the encoding supplies only multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.

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
