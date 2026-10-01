<!-- GENERATED FROM: asl/scalar/alu/XORW.asl -->
# XORW

**Normative ASL source:** `asl/scalar/alu/XORW.asl`

XORW applies the selected right-source transformation before its encoded logical left shift, performs word bitwise exclusive OR, and publishes the low 32-bit result sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-XORW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-xorw-purpose role=purpose -->
## XORW 计算什么

`XORW` 是寄存器异或的字形式。它先用选中的变换和移位准备 `SrcR`，但只保留该准备值与 `SrcL` 的低 32 位，把它们做异或，再把结果符号扩展到 `PTO_XLEN`，并通过 `RegDst` 发布。

因此它与 `XOR` 有两处不同：操作数被收窄到低字，发布值是符号扩展后的字，而不是完整的 64 位异或。`XORW` 让 `TPC` 前进 `4` 字节，不读取内存，也不产生算术异常。

设计要点：准备出的值仍是 64 位宽，但两种扩展修饰无法改变结果。`.sw` 和 `.uw` 只重写第 31 位以上的位，32 位窗口恰好丢弃这些位，而左移也绝不会把位向下移入窗口。因此 `xorw a0, a1.sw, ->a2`、`xorw a0, a1.uw, ->a2` 与 `xorw a0, a1, ->a2` 发布相同的值；只有 `.not` 会改变结果，因为取反同样改变了低字。

<!-- PTO-READER-BLOCK: scalar-xorw-mechanism role=mechanism -->
## 先准备右源，再收窄成字

执行时读取 `SrcL` 和 `SrcR`，对 `SrcR` 施加 `SrcRType` 选中的变换，把变换后的值按 `shamt` 左移，然后才取准备值的低 32 位与 `SrcL` 的低 32 位做异或。32 位结果在发布之前先符号扩展到 64 位。

四种 `SrcRType` 编码的含义与 `XOR` 相同：

- `00`（`.sw`）把 `SrcR[31:0]` 符号扩展到 `PTO_XLEN`。
- `01`（`.uw`）把 `SrcR[31:0]` 零扩展到 `PTO_XLEN`。
- `10`（`.not`）对全部 `PTO_XLEN` 位取反。
- `11`（省略后缀）保持 `SrcR` 不变。

设计要点：`.not` 对 `SrcR` 的全部 64 位取反，进入运算的是该反值的低字：当 `SrcR=0x0000000000000001` 时，准备值是 `0xfffffffffffffffe`，窗口内是 `0xfffffffe`。

设计要点：移位在收窄之前执行，因此被移出第 31 位的低字位会离开结果。当 `SrcR=0x0000000080000000`、`shamt=1` 时，准备值是 `0x0000000100000000`，窗口内是 `0x00000000`，进入异或的就是这个零。

设计要点：由于结果做符号扩展，字异或的第 31 位决定发布值的高半部分，因此 `XORW` 可以由低字为 `0x80000000` 的源发布出 `0xffffffff80000000`。

<!-- PTO-READER-BLOCK: scalar-xorw-inputs role=inputs-outputs -->
## 编码操作数

