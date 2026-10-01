<!-- GENERATED FROM: asl/scalar/alu/SRA.asl -->
# SRA

**Normative ASL source:** `asl/scalar/alu/SRA.asl`

SRA performs a arithmetic right shift of the PTO_XLEN source by the low six bits of the snapshotted SrcR; the XLEN result is published directly.

## Normative identity {#PTO-INST-SCALAR-SRA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sra-purpose role=purpose -->
## SRA 的作用

`SRA` 按 `SrcR` 低六位给出的移位量对 `SrcL` 做算术右移，把符号位复制到空出的位置，并发布完整的 `PTO_XLEN` 结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00006005`。

算术移位与 `SRL` 的唯一区别是：空出的左侧位重复 `SrcL[63]`，而不是填零。

<!-- PTO-READER-BLOCK: scalar-sra-mechanism role=mechanism -->
## 移位形成方式

分派路径通过简单二元路径在 `asl/scalar/model/dispatch/alu.asl:184-185` 处调用 `ScalarBinary(ScalarBinary_SRA, left, right)`。该辅助函数返回 `ASR(left, UInt(right[5:0]))`（`asl/scalar/model/alu/semantics.asl:458`），因此计数是快照后右源的低六位，移位按完整宽度执行。

```asm
sra SrcL, SrcR, ->{t, u, Rd}
```

设计要点：用第 `63` 位的副本填充使 `SRA` 成为保持补码取值符号的右移：负数右移后仍为负。`SrcL` 为 `-16`、计数为 `2` 时，`SRA` 发布 `-4`。

设计要点：计数为 `63` 时符号位在每个位置重复。被除数 `SrcL` 为负时结果是全一值，`SrcL` 为非负时结果是 `0`。

<!-- PTO-READER-BLOCK: scalar-sra-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 是被移位的值，`SrcR` 是计数源，`RegDst` 是目标。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。
- `SrcR`，指令切片 `[20 +: 5]`：计数源，同样的映射；每个取值都合法，只使用第 `5:0` 位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcR` 的编码零读取体系结构零 GPR，它提供移位量 `0`，因此是恒等移位。

设计要点：只有提供计数的寄存器被掩码；被移位的值按完整 `PTO_XLEN` 宽度使用，因此第 `63` 位决定填充。高半部为零的取值表现得像无符号移位。

<!-- PTO-READER-BLOCK: scalar-sra-effects role=effects -->
## 效果与顺序

两个源都在写目标之前读取，因此同名目标对执行前的值移位。结果发布后 `TPC` 推进 `4` 字节。

`SRA` 不读内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权、谓词或控制流状态。唯一的队列移动是 `30` 或 `31` 目标所选的一次压入。

设计要点：该移位从不设置粘滞标志，因此在长移位后变成 `-1` 的有符号值与本来就是 `-1` 的值，从体系结构状态上看无法区分。

<!-- PTO-READER-BLOCK: scalar-sra-constraints role=constraints -->
## 合法性与故障边界

Reg5 域中的每个源编码与每个目标编码都有定义，该形式除固定载体位外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SRA` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：算术移位对每个操作数组合都是全定义的，包括低六位为零的计数。`SRA` 中没有任何操作数取值会选择陷阱。

<!-- PTO-READER-BLOCK: scalar-sra-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `-16`、`a1` 为 `2` 时，`sra a0, a1, ->a2` 发布 `-4`。

当 `a0` 为 `-1`、`a1` 为 `63` 时，符号位被复制到每个位置，因此 `a2` 收到 `-1`。当 `a0` 为 `16` 且计数相同时，`a2` 收到 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sra SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sra_32_ba03eea6386b | L32 | 32 | 0x00006005 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sra_32_ba03eea6386b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sra_32_ba03eea6386b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sra_32_ba03eea6386b | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sra_32_ba03eea6386b | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sra_32_ba03eea6386b | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| sra_32_ba03eea6386b | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRA.asl -->
```asl
readonly func InstructionContractOperation_SRA()
    => ScalarOperation
begin
    return ScalarOperation_SRA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRA.asl -->
```asl
readonly func InstructionContractHandler_SRA()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftAmount_SRA(right: Word)
    => integer {0..63}
begin
    return UInt(right[5:0]);
end;

pure func InstructionContractResult_SRA(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SRA(right);
    let shifted = ASR(left, amount);
    return shifted;
end;

pure func InstructionContractIsWordOperation_SRA()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- The low six bits of the snapshotted SrcR select the shift amount 0 through 63; every higher SrcR bit is ignored for the amount.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- All SrcR values are legal; only its low six bits contribute to the shift amount.

## State effects

- Compute the arithmetic right shift using the low six bits of the snapshotted SrcR. The PTO_XLEN result is written unchanged.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRA raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- sra a0, a1, ->a2
- sra t#1, u#1, ->u
- sra zero, zero, ->zero
