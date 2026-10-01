<!-- GENERATED FROM: asl/scalar/alu/SUBI.asl -->
# SUBI

**Normative ASL source:** `asl/scalar/alu/SUBI.asl`

SUBI performs unsigned-immediate XLEN subtraction with Reg5 source and destination selection.

## Normative identity {#PTO-INST-SCALAR-SUBI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-subi-purpose role=purpose -->
## SUBI 的作用

`SUBI` 从 `SrcL` 中模 `2^PTO_XLEN` 减去一个零扩展的 `12` 位立即数，并发布完整的 `PTO_XLEN` 结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`uimm12` 位于 `[20 +: 12]`。

该载体在掩码 `0x0000707f` 下匹配 `0x00001015`。

立即数是无符号的，因此减数取值范围是 `0` 到 `4095`，永远不会变成负值。这与 `ORI` 使用的 `simm12` 立即数正好相反。

<!-- PTO-READER-BLOCK: scalar-subi-mechanism role=mechanism -->
## 结果形成方式

立即数解码器看到的是无符号 `12` 位字段，返回 `ZeroExtend{PTO_XLEN}(raw)`。随后分派路径在 `asl/scalar/model/dispatch/alu.asl:111-113` 处调用 `ScalarBinary(ScalarBinary_SUB, left, right)`，并通过 `RegDst` 写入 `left - right`。

```asm
subi SrcL, uimm, ->{t, u, Rd}
```

设计要点：无符号立即数意味着最小减数是 `0`、最大减数是 `4095`，完全没有符号扩展。`subi a0, 4095, ->a2` 恰好减去 `4095`，而同样的原始位在 `ori` 中会提供一个负常量。

设计要点：由于减法回绕，减去大于 `SrcL` 的值所产生的借位会表现为一个很大的结果，而不是故障或饱和。`SrcL = 0`、`uimm12 = 1` 时，`subi` 发布全一值。

<!-- PTO-READER-BLOCK: scalar-subi-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 是被减数，`uimm12` 由载体译出，`RegDst` 接收差值。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，该读取不消耗队列条目。
- `uimm12`，指令切片 `[20 +: 12]`：无符号，因此从 `0` 到 `4095` 的每个取值都有定义，且都不做符号扩展。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcL` 的编码零读取体系结构零 GPR，`uimm12` 的编码零提供减数 `0`，这使该指令成为源的恒等复制。

设计要点：`0..4095` 的范围意味着 `SUBI` 每条指令最多递减 `4095`；更大的递减量需要寄存器常量。

<!-- PTO-READER-BLOCK: scalar-subi-effects role=effects -->
## 效果与顺序

`SrcL` 在目标效果之前取快照，因此与源同名的目标使用执行前的值。回绕后的差值发布后 `TPC` 推进 `4` 字节。

`SUBI` 不访问内存，保留、描述符、数值标志、陷阱、指令束、特权、谓词与控制流状态都保持不变；仅当目标是 `30` 或 `31` 时临时队列才会移动。

设计要点：不记录借位或进位标志，因此该指令无法表明立即数超过了源。发布的字是回绕唯一的体系结构痕迹。

<!-- PTO-READER-BLOCK: scalar-subi-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码以及全部 `4096` 个立即数取值都有定义，该形式没有约束条目。唯一固定要求是掩码 `0x0000707f` 所选出的载体位匹配 `0x00001015`，因为 `uimm12` 占据全部十二个指令位 `31:20`。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SUBI` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：每个立即数模式都有定义，减法也是全定义的，因此 `SUBI` 没有由操作数选择的陷阱路径。它的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-subi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `10` 时，`subi a0, 3, ->a2` 发布 `7`，`subi a0, 10, ->a2` 发布 `0`。

当 `a0` 为 `0` 时，`subi a0, 4095, ->a2` 发布回绕后的差值 `0xFFFFFFFFFFFFF001`。`uimm12` 等于 `0` 时，`a2` 原样收到源。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
subi SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| subi_32_a0c87f5e7ac4 | L32 | 32 | 0x00001015 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| subi_32_a0c87f5e7ac4 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| subi_32_a0c87f5e7ac4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| subi_32_a0c87f5e7ac4 | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| subi_32_a0c87f5e7ac4 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| subi_32_a0c87f5e7ac4 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads the architectural zero GPR. |
| subi_32_a0c87f5e7ac4 | uimm12 | 12 | 0–4095 | none | none | unsigned 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| uimm12 | unsigned 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SUBI.asl -->
```asl
readonly func InstructionContractOperation_SUBI()
    => ScalarOperation
begin
    return ScalarOperation_SUBI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SUBI.asl -->
```asl
readonly func InstructionContractHandler_SUBI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_SUBI()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsUnsigned_SUBI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_SUBI()
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

- Zero-extend uimm12, subtract it from the snapshotted SrcL value modulo 2^PTO_XLEN, and publish the XLEN result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the result and then advances TPC by four bytes.

## Exceptions

- SUBI raises no arithmetic exception: subtraction wraps modulo 2^PTO_XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- subi a0, 1, ->a0
- subi u#1, 4095, ->t
- subi zero, 0, ->zero
