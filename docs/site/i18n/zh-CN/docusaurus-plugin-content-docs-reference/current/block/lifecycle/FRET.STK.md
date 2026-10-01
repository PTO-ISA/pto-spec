<!-- GENERATED FROM: asl/block/lifecycle/FRET.STK.asl -->
# FRET.STK

**Normative ASL source:** `asl/block/lifecycle/FRET.STK.asl`

Restores a restartable stack frame whose first stack slot supplies the validated return target.

## Normative identity {#PTO-INST-BLOCK-FRET-STK}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-fret-stk-purpose role=purpose -->
## FRET.STK 的作用

`FRET.STK` 用一条命令撤除栈帧并返回，返回地址取自帧本身保存的值。范围必须从 R10（`ra`）开始。第一个帧槽位中的值既是恢复后的 `ra`，也是返回目标。

它与范围同样从 R10 开始的 [FENTRY](FENTRY.md) 配对。栈指针是 GPR 1（`sp`）。共用的帧模板见 [帧生命周期](../model/lifecycle/lifetime.md)。

<!-- PTO-READER-BLOCK: block-fret-stk-mechanism role=mechanism -->
## 放置与执行机制

`FRET.STK` 是独立的 32 位命令。它不打开或提交 block，也不写 `BARG`。

执行按固定顺序进行：

1. 检查端点与帧大小，包括 `DstBegin = 10`。
2. 计算 `caller_sp = sp + size` 并写入 `sp`。
3. 从 `caller_sp - 8` 加载槽位零。值为奇数时引发 `Fault_InstructionPC`。否则该值成为返回目标，并写入 R10 与 `_ReturnAddress`。
4. 从 `caller_sp - 16` 起按范围顺序加载其余寄存器。
5. 最后一次加载之后，若帧深度非零则递减，记录最近帧元组，并把目标写入 `TPC`。

设计要点：槽位零在写入 `ra` 之前完成验证。因此错误的保存地址永远不会到达 `ra`、`_ReturnAddress` 或 `TPC`。

<!-- PTO-READER-BLOCK: block-fret-stk-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `DstBegin`，位 `19:15`，必须编码为 10。其他环端点对此命令保留。
- `DstEnd`，位 `24:20`，是范围的最后一个寄存器，取值在 `2..23` 内。
- `uimm` 是 12 位字段，拆分在位 `31:25`（值位 `6:0`）与位 `11:7`（值位 `11:7`）。帧大小（字节）为 `uimm << 3`。

每个字段都必须编码，没有默认值。端点的编码零指 R0，属于保留值。`uimm` 的编码零是真正的零字节帧，是非法的。

<!-- PTO-READER-BLOCK: block-fret-stk-effects role=effects -->
## 状态效果与顺序

每次加载以 relaxed 加载事件读取对齐的 8 字节并写入其寄存器。每次加载与其进度推进构成一个重启事件。

完成时，若 `_FrameDepth` 非零则递减，记录最近帧，并以槽位零目标写入 `TPC`。没有顺序的 `TPC` 递增。

设计要点：`sp` 在读取槽位零之前恢复。若槽位零发生故障，`sp` 更新保持已提交状态，并对陷阱处理程序可见。模板记录了 `sp` 已调整，因此重新执行 `FRET.STK` 不会再次调整它。

<!-- PTO-READER-BLOCK: block-fret-stk-constraints role=constraints -->
## 合法性、故障与原子性

- `DstBegin` 不为 10、端点不在 `2..23` 内，或帧小于每个寄存器 8 字节时，在任何效果之前引发 `Fault_IllegalInstruction`。
- 槽位零的值为奇数时，在 `ra`、目标、槽位零进度或后续寄存器效果之前引发 `Fault_InstructionPC`。
- 加载遵循普通数据访问故障规则，并在其所在步精确地发生故障。
- 帧模板正在进行时，另一种类的帧命令，或位于另一 PC 的帧命令，会引发 `Fault_IllegalInstruction`，而不是继续该模板。

下方生成的合法性与异常章节具有权威性。

