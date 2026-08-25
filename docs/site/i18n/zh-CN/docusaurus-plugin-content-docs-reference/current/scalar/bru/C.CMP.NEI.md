<!-- GENERATED FROM: asl/scalar/bru/C.CMP.NEI.asl -->
# C.CMP.NEI

**Normative ASL source:** `asl/scalar/bru/C.CMP.NEI.asl`

C.CMP.NEI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-C-CMP-NEI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-purpose role=purpose -->
## C.CMP.NEI 的作用

`C.CMP.NEI` 对解码后的标量操作数判断不相等，并发布规范化的 XLEN 一或零。

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-mechanism role=mechanism -->
## 执行机制

紧凑形式先把隐含的 `T#1` 快照为左操作数，再与解码后的有符号立即数比较，并把规范化结果压入 T。

源快照先于 T 压入，因此队列发布不会改变已经选定的值。

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-inputs-outputs role=inputs-outputs -->
## 输入与输出

- 隐含的 `T#1` 是左源，隐含输出是向 T 压入结果。

- `simm5` 提供有符号编码立即数。

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-effects role=effects -->
## 效果与顺序

规范化布尔值会隐含压入 T，随后 `TPC` 前进 `2` 字节。

该指令没有编码目的字段；它不修改提交状态，也不访问内存或保留状态。

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-constraints role=constraints -->
## 合法性与故障顺序

编码、保留字段值和源可用性都会在目的、控制或 `TPC` 效果前检查。

<!-- PTO-READER-BLOCK: scalar-c-cmp-nei-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

`c.cmp.nei t#1, simm, ->t` 在条件为真时发布 XLEN 一，否则发布 XLEN 零。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
c.cmp.nei t#1, simm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_cmp_nei_16_35d1f02063e2 | C16 | 16 | 0x082c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_cmp_nei_16_35d1f02063e2 | simm5 | 5 | signed | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_cmp_nei_16_35d1f02063e2 | simm5 | 5 | 0–31 | none | none | 5-bit signed immediate | Encoded zero supplies numeric zero for the 5-bit signed immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm5 | 5-bit signed immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/C.CMP.NEI.asl -->
```asl
readonly func InstructionContractOperation_C_CMP_NEI() => ScalarOperation
begin
    return ScalarOperation_C_CMP_NEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/C.CMP.NEI.asl -->
```asl
readonly func InstructionContractHandler_C_CMP_NEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_C_CMP_NEI()
    => ScalarCondition
begin
    return ScalarCondition_NE;
end;

pure func InstructionContractCompareResult_C_CMP_NEI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_C_CMP_NEI(),
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

- C.CMP.NEI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- c.cmp.nei t#1, simm, ->t
