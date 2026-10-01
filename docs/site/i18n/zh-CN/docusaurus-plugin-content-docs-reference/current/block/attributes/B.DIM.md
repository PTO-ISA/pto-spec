<!-- GENERATED FROM: asl/block/attributes/B.DIM.asl -->
# B.DIM

**Normative ASL source:** `asl/block/attributes/B.DIM.asl`

Writes one selected bundle-local LB register from an absolute GPR plus immediate, truncated to 16 bits.

## Normative identity {#PTO-INST-BLOCK-B-DIM}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-dim-purpose role=purpose -->
## B.DIM 的作用

`B.DIM` 是 32 位 header 命令，用于写入一个指令束局部维度寄存器：`LB0`、`LB1` 或 `LB2`。写入值是某个绝对 GPR 与一个无符号 17 位立即数之和的低 16 位，并做零扩展。

`B.DIM` 本身不赋予寄存器任何含义。完成后的操作 schema 决定 `LB` 寄存器表示有效列数、行数、物理列数，还是 M、N 或 K 维度。例如，`TADD` 把 `LB0` 读作 `ValidCol`，把 `LB1` 读作 `ValidRow`，把 `LB2` 读作 `Col`。

<!-- PTO-READER-BLOCK: block-b-dim-mechanism role=mechanism -->
## 放置与机制

命令分派器只在 Block 处于活动状态且仍在 header 中时接受 `B.DIM`。否则引发 `Fault_BundleControl`。随后它计算 `GPR[RegSrc] + uimm17`，保留第 15 至 0 位，并调用 `SetBundleDimension`。

`SetBundleDimension` 检查目标的存在位。若该位已置位，则引发 `Fault_BundleControl` 并保留第一个值。否则置位存在位并保存该值。见[维度 schema 模型](../model/schema/dimensions.md)。

设计要点：每个 `LB` 寄存器在每个 Block 中只能写入一次，并且 `B.DIM` 与压缩形式 `C.B.DIMI` 为每个寄存器共用一个存在位。任一形式的第二次写入都会被拒绝，而不是静默覆盖第一次写入，因此操作读取的值总是 header 中写入的唯一值。

<!-- PTO-READER-BLOCK: block-b-dim-inputs role=inputs-outputs -->
## 编码字段

- 目标寄存器由形式通过第 12 至 14 位固定：`0x00000043` 写 `LB0`，`0x00001043` 写 `LB1`，`0x00002043` 写 `LB2`。
- `RegSrc`，第 15 至 19 位：绝对 GPR 选择器 0 至 23。选择器 0 读取架构零寄存器。编码 24 至 31 不是绝对 GPR；在其他命令中它们表示 Block 相对队列项。与范围修饰符 `B.SUBVIEW` 和 `B.ASSEMBLE` 不同（它们在读取任何 GPR 之前就拒绝这些编码），`B.DIM` 的命令路径中没有任何可执行检查把 `RegSrc` 限制在 0 至 23。
- `uimm17`，第 20 至 31 位（值的第 0 至 11 位）与第 7 至 11 位（值的第 12 至 16 位）：无符号加数。编码零表示加零。

两个字段总是被编码；`B.DIM` 没有可选部分。

<!-- PTO-READER-BLOCK: block-b-dim-effects role=effects -->
## 默认值与写入值

写入值为 `ZeroExtend((GPR[RegSrc] + uimm17)[15:0])`。和被截断到 16 位，因此 65536 及以上的值会回绕。

设计要点：从未写入的 `LB` 寄存器有效值为 1，显式写入（包括写 0）会替换该默认值。写入 0 的程序得到 0 而不是 1，然后由操作 schema 决定 0 是否合法。例如，`TADD` 拒绝显式出现的零维度。

某些操作 schema 也会读取存在位。对于 `TADD`，缺省的 `LB2` 选择 `Col = ValidCol` 而不是 1，并且 `LB0` 是必需的。每个操作的页面给出其确切默认值。

维度值和存在位在 Block 提交时被清除，因此不会带入下一个 Block。`B.DIM` 没有内存效果，也不改变 Tile 状态。

<!-- PTO-READER-BLOCK: block-b-dim-constraints role=constraints -->
## 合法性与故障

- 形式元数据把 `RegSrc` 编码 24 至 31 标为保留，但当前处理器不执行该检查：它直接读取译码得到的选择器（`asl/block/model/dispatch/commands.asl:123-138`）。因此保留选择器故障并非本页归属单元的可执行结果。
- 位于活动 Block header 之外的 `B.DIM` 引发 `Fault_BundleControl`。
- 通过 `B.DIM` 或 `C.B.DIMI` 再次写同一 `LB` 寄存器会引发 `Fault_BundleControl`，并保留第一个值。
- 取值范围限制（例如非零或 2 的幂要求）属于操作 schema，在 Block 预检时检查。

