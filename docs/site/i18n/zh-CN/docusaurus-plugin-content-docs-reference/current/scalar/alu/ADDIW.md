<!-- GENERATED FROM: asl/scalar/alu/ADDIW.asl -->
# ADDIW

**Normative ASL source:** `asl/scalar/alu/ADDIW.asl`

ADDIW performs unsigned-immediate word addition and sign-extends the result to XLEN.

## Normative identity {#PTO-INST-SCALAR-ADDIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-addiw-purpose role=purpose -->
## ADDIW 的作用

`ADDIW` 把一个零扩展的无符号 12 位立即数加到 Reg5 源的低字上，并把 32 位和符号扩展到 `PTO_XLEN` 后发布。

设计要点：`ADDIW` 复用 `ADDI` 的两个字段和无符号立即数规则，只改变加法和发布的位宽。这正是两个助记符各有独立 opcode、而不是共用一个位宽字段的原因：位宽是助记符的属性，因此编码中不需要为它花费任何一位。

<!-- PTO-READER-BLOCK: scalar-addiw-mechanism role=mechanism -->
## 结果形成方式

立即数被零扩展到 `PTO_XLEN`，再按 `2^32` 取模加到 `SrcL[31:0]` 上。随后对 32 位结果做符号扩展：结果位 `31` 被复制到 `63..32` 位。

设计要点：源的 `63..32` 位完全不参与运算。因此 `ADDIW` 是把一个值规范化为 64 位寄存器中合法 32 位数的步骤，因为每个发布结果都有 `63..32` 位等于位 `31`。

字加法是定宽且全域定义的：它在 `2^32` 处回绕，不会引发算术异常。

<!-- PTO-READER-BLOCK: scalar-addiw-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，且不会消费队列项。只有 `SrcL[31:0]` 参与运算。
- `uimm12` 携带 `0` 至 `4095` 的无符号加数。
- `RegDst` 发布符号扩展后的结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`SrcL` 的编码零读取架构零 GPR，`RegDst` 的编码零表示丢弃。两者都不是省略，`ADDIW` 的任何字段都不能省略。

<!-- PTO-READER-BLOCK: scalar-addiw-effects role=effects -->
## 效果与顺序

`SrcL` 在写入目标之前读取，因此两个选择符重名时观察到的是指令执行前的值。

字和被发布或丢弃之后，`TPC` 前进 `4` 字节。`ADDIW` 不访问内存；除该前进之外，它不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词或控制流状态。

<!-- PTO-READER-BLOCK: scalar-addiw-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码，以及 `0` 至 `4095` 的全部 `4096` 个立即数取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；固定编码位不匹配或所选 T/U 源不可用会引发 `Fault_IllegalInstruction`。这些都先于目标效果和 `TPC` 前进，且都与操作数取值无关。

设计要点：截断到 `32` 位不是故障条件。放不进一个字的和会静默保留低 `32` 位并对其做符号扩展，因此 `ADDIW` 永远不会引发溢出陷阱。

<!-- PTO-READER-BLOCK: scalar-addiw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=4294967295`、`uimm12=1`、`SrcL[31:0]` 全为一时，32 位和回绕为 `0`，`ADDIW` 发布 `0`；同样的操作数在 `ADDI` 下会发布 `4294967296`。当 `SrcL=2147483648`、`uimm12=0` 时，发布值仍为 `2147483648`，因为符号扩展重现了源字。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
addiw SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| addiw_32_08cc89cd2689 | L32 | 32 | 0x00000035 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| addiw_32_08cc89cd2689 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| addiw_32_08cc89cd2689 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| addiw_32_08cc89cd2689 | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| addiw_32_08cc89cd2689 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| addiw_32_08cc89cd2689 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads the architectural zero GPR. |
| addiw_32_08cc89cd2689 | uimm12 | 12 | 0–4095 | none | none | unsigned 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| uimm12 | unsigned 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ADDIW.asl -->
```asl
readonly func InstructionContractOperation_ADDIW()
    => ScalarOperation
begin
    return ScalarOperation_ADDIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ADDIW.asl -->
```asl
readonly func InstructionContractHandler_ADDIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_ADDIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsUnsigned_ADDIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ADDIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm12, and RegDst are required encoded fields; no field can be omitted.
- uimm12 is an unsigned 12-bit immediate from 0 through 4095. Encoded zero supplies numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write absolute GPRs.
- Every unsigned 12-bit immediate from 0 through 4095 is legal; source bits above bit 31 do not affect the result.

## State effects

- Add zero-extended uimm12 to SrcL[31:0] modulo 2^32, then sign-extend the 32-bit result to XLEN and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the sign-extended word result and then advances TPC by four bytes.

## Exceptions

- ADDIW raises no arithmetic exception: word addition wraps modulo 2^32 and is sign-extended to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- addiw a0, 1, ->a0
- addiw t#1, 4095, ->u
- addiw zero, 0, ->zero
