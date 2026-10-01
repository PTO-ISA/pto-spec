<!-- GENERATED FROM: asl/scalar/bru/CMP.GEU.asl -->
# CMP.GEU

**Normative ASL source:** `asl/scalar/bru/CMP.GEU.asl`

CMP.GEU - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-CMP-GEU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-cmp-geu-purpose role=purpose -->
## CMP.GEU 的作用

`CMP.GEU` 求值无符号的大于等于关系，并把规范 XLEN 布尔值写入目的：条件成立时为 `1`，不成立时为 `0`。

结果是普通数据。`CMP.GEU` 不设置所在块的提交条件，也不触碰任何谓词寄存器。

<!-- PTO-READER-BLOCK: scalar-cmp-geu-mechanism role=mechanism -->
## 机制

契约返回 `ScalarHandler_ExecuteCompare`。模型读取左源、准备右操作数、测试条件 `ScalarCondition_GEU`，并通过目的选择子写入 `Zeros{PTO_XLEN} + 1` 或 `Zeros{PTO_XLEN}`。

`SrcRType` 选择在测试关系之前对 `SrcR` 快照施加的一种变换。取值 `1` 换为符号扩展的低 `32` 位，取值 `2` 换为零扩展的低 `32` 位。取值 `0` 与 `3` 都已定义，且都保持完整值不变：模型对 `11` 修饰符原样透传，因此没有任何 `SrcRType` 编码被保留，只有 `1` 与 `2` 会改变参与比较的值。

设计要点：`CMP.AND` 与 `CMP.OR` 才是通过另一套修饰符解码器施加 `.not` 修饰符的寄存器形式比较。对于这些关系形式，即 `cmp.eq` 及其同族，关系所测试的就是程序放入 `SrcR` 的那个值。

该关系是无符号的：模型比较 `UInt(left)` 与 `UInt(right)`，因此像全一这样的负值模式会被当作极大的值。

设计要点：规范化为恰好 `1` 或 `0`（而不是任意非零值），使两次比较可以做算术组合，并且对目的做一次测试就足以恢复该关系。

<!-- PTO-READER-BLOCK: scalar-cmp-geu-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供左侧绝对 GPR 源，`SrcR` 提供右侧绝对 GPR 源。
- `SrcRType` 选择对 `SrcR` 的变换：`1` 换为符号扩展的低 `32` 位，`2` 换为零扩展的低 `32` 位，`0` 与 `3` 都保持完整值不变。

`RegDst` 命名目的：编码 `1..23` 写入所指的绝对 GPR，编码 `0` 与编码 `24..29` 丢弃结果，编码 `30` 把它压入 `U` 队列，编码 `31` 把它压入 `T` 队列。

`SrcL` 编码为零时指向架构零 GPR。源按值读取，不会被消耗。

<!-- PTO-READER-BLOCK: scalar-cmp-geu-effects role=effects -->
## 效果与排序

成功时该指令恰好写入一个目的值，并让 `TPC` 前进 `4` 字节，即 `32` 位形式的编码长度。

它没有内存效果、没有保留效果、没有描述符效果，也没有数值状态标志。它保持提交参数、块参数和块条件标记不变，因为它不是条件设置指令。

设计要点：由于该比较既不能观察提交条件，也不能安装控制流目标，编译器可以在其目的被读取之前，把它与其他纯标量操作自由重排。

<!-- PTO-READER-BLOCK: scalar-cmp-geu-constraints role=constraints -->
## 合法性与故障顺序

先执行解码，固定位不匹配会在指令地址处抛出 `Fault_IllegalInstruction`，且在任何效果之前。

`SrcL`、`SrcR` 和 `RegDst` 的全部 `32` 个编码都已分配，且 `SrcRType` 的四个取值都已定义，因此没有保留的寄存器或修饰位编码。

被选中但不可用的 `T` 或 `U` 源会在操作数合法性阶段被拒绝，且早于目的写入。被拒绝的指令既不改变目的也不改变 `TPC`，陷入入口保存原始 `TPC`，因此它可以重新执行。

<!-- PTO-READER-BLOCK: scalar-cmp-geu-example role=example -->
## 非规范示例

把 GPR1 设为 `5`，把 GPR2 设为 `5`。

`cmp.geu 1, 2, ->0` 把 `1` 写入目的。若把 GPR2 设为 `6`，同一形式写入 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
cmp.geu SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_geu_32_0c002dc415ef | L32 | 32 | 0x00007045 / 0xf800707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_geu_32_0c002dc415ef | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_geu_32_0c002dc415ef | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_geu_32_0c002dc415ef | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| cmp_geu_32_0c002dc415ef | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| cmp_geu_32_0c002dc415ef | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| cmp_geu_32_0c002dc415ef | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_geu_32_0c002dc415ef | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_geu_32_0c002dc415ef | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.GEU.asl -->
```asl
readonly func InstructionContractOperation_CMP_GEU() => ScalarOperation
begin
    return ScalarOperation_CMP_GEU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.GEU.asl -->
```asl
readonly func InstructionContractHandler_CMP_GEU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_CMP_GEU()
    => ScalarCondition
begin
    return ScalarCondition_GEU;
end;

pure func InstructionContractCompareResult_CMP_GEU(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_CMP_GEU(),
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

- CMP.GEU - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- cmp.geu SrcL, SrcR<{.sw, .uw}>, ->{t, u, Rd}
