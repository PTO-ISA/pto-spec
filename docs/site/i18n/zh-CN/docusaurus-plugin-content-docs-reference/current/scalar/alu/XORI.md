<!-- GENERATED FROM: asl/scalar/alu/XORI.asl -->
# XORI

**Normative ASL source:** `asl/scalar/alu/XORI.asl`

XORI performs XLEN exclusive-or with a sign-extended signed 12-bit immediate.

## Normative identity {#PTO-INST-SCALAR-XORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-xori-purpose role=purpose -->
## XORI 计算什么

`XORI` 是标量异或的立即数形式。它把 12 位立即数 `simm12` 符号扩展到完整的 `PTO_XLEN` 宽度，把该值与左源 `SrcL` 做异或，并通过 `RegDst` 发布完整的 64 位结果。

`XORI` 是 32 位形式，成功执行后 `TPC` 前进 `4` 字节。它没有内存效果，也不产生算术异常。

设计要点：立即数形式没有 `SrcR` 字段、没有 `SrcRType` 选择器和 `shamt` 移位，因此在运算之前没有任何需要变换或移位的东西。全部 4096 种立即数编码都是可用取值，该助记符也不可能被赋予它并不具备的右源修饰。

<!-- PTO-READER-BLOCK: scalar-xori-mechanism role=mechanism -->
## 先扩展立即数，再做异或

`simm12` 字段是带符号的。它的取值范围是 `-2048` 到 `2047`，执行时会把这 12 位符号扩展到 64 位，因此负立即数会在第 10 位以上的每一位都贡献 1。

运算本身是 `SrcL` 与扩展后立即数的全宽度异或，结果截断到 64 位。

设计要点：由于立即数经过符号扩展，`-1` 为全部 64 位提供全 1 操作数，因此 `xori a0, -1, ->a0` 对 `a0` 取反。最大的正立即数 `2047` 只触及第 10 位，因此永远无法改变源的 63 到 11 位。

<!-- PTO-READER-BLOCK: scalar-xori-inputs role=inputs-outputs -->
## 编码操作数

- `RegDst` 是位于指令位 `7..11` 的 5 位字段：编码 `1..23` 写对应的绝对 GPR，编码 `0` 和编码 `24..29` 丢弃结果，编码 `30` 压入 U 队列，编码 `31` 压入 T 队列。
- `SrcL` 是位于位 `15..19` 的 5 位字段：编码 `0..23` 读取绝对 GPR，编码 `24..27` 读取 `T#1..T#4`，编码 `28..31` 读取 `U#1..U#4`。
- `simm12` 是位于位 `20..31` 的带符号 12 位字段。

源编码 `0` 读取架构零寄存器，T/U 源按不消费队列项的方式读取。编码为零的立即数提供数值零，因此 `xori a0, 0, ->a1` 复制 `a0`。

<!-- PTO-READER-BLOCK: scalar-xori-effects role=effects -->
## 目的位置与顺序

`SrcL` 在目的位置被写入之前读取，发布的值由该指令执行前的值算出。

设计要点：因此 `xori a0, 255, ->a0` 发布的是旧 `a0` 与 `255` 的异或，而不是新写入的值与 `255` 的异或。源和目的可以指向同一个寄存器，结果不受影响。

成功执行后 `TPC` 前进 `4` 字节。内存位置、保留状态、描述符、数值标志、陷阱、指令束、特权以及控制流状态都不改变。

<!-- PTO-READER-BLOCK: scalar-xori-constraints role=constraints -->
## 合法性与故障边界

`SrcL` 和 `RegDst` 的每一种编码都已分配，`-2048` 到 `2047` 之间的每个带符号 12 位立即数也都合法，因此 `XORI` 没有保留字段值。按位异或对任何源和立即数位型都有定义，因此不会产生算术异常。

在任何效果之前，先译码该形式并检查其编码字段，随后被选中的 T/U 源必须指向有效的队列项。不属于任何形式的编码，或者不可用的 `T#1..T#4` 或 `U#1..U#4` 队列项，会在写目的位置之前、`TPC` 前进之前产生 `Fault_IllegalInstruction`。

设计要点：`XORI` 没有内存操作数，因此被拒绝的 `XORI` 不会改动寄存器堆，也不会改动 `TPC`：操作数可用性检查在写目的位置之前执行。

<!-- PTO-READER-BLOCK: scalar-xori-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=0x0000000000000000`、`simm=-1` 时，扩展后的立即数是 `0xffffffffffffffff`，因此发布值为 `0xffffffffffffffff`。

当 `SrcL=0x00000000000000ff`、`simm=240` 时，扩展后的立即数是 `0x00000000000000f0`，发布值为 `0x000000000000000f`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
xori SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xori_32_5cf7e5be17e7 | L32 | 32 | 0x00004015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xori_32_5cf7e5be17e7 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| xori_32_5cf7e5be17e7 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| xori_32_5cf7e5be17e7 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| xori_32_5cf7e5be17e7 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| xori_32_5cf7e5be17e7 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads the architectural zero GPR. |
| xori_32_5cf7e5be17e7 | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XORI.asl -->
```asl
readonly func InstructionContractOperation_XORI()
    => ScalarOperation
begin
    return ScalarOperation_XORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XORI.asl -->
```asl
readonly func InstructionContractHandler_XORI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_XORI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_XORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_XORI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm12, and RegDst are required encoded fields; no field can be omitted.
- simm12 is a signed 12-bit immediate from -2048 through 2047. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every signed 12-bit immediate from -2048 through 2047 is legal and is sign-extended to PTO_XLEN before the exclusive-or.

## State effects

- Sign-extend simm12 to PTO_XLEN, compute the bitwise exclusive-or with the snapshotted SrcL value, and publish the complete XLEN result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the result and then advances TPC by four bytes.

## Exceptions

- XORI raises no arithmetic exception; bitwise exclusive-or is defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- xori a0, -1, ->a0
- xori t#1, 2047, ->u
- xori zero, -2048, ->zero
