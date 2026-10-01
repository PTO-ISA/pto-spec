<!-- GENERATED FROM: asl/block/lifecycle/MSET.asl -->
# MSET

**Normative ASL source:** `asl/block/lifecycle/MSET.asl`

Fills an arbitrary complete-XLEN byte range from three absolute GPR operands after complete access preflight.

## Normative identity {#PTO-INST-BLOCK-MSET}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-mset-purpose role=purpose -->
## MSET 的作用

`MSET` 用一条命令以一个字节值填充一段字节范围。它在写入任何内容之前检查整个目的范围，因此要么填满整个范围，要么在故障时保持内存不变。

<!-- PTO-READER-BLOCK: block-mset-mechanism role=mechanism -->
## 放置与执行机制

`MSET` 是独立的 32 位命令。它不打开或提交 block，也不写 `BARG`。

执行按固定顺序进行：

1. 从三个 GPR 读取目的地址、填充值与长度。
2. 拒绝越过地址空间顶端而回绕的非零范围。
3. 长度非零时，对完整目的范围预检写访问。
4. 按地址递增顺序，把填充值的低字节写入每个字节。
5. 记录最近内存命令，并把 `TPC` 推进 4。

设计要点：完整范围在第一次存储之前完成预检。与 [MCOPY](MCOPY.md) 不同，`MSET` 不保存进度状态。发生故障的 `MSET` 没有写入任何内容，因此再次执行会完成整个填充。

<!-- PTO-READER-BLOCK: block-mset-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `RegSrc0`，位 `19:15`，指定保存目的字节地址的 GPR。
- `RegSrc1`，位 `24:20`，指定其低八位作为填充字节的 GPR。更高位被忽略。
- `RegSrc2`，位 `31:27`，指定保存字节数的 GPR，该字节数是完整的无符号 XLEN 值。

位 `14:0` 为 `0x1031`，位 `26:25` 为零。每个选择器只接受绝对 GPR `0..23`；代码 `24..31` 属于保留值。

设计要点：三个字段都是必需的，编码零读取架构零寄存器。因此 `MSET [zero, zero, zero]` 是合法的零长度命令：它不访问内存，但仍把目的地址 0 与大小 0 记录为最近内存命令。

<!-- PTO-READER-BLOCK: block-mset-effects role=effects -->
## 状态效果与顺序

成功的非零填充写入范围内每个字节，若范围与本地加载保留的粒度重叠，则使该保留失效。零长度不执行任何内存或保留访问。

任何成功完成之后，`_LastMemoryCommandAddress` 接收目的地址，`_LastMemoryCommandSize` 接收长度。

此处内存按字节寻址：写预检使用一字节对齐，因此目的地址可以具有任意对齐。

<!-- PTO-READER-BLOCK: block-mset-constraints role=constraints -->
## 合法性、故障与原子性

- 选择器代码在 `24..31` 内时，在任何寄存器、内存、保留、最近命令或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。
- 回绕的非零目的范围在任何内存或最近命令效果之前引发 `Fault_IllegalInstruction`。
- 在可执行 ASL 中，长度超过 262144 字节或超过建模内存大小时，在任何存储之前以目的地址引发 `Fault_DataPage`。
- 预检中的写访问故障在第一次存储之前报告。

每种故障都使内存、保留、最近命令状态和 `TPC` 保持不变。下方生成的合法性与异常章节具有权威性。

<!-- PTO-READER-BLOCK: block-mset-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
MSET [a0, a1, a2]
```

假设 `a0` 保存 `0x9001`，`a1` 保存 `0x1234`，`a2` 保存 5。预检覆盖 `0x9001` 至 `0x9005`。若预检通过，这五个字节接收 `a1` 的低字节 `0x34`，最近内存命令变为地址 `0x9001`、大小 5。若预检在这五个字节中的任一字节上失败，则一个字节都不会被写入。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
MSET [Destination, FillByte, LengthBytes]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mset_32_0b932f291932 | L32 | 32 | 0x00001031 / 0x06007fff | [{"field":"RegSrc0","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc1","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]},{"field":"RegSrc2","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mset_32_0b932f291932 | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mset_32_0b932f291932 | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| mset_32_0b932f291932 | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| mset_32_0b932f291932 | RegSrc0 | 5 | 0–23 | none | 24–31 | absolute GPR containing destination byte address | Encoded zero supplies destination address zero. |
| mset_32_0b932f291932 | RegSrc1 | 5 | 0–23 | none | 24–31 | absolute GPR whose low eight bits are replicated | Encoded zero supplies fill byte zero. |
| mset_32_0b932f291932 | RegSrc2 | 5 | 0–23 | none | 24–31 | absolute GPR containing complete unsigned byte length | Encoded zero supplies zero length. |

- `mset_32_0b932f291932.RegSrc0` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `mset_32_0b932f291932.RegSrc1` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `mset_32_0b932f291932.RegSrc2` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegSrc0 | absolute GPR containing destination byte address |
| RegSrc1 | absolute GPR whose low eight bits are replicated |
| RegSrc2 | absolute GPR containing complete unsigned byte length |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/MSET.asl -->
```asl
readonly func InstructionContractMatches_MSET(operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_mset_32_0b932f291932;
end;

pure func InstructionContractAbsoluteGPRSelectorLegal_MSET(
    selector: Reg5Selector) => boolean
begin
    return selector <= 23;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
MSET is a standalone template instruction and does not consume a BSTART/BSTOP body.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/MSET.asl -->
```asl
readonly func InstructionContractHandler_MSET() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteMemorySet;
end;

pure func InstructionContractMemoryStepRestartable_MSET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractAcceptsCompleteXLENLength_MSET()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractWritesMemory_MSET()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- All three absolute GPR fields are encoded and required; encoded zero reads the architectural zero GPR.
- LengthBytes is the complete unsigned XLEN value. Zero is a successful zero-length command; every nonzero value names that many bytes and no fixed instruction-length ceiling applies.

## Legality

- RegSrc0, RegSrc1, and RegSrc2 each accept only absolute GPR codes 0 through 23; 24 through 31 are reserved.
- The complete unsigned LengthBytes value is assigned and is never truncated to a smaller surrogate; every nonzero destination interval must be non-wrapping.
- Every byte address is naturally aligned and the full destination range must pass write access preflight before effects.

## State effects

- After successful zero or nonzero completion, set _LastMemoryCommandAddress to Destination and _LastMemoryCommandSize to LengthBytes.
- On every fault, preserve memory, reservation state, last-command state, and TPC.

## Memory effects and ordering

### Memory effects

- For nonzero length, probe the complete destination byte range before the first store, then write FillByte[7:0] to every byte in increasing address order.
- A successful nonzero fill invalidates an overlapping local load-reservation granule; zero length performs no memory or reservation access.

### Ordering

- Snapshot all three GPR values before access validation and memory effects.
- Successful completion records the command state and then advances TPC by four bytes.

## Exceptions

- Selectors 24 through 31 in any source field raise Fault_IllegalInstruction before register, memory, reservation, last-command, or TPC effects.
- A nonzero destination interval that wraps modulo 2^PTO_XLEN raises Fault_IllegalInstruction before memory or last-command effects.
- A destination access fault is reported before the first store and leaves the complete range unchanged.

## Examples

- MSET [a0, a1, a2]
- MSET [zero, zero, zero]
