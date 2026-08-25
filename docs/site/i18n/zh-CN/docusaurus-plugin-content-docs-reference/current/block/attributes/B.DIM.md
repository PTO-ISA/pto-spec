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

`B.DIM` 是一条 32 位 Block header 命令，用来在构造 header 时写入一个 Block 局部维度寄存器。它修改待处理 Block 元数据，不会立即执行 Tile body 操作。

<!-- PTO-READER-BLOCK: block-b-dim-mechanism role=mechanism -->
## 位置与机制

该命令位于有效 header 中，并且在第一条 body 指令之前。它的有效顺序和数量由完成后的操作 schema 检查，而不是由本命令单独推断。

该命令把无符号立即数与选中的绝对 GPR 相加，保留低 16 位并做零扩展，然后一次性写入选中的 `LB0`、`LB1` 或 `LB2` 槽。

<!-- PTO-READER-BLOCK: block-b-dim-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `RegSrc` 标识输入源或源角色选择；其确切分配域仍以下方生成契约为准。
- `uimm17` 提供编码偏移或加数；其确切分配域仍以下方生成契约为准。

<!-- PTO-READER-BLOCK: block-b-dim-effects role=effects -->
## 待处理状态与完成

被接受的 header 命令只改变自己的待处理记录或 carrier。除非本所有者明确指出即时 header 状态更新，否则架构 Tile、Shared、GPR、内存和完成影响都推迟到完整 Block。

<!-- PTO-READER-BLOCK: block-b-dim-constraints role=constraints -->
## 合法性与故障边界

保留编码会在读取或待处理状态变化前被拒绝。位置、重复、角色或完成后 schema 不匹配，会在 body 影响前失败。

<!-- PTO-READER-BLOCK: block-b-dim-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.DIM RegSrc, uimm, ->LB2
```

假设当前存在兼容的有效 header，并且之前没有冲突的 `B.DIM` 命令。把 `B.DIM RegSrc, uimm, ->LB2` 放在下一个 header 槽，会记录该命令的待处理字段；它本身不会执行最终的 body 操作。
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
