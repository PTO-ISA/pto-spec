<!-- GENERATED FROM: asl/scalar/alu/DIVU.asl -->
# DIVU

**Normative ASL source:** `asl/scalar/alu/DIVU.asl`

DIVU computes the unsigned XLEN quotient using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-DIVU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-divu-purpose role=purpose -->
## DIVU 的作用

`DIVU` 是 `DIV` 的无符号对应形式：一种 32 位 L32 形式，读取两个 Reg5 操作数并通过 `RegDst` 发布一个商。两个完整的 `PTO_XLEN` 字都按从 `0` 到 `2^64 - 1` 的无符号整数读取，因此截断后的商同时也是精确比值的向下取整。

设计要点：这里源的最高位是数据而不是符号。当 `a0` 的 `64` 位全为 1、`a1` 为 `2` 时，`divu a0, a1, ->a2` 发布 `9223372036854775807`；而对同样的两个寄存器值，`DIV` 会把它们读成 `-1` 和 `2`，并发布 `0`。

<!-- PTO-READER-BLOCK: scalar-divu-mechanism role=mechanism -->
## 商的形成方式

执行时读取 `SrcL` 与 `SrcR`，然后调用无符号除法器。

- 除数为零时立即返回 `0`，不会运行任何除法循环。
- 否则恢复余数法循环从位 `63` 走到位 `0`：把部分余数左移，移入一个被除数位，并在部分余数达到除数时减去除数。

商按原样发布。这里没有扩展步骤，因为两个 `PTO_XLEN` 操作数的无符号商本身就是一个完整的 `PTO_XLEN` 值。

设计要点：只有商离开除法器。循环中建立的部分余数是一个局部值，从不会被写入，因此 `DIVU` 无法报告被除数剩余多少；成对形式 `HL.DIVU` 才是同时返回两半的拼写。

<!-- PTO-READER-BLOCK: scalar-divu-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是被除数，`SrcR` 是除数，两者都按 Reg5 源映射读取：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。
- `RegDst` 发布商：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃它。

设计要点：读取源不会消费队列项，而丢弃型目标仍然让指令正常退休。因此只要 `t#1` 与 `t#2` 都可用，`divu t#1, t#2, ->u` 就保持这两个槽位不变，并追加一个新的 `U` 项。

<!-- PTO-READER-BLOCK: scalar-divu-effects role=effects -->
## 效果与顺序

两次读取都发生在写入 `RegDst` 之前，因此 `divu a0, a1, ->a1` 用除数的指令执行前取值把商写入原来存放除数的位置。

商被发布或丢弃之后，`TPC` 前进 `4` 字节。内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变。

设计要点：只有目标压入会触碰临时队列，因此把无符号除法的目标设为 GPR 或丢弃编码时，两个队列与执行前完全一致；之后再读取 `T#1` 得到的仍是执行该指令之前会看到的同一个字。

<!-- PTO-READER-BLOCK: scalar-divu-constraints role=constraints -->
## 合法性与故障边界

`SrcL`、`SrcR` 和 `RegDst` 的全部 `32` 个编码都已分配，唯一的固定要求是 32 位字与 `DIVU` 的掩码和匹配相符，因此这个无符号助记符没有自己的保留操作数取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`。不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。所选 `T` 或 `U` 源不可用在目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`，位置在 `PC`。

设计要点：模型绝不会从除数推导出算术故障。除数为零在无符号除法器内部以 `0` 作答，因此 `DIVU` 没有任何会导致陷阱、或让结果不被写入的除数取值。

<!-- PTO-READER-BLOCK: scalar-divu-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0=13`、`a1=5` 时，`divu a0, a1, ->a2` 把 `2` 写入 `a2`。当 `a0` 的 `64` 位全为 1、`a1=2` 时，同一条指令写入 `9223372036854775807`，因为被除数被读成 `18446744073709551615`；对同样的两个寄存器值，`DIV` 会返回 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
divu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| divu_32_cfbc0d1760e4 | L32 | 32 | 0x00001057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| divu_32_cfbc0d1760e4 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| divu_32_cfbc0d1760e4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| divu_32_cfbc0d1760e4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| divu_32_cfbc0d1760e4 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| divu_32_cfbc0d1760e4 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| divu_32_cfbc0d1760e4 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIVU.asl -->
```asl
readonly func InstructionContractOperation_DIVU() => ScalarOperation
begin
    return ScalarOperation_DIVU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIVU.asl -->
```asl
readonly func InstructionContractHandler_DIVU() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideUnsigned;
end;
pure func InstructionContractResult_DIVU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsigned(
        dividend,
        divisor);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness, operand width, and quotient-versus-remainder selection.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical form.

## State effects

- Interpret both complete XLEN sources as unsigned integers and return the unsigned quotient.
- A zero divisor returns zero.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- divu a0, a1, ->a2
- divu t#1, zero, ->u
