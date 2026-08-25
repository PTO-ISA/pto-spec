<!-- GENERATED FROM: asl/scalar/bru/CMP.ORI.asl -->
# CMP.ORI

**Normative ASL source:** `asl/scalar/bru/CMP.ORI.asl`

CMP.ORI - Combine scalar comparison results with the encoded logical operation.

## Normative identity {#PTO-INST-SCALAR-CMP-ORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-cmp-ori-purpose role=purpose -->
## CMP.ORI 的作用

`CMP.ORI` 对两个解码标量值执行按位或，并发布组合值是否非零。

<!-- PTO-READER-BLOCK: scalar-cmp-ori-mechanism role=mechanism -->
## 执行机制

两个源会在按位或之前完成快照。

组合 word 为零时结果是 XLEN 零，非零时规范化为 XLEN 一。

<!-- PTO-READER-BLOCK: scalar-cmp-ori-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RegDst` 选择编码指定的目的位置或丢弃行为。

- `SrcL` 提供左侧标量源。

- `simm12` 提供有符号编码立即数。

<!-- PTO-READER-BLOCK: scalar-cmp-ori-effects role=effects -->
## 效果与顺序

规范化布尔值先通过编码目的位置发布，随后 `TPC` 前进 `4` 字节。

该指令不修改提交状态，也不访问内存或保留状态。

<!-- PTO-READER-BLOCK: scalar-cmp-ori-constraints role=constraints -->
## 合法性与故障顺序

编码、保留字段值和源可用性都会在目的、控制或 `TPC` 效果前检查。

<!-- PTO-READER-BLOCK: scalar-cmp-ori-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

`cmp.ori SrcL, simm, ->{t, u, Rd}` 在条件为真时发布 XLEN 一，否则发布 XLEN 零。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
cmp.ori SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_ori_32_6d3efbc3d093 | L32 | 32 | 0x00003055 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_ori_32_6d3efbc3d093 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_ori_32_6d3efbc3d093 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_ori_32_6d3efbc3d093 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| cmp_ori_32_6d3efbc3d093 | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| cmp_ori_32_6d3efbc3d093 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_ori_32_6d3efbc3d093 | simm12 | 12 | 0–4095 | none | none | 12-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| simm12 | 12-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.ORI.asl -->
```asl
readonly func InstructionContractOperation_CMP_ORI() => ScalarOperation
begin
    return ScalarOperation_CMP_ORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.ORI.asl -->
```asl
readonly func InstructionContractHandler_CMP_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompareLogical;
end;

pure func InstructionContractCombinesWithOR_CMP_ORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCompareLogicalValue_CMP_ORI(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_CMP_ORI() then
        return left OR right;
    end;
    return left AND right;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- CMP.ORI - Combine scalar comparison results with the encoded logical operation.
- After decode and legality checks, execute the normative ExecuteCompareLogical ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- cmp.ori SrcL, simm, ->{t, u, Rd}
