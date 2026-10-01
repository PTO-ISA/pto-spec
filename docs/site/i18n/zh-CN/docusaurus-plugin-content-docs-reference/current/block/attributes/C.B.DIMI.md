<!-- GENERATED FROM: asl/block/attributes/C.B.DIMI.asl -->
# C.B.DIMI

**Normative ASL source:** `asl/block/attributes/C.B.DIMI.asl`

Writes one selected bundle-local LB from a zero-extended eight-bit immediate exactly once.

## Normative identity {#PTO-INST-BLOCK-C-B-DIMI}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-b-dimi-purpose role=purpose -->
## C.B.DIMI 的作用

`C.B.DIMI` 是 `B.DIM` 的 16 位压缩形式。它用一个无符号 8 位立即数写入一个指令束局部维度寄存器 `LB0`、`LB1` 或 `LB2`。它不读取任何寄存器。

与 `B.DIM` 一样，它不赋予寄存器任何含义。完成后的操作 schema 决定该值是有效列数、行数还是矩阵维度。

<!-- PTO-READER-BLOCK: block-c-b-dimi-mechanism role=mechanism -->
## 放置与执行机制

命令分派器只在 Block 处于活动状态且仍在 header 中（`BSTART` 之后、第一条 body 指令之前）时接受 `C.B.DIMI`。否则引发 `Fault_BundleControl`。

该命令通过 `SetBundleDimension` 写入 `ZeroExtend(imm8)`，这与 `B.DIM` 使用的写入器相同（见[维度 schema 模型](../model/schema/dimensions.md)）。

`C.B.DIMI` 与 `B.DIM` 为 `LB0`、`LB1`、`LB2` 分别共享一个只写一次的存在位。

设计要点：由于存在位是共享的，压缩形式与完整形式对同一寄存器可以互换，但不能都写它。混合使用（例如用 `C.B.DIMI` 写 `LB0`、用 `B.DIM` 写 `LB2`）是合法的；用两者都写 `LB0` 会被拒绝。

<!-- PTO-READER-BLOCK: block-c-b-dimi-inputs role=inputs-outputs -->
## 编码字段

- `imm8`，第 6 至 13 位：无符号值 0 至 255，零扩展到维度字。
- `LoopNest`，第 14 与 15 位：编码 0、1、2 依次选择 `LB0`、`LB1`、`LB2`。编码 3 保留，会在任何状态改变之前引发 `Fault_IllegalInstruction`。
- 第 0 至 5 位固定为 `0x3c`。

<!-- PTO-READER-BLOCK: block-c-b-dimi-effects role=effects -->
## 状态效果与顺序

放置检查和重复写检查发生在维度更新之前。

成功执行会原子发布所选原始 LB 值及其共享存在位，再将 `TPC` 前移 `2` 字节。

设计要点：`imm8` 总是被编码，因此编码零写入数值零。这不是省略：从未写入的 `LB` 寄存器有效值为 1，而 `C.B.DIMI 0, ->LB0` 使其为 0。随后由操作 schema 决定 0 是否合法。

<!-- PTO-READER-BLOCK: block-c-b-dimi-constraints role=constraints -->
## 合法性、故障与原子性

- `LoopNest` 编码 3 在 `TPC` 或 Block 状态发生任何改变之前引发 `Fault_IllegalInstruction`。
- 位于活动 Block header 之外的 `C.B.DIMI` 引发 `Fault_BundleControl`。

当前归属单元通过 `Fault_BundleControl`, `Fault_IllegalInstruction` 报告无效模式、状态、地址或后继条件；本页说明文字不创建额外故障规则。

通过 `C.B.DIMI` 或 `B.DIM` 再次写同一 LB 时，会在改变首次写入的值或存在位之前拒绝。

<!-- PTO-READER-BLOCK: block-c-b-dimi-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
C.B.DIMI 0, ->LB0
```

在活动 `BSTART` 之后，该 header 命令把数值零写入 `LB0` 并置位其存在位。大于 255 的值（例如 256）无法放入 `imm8`，需要使用带寄存器或 17 位立即数的 `B.DIM`，例如 `B.DIM zero, 256, ->LB2`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
C.B.DIMI imm8, ->LB0
C.B.DIMI imm8, ->LB1
C.B.DIMI imm8, ->LB2
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_b_dimi_16_3f1b113c76ce | C16 | 16 | 0x003c / 0x003f | [{"field":"LoopNest","operator":"not-equal","value":3}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_b_dimi_16_3f1b113c76ce | LoopNest | 2 | encoding-defined | [{"instruction_lsb":14,"value_lsb":0,"width":2}] |
| c_b_dimi_16_3f1b113c76ce | imm8 | 8 | encoding-defined | [{"instruction_lsb":6,"value_lsb":0,"width":8}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_b_dimi_16_3f1b113c76ce | LoopNest | 2 | 0–2 | none | 3 | encoded LB0, LB1, or LB2 selector | Code zero selects LB0. |
| c_b_dimi_16_3f1b113c76ce | imm8 | 8 | 0–255 | none | none | unsigned eight-bit bundle-local dimension value | Encoded zero writes numeric zero to the selected LB. |

- `c_b_dimi_16_3f1b113c76ce.LoopNest` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| LoopNest | encoded LB0, LB1, or LB2 selector |
| imm8 | unsigned eight-bit bundle-local dimension value |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/C.B.DIMI.asl -->
```asl
readonly func InstructionContractMatches_C_B_DIMI(
    operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_c_b_dimi_16_3f1b113c76ce;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Header command after BSTART and before the first body instruction. C.B.DIMI and B.DIM share one write-once presence bit for each of LB0, LB1, and LB2.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/C.B.DIMI.asl -->
```asl
pure func InstructionContractDimension_C_B_DIMI(
    loop_nest: bits(2))
    => BundleDimensionIndex
begin
    assert loop_nest != '11';
    return UInt(loop_nest) as BundleDimensionIndex;
end;

pure func InstructionContractValue_C_B_DIMI(
    immediate: bits(8))
    => Word
begin
    return ZeroExtend{PTO_XLEN}(immediate);
end;

readonly func InstructionContractHandler_C_B_DIMI()
    => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDimension;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- LoopNest 0, 1, and 2 select LB0, LB1, and LB2. imm8 is always present; encoded zero writes numeric zero and is not omission.

## Legality

- LoopNest codes 0..2 are assigned to LB0..LB2; code 3 is reserved.
- imm8 accepts every unsigned value 0..255 and is zero-extended to the bundle dimension word.
- Each selected LB is write-once for one block across full and compressed dimension commands.

## State effects

- Write ZeroExtend(imm8) to the selected raw LB and set its presence bit.
- LB meaning is selected by the completed operation schema; C.B.DIMI assigns no universal row, column, M, N, or K role.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Placement and duplicate checks precede the LB update. A successful update sets the presence bit and value together, then command dispatch advances TPC by two bytes.

## Exceptions

- LoopNest code 3 raises Fault_IllegalInstruction before changing TPC or bundle state.
- Execution outside an active block header or a second write to the same LB across C.B.DIMI and B.DIM raises Fault_BundleControl before changing the first value.

## Examples

- C.B.DIMI 0, ->LB0
- C.B.DIMI 255, ->LB2
