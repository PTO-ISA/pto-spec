<!-- GENERATED FROM: asl/scalar/alu/ANDIW.asl -->
# ANDIW

**Normative ASL source:** `asl/scalar/alu/ANDIW.asl`

ANDIW performs word conjunction with a signed 12-bit immediate and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-ANDIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-andiw-purpose role=purpose -->
## ANDIW 的作用

`ANDIW` 计算 Reg5 源低 `32` 位与符号扩展后立即数低 `32` 位的逐位合取，并把 32 位结果符号扩展到 `PTO_XLEN` 后发布。

设计要点：`ANDIW` 是 `ANDI` 的字形式，唯一区别是取合取和发布的位宽。源的高位不是被屏蔽后保留，而是完全不参与运算。

<!-- PTO-READER-BLOCK: scalar-andiw-mechanism role=mechanism -->
## 结果形成方式

`simm12` 被符号扩展到 `PTO_XLEN`，其低 `32` 位与 `SrcL[31:0]` 做按位与，随后结果位 `31` 被复制到 `63..32` 位。

设计要点：无论源原来的高位是什么，发布值的 `63..32` 位总是等于位 `31`。因此 `andiw a0, -1, ->a0` 把 `a0` 规范化为合法的 32 位值，与 `addiw a0, 0, ->a0` 完全一样。

设计要点：只使用符号扩展后立即数的低字。对 `simm12=-1` 而言该字全为 1，因此合取原样返回 `SrcL[31:0]`，与源不同的只有扩展部分。

<!-- PTO-READER-BLOCK: scalar-andiw-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，且不会消费队列项。只有 `SrcL[31:0]` 参与运算。
- `simm12` 携带 `-2048` 至 `2047` 的有符号立即数。
- `RegDst` 发布符号扩展后的字结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`simm12` 的编码零是数值零，因此对任何源合取结果都是零。`SrcL` 的编码零读取架构零 GPR，`RegDst` 的编码零表示丢弃，而不是写入它。

<!-- PTO-READER-BLOCK: scalar-andiw-effects role=effects -->
## 效果与顺序

`SrcL` 在写入目标之前读取，因此源和目标可以命名同一个寄存器而不改变结果。

字结果发布或丢弃之后，`TPC` 前进 `4` 字节。`ANDIW` 不访问内存；除该前进之外，它不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词或控制流状态。

<!-- PTO-READER-BLOCK: scalar-andiw-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码，以及 `-2048` 至 `2047` 的全部 `4096` 个立即数取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；固定编码位不匹配或所选 T/U 源不可用会引发 `Fault_IllegalInstruction`。这些都先于目标效果和 `TPC` 前进。

设计要点：丢弃源的高字不是故障条件，也不会被报告。`ANDIW` 与陷阱机制之间没有依赖取值的交互。

<!-- PTO-READER-BLOCK: scalar-andiw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=4294967295`、`simm12=2047` 时，`ANDIW` 发布 `2047`。当 `SrcL=4294967295`、`simm12=-1` 时，立即数的低字全为 1，合取结果全为 1，发布值为 `18446744073709551615`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
andiw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| andiw_32_9ec1f7343dbd | L32 | 32 | 0x00002035 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| andiw_32_9ec1f7343dbd | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| andiw_32_9ec1f7343dbd | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| andiw_32_9ec1f7343dbd | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| andiw_32_9ec1f7343dbd | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| andiw_32_9ec1f7343dbd | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads the architectural zero GPR. |
| andiw_32_9ec1f7343dbd | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ANDIW.asl -->
```asl
readonly func InstructionContractOperation_ANDIW()
    => ScalarOperation
begin
    return ScalarOperation_ANDIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ANDIW.asl -->
```asl
readonly func InstructionContractHandler_ANDIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_ANDIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_ANDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ANDIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm12, and RegDst are required encoded fields; no field can be omitted.
- simm12 is a signed 12-bit immediate from -2048 through 2047. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every signed 12-bit immediate from -2048 through 2047 is legal. Only the low 32 bits of SrcL and the sign-extended immediate participate.

## State effects

- Sign-extend simm12, AND its low 32 bits with the low 32 bits of SrcL, then produce a 32-bit result sign-extended to XLEN and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the sign-extended word result and then advances TPC by four bytes.

## Exceptions

- ANDIW raises no arithmetic exception; word conjunction and final sign extension are defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- andiw a0, -1, ->a0
- andiw u#1, 2047, ->t
- andiw zero, -2048, ->zero
