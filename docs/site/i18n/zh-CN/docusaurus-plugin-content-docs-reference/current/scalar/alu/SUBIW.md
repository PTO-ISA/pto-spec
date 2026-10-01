<!-- GENERATED FROM: asl/scalar/alu/SUBIW.asl -->
# SUBIW

**Normative ASL source:** `asl/scalar/alu/SUBIW.asl`

SUBIW performs unsigned-immediate word subtraction and sign-extends the result to XLEN.

## Normative identity {#PTO-INST-SCALAR-SUBIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-subiw-purpose role=purpose -->
## SUBIW 的作用

`SUBIW` 从 `SrcL` 的低 `32` 位中模 `2^32` 减去一个零扩展的 `12` 位立即数，并发布符号扩展到 `PTO_XLEN` 的 `32` 位结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`uimm12` 位于 `[20 +: 12]`。

该载体在掩码 `0x0000707f` 下匹配 `0x00001035`，并分派到 `ScalarBinaryW`。

这里可以看到两个彼此独立的宽度决定：减法按 `32` 位进行，而发布的取值是一个 `PTO_XLEN` 字，其高半部重复字位 `31`。

<!-- PTO-READER-BLOCK: scalar-subiw-mechanism role=mechanism -->
## 字结果形成方式

分派路径在 `asl/scalar/model/dispatch/alu.asl:114-116` 处以真 `word_operation` 调用 `ExecuteDecodedImmediateBinary`。`ScalarBinaryW` 把 `left32` 绑定为 `left[31:0]`，按模 `2^32` 计算 `left32 - right32`，并返回 `SignExtend{PTO_XLEN}(result32)`（`asl/scalar/model/alu/semantics.asl:477`）。

```asm
subiw SrcL, uimm, ->{t, u, Rd}
```

设计要点：立即数先零扩展到 `PTO_XLEN`，但只有其低字进入减法，而且立即数最大为 `4095`，因此它永远不会置起第 `11` 位以上的位。

设计要点：结果低于零的字减法会产生字位 `31` 被置起的字，最终的扩展把它变成负的发布值。源字为 `0`、`uimm12 = 1` 时，`subiw` 发布 `0xFFFFFFFFFFFFFFFF`，即 `-1`。

<!-- PTO-READER-BLOCK: scalar-subiw-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 提供该字，`uimm12` 由载体译出，`RegDst` 接收符号扩展后的字。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。只有 `SrcL[31:0]` 参与运算。
- `uimm12`，指令切片 `[20 +: 12]`：无符号，取值 `0` 到 `4095`；编码零提供减数 `0`。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcL` 的编码零读取体系结构零 GPR，其低字是 `0`。

设计要点：`SrcL` 的高半部在减法之前被丢弃，因此当 `a0 = 0x0000000100000000`、`uimm12 = 1` 时，`subiw` 发布 `0xFFFFFFFFFFFFFFFF`，而不是 `0x00000000FFFFFFFF`。源的字是零，字结果是 `-1`。

<!-- PTO-READER-BLOCK: scalar-subiw-effects role=effects -->
## 效果与顺序

`SrcL` 在写入之前读取，因此同名目标基于执行前的值计算。符号扩展后的字发布后 `TPC` 推进 `4` 字节。

`SUBIW` 不读内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权、谓词或控制流状态；唯一的队列移动是 `30` 或 `31` 目标所选的一次压入。

设计要点：`32` 位的回绕与符号扩展都是静默的。想要无符号字差值的调用者读取目标的低 `32` 位并忽略高半部。

<!-- PTO-READER-BLOCK: scalar-subiw-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码以及全部 `4096` 个立即数取值都有定义，该形式没有约束条目。唯一固定要求是掩码 `0x0000707f` 所选出的载体位匹配 `0x00001035`，因为 `uimm12` 占据全部十二个指令位 `31:20`。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SUBIW` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：字级减法与最终的符号扩展都是全定义的，因此 `SUBIW` 没有由操作数选择的陷阱。它的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-subiw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `10` 时，`subiw a0, 3, ->a2` 发布 `7`。

当 `a0` 的低字为 `3`、立即数为 `7` 时，字差值是 `0xFFFFFFFC`，因此 `a2` 收到 `0xFFFFFFFFFFFFFFFC`，即 `-4`。同一源下立即数为 `3` 时发布 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
subiw SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| subiw_32_51019ff77d0a | L32 | 32 | 0x00001035 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| subiw_32_51019ff77d0a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| subiw_32_51019ff77d0a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| subiw_32_51019ff77d0a | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| subiw_32_51019ff77d0a | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| subiw_32_51019ff77d0a | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads the architectural zero GPR. |
| subiw_32_51019ff77d0a | uimm12 | 12 | 0–4095 | none | none | unsigned 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| uimm12 | unsigned 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SUBIW.asl -->
```asl
readonly func InstructionContractOperation_SUBIW()
    => ScalarOperation
begin
    return ScalarOperation_SUBIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SUBIW.asl -->
```asl
readonly func InstructionContractHandler_SUBIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_SUBIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsUnsigned_SUBIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_SUBIW()
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

- Subtract zero-extended uimm12 from SrcL[31:0] modulo 2^32, then sign-extend the 32-bit result to XLEN and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the sign-extended word result and then advances TPC by four bytes.

## Exceptions

- SUBIW raises no arithmetic exception: word subtraction wraps modulo 2^32 and is sign-extended to XLEN.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- subiw a0, 1, ->a0
- subiw u#1, 4095, ->t
- subiw zero, 0, ->zero
