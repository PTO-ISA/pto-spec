<!-- GENERATED FROM: asl/scalar/alu/XOR.asl -->
# XOR

**Normative ASL source:** `asl/scalar/alu/XOR.asl`

XOR applies the selected right-source transformation before its encoded logical left shift, performs bitwise exclusive OR, and publishes the PTO_XLEN result.

## Normative identity {#PTO-INST-SCALAR-XOR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-xor-purpose role=purpose -->
## XOR 计算什么

`XOR` 是一个 32 位标量 ALU 形式。它把左源 `SrcL` 与右源 `SrcR` 经过准备后的副本按位做异或，并通过目的字段 `RegDst` 发布结果。

该运算在完整的 `PTO_XLEN` 宽度上进行，因此两个操作数逐位异或，结果截断到 64 位。`XOR` 不读取内存，也不产生算术异常，因此除目的位置外，它唯一的架构效果就是 `TPC` 前进 `4` 字节。

设计要点：`XOR` 是寄存器逻辑族中的异或成员。它与 `AND`、`OR` 以及其他同样带有 `SrcRType` 与 `shamt` 字段的寄存器形式共用同一套操作数布局；决定这是哪条运算的是译码出的助记符，而不是不同的操作数形状。

<!-- PTO-READER-BLOCK: scalar-xor-mechanism role=mechanism -->
## 先准备右源，再做异或

执行按严格顺序确定输入：先读取 `SrcL` 和 `SrcR`，再按 2 位的 `SrcRType` 字段变换 `SrcR`，然后把变换后的值按 5 位的 `shamt` 左移，最后才做异或并写目的位置。

| `SrcRType` | 汇编后缀 | 移位前对 `SrcR` 的作用 |
| --- | --- | --- |
| `00` | `.sw` | 把 `SrcR[31:0]` 符号扩展到 `PTO_XLEN` |
| `01` | `.uw` | 把 `SrcR[31:0]` 零扩展到 `PTO_XLEN` |
| `10` | `.not` | 对全部 `PTO_XLEN` 位取反 |
| `11` | 省略 | 保持 `SrcR` 不变 |

设计要点：变换和移位都只作用于 `SrcR`，而且变换先执行，所以两者不能交换顺序。当 `SrcR=0x000000000000000f` 时，先 `.not` 再左移 `4` 位得到 `0xffffffffffffff00`，而先左移 `4` 位再 `.not` 会得到 `0xffffffffffffff0f`。

设计要点：`.not` 对完整的 64 位源取反，而不是只对其低字取反，因为逻辑族请求的是取反解释，而算术族把同一编码解释为取负。因此当 `SrcR=0x0000000000000001` 时，`.not` 准备出的值是 `0xfffffffffffffffe`，绝不会是 `0x00000000fffffffe`。

<!-- PTO-READER-BLOCK: scalar-xor-inputs role=inputs-outputs -->
## 编码操作数

- `RegDst` 是位于指令位 `7..11` 的 5 位字段：编码 `1..23` 写对应的绝对 GPR，编码 `0` 和编码 `24..29` 丢弃结果，编码 `30` 压入 U 队列，编码 `31` 压入 T 队列。
- `SrcL` 是位于位 `15..19` 的 5 位字段，`SrcR` 是位于位 `20..24` 的 5 位字段。编码 `0..23` 读取绝对 GPR，编码 `24..27` 读取 `T#1..T#4`，编码 `28..31` 读取 `U#1..U#4`。
- `SrcRType` 是位于位 `25..26` 的 2 位字段，`shamt` 是位于位 `27..31` 的 5 位字段，编码变换之后施加的左移量。

队列源按不消费的方式读取，源编码 `0` 始终读出零。`XOR` 不访问内存，因此它完全没有地址操作数、排序位和 `far` 字段。

设计要点：省略 `.sw`、`.uw` 或 `.not` 后缀时编码为 `SrcRType=11`，其含义是"保持源不变"，而不是做符号扩展的 `.sw`。因此普通的 `xor a0, a1, ->a2` 按原样使用 `a1` 的全部 64 位。

<!-- PTO-READER-BLOCK: scalar-xor-effects role=effects -->
## 目的位置与顺序

两个源都在写目的位置之前读取，发布的值由这些指令执行前的值算出。

设计要点：由于读取先完成，`xor a0, a1, ->a0` 发布旧 `a0` 与 `a1` 的异或，而 `xor a0, a0, ->a1` 无论 `a0` 原来是什么都发布零。任何目的位置别名都无法改变参与组合的操作数值。

成功执行后 `TPC` 前进 `4` 字节。其他状态不变：`XOR` 不触碰任何内存位置、保留状态、描述符、数值标志、陷阱、指令束、特权或控制流状态。

