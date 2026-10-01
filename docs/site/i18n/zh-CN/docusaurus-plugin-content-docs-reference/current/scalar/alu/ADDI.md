<!-- GENERATED FROM: asl/scalar/alu/ADDI.asl -->
# ADDI

**Normative ASL source:** `asl/scalar/alu/ADDI.asl`

ADDI performs unsigned-immediate XLEN addition with Reg5 source and destination selection.

## Normative identity {#PTO-INST-SCALAR-ADDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-addi-purpose role=purpose -->
## ADDI 的作用

`ADDI` 把一个零扩展的无符号 12 位立即数加到 Reg5 源上，并通过 Reg5 目标发布和。它是 `ADD` 用寄存器右源所做的那次 XLEN 加法的立即数形式。

设计要点：`ADDI` 没有 `SrcR`、`SrcRType` 或 `shamt` 字段，因此它的 32 位编码把十二位用于常数，而不是两个 5 位寄存器选择符加一个修饰符和一个移位量。代价是明确的：只得到一个紧凑常数，不能变换右源。

<!-- PTO-READER-BLOCK: scalar-addi-mechanism role=mechanism -->
## 结果形成方式

立即数被零扩展到 `PTO_XLEN`，再按 `2^PTO_XLEN` 取模加到快照的源值上。

设计要点：`uimm12` 是无符号的，覆盖 `0` 至 `4095`，因此编码中不存在负常数。`addi a0, 4095, ->a0` 加的是 `4095`；要编码一个小负常数，需要使用立即数字段有符号的助记符，例如带 `simm12` 的 `ANDI`。

加法是定宽且全域定义的。它会回绕，不会引发算术异常。

<!-- PTO-READER-BLOCK: scalar-addi-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，且不会消费队列项。
- `uimm12` 携带无符号加数。
- `RegDst` 发布结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：本页中编码零有三种不同含义。`SrcL=0` 读取架构零 GPR，`uimm12=0` 是数值零加数，`RegDst=0` 丢弃结果而不是写入零 GPR。三者都是取值而非省略，编码中也没有可省略的形式。

<!-- PTO-READER-BLOCK: scalar-addi-effects role=effects -->
## 效果与顺序

`SrcL` 在写入目标之前读取，因此像 `addi a0, 1, ->a0` 这样源和目标选择符重复的写法仍然读取指令执行前的 `a0`。

结果发布或丢弃之后，`TPC` 前进 `4` 字节。`ADDI` 不访问内存；除该前进之外，它不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词或控制流状态。

<!-- PTO-READER-BLOCK: scalar-addi-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码，以及 `0` 至 `4095` 的全部 `4096` 个立即数取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；固定编码位不匹配或所选 T/U 源不可用会引发 `Fault_IllegalInstruction`。这些都先于目标效果和 `TPC` 前进。`ADDI` 自身不增加任何故障。

设计要点：由于立即数无符号且取值全部已分配，既没有非法常数，也没有保留常数。需要 12 位有符号加数的代码必须改用立即数有符号的助记符，或把常数拆到两条指令中。

<!-- PTO-READER-BLOCK: scalar-addi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL` 保存 `10`、`uimm12=4095` 时，`ADDI` 发布 `10 + 4095 = 4105`。当 `uimm12=1` 且 `RegDst` 与 `SrcL` 指向同一个 GPR 时，它把该 GPR 加 `1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
addi SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| addi_32_2decd0a93a0a | L32 | 32 | 0x00000015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| addi_32_2decd0a93a0a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| addi_32_2decd0a93a0a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| addi_32_2decd0a93a0a | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| addi_32_2decd0a93a0a | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| addi_32_2decd0a93a0a | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads the architectural zero GPR. |
| addi_32_2decd0a93a0a | uimm12 | 12 | 0–4095 | none | none | unsigned 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| uimm12 | unsigned 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ADDI.asl -->
```asl
readonly func InstructionContractOperation_ADDI()
    => ScalarOperation
begin
    return ScalarOperation_ADDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ADDI.asl -->
```asl
readonly func InstructionContractHandler_ADDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_ADDI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsUnsigned_ADDI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ADDI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm12, and RegDst are required encoded fields; no field can be omitted.
- uimm12 is an unsigned 12-bit immediate from 0 through 4095. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every unsigned 12-bit immediate from 0 through 4095 is legal.

## State effects

- Zero-extend uimm12, add it to the snapshotted SrcL value modulo 2^PTO_XLEN, and publish the XLEN result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the result and then advances TPC by four bytes.

## Exceptions

- ADDI raises no arithmetic exception: addition wraps modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- addi a0, 1, ->a0
- addi t#1, 4095, ->u
- addi zero, 0, ->zero
