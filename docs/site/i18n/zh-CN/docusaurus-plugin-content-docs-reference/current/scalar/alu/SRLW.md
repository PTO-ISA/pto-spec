<!-- GENERATED FROM: asl/scalar/alu/SRLW.asl -->
# SRLW

**Normative ASL source:** `asl/scalar/alu/SRLW.asl`

SRLW performs a logical right shift of the low 32-bit source by the low five bits of the snapshotted SrcR; the 32-bit result is sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-SRLW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-srlw-purpose role=purpose -->
## SRLW 的作用

`SRLW` 按取自 `SrcR` 低五位的移位量对 `SrcL` 的低 `32` 位做逻辑右移，并发布符号扩展到 `PTO_XLEN` 的 `32` 位结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00005025`。

计数源可以在运行时计算，而被移位的值被截断到其低字。

<!-- PTO-READER-BLOCK: scalar-srlw-mechanism role=mechanism -->
## 字移位形成方式

分派路径以为真的 `word_operation` 通过 `ExecuteDecodedSimpleBinary` 到达 `ScalarBinaryW(ScalarBinary_SRL, left, right)`（`asl/scalar/model/dispatch/alu.asl:182-183`）。该辅助函数把 `left32` 绑定为 `left[31:0]`，用 `LSR(left32, UInt(right[4:0]))` 移位，并返回 `SignExtend{PTO_XLEN}(result32)`（`asl/scalar/model/alu/semantics.asl:482`）。

```asm
srlw SrcL, SrcR, ->{t, u, Rd}
```

设计要点：计数来自完整的 `SrcR`，因此第 `4` 位以上被置起的计数值仍然只提供其低五位。保存 `5` 的计数寄存器移 `5` 位，保存 `37` 的计数寄存器同样移 `5` 位。

设计要点：最终的符号扩展意味着即使移位是逻辑的，发布的字也是有符号取值。想要无符号字结果的程序把目标的低 `32` 位当作答案，并忽略高半部。

<!-- PTO-READER-BLOCK: scalar-srlw-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 是被移位的值，`SrcR` 是计数源，`RegDst` 是目标。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。只有 `SrcL[31:0]` 参与运算。
- `SrcR`，指令切片 `[20 +: 5]`：计数源，同样的映射；每个取值都合法，只使用第 `4:0` 位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcR` 的编码零读取体系结构零 GPR，它提供移位量 `0`。

设计要点：低五位为 `0` 的计数发布的是源字的符号扩展，它与源寄存器不一定是同一个值。当 `a0 = 0x00000000FFFFFFFF`、`a1 = 0` 时，`srlw a0, a1, ->a2` 发布 `0xFFFFFFFFFFFFFFFF`，因为该字作为有符号取值是 `-1`。

<!-- PTO-READER-BLOCK: scalar-srlw-effects role=effects -->
## 效果与顺序

两个源都在写目标之前取快照，因此与任一源同名的目标对执行前的值移位。符号扩展后的字发布后 `TPC` 推进 `4` 字节。

`SRLW` 不访问内存，保留、描述符、数值标志、陷阱、指令束、特权、谓词与控制流状态都保持不变；仅当目标是 `30` 或 `31` 时临时队列才会移动。

设计要点：该指令只有一个目标，也不记录状态。目标的低字保存移位后的位模式，高半部重复其第 `31` 位，因此总能从发布值中恢复原始移位字。

<!-- PTO-READER-BLOCK: scalar-srlw-constraints role=constraints -->
## 合法性与故障边界

每个 Reg5 源编码与每个 Reg5 目标编码都有定义，该形式除固定载体位外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SRLW` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：计数截断与取值截断都是全定义的，因此 `SRLW` 没有由操作数选择的陷阱。它的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-srlw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `16`、`a1` 为 `2` 时，`srlw a0, a1, ->a2` 发布 `4`。

当 `a0` 为 `0x0000000080000000`、`a1` 为 `31` 时，字结果是 `1`，`a2` 收到 `1`。当 `a1` 为 `32` 时，计数的低五位是 `0`，因此结果字是 `0x80000000`，`a2` 收到 `0xFFFFFFFF80000000`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
srlw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srlw_32_2c6458b2aadb | L32 | 32 | 0x00005025 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srlw_32_2c6458b2aadb | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srlw_32_2c6458b2aadb | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srlw_32_2c6458b2aadb | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srlw_32_2c6458b2aadb | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srlw_32_2c6458b2aadb | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| srlw_32_2c6458b2aadb | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRLW.asl -->
```asl
readonly func InstructionContractOperation_SRLW()
    => ScalarOperation
begin
    return ScalarOperation_SRLW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRLW.asl -->
```asl
readonly func InstructionContractHandler_SRLW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftAmount_SRLW(right: Word)
    => integer {0..31}
begin
    return UInt(right[4:0]);
end;

pure func InstructionContractResult_SRLW(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SRLW(right);
    let shifted = LSR(left[31:0], amount);
    return SignExtend{PTO_XLEN}(shifted);
end;

pure func InstructionContractIsWordOperation_SRLW()
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

- Compute the logical right shift using the low five bits of the snapshotted SrcR. The low 32-bit result is sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRLW raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- srlw a0, a1, ->a2
- srlw t#1, u#1, ->u
- srlw zero, zero, ->zero
