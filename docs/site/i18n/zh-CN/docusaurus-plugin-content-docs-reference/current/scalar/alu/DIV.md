<!-- GENERATED FROM: asl/scalar/alu/DIV.asl -->
# DIV

**Normative ASL source:** `asl/scalar/alu/DIV.asl`

DIV computes the signed XLEN quotient using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-DIV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-div-purpose role=purpose -->
## DIV 的作用

`DIV` 是一种 32 位 L32 标量 ALU 形式。它读取一个 Reg5 被除数和一个 Reg5 除数，把两个完整的 `PTO_XLEN` 字都解释为有符号二进制补码整数，并通过第三个 Reg5 字段发布向零截断的商。`DIV` 不产生余数。

设计要点：`DIV` 与 `DIVU` 共用同一套字段布局，只在助记符和 32 位编码的固定匹配位上不同。有符号性不是模式字段，因此没有任何操作数取值能把无符号除法变成有符号除法；只有被执行的指令字本身选择解释方式。

<!-- PTO-READER-BLOCK: scalar-div-mechanism role=mechanism -->
## 商的形成方式

执行时先解析三个选择符，读取 `SrcL` 与 `SrcR`，然后计算一个值。

- 除数为零时 `ScalarDivideSigned` 返回 `0`。
- 否则它先取每个操作数的绝对值，用恢复余数法对绝对值做除法，并在恰好一个操作数为负时用 `0` 减去该绝对值。

计算出的字只有在两次源读取都发生之后才到达 `RegDst`。

设计要点：符号在绝对值除法之后才施加，因此有符号最小值（只有最高位为 1 的那个字）除以 `-1` 得到同一个字。在 `PTO_XLEN` 二进制补码下计算 `0 - minimum` 返回 `minimum`，模型中也没有更宽的中间值可以保存数学上为正的那个结果。

<!-- PTO-READER-BLOCK: scalar-div-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是被除数，`SrcR` 是除数。两者都使用 Reg5 源映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。
- `RegDst` 发布这一个结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：读取源不会移除队列项，因此保存在 `T#1` 中的除数在该指令之后依然存在。只有 `30` 或 `31` 作为目标才会移动队列，而这次移动正是让被压入的字成为该队列最新项的原因。

<!-- PTO-READER-BLOCK: scalar-div-effects role=effects -->
## 效果与顺序

两次源读取都发生在写入 `RegDst` 之前，因此 `div a0, a0, ->a0` 用指令执行前的 `a0` 除以它自身，与源重名的目标也仍然使用快照值。

结果被发布或丢弃之后，`TPC` 前进 `4` 字节，即该 32 位形式的长度。内存、保留状态、描述符、数值状态、指令束、特权、谓词和控制流状态都不改变。

设计要点：除数这个字决定整个结果，而 `T` 或 `U` 除数被读取后不会被消费。因此只要 `SrcR` 仍指向 `T#1`，重复执行同一条除法每次都会除以同一个 `T#1` 字，直到别的指令压入新值。

<!-- PTO-READER-BLOCK: scalar-div-constraints role=constraints -->
## 合法性与故障边界

`SrcL`、`SrcR` 和 `RegDst` 的每个编码都已分配，且该形式除 32 位编码的匹配与掩码之外没有额外的固定位约束，因此 `DIV` 没有保留的选择符取值。

所选 `T` 或 `U` 源不可用会在目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`，位置在 `PC`。无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`，而不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。

设计要点：没有任何除数取值会引发故障。`ScalarDivideSigned` 在调用恢复余数法辅助函数之前先检测除数为零，而该辅助函数断言除数非零，因此没有任何 `SrcR` 编码能到达那条断言。

<!-- PTO-READER-BLOCK: scalar-div-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0=-13`、`a1=5` 时，`div a0, a1, ->a2` 把 `-2` 写入 `a2`：绝对值相除得到 `13 / 5 = 2`，且恰好一个操作数为负。当 `SrcR` 编码为零时，除数是架构零 GPR，因此在 `T#1` 可用时，`div t#1, zero, ->u` 压入 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
div SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| div_32_a6efe85f8662 | L32 | 32 | 0x00000057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| div_32_a6efe85f8662 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| div_32_a6efe85f8662 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| div_32_a6efe85f8662 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| div_32_a6efe85f8662 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| div_32_a6efe85f8662 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| div_32_a6efe85f8662 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/DIV.asl -->
```asl
readonly func InstructionContractOperation_DIV() => ScalarOperation
begin
    return ScalarOperation_DIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/DIV.asl -->
```asl
readonly func InstructionContractHandler_DIV() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarDivideSigned;
end;
pure func InstructionContractResult_DIV(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideSigned(
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

- Interpret both complete XLEN sources as signed two-complement integers and return the quotient truncated toward zero.
- A zero divisor returns zero. Signed minimum divided by negative one returns signed minimum.
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

- div a0, a1, ->a2
- div t#1, zero, ->u
