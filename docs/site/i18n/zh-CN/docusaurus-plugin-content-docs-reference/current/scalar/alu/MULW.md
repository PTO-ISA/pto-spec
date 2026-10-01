<!-- GENERATED FROM: asl/scalar/alu/MULW.asl -->
# MULW

**Normative ASL source:** `asl/scalar/alu/MULW.asl`

MULW multiplies the source low 32-bit values, retains the low 32 product bits, sign-extends them to XLEN, and publishes the result.

## Normative identity {#PTO-INST-SCALAR-MULW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-mulw-purpose role=purpose -->
## MULW 的作用

`MULW` 把两个 Reg5 源的低 `32` 位当作无符号位模式相乘，保留 `64` 位乘积的低 `32` 位，再把该字的第 `31` 位符号扩展到 `PTO_XLEN`，并发布一个字。

该指令有三个字段且没有立即数：`RegDst` 位于指令切片 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`。这个 `32` 位载体在掩码 `0xfe00707f` 下匹配 `0x00002047`。

同族助记符 `MULUW` 调用同一个辅助函数，因此对相同的源位，`MULW` 与 `MULUW` 发布的位完全相同。

<!-- PTO-READER-BLOCK: scalar-mulw-mechanism role=mechanism -->
## 乘积形成方式

所属 ASL 把该操作交给 `ScalarMultiplyW(left, right)`。该辅助函数把 `left[31:0]` 与 `right[31:0]` 零扩展到 `PTO_XLEN`，对两个扩展后的值调用 `MultiplyWord`，并返回 `SignExtend{PTO_XLEN}(product[31:0])`。分派路径在 `asl/scalar/model/dispatch/alu.asl:265-270` 处为 `ScalarOperation_MULW` 与 `ScalarOperation_MULUW` 调用它。

```asm
mulw SrcL, SrcR, ->{t, u, Rd}
```

设计要点：零扩展只是为乘法服务的载体：它把低字变成一个非负的 `64` 位值。读者真正看到的是最后的符号扩展，因此低字 `0x80000000` 发布为 `0xFFFFFFFF80000000`。

设计要点：由于乘积首先被截断到 `32` 位，该辅助函数不保留宽结果。无论操作数多大，`mulw` 都不可能发布超过乘积低字的内容。

源的有符号性对该辅助函数没有影响。只有 `left[31:0]` 与 `right[31:0]` 进入 `MultiplyWord`，因此低字相同的两个寄存器给出相同结果，与它们的高半部无关。

<!-- PTO-READER-BLOCK: scalar-mulw-inputs role=inputs-outputs -->
## 输入与目标

两个操作数都来自通用 Reg5 源映射，唯一的结论通过通用 Reg5 目标映射发布。

- `SrcL` 位于 `[15 +: 5]`，是左乘数：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，任何读取都不消耗队列条目。
- `SrcR` 位于 `[20 +: 5]`，是右乘数，使用同样的五位映射。
- `RegDst` 位于 `[7 +: 5]`，发布符号扩展后的字：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃结果。
- `SrcL` 或 `SrcR` 的编码零读取体系结构零 GPR，因此源为零的 `mulw` 无论目标是什么都发布 `0`。

设计要点：丢弃是一种编码选择，而不是缺失：`RegDst=0` 仍然执行乘法，也仍然推进 `TPC`。只想利用该指令故障行为的程序可以编码一个丢弃目标。

<!-- PTO-READER-BLOCK: scalar-mulw-effects role=effects -->
## 效果与顺序

两个源在写入 `RegDst` 之前被读取，因此与源同名的目标仍然对执行前的值做乘法。除 `RegDst` 为 `30` 或 `31` 时的一次队列压入外，发布的字是唯一的体系结构变化。

成功的 `MULW` 随后把 `TPC` 推进 `4` 字节，即 `32` 位载体的长度。`MULW` 不读内存，保留、描述符、数值标志、陷阱、指令束、特权、谓词与控制流状态都保持不变。

设计要点：`MULW` 不记录数值状态。被截断的乘积不会留下粘滞标志，因此后续指令无法观察到曾丢弃溢出。

<!-- PTO-READER-BLOCK: scalar-mulw-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个源编码与全部 `32` 个目标编码都有定义，该形式除固定编码位外没有约束条目。

不匹配的 `32` 位载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`；对 ALU 操作来说，这仅发生在系统块终止请求挂起期间。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`。

上述每一项检查都先于目标效果与 `TPC` 推进。

设计要点：算术本身是全定义的。乘法、截断与符号扩展都不会触发故障，因此 `MULW` 的整个故障边界就是编码有效性与源可用性；没有任何操作数取值会选择陷阱。

<!-- PTO-READER-BLOCK: scalar-mulw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `6`、`a1` 为 `7` 时，`mulw a0, a1, ->a2` 把 `42` 写入 `a2`：乘积的低字是 `42`，符号扩展不改变它。

当 `a0` 为 `0x80000000`、`a1` 为 `2` 时，乘积的第 `32` 位落在保留的 `32` 位之外，因此乘积的低字是 `0x00000000`，`a2` 收到 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
mulw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mulw_32_b90cb6a30a23 | L32 | 32 | 0x00002047 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mulw_32_b90cb6a30a23 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| mulw_32_b90cb6a30a23 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mulw_32_b90cb6a30a23 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| mulw_32_b90cb6a30a23 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| mulw_32_b90cb6a30a23 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| mulw_32_b90cb6a30a23 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MULW.asl -->
```asl
readonly func InstructionContractOperation_MULW() => ScalarOperation
begin
    return ScalarOperation_MULW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MULW.asl -->
```asl
readonly func InstructionContractHandler_MULW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyW;
end;
pure func InstructionContractResult_MULW(left: Word, right: Word) => Word
begin
    return ScalarMultiplyW(left, right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded operand and destination field is required; no field can be omitted.
- The mnemonic fixes signedness, effective operand width, single-versus-pair result shape, and add-versus-subtract behavior; there is no encoded arithmetic mode.

## Legality

- Every source Reg5 code is assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Fixed encoding bits must match the canonical form; every encoded source, destination, and immediate value otherwise has assigned behavior.

## State effects

- Multiply the source low 32-bit patterns modulo 2^32, then sign-extend result bit 31 through XLEN.
- Snapshot every source before the destination effect, publish the XLEN result through the common Reg5 destination map, and do not consume relative sources.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- mulw srcl, srcr, ->{t, u, rd}
