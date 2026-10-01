<!-- GENERATED FROM: asl/block/lifecycle/MCOPY.asl -->
# MCOPY

**Normative ASL source:** `asl/block/lifecycle/MCOPY.asl`

Copies a non-overlapping byte range in restartable forward memory steps.

## Normative identity {#PTO-INST-BLOCK-MCOPY}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-mcopy-purpose role=purpose -->
## MCOPY 的作用

`MCOPY` 用一条命令把一段字节范围从源地址复制到目的地址。两个范围不得重叠。复制以小步向前进行，每一步都是重启点，因此中途发生故障时已复制的字节保留，重试会完成其余部分。

<!-- PTO-READER-BLOCK: block-mcopy-mechanism role=mechanism -->
## 放置与执行机制

`MCOPY` 是独立的 32 位命令。它不打开或提交 block，也不写 `BARG`。

首次执行时，它读取三个 GPR 并检查范围。随后记录一个复制模板：指令 PC、目的地址、源地址、长度以及为零的进度。进度是已复制的字节数。

每一步复制 8、4、2 或 1 字节中不超过剩余长度的最大者。一步先探测源地址，再探测目的地址，之后才读取源并写入目的。最后一步之后，命令记录最近内存命令，并把 `TPC` 推进 4。

设计要点：一步的两个地址都在读取源之前完成探测。ASL 注释给出了结果：被拒绝的目的地址不会留下任何源读取或内存事件。

<!-- PTO-READER-BLOCK: block-mcopy-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `RegSrc0`，位 `19:15`，指定保存目的字节地址的 GPR。
- `RegSrc1`，位 `24:20`，指定保存源字节地址的 GPR。
- `RegSrc2`，位 `31:27`，指定保存字节数的 GPR，该字节数是完整的无符号 XLEN 值。

位 `14:0` 为 `0x0031`，位 `26:25` 为零。每个选择器只接受绝对 GPR `0..23`。代码 `24..31` 在其他命令中表示相对 T 与 U 队列条目，在此处属于保留值。

设计要点：没有可省略的操作数，编码零是真实的寄存器：选择器 0 读取架构零寄存器。因此 `RegSrc2` 为 0 时长度为零，这是合法的，不复制任何内容。

<!-- PTO-READER-BLOCK: block-mcopy-effects role=effects -->
## 状态效果与顺序

每一步按程序顺序记录一个 relaxed 加载事件，然后记录一个 relaxed 存储事件。写入与本地加载保留重叠的一步会使该保留失效。成功的零长度复制不执行访问，保留状态保持不变。

完成时，`_LastMemoryCommandAddress` 接收原始目的地址，`_LastMemoryCommandSize` 接收完整长度。

设计要点：模板在故障后保留。在同一 PC 再次执行同一条 `MCOPY` 时，它复用保存的地址与长度而不是重读 GPR，并从第一个尚未复制的字节继续。已提交的字节不会被复制两次。

设计要点：重叠在第一步之前被拒绝。因此向前复制永远不会读取同一次复制中较早一步写入的字节，目的范围总是接收原始的源字节。

<!-- PTO-READER-BLOCK: block-mcopy-constraints role=constraints -->
## 合法性、故障与原子性

- 选择器代码在 `24..31` 内时，在任何寄存器读取或内存效果之前引发 `Fault_IllegalInstruction`。
- 长度非零时，源或目的范围越过地址空间顶端而回绕，或两个范围重叠，会在任何内存、事件、保留、进度、最近命令或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。
- 源或目的访问故障精确到当前步。之前的步保持可见；被拒绝的一步没有读取、写入、事件、保留或进度效果。
- 复制模板处于活动状态时，在另一 PC 执行 `MCOPY` 会引发 `Fault_IllegalInstruction`。

下方生成的合法性与异常章节具有权威性。

