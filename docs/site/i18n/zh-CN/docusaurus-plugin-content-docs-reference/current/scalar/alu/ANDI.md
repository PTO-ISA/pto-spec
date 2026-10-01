<!-- GENERATED FROM: asl/scalar/alu/ANDI.asl -->
# ANDI

**Normative ASL source:** `asl/scalar/alu/ANDI.asl`

ANDI performs XLEN conjunction with a sign-extended signed 12-bit immediate.

## Normative identity {#PTO-INST-SCALAR-ANDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-andi-purpose role=purpose -->
## ANDI 的作用

`ANDI` 把一个有符号 12 位立即数符号扩展到 `PTO_XLEN`，计算该值与 Reg5 源逐位相与的结果，并通过 Reg5 目标发布。

设计要点：这里的立即数字段是有符号的，而 `ADDI` 把同样的十二位用于无符号值。两个助记符共用编码形状，只在一个字段的解释上不同，因此符号规则属于助记符，而不是属于该字段。

<!-- PTO-READER-BLOCK: scalar-andi-mechanism role=mechanism -->
## 结果形成方式

`simm12` 被符号扩展到 `PTO_XLEN`，再与源值做按位与。

设计要点：符号扩展使每个负值的立即数全为 1。因此 `andi a0, -1, ->a0` 保留 `a0` 的每一位：该运算是已定义的，也会让 `TPC` 前进，但结果没有任何一位与源不同。

设计要点：当常数需要直接写出时，可用的掩码范围是 `0` 至 `2047`，因为对大于 `2047` 的任何取值，符号扩展后的 `simm12` 都会置起 `63..11` 位。要屏蔽更宽的字段，需要使用运行期得到的值或另一个助记符。

<!-- PTO-READER-BLOCK: scalar-andi-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 是 Reg5 源：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，且不会消费队列项。
- `simm12` 携带 `-2048` 至 `2047` 的有符号立即数。
- `RegDst` 发布结果：`1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`simm12` 的编码零是数值零，因此 `andi a0, 0, ->a1` 发布 `0`，而不是拷贝源。`RegDst` 的编码零表示丢弃，这同样不同于写入零 GPR。

<!-- PTO-READER-BLOCK: scalar-andi-effects role=effects -->
## 效果与顺序

`SrcL` 在写入目标之前读取，因此既是源又是目标的选择符保留指令执行前的值。

结果发布或丢弃之后，`TPC` 前进 `4` 字节。`ANDI` 不访问内存；除该前进之外，它不改变保留状态、描述符、数值状态、陷阱、指令束、特权、谓词或控制流状态。

<!-- PTO-READER-BLOCK: scalar-andi-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码，以及 `-2048` 至 `2047` 的全部 `4096` 个立即数取值。

无法译码的形式在 `PC` 处引发 `Fault_IllegalInstruction`；不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`；固定编码位不匹配或所选 T/U 源不可用会引发 `Fault_IllegalInstruction`。这些都先于目标效果和 `TPC` 前进。

设计要点：对两个操作数的任意位模式，合取都是已定义的，因此 `ANDI` 没有依赖取值的故障。清掉了程序仍然需要的位属于编程错误，而不是架构异常。

<!-- PTO-READER-BLOCK: scalar-andi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `SrcL=4095`、`simm12=2047` 时，`ANDI` 发布 `4095 AND 2047 = 2047`。对同样的源取 `simm12=-1` 时，符号扩展后的立即数全为 1，发布值仍为 `4095`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
andi SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| andi_32_1d9302e57d30 | L32 | 32 | 0x00002015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| andi_32_1d9302e57d30 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| andi_32_1d9302e57d30 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| andi_32_1d9302e57d30 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| andi_32_1d9302e57d30 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| andi_32_1d9302e57d30 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads the architectural zero GPR. |
| andi_32_1d9302e57d30 | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ANDI.asl -->
```asl
readonly func InstructionContractOperation_ANDI()
    => ScalarOperation
begin
    return ScalarOperation_ANDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ANDI.asl -->
```asl
readonly func InstructionContractHandler_ANDI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_ANDI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_ANDI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ANDI()
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
- Every signed 12-bit immediate from -2048 through 2047 is legal and is sign-extended to PTO_XLEN before the conjunction.

## State effects

- Sign-extend simm12 to PTO_XLEN, compute the bitwise conjunction with the snapshotted SrcL value, and publish the complete XLEN result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the result and then advances TPC by four bytes.

## Exceptions

- ANDI raises no arithmetic exception; bitwise conjunction is defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- andi a0, -1, ->a0
- andi t#1, 2047, ->u
- andi zero, -2048, ->zero
