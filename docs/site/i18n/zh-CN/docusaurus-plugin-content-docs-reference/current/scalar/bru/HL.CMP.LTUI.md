<!-- GENERATED FROM: asl/scalar/bru/HL.CMP.LTUI.asl -->
# HL.CMP.LTUI

**Normative ASL source:** `asl/scalar/bru/HL.CMP.LTUI.asl`

HL.CMP.LTUI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-HL-CMP-LTUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-purpose role=purpose -->
## HL.CMP.LTUI 的作用

`HL.CMP.LTUI` 对解码后的标量操作数判断无符号小于，并发布规范化的 XLEN 一或零。

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-mechanism role=mechanism -->
## 执行机制

指令先对操作数取快照，准备解码立即数，再判断无符号小于。

`uimm24` 会在任何移位或比较前零扩展到 XLEN。

关系成立时结果为 XLEN 一，否则为 XLEN 零。

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `RegDst` 选择编码指定的目的位置或丢弃行为。

- `SrcL` 提供左侧标量源。

- `uimm24` 提供无符号编码立即数。

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-effects role=effects -->
## 效果与顺序

规范化布尔值先通过编码目的位置发布，随后 `TPC` 前进 `6` 字节。

该指令不修改提交状态，也不访问内存或保留状态。

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-constraints role=constraints -->
## 合法性与故障顺序

编码、保留字段值和源可用性都会在目的、控制或 `TPC` 效果前检查。

<!-- PTO-READER-BLOCK: scalar-hl-cmp-ltui-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

`hl.cmp.ltui SrcL, uimm, ->{t, u, Rd}` 在条件为真时发布 XLEN 一，否则发布 XLEN 零。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.cmp.ltui SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_cmp_ltui_48_d12167277d58 | HL48 | 48 | 0x00006055000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_cmp_ltui_48_d12167277d58 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_cmp_ltui_48_d12167277d58 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_cmp_ltui_48_d12167277d58 | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_cmp_ltui_48_d12167277d58 | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| hl_cmp_ltui_48_d12167277d58 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_cmp_ltui_48_d12167277d58 | uimm24 | 24 | 0–16777215 | none | none | 24-bit unsigned immediate | Encoded zero supplies numeric zero for the 24-bit unsigned immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| uimm24 | 24-bit unsigned immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.CMP.LTUI.asl -->
```asl
readonly func InstructionContractOperation_HL_CMP_LTUI() => ScalarOperation
begin
    return ScalarOperation_HL_CMP_LTUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.CMP.LTUI.asl -->
```asl
readonly func InstructionContractHandler_HL_CMP_LTUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_HL_CMP_LTUI()
    => ScalarCondition
begin
    return ScalarCondition_LTU;
end;

pure func InstructionContractCompareResult_HL_CMP_LTUI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_HL_CMP_LTUI(),
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- Every value in each unconstrained encoded field is assigned; constrained complements are reserved and reject before effects.

## State effects

- HL.CMP.LTUI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- hl.cmp.ltui SrcL, uimm, ->{t, u, Rd}
