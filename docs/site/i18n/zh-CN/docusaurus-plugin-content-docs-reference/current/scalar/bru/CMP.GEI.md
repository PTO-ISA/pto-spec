<!-- GENERATED FROM: asl/scalar/bru/CMP.GEI.asl -->
# CMP.GEI

**Normative ASL source:** `asl/scalar/bru/CMP.GEI.asl`

CMP.GEI - Compare scalar operands and write the encoded boolean result.

## Normative identity {#PTO-INST-SCALAR-CMP-GEI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-cmp-gei-purpose role=purpose -->
## CMP.GEI 的作用

`CMP.GEI` 求值有符号的大于等于关系，并把规范 XLEN 布尔值写入目的：条件成立时为 `1`，不成立时为 `0`。

结果是普通数据。`CMP.GEI` 不设置所在块的提交条件，也不触碰任何谓词寄存器。

<!-- PTO-READER-BLOCK: scalar-cmp-gei-mechanism role=mechanism -->
## 机制

契约返回 `ScalarHandler_ExecuteCompare`。模型读取左源、准备右操作数、测试条件 `ScalarCondition_GE`，并通过目的选择子写入 `Zeros{PTO_XLEN} + 1` 或 `Zeros{PTO_XLEN}`。

右操作数是 `simm12`，一个 `12` 位有符号立即数，解码器把它符号扩展到 XLEN。关系本身是有符号的，因此两侧都按有符号整数读取，立即数的符号扩展与该比较所使用的读数一致。

设计要点：这里并不存在"扩展立即数还是扩展关系"的独立选择。由于两侧都按有符号 XLEN 值读取，负立即数是用一条指令表达零以下有符号边界的唯一方式。

设计要点：规范化为恰好 `1` 或 `0`（而不是任意非零值），使两次比较可以做算术组合，并且对目的做一次测试就足以恢复该关系。

<!-- PTO-READER-BLOCK: scalar-cmp-gei-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供左侧绝对 GPR 源。
- `simm12` 提供 `12` 位有符号立即数。

`RegDst` 命名目的：编码 `1..23` 写入所指的绝对 GPR，编码 `0` 与编码 `24..29` 丢弃结果，编码 `30` 把它压入 `U` 队列，编码 `31` 把它压入 `T` 队列。

`SrcL` 编码为零时指向架构零 GPR。源按值读取，不会被消耗。

<!-- PTO-READER-BLOCK: scalar-cmp-gei-effects role=effects -->
## 效果与排序

成功时该指令恰好写入一个目的值，并让 `TPC` 前进 `4` 字节，即 `32` 位形式的编码长度。

它没有内存效果、没有保留效果、没有描述符效果，也没有数值状态标志。它保持提交参数、块参数和块条件标记不变，因为它不是条件设置指令。

设计要点：由于该比较既不能观察提交条件，也不能安装控制流目标，编译器可以在其目的被读取之前，把它与其他纯标量操作自由重排。

<!-- PTO-READER-BLOCK: scalar-cmp-gei-constraints role=constraints -->
## 合法性与故障顺序

先执行解码，固定位不匹配会在指令地址处抛出 `Fault_IllegalInstruction`，且在任何效果之前。

`simm12` 的全部 `4096` 个模式都已分配；没有保留立即数。

被选中但不可用的 `T` 或 `U` 源会在操作数合法性阶段被拒绝，且早于目的写入。被拒绝的指令既不改变目的也不改变 `TPC`，陷入入口保存原始 `TPC`，因此它可以重新执行。

<!-- PTO-READER-BLOCK: scalar-cmp-gei-example role=example -->
## 非规范示例

把 GPR1 设为 `5`。

`cmp.gei 1, 5, ->0` 把 `1` 写入目的。若把 `simm12` 设为 `6`，同一形式写入 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
cmp.gei SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| cmp_gei_32_48bf7ea50737 | L32 | 32 | 0x00005055 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| cmp_gei_32_48bf7ea50737 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| cmp_gei_32_48bf7ea50737 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| cmp_gei_32_48bf7ea50737 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| cmp_gei_32_48bf7ea50737 | RegDst | 5 | 0–31 | none | none | absolute GPR destination | Encoded zero names the architectural zero GPR. |
| cmp_gei_32_48bf7ea50737 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| cmp_gei_32_48bf7ea50737 | simm12 | 12 | 0–4095 | none | none | 12-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | absolute GPR destination |
| SrcL | left absolute GPR source |
| simm12 | 12-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/CMP.GEI.asl -->
```asl
readonly func InstructionContractOperation_CMP_GEI() => ScalarOperation
begin
    return ScalarOperation_CMP_GEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/CMP.GEI.asl -->
```asl
readonly func InstructionContractHandler_CMP_GEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;

pure func InstructionContractCondition_CMP_GEI()
    => ScalarCondition
begin
    return ScalarCondition_GE;
end;

pure func InstructionContractCompareResult_CMP_GEI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_CMP_GEI(),
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

- CMP.GEI - Compare scalar operands and write the encoded boolean result.
- After decode and legality checks, execute the normative ExecuteCompare ASL handler; no other architectural state is modified.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- none

## Exceptions

- Reserved field encodings raise Fault_IllegalInstruction before effects; handler-specific arithmetic, memory, control-flow, system-register, and privilege faults follow the embedded normative ASL operation.

## Examples

- cmp.gei SrcL, simm, ->{t, u, Rd}
