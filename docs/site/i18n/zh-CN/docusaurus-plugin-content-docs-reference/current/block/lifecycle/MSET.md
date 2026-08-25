<!-- GENERATED FROM: asl/block/lifecycle/MSET.asl -->
# MSET

**Normative ASL source:** `asl/block/lifecycle/MSET.asl`

Fills a bounded byte range from three absolute GPR operands after complete access preflight.

## Normative identity {#PTO-INST-BLOCK-MSET}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-mset-purpose role=purpose -->
## MSET 的作用

`MSET` 是独立的全有或全无内存命令：填充前会预检完整目的范围；任何故障都要求完整重发，不保留部分进度。

<!-- PTO-READER-BLOCK: block-mset-mechanism role=mechanism -->
## 放置与执行机制

`MSET` 作为独立的 `32` 位命令执行，不要求放在 `BSTART`/`BSTOP` Block 体内。

已接受载体使用 `L32` 编码类别；命令在读取绑定或改变状态前，会先解析所有显示字段。

命令先快照目的地址、填充值和完整 `0..63` 长度，再在第一次存储前预检完整目的范围。

<!-- PTO-READER-BLOCK: block-mset-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 编码操作数：`RegSrc0` — 保存目的字节地址的绝对 GPR; `RegSrc1` — 低八位会被复制的绝对 GPR; `RegSrc2` — 保存完整无符号字节长度的绝对 GPR。
- 所有操作数都来自已接受载体或命名架构状态；命令不会创建 Block 体私有的隐藏操作数流。
- 编码零仍是已分配值或明确规定的拒绝值；它不会静默表示省略操作数。

<!-- PTO-READER-BLOCK: block-mset-effects role=effects -->
## 状态效果与顺序

三个 GPR 值都在范围验证或内存效果之前完成快照。

完整范围预检后，按地址递增顺序填充字节；成功时使重叠保留失效、记录命令状态，并在不保存进度的情况下退休一次。

<!-- PTO-READER-BLOCK: block-mset-constraints role=constraints -->
## 合法性、故障与原子性

固定比特、保留值、选择器取值域与必需的 Block 放置关系都在架构效果之前检查。

当前归属单元通过 `Fault_IllegalInstruction` 报告无效模式、状态、地址或后继条件；本页说明文字不创建额外故障规则。

预检期间发生 `Fault_DataPage` 时，完整范围、保留、最后命令状态和 `TPC` 都保持不变；恢复会完整重发。

<!-- PTO-READER-BLOCK: block-mset-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
MSET [a0, a1, a2]
```

所示已接受拼写从当前载体解析字段，快照必需源，再执行归属单元规定的状态与顺序转换。
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

pure func InstructionContractWritesMemory_MSET()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- All three absolute GPR fields are encoded and required; encoded zero reads the architectural zero GPR.
- LengthBytes is the complete unsigned XLEN value. Zero is a successful zero-length command; values 1 through 63 fill that many bytes.

## Legality

- RegSrc0, RegSrc1, and RegSrc2 each accept only absolute GPR codes 0 through 23; 24 through 31 are reserved.
- The complete unsigned LengthBytes value must be at most 63; it is never truncated to a smaller surrogate.
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
- LengthBytes greater than 63 raises Fault_IllegalInstruction before memory or last-command effects.
- A destination access fault is reported before the first store and leaves the complete range unchanged.

## Examples

- MSET [a0, a1, a2]
- MSET [zero, zero, zero]
