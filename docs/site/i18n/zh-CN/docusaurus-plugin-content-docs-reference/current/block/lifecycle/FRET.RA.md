<!-- GENERATED FROM: asl/block/lifecycle/FRET.RA.asl -->
# FRET.RA

**Normative ASL source:** `asl/block/lifecycle/FRET.RA.asl`

Restores a restartable stack frame and returns through the pre-restore architectural return address.

## Normative identity {#PTO-INST-BLOCK-FRET-RA}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-fret-ra-purpose role=purpose -->
## FRET.RA 的作用

`FRET.RA` 用一条命令撤除栈帧并返回。它与 [FEXIT](FEXIT.md) 完全一样地恢复寄存器，然后转移到恢复开始之前的当前返回地址。

返回地址是返回地址状态 `_ReturnAddress`。调用形式的 block 启动与 [SETRET](../../scalar/bru/SETRET.md) 会把相同的值写入它和 R10（`ra`）。栈指针是 GPR 1（`sp`）。共用的帧模板见 [帧生命周期](../model/lifecycle/lifetime.md)。

<!-- PTO-READER-BLOCK: block-fret-ra-mechanism role=mechanism -->
## 放置与执行机制

`FRET.RA` 是独立的 32 位命令。它不打开或提交 block，也不写 `BARG`。

执行按固定顺序进行：

1. 检查端点与帧大小。
2. 把 `_ReturnAddress` 快照为返回目标。目标为奇数时引发 `Fault_InstructionPC`。
3. 计算 `caller_sp = sp + size` 并写入 `sp`。
4. 按范围顺序从 `caller_sp - 8`、`caller_sp - 16` 等位置加载寄存器。
5. 最后一次加载之后，若帧深度非零则递减，记录最近帧元组，并把快照的目标写入 `TPC`。

设计要点：目标在任何寄存器被恢复之前捕获。若范围包含 R10，恢复会改变 `ra` 与 `_ReturnAddress`，但命令仍返回到它开始时的当前地址。

<!-- PTO-READER-BLOCK: block-fret-ra-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `DstBegin`，位 `19:15`，是范围的第一个寄存器。
- `DstEnd`，位 `24:20`，是范围的最后一个寄存器。
- `uimm` 是 12 位字段，拆分在位 `31:25`（值位 `6:0`）与位 `11:7`（值位 `11:7`）。帧大小（字节）为 `uimm << 3`。

范围在环 `R2..R23` 上是闭区间，并从 R23 回绕到 R2。每个字段都必须编码，没有默认值。端点的编码零指 R0，属于保留值。`uimm` 的编码零是真正的零字节帧，是非法的。

<!-- PTO-READER-BLOCK: block-fret-ra-effects role=effects -->
## 状态效果与顺序

每次加载以 relaxed 加载事件读取对齐的 8 字节并写入其寄存器。与 `FEXIT` 相同，每次加载与其进度推进构成一个重启事件，重试的命令不会两次调整 `sp`，也不会重复之前的加载。

完成时，若 `_FrameDepth` 非零则递减，记录最近帧，并以目标写入 `TPC`。没有顺序的 `TPC` 递增。

设计要点：转移只在最后一个寄存器恢复之后写入。中途发生故障时，`TPC` 仍指向该 `FRET.RA`，因此恢复会重新执行它，在返回之前继续完成恢复。

<!-- PTO-READER-BLOCK: block-fret-ra-constraints role=constraints -->
## 合法性、故障与原子性

- 端点不在 `2..23` 内，或帧小于每个寄存器 8 字节时，在任何效果之前引发 `Fault_IllegalInstruction`。
- 返回目标为奇数时，在任何 `sp`、内存、寄存器、帧或返回效果之前引发 `Fault_InstructionPC`。
- 加载遵循普通数据访问故障规则，并在其所在步精确地发生故障。
- 帧模板正在进行时，另一种类的帧命令，或位于另一 PC 的帧命令，会引发 `Fault_IllegalInstruction`，而不是继续该模板。

下方生成的合法性与异常章节具有权威性。