<!-- PTO-READER-BLOCK: scalar-xor-constraints role=constraints -->
## 合法性与故障边界

`SrcRType` 的每一种编码以及 `0` 到 `31` 之间的每个 `shamt` 值都已分配，源和目的编码也全部已分配，因此 `XOR` 没有任何保留字段值。操作数按 `2^PTO_XLEN` 取模组合：最高位的进位被丢弃，不产生算术异常。

在任何效果之前，先译码该形式并检查其编码字段，随后要求每个被选中的 T/U 源都指向有效的队列项。不属于任何形式的编码，或者被选中却不可用的 `T#1..T#4` 或 `U#1..U#4` 队列项，会在写目的位置之前、`TPC` 前进之前产生 `Fault_IllegalInstruction`。

设计要点：`XOR` 不形成地址，因此既不会产生对齐故障，也不会产生访问故障。译码成功之后先检查适用性：当系统块终结标记 `_SystemBlockTerminalPending` 已置位时，该检查会以 `Fault_BundleControl` 拒绝任何标量操作。除此之外，拒绝 `XOR` 的剩余理由就是操作数可用性，而该检查在写目的位置之前执行，因此不可用的队列源会拒绝该指令，而不是读出一个未定义值。

<!-- PTO-READER-BLOCK: scalar-xor-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=0xc`、`SrcR=0xa`、`SrcRType=11`、`shamt=0` 时，右源既不变换也不移位，因此该指令发布 `0xc XOR 0xa = 0x6`。

第二个例子展示准备顺序。当 `SrcL=0x00000000000000ff`、`SrcR=0x000000000000000f`、`SrcRType=10`（`.not`）、`shamt=4` 时，`0x000000000000000f` 的取反是 `0xfffffffffffffff0`，左移后得到 `0xffffffffffffff00`，异或发布 `0xffffffffffffffff`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
xor SrcL, SrcR<{.sw,.uw,.not}><<<shamt>, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xor_32_33510860c585 | L32 | 32 | 0x00004005 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xor_32_33510860c585 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| xor_32_33510860c585 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| xor_32_33510860c585 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| xor_32_33510860c585 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| xor_32_33510860c585 | shamt | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| xor_32_33510860c585 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| xor_32_33510860c585 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| xor_32_33510860c585 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |
| xor_32_33510860c585 | SrcRType | 2 | 0–3 | none | none | right-source transformation selector | Encoded zero selects .sw and sign-extends SrcR[31:0]. |
| xor_32_33510860c585 | shamt | 5 | 0–31 | none | none | post-transformation logical-left-shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |
| SrcRType | right-source transformation selector |
| shamt | post-transformation logical-left-shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/XOR.asl -->
```asl
readonly func InstructionContractOperation_XOR()
    => ScalarOperation
begin
    return ScalarOperation_XOR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/XOR.asl -->
```asl
readonly func InstructionContractHandler_XOR()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractRightModifier_XOR(encoded: bits(2))
    => ScalarRightModifier
begin
    case encoded of
        when '00' => return ScalarRight_SignedWord;
        when '01' => return ScalarRight_UnsignedWord;
        when '10' => return ScalarRight_NegateOrNot;
        when '11' => return ScalarRight_None;
    end;
end;

pure func InstructionContractPreparedRight_XOR(
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let modifier = InstructionContractRightModifier_XOR(encoded_modifier);
    let transformed = ApplyScalarRightModifier(right, modifier, TRUE);
    let shifted = LSL(transformed, shift_amount);
    return shifted;
end;

pure func InstructionContractResult_XOR(
    left: Word,
    right: Word,
    encoded_modifier: bits(2),
    shift_amount: integer {0..31})
    => Word
begin
    let prepared_right = InstructionContractPreparedRight_XOR(
        right,
        encoded_modifier,
        shift_amount);
    return ScalarBinary(ScalarBinary_XOR, left, prepared_right);
end;

pure func InstructionContractIsLogicalFamily_XOR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_XOR()
    => boolean
begin
    return FALSE;
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
- All four SrcRType encodings are assigned. The logical family uses .not while the arithmetic family uses .neg; XOR uses .not.
- Every five-bit shamt value from 0 through 31 is legal.

## State effects

- Transform SrcR, perform the logical left shift, and compute the bitwise exclusive OR with SrcL at PTO_XLEN width modulo 2^PTO_XLEN.
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

- XOR raises no arithmetic exception; transformation, shifting, and the final operation use PTO_XLEN bits modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- xor a0, a1, ->a2
- xor t#1, u#1.not<<1, ->u
- xor zero, a0.sw, ->zero
