<!-- GENERATED FROM: asl/scalar/alu/ORIW.asl -->
# ORIW

**Normative ASL source:** `asl/scalar/alu/ORIW.asl`

ORIW performs word disjunction with a signed 12-bit immediate and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-ORIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-oriw-purpose role=purpose -->
## ORIW 的作用

`ORIW` 把 `SrcL` 的低 `32` 位与一个符号扩展的 `12` 位立即数的低 `32` 位做按位或，并发布符号扩展到 `PTO_XLEN` 的 `32` 位结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`simm12` 位于 `[20 +: 12]`。

该载体在掩码 `0x0000707f` 下匹配 `0x00003035`，处理函数是 `ScalarBinaryW`。因此该指令在运算前丢弃源的高字，并在运算后重建符号位。

`ORIW` 与 `OR` 共享目标映射，`ORIW` 与 `ORI` 共享 `12` 位立即数形式，但只有 `ORIW` 收窄到低字。

<!-- PTO-READER-BLOCK: scalar-oriw-mechanism role=mechanism -->
## 字结果形成方式

分派路径在 `asl/scalar/model/dispatch/alu.asl:108-110` 处以 `word_operation` 为真调用 `ExecuteDecodedImmediateBinary`。该路径进入 `ScalarBinaryW(ScalarBinary_OR, left, right)`，它把 `left32` 绑定为 `left[31:0]`、`right32` 绑定为 `right[31:0]`，对两个 `32` 位模式做或运算，并返回 `SignExtend{PTO_XLEN}(result32)`。

```asm
oriw SrcL, simm, ->{t, u, Rd}
```

设计要点：立即数在宽度收窄之前先符号扩展到 `PTO_XLEN`，但只有其低字保留下来。因此 `simm12 = -1` 向字级或运算贡献 `0xFFFFFFFF`，发布的字就是全一值。

设计要点：字结果的第 `31` 位被复制到 `63..32` 位。第 `31` 位为 `1` 的字会发布全一的高半部，因此仅凭收窄本身，`oriw` 不会产生零扩展的字。

<!-- PTO-READER-BLOCK: scalar-oriw-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 选择一个 Reg5 源；立即数由载体译出；`RegDst` 选择 Reg5 目标。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。只有 `SrcL[31:0]` 参与运算。
- `simm12`，指令切片 `[20 +: 12]`：有符号，取值 `-2048` 到 `2047`；只有其符号扩展结果的低 `32` 位参与运算。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcL` 的编码零读取体系结构零 GPR，`simm12` 的编码零提供 `0`。

设计要点：低字相同的两个源在 `ORIW` 下发布相同结果，与它们的高半部无关。该助记符是对该操作的完整描述，而不是 `PTO_XLEN` 或运算的预览。

<!-- PTO-READER-BLOCK: scalar-oriw-effects role=effects -->
## 效果与顺序

在写入 `RegDst` 之前读取 `SrcL` 并算出字结果，因此同名目标观察到的是执行前的值。符号扩展后的字发布后，`TPC` 推进 `4` 字节。

`ORIW` 不访问内存，保留、描述符、数值标志、陷阱、指令束、特权、谓词与控制流状态都保持不变；唯一可能的队列移动是 `30` 或 `31` 目标所选的一次压入。

设计要点：`ORIW` 不记录数值状态。收窄不会在任何地方被报告，因此发布的字是该指令唯一可观察的痕迹。

<!-- PTO-READER-BLOCK: scalar-oriw-constraints role=constraints -->
## 合法性与故障边界

每个 `SrcL` 编码、每个 `RegDst` 编码以及全部 `4096` 个立即数取值都有定义。除固定编码位 `14:12` 与 `6:0` 外，该形式没有约束。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `ORIW` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`。这三项检查都先于目标效果与 `TPC` 推进。

设计要点：`32` 位截断与最终的符号扩展都不会触发故障，因此 `ORIW` 没有依赖取值的陷阱路径。它的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-oriw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 的低 `32` 位为 `0x00F0`、`simm12 = 15` 时，`oriw a0, 15, ->a2` 发布 `0x00FF`。

当 `a0` 为 `0x00000000F0000000`、`simm12 = 15` 时，`a0` 的低字是 `0`，因此字结果是 `15`，`a2` 收到 `15`；`a0` 非零的高半部从不进入按位或。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
oriw SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| oriw_32_91608caf1ba6 | L32 | 32 | 0x00003035 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| oriw_32_91608caf1ba6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| oriw_32_91608caf1ba6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| oriw_32_91608caf1ba6 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| oriw_32_91608caf1ba6 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| oriw_32_91608caf1ba6 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads the architectural zero GPR. |
| oriw_32_91608caf1ba6 | simm12 | 12 | 0–4095 | none | none | signed 12-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| simm12 | signed 12-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/ORIW.asl -->
```asl
readonly func InstructionContractOperation_ORIW()
    => ScalarOperation
begin
    return ScalarOperation_ORIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/ORIW.asl -->
```asl
readonly func InstructionContractHandler_ORIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_ORIW()
    => integer {1..64}
begin
    return 12;
end;

pure func InstructionContractImmediateIsSigned_ORIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_ORIW()
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

- Sign-extend simm12, OR its low 32 bits with the low 32 bits of SrcL, then produce a 32-bit result sign-extended to XLEN and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Source queue selections are non-consuming.
- No memory, reservation, descriptor, block, privilege, numeric-flag, or control-flow state changes other than TPC advancing by four bytes after success.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect. Repeated source and destination selectors therefore read the pre-instruction value.
- Successful execution publishes the sign-extended word result and then advances TPC by four bytes.

## Exceptions

- ORIW raises no arithmetic exception; word disjunction and final sign extension are defined for every source and simm12 bit pattern.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- oriw a0, -1, ->a0
- oriw u#1, 2047, ->t
- oriw zero, -2048, ->zero