<!-- PTO-READER-BLOCK: block-fret-stk-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
FRET.STK [ra ~ RegDstn], sp!, uimm
```

某条 `FENTRY` 从 `sp = 0x8000` 起在 24 字节帧中保存了 R10 至 R12，因此 `sp` 现为 `0x7FE8`，位于 `0x7FF8` 的槽位零保存 `0x3000`。`DstEnd = 12`、编码 `uimm` 为 3 的 `FRET.STK` 把 `sp` 设为 `0x8000`，把 `0x3000` 加载到 R10 作为目标，然后从 `0x7FF0` 恢复 R11，从 `0x7FE8` 恢复 R12。`TPC` 变为 `0x3000`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
FRET.STK [ra ~ RegDstn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fret_stk_32_4fe246bd8241 | L32 | 32 | 0x00003041 / 0x0000707f | [{"field":"DstBegin","operator":"one-of","values":[10]},{"field":"DstEnd","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fret_stk_32_4fe246bd8241 | DstBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fret_stk_32_4fe246bd8241 | DstEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fret_stk_32_4fe246bd8241 | uimm | 12 | unsigned | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fret_stk_32_4fe246bd8241 | DstBegin | 5 | 10 | none | 0–9, 11–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fret_stk_32_4fe246bd8241 | DstEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fret_stk_32_4fe246bd8241 | uimm | 12 | 0–4095 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

- `fret_stk_32_4fe246bd8241.DstBegin` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `fret_stk_32_4fe246bd8241.DstEnd` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstBegin | first register in the inclusive R2..R23 ring range |
| DstEnd | last register in the inclusive R2..R23 ring range |
| uimm | frame byte count, encoded in multiples of eight |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FRET.STK.asl -->
```asl
readonly func InstructionContractMatches_FRET_STK(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fret_stk_32_4fe246bd8241);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FRET.STK.asl -->
```asl
readonly func InstructionContractHandler_FRET_STK() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameReturnStack;
end;

func ExecuteFRETSTK(begin_reg: Reg5Selector,
                    end_reg: Reg5Selector,
                    frame_size: Word)
begin
    ReturnFromFrame(begin_reg, end_reg, frame_size, FALSE);
end;

pure func InstructionContractUsesInclusiveRegisterRange_FRET_STK()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRejectsInvalidFrameRange_FRET_STK()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The inclusive register range is the ring R2..R23. Singleton, full-ring, and wraparound ranges are assigned.
- uimm is always present and encodes the frame byte count scaled by eight: the semantic byte count is the encoded value shifted left by three, so the encoding supplies only multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.
- The range must begin at architectural ra (R10); stack slot zero supplies both restored ra and the return target.

## Legality

- DstBegin and DstEnd select the inclusive R2..R23 callee-save ring; every endpoint outside 2..23 is reserved before effects.
- If the range contains N registers, uimm must be at least 8*N bytes. The encoding supplies only multiples of eight.
- DstBegin must encode R10 exactly; other otherwise legal ring endpoints are reserved for FRET.STK.

## State effects

- Slot zero updates both architectural ra and the retained return-address state; subsequent slots restore the rest of the inclusive range.
- Completion decrements nonzero frame depth, publishes the last-frame tuple, clears progress, and transfers to the validated target.

## Memory effects and ordering

### Memory effects

- Load one aligned eight-byte value per selected destination; slot zero is the return-target load and remains an exact restart boundary.

### Ordering

- Add uimm to sp, load and validate slot zero before restoring ra, then restore the remaining selected registers in ring order.
- After the final restore, publish the validated slot-zero target to TPC; the command does not perform a sequential TPC increment.

## Exceptions

- Reserved endpoints or an insufficient frame size raise Fault_IllegalInstruction before sp, register, memory, target, progress, or TPC effects.
- Each eight-byte stack access is a restart boundary. A recoverable access fault preserves earlier committed events and retries exactly the first uncommitted event from trap-preserved template state.
- An odd slot-zero value raises Fault_InstructionPC before ra, target, slot-zero progress, or later-register effects; an earlier committed sp adjustment remains restart-visible.

## Examples

- FRET.STK [ra ~ RegDstn], sp!, uimm