<!-- PTO-READER-BLOCK: block-fret-ra-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
FRET.RA [RegDst0 ~ RegDstn], sp!, uimm
```

某函数在 48 字节帧中保存了 R8 至 R11，因此 `sp` 为 `0x7FD0`，且 `_ReturnAddress` 为 `0x3000`。`DstBegin = 8`、`DstEnd = 11`、编码 `uimm` 为 6 的 `FRET.RA` 快照 `0x3000`，把 `sp` 设为 `0x8000`，并恢复 R8 至 R11。R10 接收来自 `0x7FE8` 的保存值，这也会更新 `_ReturnAddress`。`TPC` 仍然变为 `0x3000`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
FRET.RA [RegDst0 ~ RegDstn], sp!, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fret_ra_32_659c886221c1 | L32 | 32 | 0x00002041 / 0x0000707f | [{"field":"DstBegin","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"DstEnd","operator":"one-of","values":[2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fret_ra_32_659c886221c1 | DstBegin | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fret_ra_32_659c886221c1 | DstEnd | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fret_ra_32_659c886221c1 | uimm | 12 | unsigned | [{"instruction_lsb":25,"value_lsb":0,"width":7},{"instruction_lsb":7,"value_lsb":7,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| fret_ra_32_659c886221c1 | DstBegin | 5 | 2–23 | none | 0–1, 24–31 | first register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fret_ra_32_659c886221c1 | DstEnd | 5 | 2–23 | none | 0–1, 24–31 | last register in the inclusive R2..R23 ring range | Encoded zero is outside the callee-save ring and is reserved. |
| fret_ra_32_659c886221c1 | uimm | 12 | 0–4095 | none | none | frame byte count, encoded in multiples of eight | Encoded zero is a real zero-byte frame size and is illegal for every nonempty range. |

- `fret_ra_32_659c886221c1.DstBegin` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `fret_ra_32_659c886221c1.DstEnd` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| DstBegin | first register in the inclusive R2..R23 ring range |
| DstEnd | last register in the inclusive R2..R23 ring range |
| uimm | frame byte count, encoded in multiples of eight |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/FRET.RA.asl -->
```asl
readonly func InstructionContractMatches_FRET_RA(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_fret_ra_32_659c886221c1);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/FRET.RA.asl -->
```asl
readonly func InstructionContractHandler_FRET_RA() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteFrameReturnAddress;
end;

func ExecuteFRETRA(begin_reg: Reg5Selector,
                   end_reg: Reg5Selector,
                   frame_size: Word)
begin
    ReturnFromFrame(begin_reg, end_reg, frame_size, TRUE);
end;

pure func InstructionContractUsesInclusiveRegisterRange_FRET_RA()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractRejectsInvalidFrameRange_FRET_RA()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The inclusive register range is the ring R2..R23. Singleton, full-ring, and wraparound ranges are assigned.
- uimm is always present and encodes the frame byte count scaled by eight: the semantic byte count is the encoded value shifted left by three, so the encoding supplies only multiples of eight; encoded zero is real zero and is illegal because every assigned range contains at least one register.
- The return target is the architectural ra value snapshotted before any restored register can overwrite ra.

## Legality

- DstBegin and DstEnd select the inclusive R2..R23 callee-save ring; every endpoint outside 2..23 is reserved before effects.
- If the range contains N registers, uimm must be at least 8*N bytes. The encoding supplies only multiples of eight.

## State effects

- Restoring a range that contains ra updates the architectural ra value without changing the already snapshotted return target.
- Completion decrements nonzero frame depth, publishes the last-frame tuple, clears progress, and transfers to the validated target.

## Memory effects and ordering

### Memory effects

- Load one aligned eight-byte value per selected destination using the same restartable frame-slot order as FEXIT.

### Ordering

- Snapshot and validate the pre-restore return target, add uimm to sp, then restore descending slots in register-ring order.
- After the final restore, publish the snapshotted target to TPC; the command does not perform a sequential TPC increment.

## Exceptions

- Reserved endpoints or an insufficient frame size raise Fault_IllegalInstruction before sp, register, memory, target, progress, or TPC effects.
- Each eight-byte stack access is a restart boundary. A recoverable access fault preserves earlier committed events and retries exactly the first uncommitted event from trap-preserved template state.
- An odd pre-restore ra raises Fault_InstructionPC before sp, memory, destination, frame, or return effects.

## Examples

- FRET.RA [RegDst0 ~ RegDstn], sp!, uimm
