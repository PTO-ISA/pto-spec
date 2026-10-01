<!-- GENERATED FROM: asl/scalar/alu/CLZ.asl -->
# CLZ

**Normative ASL source:** `asl/scalar/alu/CLZ.asl`

CLZ counts leading zero bits in an independently selected wrapping scalar field and publishes the XLEN count.

## Normative identity {#PTO-INST-SCALAR-CLZ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-clz-purpose role=purpose -->
## CLZ 的作用

`CLZ` 统计一个 Reg5 源中某个所选字段内、第一个 1 位之前的高端零位个数，并把该计数作为 XLEN 值发布。

设计要点：被统计的范围由两个互相独立的编码字段选定，而不是整个寄存器。`imms` 给出字段的起始位，`imml` 给出其宽度，因此一条指令可以统计一个字节、一个字或全部六十四位。

<!-- PTO-READER-BLOCK: scalar-clz-mechanism role=mechanism -->
## 结果形成方式

字段通过把源右移起始位并取低 `N` 位得到，因此字段位零就是源位 `M`，字段也可以越过位 `63` 并从位 `0` 继续。计数随后从字段自身最高位向下走，遇到第一个 1 位即停止。全零字段返回 `N`。

设计要点：`imml` 存放的是 `N` 减一，因此编码零选择一位字段，而不是零宽字段。于是每个六位取值都对应一个可用的计数范围，从 `1` 到 `64`，最宽字段的编码值是 `63`。

设计要点：发布的计数在选择宽度处饱和，而不是在 `PTO_XLEN` 处饱和。统计全零的八位字段发布 `8`，因此答案总是用调用者所选字段的坐标系表达的。

<!-- PTO-READER-BLOCK: scalar-clz-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，读取时不消费队列项。
- `imms` 是起始位 `M`，直接编码 `0` 至 `63`。
- `imml` 是宽度 `N` 减一，编码 `0` 至 `63`，对应 `N` 从 `1` 到 `64`。
- `RegDst` 通过公共目标映射发布：编码 `0` 和 `24..29` 丢弃，`1..23` 写 GPR，`30` 压入 `U`，`31` 压入 `T`。

设计要点：四个字段的编码零都有已定义含义，因此 `clz zero, 0, 1, ->zero` 是一条完整指令：它统计架构零 GPR 的单个零位并丢弃结果。

<!-- PTO-READER-BLOCK: scalar-clz-effects role=effects -->
## 效果与顺序

`SrcL` 在任何目标效果之前快照，因此与源同名的 GPR 目标，或压入同一队列的目标，观察到的都是指令执行前的源值。计数随后作为一个 XLEN 值发布。

发布之后，`TPC` 前进 `4` 字节。内存、保留状态、描述符、数值状态、指令束、特权、分支目标和其他控制状态都不改变；相对源不被消费，只有 `T` 或 `U` 目标压入才会改变临时队列。

<!-- PTO-READER-BLOCK: scalar-clz-constraints role=constraints -->
## 合法性与故障边界

每个 `imml` 和 `imms` 取值都已分配，因此 `1` 至 `64` 的所有宽度和 `0` 至 `63` 的所有起始位都合法，没有保留的字段取值。固定编码位必须匹配规范形式。

所选 `T` 或 `U` 源不可用会在目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`。对任何操作数，`CLZ` 都不会引发算术、内存、对齐、权限或控制流异常。

设计要点：丢弃目标合法，且不会跳过源检查。源可用的丢弃形式仍会读取并预检 `SrcL`，随后除 `TPC` 外不改变任何架构状态，这正是它可以作为已定义占位使用的原因。

<!-- PTO-READER-BLOCK: scalar-clz-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 保存 `256` 时，`clz a0, 0, 64, ->a1` 统计整个寄存器并压入 `55`，因为位 `8` 是最高置位位。当 `T#1` 保存 `2^63` 时，`clz t#1, 62, 4, ->a0` 选择位 `62`、`63`、`0`、`1` 这四位，并按 `1`、`0`、`63`、`62` 的顺序扫描，因此计入位 `1` 和位 `0` 的两个零并压入 `2`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
clz SrcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| clz_32_f890415c15b6 | L32 | 32 | 0x00005067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| clz_32_f890415c15b6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| clz_32_f890415c15b6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| clz_32_f890415c15b6 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| clz_32_f890415c15b6 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| clz_32_f890415c15b6 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| clz_32_f890415c15b6 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| clz_32_f890415c15b6 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| clz_32_f890415c15b6 | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/CLZ.asl -->
```asl
readonly func InstructionContractOperation_CLZ()
    => ScalarOperation
begin
    return ScalarOperation_CLZ;
end;

pure func InstructionContractWidth_CLZ(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_CLZ(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/CLZ.asl -->
```asl
readonly func InstructionContractHandler_CLZ()
    => ScalarSemanticHandler
begin
    return ScalarHandler_CountBitfield;
end;

pure func InstructionContractResult_CLZ(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return CountBitfield(
        value,
        width,
        offset,
        TRUE,
        FALSE);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, imml, imms, and RegDst are required encoded fields; no field can be omitted.
- imml encodes N minus one, so raw values 0 through 63 select widths 1 through 64; encoded zero selects N=1.
- imms directly encodes M from 0 through 63; encoded zero selects source bit zero.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every imml and imms value is assigned. The selected N-bit field begins at bit M and wraps through bit 63 to bit 0.

## State effects

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0, then count zero bits from the selected field most-significant end until the first one. An all-zero selected field returns N.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before any destination effect so a GPR alias or a T/U destination push observes the pre-instruction source value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.
- CLZ raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- clz a0, 0, 64, ->a1
- clz t#1, 60, 8, ->u
- clz zero, 0, 1, ->zero
