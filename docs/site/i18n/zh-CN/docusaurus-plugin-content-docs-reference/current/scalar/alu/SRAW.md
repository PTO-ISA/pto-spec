<!-- GENERATED FROM: asl/scalar/alu/SRAW.asl -->
# SRAW

**Normative ASL source:** `asl/scalar/alu/SRAW.asl`

SRAW performs a arithmetic right shift of the low 32-bit source by the low five bits of the snapshotted SrcR; the 32-bit result is sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-SRAW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sraw-purpose role=purpose -->
## SRAW 的作用

`SRAW` 按取自 `SrcR` 低五位的移位量对 `SrcL` 的低 `32` 位做算术右移，并发布符号扩展到 `PTO_XLEN` 的 `32` 位结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00006025`。

符号来源是字位 `31`，计数源被截断到五位，因此两个操作数的角色处理并不对称。

<!-- PTO-READER-BLOCK: scalar-sraw-mechanism role=mechanism -->
## 字移位形成方式

分派路径以 `ScalarBinary_SRA` 与为真的 `word_operation` 调用 `ExecuteDecodedSimpleBinary`（`asl/scalar/model/dispatch/alu.asl:186-187`）。`ScalarBinaryW` 取 `left[31:0]`，用 `ASR(left32, UInt(right[4:0]))` 移位，并返回 `SignExtend{PTO_XLEN}(result32)`（`asl/scalar/model/alu/semantics.asl:483`）。

```asm
sraw SrcL, SrcR, ->{t, u, Rd}
```

设计要点：计数是完整快照 `SrcR` 的低五位，而不是预先截断的字。保存 `0x1000000020` 的计数寄存器提供 `0`，因为第 `5` 位在所使用字段之外，而它的低五位本来就是零。

设计要点：由于移位作用于该字，`SrcL` 的高半部对结果没有影响。只有取值的字与计数的低五位起作用。

<!-- PTO-READER-BLOCK: scalar-sraw-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 是被移位的值，`SrcR` 提供计数，`RegDst` 接收符号扩展后的字。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。只有 `SrcL[31:0]` 参与运算。
- `SrcR`，指令切片 `[20 +: 5]`：计数源，使用同样的五位映射；每个取值都合法，只使用第 `4:0` 位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcR` 的编码零读取体系结构零 GPR，它提供移位量 `0`。

设计要点：低五位全为 `1` 的计数移 `31` 位，使字符号位在该字的每个位置重复。此时发布值只取决于 `SrcL` 的字位 `31`，要么是 `0`，要么是全一值。

<!-- PTO-READER-BLOCK: scalar-sraw-effects role=effects -->
## 效果与顺序

两个源都在写目标之前取快照，因此与任一源同名的目标对执行前的值移位。符号扩展后的字发布后 `TPC` 推进 `4` 字节。

`SRAW` 不访问内存，保留、描述符、数值标志、陷阱、指令束、特权、谓词与控制流状态都保持不变；唯一的队列移动是 `30` 或 `31` 目标所选的一次压入。

设计要点：`SRAW` 不报告有多少比特离开了该字。由于符号填充是确定性的，发布的字就是移位结果的完整描述。

<!-- PTO-READER-BLOCK: scalar-sraw-constraints role=constraints -->
## 合法性与故障边界

每个 `SrcL`、`SrcR` 与 `RegDst` 编码都有定义，除固定载体位外没有约束条目适用。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SRAW` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`。每项检查都先于目标效果与 `TPC` 推进。

设计要点：计数字段完全有定义，字级移位也不会触发故障，因此 `SRAW` 没有由操作数选择的陷阱。它的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-sraw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0 = -16`、`a1 = 2` 时，`sraw a0, a1, ->a2` 发布 `-4`。

当 `a0` 为 `0x0000000080000000`、`a1` 为 `4` 时，该字为负，结果字是 `0xF8000000`，因此 `a2` 收到 `0xFFFFFFFFF8000000`。当 `a1` 为 `32` 时，低五位是 `0`，`a2` 原样收到 `a0` 的符号扩展字。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sraw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sraw_32_5baf37f34241 | L32 | 32 | 0x00006025 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sraw_32_5baf37f34241 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sraw_32_5baf37f34241 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sraw_32_5baf37f34241 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sraw_32_5baf37f34241 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sraw_32_5baf37f34241 | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| sraw_32_5baf37f34241 | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRAW.asl -->
```asl
readonly func InstructionContractOperation_SRAW()
    => ScalarOperation
begin
    return ScalarOperation_SRAW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRAW.asl -->
```asl
readonly func InstructionContractHandler_SRAW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftAmount_SRAW(right: Word)
    => integer {0..31}
begin
    return UInt(right[4:0]);
end;

pure func InstructionContractResult_SRAW(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SRAW(right);
    let shifted = ASR(left[31:0], amount);
    return SignExtend{PTO_XLEN}(shifted);
end;

pure func InstructionContractIsWordOperation_SRAW()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- The low five bits of the snapshotted SrcR select the shift amount 0 through 31; every higher SrcR bit is ignored for the amount.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All SrcR values are legal; only its low five bits contribute to the shift amount.

## State effects

- Compute the arithmetic right shift using the low five bits of the snapshotted SrcR. The low 32-bit result is sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRAW raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- sraw a0, a1, ->a2
- sraw t#1, u#1, ->u
- sraw zero, zero, ->zero