- `RegDst` 是位于指令位 `7..11` 的 5 位字段：编码 `1..23` 写对应的绝对 GPR，编码 `0` 和编码 `24..29` 丢弃结果，编码 `30` 压入 U 队列，编码 `31` 压入 T 队列。
- `SrcL` 是位于位 `15..19` 的 5 位字段，`SrcR` 位于位 `20..24`。编码 `0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。
- `SrcRType` 是位于位 `25..26` 的 2 位字段；`shamt` 是位于位 `27..31` 的 5 位字段。

队列源按不消费的方式读取，源编码 `0` 读出零。`XORW` 没有地址操作数、排序位和 `far` 字段。

<!-- PTO-READER-BLOCK: scalar-xorw-effects role=effects -->
## 目的位置与顺序

两个源都在写目的位置之前读取，发布的值由这些指令执行前的值算出。

设计要点：`xorw a0, a1, ->a0` 发布旧 `a0` 与准备好的 `a1` 的字异或，而 `xorw a0, a0, ->a1` 无论 `a0` 原来是什么都发布 `0x0`。收窄到 32 位发生在运算内部，因此两个源被丢弃的高半部分绝不会影响结果。

成功执行后 `TPC` 前进 `4` 字节。内存位置、保留状态、描述符、数值标志、陷阱、指令束、特权以及控制流状态都不改变。

<!-- PTO-READER-BLOCK: scalar-xorw-constraints role=constraints -->
## 合法性与故障边界

`SrcRType` 的每一种编码以及 `0` 到 `31` 之间的每个 `shamt` 值都已分配，源和目的编码也全部已分配，因此 `XORW` 没有保留字段值。字异或和最后的符号扩展都是全定义的，因此不会产生算术异常。

在任何效果之前，先译码该形式并检查其编码字段，随后每个被选中的 T/U 源必须指向有效的队列项。不属于任何形式的编码，或者不可用的 `T#1..T#4` 或 `U#1..U#4` 队列项，会在写目的位置之前、`TPC` 前进之前产生 `Fault_IllegalInstruction`。

设计要点：`XORW` 不形成地址，因此既不会产生对齐故障，也不会产生访问故障。译码成功之后先检查适用性：当系统块终结标记 `_SystemBlockTerminalPending` 已置位时，该检查会以 `Fault_BundleControl` 拒绝任何标量操作。除此之外，拒绝 `XORW` 的剩余理由就是操作数可用性，而截断到 32 位并不是故障条件。

<!-- PTO-READER-BLOCK: scalar-xorw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=0x0000000000000000`、`SrcR=0x0000000080000000`、`SrcRType=11`、`shamt=0` 时，准备好的右源是 `0x0000000080000000`，其低字 `0x80000000` 与 `SrcL` 的低字做异或，发布值为符号扩展后的 `0xffffffff80000000`。

操作数相同但 `shamt=1` 时，准备值是 `0x0000000100000000`，窗口内是 `0x00000000`，发布值为 `0x0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
xorw SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xorw_32_32282566e32d | L32 | 32 | 0x00004025 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xorw_32_32282566e32d | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| xorw_32_32282566e32d | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| xorw_32_32282566e32d | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| xorw_32_32282566e32d | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| xorw_32_32282566e32d | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| xorw_32_32282566e32d | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| xorw_32_32282566e32d | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| xorw_32_32282566e32d | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| xorw_32_32282566e32d | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| xorw_32_32282566e32d | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XORW.asl -->
```asl
readonly func InstructionContractOperation_XORW()
    => ScalarOperation
begin
    return ScalarOperation_XORW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XORW.asl -->
```asl
readonly func InstructionContractHandler_XORW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractRightModifier_XORW(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_XORW(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_XORW(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_XORW(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_XORW(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinaryW(ScalarBinary_XOR, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_XORW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_XORW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, SrcRType, shamt, and RegDst are required encoded fields; no field can be omitted.
- SrcRType=00 selects .sw, SrcRType=01 selects .uw, SrcRType=10 selects .not, and SrcRType=11 selects no modifier. An omitted assembly suffix encodes SrcRType=11.
- Encoded shamt zero performs no shift; every value from 0 through 31 is assigned.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; XORW uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, compute the bitwise exclusive OR with SrcL[31:0], and sign-extend the low 32-bit result to XLEN.
- Apply the selected SrcRType transformation before the logical left shift. The transformation and shift affect SrcR only; SrcL is unchanged before the final operation.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so duplicate sources, destination aliases, and queue publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- XORW raises no arithmetic exception; the word operation keeps its low 32-bit result and sign-extends it to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- xorw a0, a1, ->a2
- xorw t#1, u#1.not<<1, ->u
- xorw zero, a0.sw, ->zero