<!-- PTO-READER-BLOCK: block-mcopy-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
MCOPY [a0, a1, a2]
```

假设 `a0` 保存 `0x9000`，`a1` 保存 `0x8000`，`a2` 保存 13。范围 `[0x9000, 0x900D)` 与 `[0x8000, 0x800D)` 互不相交。命令先复制 8 字节，再复制 4 字节，最后复制 1 字节。若 4 字节那一步在目的地址上发生故障，进度停留在 8，该步既不读取也不写入任何内容。重试复制字节 8 至 11，然后复制字节 12，并记录目的地址 `0x9000` 与长度 13。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
MCOPY [RegSrc0, RegSrc1, RegSrc2]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mcopy_32_4fc4a803e995 | L32 | 32 | 0x00000031 / 0x06007fff | [{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mcopy_32_4fc4a803e995 | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mcopy_32_4fc4a803e995 | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| mcopy_32_4fc4a803e995 | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| mcopy_32_4fc4a803e995 | RegSrc0 | 5 | 0–23 | none | 24–31 | absolute GPR containing destination byte address | Encoded zero reads destination byte address zero. |
| mcopy_32_4fc4a803e995 | RegSrc1 | 5 | 0–23 | none | 24–31 | absolute GPR containing source byte address | Encoded zero reads source byte address zero. |
| mcopy_32_4fc4a803e995 | RegSrc2 | 5 | 0–23 | none | 24–31 | absolute GPR containing complete unsigned XLEN byte count | Encoded zero reads length zero and selects the legal memory-free no-op. |

- `mcopy_32_4fc4a803e995.RegSrc0` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `mcopy_32_4fc4a803e995.RegSrc1` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `mcopy_32_4fc4a803e995.RegSrc2` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegSrc0 | absolute GPR containing destination byte address |
| RegSrc1 | absolute GPR containing source byte address |
| RegSrc2 | absolute GPR containing complete unsigned XLEN byte count |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/MCOPY.asl -->
```asl
readonly func InstructionContractMatches_MCOPY(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_mcopy_32_4fc4a803e995);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
MCOPY is one standalone template block. It retires only after the complete byte range has copied or after a legal zero-length no-op.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/MCOPY.asl -->
```asl
readonly func InstructionContractHandler_MCOPY() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteMemoryCopy;
end;

pure func InstructionContractMemoryStepRestartable_MCOPY()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractForbidsOverlap_MCOPY()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No operand is omitted. RegSrc0, RegSrc1, and RegSrc2 are absolute GPR selectors 0..23; selector zero reads architectural zero.
- RegSrc2 supplies the complete unsigned XLEN byte count. Zero length is legal and performs no memory access.

## Legality

- Each RegSrc field accepts exactly absolute GPR selectors 0..23. Relative T/U selector codes 24..31 are reserved for MCOPY.
- For nonzero length, both half-open intervals must be non-wrapping and disjoint.

## State effects

- At accepted start, snapshot destination, source, length, instruction PC, and zero progress into trap-preserved MemoryCopyTemplateState.
- After the final step, clear active progress, record the original destination and full length as the last memory command, and retire exactly once.

## Memory effects and ordering

### Memory effects

- Copy forward from source to destination in 8-, 4-, 2-, or 1-byte steps. Each step probes source and destination before reading, then records the source load and destination store in program order.
- The step write invalidates an overlapping local reservation. A successful zero-length command performs no access and does not change reservation state.

### Ordering

- Each source read precedes its corresponding destination write. The write and progress advance commit together at one restart boundary.
- On recovery the template resumes from its saved operand snapshot and first uncommitted byte without rereading GPRs or repeating earlier memory events.

## Exceptions

- Selector codes 24..31, a wrapping source or destination interval, or overlapping nonempty intervals raise Fault_IllegalInstruction before register-dependent memory, event, reservation, progress, last-command, or TPC effects.
- A source or destination access fault is precise to the current memory step. Earlier completed steps remain visible; the rejected step has no read, write, event, reservation, or progress effect.

## Examples

- MCOPY [a0, a1, a2]
