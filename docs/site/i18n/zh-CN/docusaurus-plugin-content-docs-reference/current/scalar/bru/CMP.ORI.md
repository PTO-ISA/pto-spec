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

`CMP.ORI` 用按位或组合两个操作数的值，并在组合结果非零时写入规范 XLEN 布尔值 `1`，为零时写入 `0`。

它只在结果形状上算比较。写入的值并不报告两个操作数之间的关系；它报告的是二者的或是否全为零。

<!-- PTO-READER-BLOCK: scalar-cmp-ori-mechanism role=mechanism -->
## 机制

契约返回 `ScalarHandler_ExecuteCompareLogical`，其操作为 OR。模型把 `12` 位 `simm12` 字段符号扩展到 XLEN，并把它用作右值。

随后处理程序取左源和准备好的右值，计算 `left OR right`，并在逻辑结果非零时写入 `Zeros{PTO_XLEN} + 1`、为零时写入 `Zeros{PTO_XLEN}`。不读取也不写入任何其他状态。

设计要点：先组合两个操作数，再测试组合结果，因此该指令无法单独泄露任何一个操作数的信息。这正是"这个值是否含有这些位中的任意一位"这类掩码测试只需一条指令，而不必用一次比较加一次分支处理两个结果的原因。

<!-- PTO-READER-BLOCK: scalar-cmp-ori-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 是 Reg5 源：编码 `0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。
- `simm12` 提供 `12` 位有符号立即数。

`RegDst` 命名目的：编码 `1..23` 写入所指的绝对 GPR，编码 `0` 与编码 `24..29` 丢弃结果，编码 `30` 把它压入 `U` 队列，编码 `31` 把它压入 `T` 队列。

源编码为 `0` 时读取架构零 GPR。队列源只被读取，不会被消费。

<!-- PTO-READER-BLOCK: scalar-cmp-ori-effects role=effects -->
## 效果与排序

成功时该指令恰好写入一个目的值，并让 `TPC` 前进 `4` 字节，即 `32` 位形式的编码长度。

它没有内存效果、没有保留效果、没有描述符效果，也没有数值状态标志。它保持提交参数、块参数和块条件标记不变，因为它不是条件设置指令。

设计要点：`CMP.ORI` 不是 `ORI` 的别名。`ORI` 写入组合后的 XLEN 值，而 `CMP.ORI` 写入的是报告该值是否非零的规范布尔值，因此当之后需要组合后的位本身时，这两种形式不可互换。

<!-- PTO-READER-BLOCK: scalar-cmp-ori-constraints role=constraints -->
## 合法性与故障顺序

先执行解码，固定位不匹配会在指令地址处抛出 `Fault_IllegalInstruction`，且在任何效果之前。

`SrcL` 与 `RegDst` 的全部 `32` 个编码都已分配，`simm12` 的全部 `4096` 个模式也都已分配，因此没有保留的操作数编码。

被选中但不可用的 `T` 或 `U` 源会在操作数合法性阶段被拒绝，且早于目的写入。被拒绝的指令既不改变目的也不改变 `TPC`，陷入入口保存原始 `TPC`，因此它可以重新执行。

<!-- PTO-READER-BLOCK: scalar-cmp-ori-example role=example -->
## 非规范示例

把 GPR1 设为 `5`。

`cmp.ori 1, 9, ->0` 计算 `5 OR 9`，结果为 `13`，因此把 `1` 写入目的。若把 GPR1 设为 `0` 且把 `simm12` 设为 `0`，同一形式写入 `0`。
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
