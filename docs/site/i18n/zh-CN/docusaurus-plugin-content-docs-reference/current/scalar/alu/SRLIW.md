<!-- GENERATED FROM: asl/scalar/alu/SRLIW.asl -->
# SRLIW

**Normative ASL source:** `asl/scalar/alu/SRLIW.asl`

SRLIW performs a word logical right shift and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-SRLIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-srliw-purpose role=purpose -->
## SRLIW 的作用

`SRLIW` 按常量 `shamt`（`0` 到 `31`）对 `SrcL` 的低 `32` 位做逻辑右移，并发布符号扩展到 `PTO_XLEN` 的 `32` 位结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、五位的 `shamt` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00005035`。

零比特在字位 `31` 处进入，随后最终的符号扩展根据新的字位 `31` 决定高半部。

<!-- PTO-READER-BLOCK: scalar-srliw-mechanism role=mechanism -->
## 字移位形成方式

分派路径以为真的 `word_operation` 调用 `ExecuteDecodedShiftImmediate`（`asl/scalar/model/dispatch/alu.asl:194-195`）。`ScalarBinaryW` 把 `left32` 绑定为 `left[31:0]`，执行 `LSR(left32, UInt(right[4:0]))`，并返回 `SignExtend{PTO_XLEN}(result32)`（`asl/scalar/model/alu/semantics.asl:482`）。

```asm
srliw SrcL, shamt, ->{t, u, Rd}
```

设计要点：由于移位是逻辑的而发布是符号扩展，同一条指令可以产生看起来为负的结果。把字 `0x80000000` 右移 `31` 位得到字 `1`，发布为 `1`；而把同一个字右移 `1` 位得到 `0x40000000`，发布为正字 `0x0000000040000000`。

设计要点：非零移位量总会在字位 `31` 处引入零，因此全一高半部只能来自低五位为 `0` 的移位量，而该移位量保持该字不变。因此字为 `0xFFFFFFFF`、移位量为 `0` 时，`SRLIW` 发布 `0xFFFFFFFFFFFFFFFF`；移位量为 `1` 时得到字 `0x7FFFFFFF`，发布 `0x000000007FFFFFFF`。

<!-- PTO-READER-BLOCK: scalar-srliw-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 提供该字，`shamt` 由载体译出，`RegDst` 接收符号扩展后的字。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。只有 `SrcL[31:0]` 参与运算。
- `shamt`，指令切片 `[20 +: 5]`：`0` 到 `31`；编码零执行恒等字移位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcL` 的编码零读取体系结构零 GPR，因此任何移位量都发布 `0`。

设计要点：源的高半部无法进入结果。只有低字被移位，因此当 `a0 = 0xFFFFFFFF00000000`、移位量为 `16` 时，`srliw` 发布 `0`，因为源的字是零。

<!-- PTO-READER-BLOCK: scalar-srliw-effects role=effects -->
## 效果与顺序

`SrcL` 在写入之前读取，因此同名目标对执行前的值移位。符号扩展后的字发布后 `TPC` 推进 `4` 字节。

`SRLIW` 不读内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权、谓词或控制流状态；仅当目标是 `30` 或 `31` 时临时队列才会移动。

设计要点：由于收窄先于移位，发布值完全由源的字与常量移位量决定。`SrcL` 高半部的任何比特都无法改变它。

<!-- PTO-READER-BLOCK: scalar-srliw-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码以及全部 `32` 个移位量都有定义；该形式除固定位 `31:25` 与 `14:12` 外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SRLIW` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：字级移位与最终扩展都是全定义的，因此 `SRLIW` 没有由操作数选择的陷阱。它的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-srliw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `16` 时，`srliw a0, 2, ->a2` 发布 `4`。

当 `a0` 为 `0x0000000080000000`、移位量为 `1` 时，字结果是 `0x40000000`，`a2` 收到正字 `0x0000000040000000`。移位量为 `31` 时，字结果是 `1`，`a2` 收到 `1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
srliw SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srliw_32_ef4aa650f46e | L32 | 32 | 0x00005035 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srliw_32_ef4aa650f46e | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srliw_32_ef4aa650f46e | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srliw_32_ef4aa650f46e | shamt | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srliw_32_ef4aa650f46e | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srliw_32_ef4aa650f46e | SrcL | 5 | 0–31 | none | none | Reg5 source; low 32 bits used | Encoded zero reads the architectural zero GPR. |
| srliw_32_ef4aa650f46e | shamt | 5 | 0–31 | none | none | five-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source; low 32 bits used |
| shamt | five-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRLIW.asl -->
```asl
readonly func InstructionContractOperation_SRLIW()
    => ScalarOperation
begin
    return ScalarOperation_SRLIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRLIW.asl -->
```asl
readonly func InstructionContractHandler_SRLIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftWidth_SRLIW()
    => integer {1..64}
begin
    return 5;
end;

pure func InstructionContractIsWordOperation_SRLIW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, shamt, and RegDst are required fields; no field can be omitted.
- shamt is a 5-bit shift amount from 0 through 31. Encoded zero performs an identity word shift.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- Every 5-bit shift amount from 0 through 31 is legal; source bits above bit 31 do not participate.

## State effects

- Compute the 32-bit logical right shift LSR(SrcL[31:0], shamt), then publish the 32-bit result sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the sign-extended word result, then advance TPC by four bytes.

## Exceptions

- SRLIW raises no arithmetic exception; zero bits enter from the left and the final word is sign-extended to XLEN.
- Bits 31:25 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- srliw a0, 1, ->a0
- srliw u#1, 31, ->t
- srliw zero, 0, ->zero
