<!-- GENERATED FROM: asl/scalar/alu/XORIW.asl -->
# XORIW

**Normative ASL source:** `asl/scalar/alu/XORIW.asl`

XORIW performs word exclusive-or with a signed 12-bit immediate and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-XORIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-xoriw-purpose role=purpose -->
## XORIW 计算什么

`XORIW` 是立即数异或的字形式。它只把 `SrcL` 的低 32 位与符号扩展后立即数的低 32 位做异或，再把该 32 位结果符号扩展到 `PTO_XLEN`，并通过 `RegDst` 发布。

字规则正是 `XORIW` 与 `XORI` 的区别：运算是 32 位宽，结果的第 31 位决定发布值的全部 32 个高位。`XORIW` 是 32 位形式，`TPC` 前进 `4` 字节，不读取内存，也不产生算术异常。

设计要点：由于结果做符号扩展而不是零扩展，`XORIW` 可以由两个小的正操作数发布出负的 XLEN 值。当 `SrcL=0x0000000000000000`、`simm=-1` 时，它发布 `0xffffffffffffffff`，绝不会是 `0x00000000ffffffff`。

<!-- PTO-READER-BLOCK: scalar-xoriw-mechanism role=mechanism -->
## 窗口宽度为 32 位

执行时先把带符号的 `simm12` 字段从 `-2048` 到 `2047` 符号扩展到 64 位，取该值的低 32 位与 `SrcL` 的低 32 位做异或，再把 32 位结果符号扩展到 64 位。

设计要点：只有 `SrcL` 的第 `31..0` 位参与运算。当 `SrcL=0xffffffff00000000`、`simm=0` 时发布值是 `0x0`，而 64 位形式 `XORI` 在相同操作数下发布 `0xffffffff00000000`。因此当源的高半部分有意义时，这两条助记符不能互换。

设计要点：立即数在收窄之前先做符号扩展，因此进入运算的是它的低 32 位。`-1` 在该窗口内成为 `0xffffffff` 并对源的低字取反，而它的高位全 1 是被丢弃，而不是折进结果。

<!-- PTO-READER-BLOCK: scalar-xoriw-inputs role=inputs-outputs -->
## 编码操作数

- `RegDst` 是位于指令位 `7..11` 的 5 位字段：编码 `1..23` 写对应的绝对 GPR，编码 `0` 和编码 `24..29` 丢弃结果，编码 `30` 压入 U 队列，编码 `31` 压入 T 队列。
- `SrcL` 是位于位 `15..19` 的 5 位字段，但只有它的低 32 位进入运算：编码 `0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。
- `simm12` 是位于位 `20..31` 的带符号 12 位字段。

源编码 `0` 读出零，T/U 源按不消费队列项的方式读取。该编码没有 `SrcRType`，也没有 `shamt`，因此右操作数始终是立即数，而且永远不做移位。

<!-- PTO-READER-BLOCK: scalar-xoriw-effects role=effects -->
## 目的位置与顺序

`SrcL` 在目的位置被写入之前读取，发布的值由该指令执行前的值算出。

设计要点：`SrcL` 先于目的位置写入被读取，因此 `xoriw a0, -1, ->a0` 对旧 `a0` 的低字取反并符号扩展；刚写入的值绝不会回喂给本次运算。

成功执行后 `XORIW` 让 `TPC` 前进 `4` 字节。内存位置、保留状态、描述符、数值标志、陷阱、指令束、特权以及控制流状态都不改变。

<!-- PTO-READER-BLOCK: scalar-xoriw-constraints role=constraints -->
## 合法性与故障边界

`SrcL` 和 `RegDst` 的每一种编码以及每个带符号 12 位立即数都已分配，因此 `XORIW` 没有保留字段值。字异或以及最后的符号扩展对任何源和立即数位型都有定义，因此不会产生算术异常。

在任何效果之前，先译码该形式并检查其编码字段，随后被选中的 T/U 源必须指向有效的队列项。不属于任何形式的编码，或者不可用的 `T#1..T#4` 或 `U#1..U#4` 队列项，会在写目的位置之前、`TPC` 前进之前产生 `Fault_IllegalInstruction`。

设计要点：32 位宽度是运算本身的属性，因此超出 32 位的操作数或结果会被截断，而不是被拒绝。这里没有溢出故障，也没有任何检查源取值的合法性规则。

<!-- PTO-READER-BLOCK: scalar-xoriw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=0x0000000012345678`、`simm=-1` 时，窗口内的两个 32 位值是 `0x12345678` 和 `0xffffffff`。它们的异或是 `0xedcba987`，发布值为符号扩展后的 `0xffffffffedcba987`。

第二个例子展示这个窄窗口：`SrcL=0xffffffff00000000` 与 `simm=0` 发布 `0x0`，因为源的高 32 位不参与运算。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
xoriw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xoriw_32_1f8c6f43e2bd | L32 | 32 | 0x00004035 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xoriw_32_1f8c6f43e2bd | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| xoriw_32_1f8c6f43e2bd | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| xoriw_32_1f8c6f43e2bd | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| xoriw_32_1f8c6f43e2bd | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| xoriw_32_1f8c6f43e2bd | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads the architectural zero GPR. |
| xoriw_32_1f8c6f43e2bd | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XORIW.asl -->
```asl
readonly func InstructionContractOperation_XORIW()
    => ScalarOperation
begin
    return ScalarOperation_XORIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XORIW.asl -->
```asl
readonly func InstructionContractHandler_XORIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_XORIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_XORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_XORIW()
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

- Sign-extend simm12, XOR its low 32 bits with the low 32 bits of SrcL, then produce a 32-bit result sign-extended to XLEN and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the sign-extended word result and then advances TPC by four bytes.

## Exceptions

- XORIW raises no arithmetic exception; word exclusive-or and final sign extension are defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- xoriw a0, -1, ->a0
- xoriw u#1, 2047, ->t
- xoriw zero, -2048, ->zero
