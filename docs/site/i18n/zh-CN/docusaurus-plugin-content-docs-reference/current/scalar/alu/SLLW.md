<!-- GENERATED FROM: asl/scalar/alu/SLLW.asl -->
# SLLW

**Normative ASL source:** `asl/scalar/alu/SLLW.asl`

SLLW performs a logical left shift of the low 32-bit source by the low five bits of the snapshotted SrcR; the 32-bit result is sign-extended to XLEN.

## Normative identity {#PTO-INST-SCALAR-SLLW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sllw-purpose role=purpose -->
## SLLW 的作用

`SLLW` 按取自 `SrcR` 低五位的移位量对 `SrcL` 的低 `32` 位做逻辑左移，并发布符号扩展到 `PTO_XLEN` 的 `32` 位结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00007025`，并分派到 `ScalarBinaryW`。

字形式使用五位计数位，与该字的宽度一致，因此可编码的最大移位是 `31`。

<!-- PTO-READER-BLOCK: scalar-sllw-mechanism role=mechanism -->
## 字移位形成方式

分派路径以 `ScalarBinary_SLL` 与为真的 `word_operation` 调用 `ExecuteDecodedSimpleBinary`（`asl/scalar/model/dispatch/alu.asl:178-179`）。`ScalarBinaryW` 把 `left32` 绑定为 `left[31:0]`、把 `right32` 绑定为 `right[31:0]`，用 `LSL(left32, UInt(right[4:0]))` 移位，并返回 `SignExtend{PTO_XLEN}(result32)`（`asl/scalar/model/alu/semantics.asl:481`）。

```asm
sllw SrcL, SrcR, ->{t, u, Rd}
```

设计要点：只有 `SrcR` 的低五位成为移位量。因此保存 `32` 的计数寄存器移 `0` 位，因为 `32` 是 `0b100000`，第 `5` 位在所使用字段之外；移位不可能超过 `31`。

设计要点：移位在符号扩展之前作用于该字，因此离开第 `31` 位的比特就此消失，发布值的高半部是结果第 `31` 位的副本。

<!-- PTO-READER-BLOCK: scalar-sllw-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 是被移位的值，`SrcR` 提供计数，`RegDst` 接收符号扩展后的字。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。只有 `SrcL[31:0]` 参与运算。
- `SrcR`，指令切片 `[20 +: 5]`：计数源，使用同样的五位映射。每个取值都合法；只使用第 `4:0` 位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcR` 的编码零读取体系结构零 GPR，它提供移位量 `0`。

设计要点：由于计数被掩码到五位，而不是由另一条规则对字宽取模，计数 `33` 移 `1` 位。计数是原始位模式，该指令不会把它与 `32` 比较。

<!-- PTO-READER-BLOCK: scalar-sllw-effects role=effects -->
## 效果与顺序

两个源都在写入之前取快照，因此与任一源同名的目标对执行前的值移位。结果发布后 `TPC` 推进 `4` 字节。

`SLLW` 不访问内存，保留、描述符、数值标志、陷阱、指令束、特权、谓词与控制流状态都保持不变；仅当目标是 `30` 或 `31` 时临时队列才会移动。

设计要点：`SLLW` 不记录数值状态。被丢弃的字高位不会留下痕迹，因此需要知道是否丢失信息的调用者必须自行比较取值。

<!-- PTO-READER-BLOCK: scalar-sllw-constraints role=constraints -->
## 合法性与故障边界

每个 `SrcL`、`SrcR` 与 `RegDst` 编码都有定义，该形式除固定载体位外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SLLW` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`。所有检查都先于目标效果与 `TPC` 推进。

设计要点：字级移位与符号扩展对每个操作数取值都是全定义的，因此没有任何操作数取值会在 `SLLW` 中选择陷阱；除上述块适用性检查外，它的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-sllw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `1`、`a1` 为 `4` 时，`sllw a0, a1, ->a2` 发布 `16`。

当 `a0` 为 `1`、`a1` 为 `33` 时，移位量收窄到低五位，即 `1`，因此 `a2` 收到 `2`。当低字源为 `0x80000000`、计数为 `1` 时，字结果是 `0`，`a2` 收到 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sllw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sllw_32_a37b63c16b27 | L32 | 32 | 0x00007025 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sllw_32_a37b63c16b27 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sllw_32_a37b63c16b27 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sllw_32_a37b63c16b27 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sllw_32_a37b63c16b27 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sllw_32_a37b63c16b27 | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| sllw_32_a37b63c16b27 | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLLW.asl -->
```asl
readonly func InstructionContractOperation_SLLW()
    => ScalarOperation
begin
    return ScalarOperation_SLLW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLLW.asl -->
```asl
readonly func InstructionContractHandler_SLLW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftAmount_SLLW(right: Word)
    => integer {0..31}
begin
    return UInt(right[4:0]);
end;

pure func InstructionContractResult_SLLW(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SLLW(right);
    let shifted = LSL(left[31:0], amount);
    return SignExtend{PTO_XLEN}(shifted);
end;

pure func InstructionContractIsWordOperation_SLLW()
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

- Compute the logical left shift using the low five bits of the snapshotted SrcR. The low 32-bit result is sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SLLW raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- sllw a0, a1, ->a2
- sllw t#1, u#1, ->u
- sllw zero, zero, ->zero