<!-- PTO-READER-BLOCK: block-b-dim-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.DIM a0, 16, ->LB0
B.DIM zero, 0, ->LB2
```

若 `a0 = 0x10010`，第一行计算得 `0x10020`，保留低 16 位，把 `0x0020`（即 32）写入 `LB0`。第二行把 0 写入 `LB2` 并置位其存在位，因此 `LB2` 不再具有默认值 1。`LB1` 保持默认值 1。同一 header 中之后的 `C.B.DIMI 8, ->LB0` 会访问同一存在位，并因重复写入引发 `Fault_BundleControl`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.DIM RegSrc, uimm17, ->LB0
B.DIM RegSrc, uimm17, ->LB1
B.DIM RegSrc, uimm17, ->LB2
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_dim_32_1caa1aa2944a | L32 | 32 | 0x00002043 / 0x0000707f | [{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |
| b_dim_32_27602ab68929 | L32 | 32 | 0x00000043 / 0x0000707f | [{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |
| b_dim_32_4191099a5f4d | L32 | 32 | 0x00001043 / 0x0000707f | [{"field":"RegSrc","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_dim_32_1caa1aa2944a | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_dim_32_1caa1aa2944a | uimm17 | 17 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |
| b_dim_32_27602ab68929 | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_dim_32_27602ab68929 | uimm17 | 17 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |
| b_dim_32_4191099a5f4d | RegSrc | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| b_dim_32_4191099a5f4d | uimm17 | 17 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_dim_32_1caa1aa2944a | RegSrc | 5 | 0–23 | none | 24–31 | absolute GPR source 0 through 23 | Encoded zero names the architectural zero GPR. |
| b_dim_32_1caa1aa2944a | uimm17 | 17 | 0–131071 | none | none | unsigned addend before low-16-bit truncation | Encoded zero supplies a zero displacement or zero immediate value. |
| b_dim_32_27602ab68929 | RegSrc | 5 | 0–23 | none | 24–31 | absolute GPR source 0 through 23 | Encoded zero names the architectural zero GPR. |
| b_dim_32_27602ab68929 | uimm17 | 17 | 0–131071 | none | none | unsigned addend before low-16-bit truncation | Encoded zero supplies a zero displacement or zero immediate value. |
| b_dim_32_4191099a5f4d | RegSrc | 5 | 0–23 | none | 24–31 | absolute GPR source 0 through 23 | Encoded zero names the architectural zero GPR. |
| b_dim_32_4191099a5f4d | uimm17 | 17 | 0–131071 | none | none | unsigned addend before low-16-bit truncation | Encoded zero supplies a zero displacement or zero immediate value. |

- `b_dim_32_1caa1aa2944a.RegSrc` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_dim_32_27602ab68929.RegSrc` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.
- `b_dim_32_4191099a5f4d.RegSrc` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegSrc | absolute GPR source 0 through 23 |
| uimm17 | unsigned addend before low-16-bit truncation |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/attributes/B.DIM.asl -->
```asl
readonly func InstructionContractMatches_B_DIM(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_dim_32_1caa1aa2944a) ||
           (operation == CommandOperation_b_dim_32_27602ab68929) ||
           (operation == CommandOperation_b_dim_32_4191099a5f4d);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Header command after BSTART and before the first body instruction. B.DIM and compressed dimension forms share one write-once presence bit for each of LB0, LB1, and LB2.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/attributes/B.DIM.asl -->
```asl
type BundleDimensionRegister of enumeration {
    BundleDimension_LB0,
    BundleDimension_LB1,
    BundleDimension_LB2
};

pure func BundleDimensionIndexOfRegister(reg: BundleDimensionRegister)
    => BundleDimensionIndex
begin
    case reg of
        when BundleDimension_LB0 => return 0;
        when BundleDimension_LB1 => return 1;
        when BundleDimension_LB2 => return 2;
    end;
end;

readonly func InstructionContractHandler_B_DIM() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleDimension;
end;

pure func InstructionContractHeaderOnly_B_DIM()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractDuplicateRejects_B_DIM()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected form fixes LB0, LB1, or LB2; RegSrc and uimm17 are both encoded and zero remains an explicit value.

## Legality

- b_dim_32_1caa1aa2944a.RegSrc accepts only absolute GPR codes 0..23; 24..31 are reserved.
- b_dim_32_27602ab68929.RegSrc accepts only absolute GPR codes 0..23; 24..31 are reserved.
- b_dim_32_4191099a5f4d.RegSrc accepts only absolute GPR codes 0..23; 24..31 are reserved.

## State effects

- Computes zero-extend((GPR[RegSrc] + zero-extend(uimm17))[15:0]) and writes the selected LB0, LB1, or LB2 register.
- LB meanings are selected by the completed operation schema; B.DIM itself assigns no universal row, column, M, N, or K role.
- Each LB may be written at most once per block across B.DIM and compressed dimension forms.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- RegSrc codes 24 through 31 raise Fault_IllegalInstruction before reading a queue or changing bundle state.
- A write outside an active block header or a second write to the same LB raises Fault_BundleControl before changing the first value.

## Examples

- B.DIM a0, 16, ->LB0
- B.DIM zero, 0, ->LB2
