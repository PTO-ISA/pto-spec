<!-- GENERATED FROM: asl/scalar/alu/SLLI.asl -->
# SLLI

**Normative ASL source:** `asl/scalar/alu/SLLI.asl`

SLLI performs an XLEN logical left shift by a six-bit immediate.

## Normative identity {#PTO-INST-SCALAR-SLLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-slli-purpose role=purpose -->
## SLLI 的作用

`SLLI` 按常量 `shamt`（`0` 到 `63`）对 `SrcL` 做逻辑左移，并发布完整的 `PTO_XLEN` 结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、六位的 `shamt` 位于 `[20 +: 6]`。

该载体在掩码 `0xfc00707f` 下匹配 `0x00007015`。掩码固定了 `31:26` 位，即移位量正上方的六位，因此 `shamt` 没有任何保留位。

`SLLI` 与 `SLL` 计算同一个函数；区别在于移位量属于指令本身，而不是第二个寄存器。

<!-- PTO-READER-BLOCK: scalar-slli-mechanism role=mechanism -->
## 移位形成方式

分派路径在 `asl/scalar/model/dispatch/alu.asl:188-189` 处以 `ScalarBinary_SLL` 调用 `ExecuteDecodedShiftImmediate`。该路径读取 `SrcL`，用 `ScalarDecodedWord` 把六位字段译成一个字，并调用 `ScalarBinary(ScalarBinary_SLL, left, amount)`，也就是 `LSL(left, UInt(right[5:0]))`（`asl/scalar/model/alu/semantics.asl:456`）。

```asm
slli SrcL, shamt, ->{t, u, Rd}
```

设计要点：立即数路径把译出的 `shamt` 通过与寄存器形式相同的六位掩码，因此 `shamt` 为 `64` 无法编码，`shamt` 为 `63` 是最大移位量。每个可编码的移位量都合法。

设计要点：被移出第 `63` 位的比特被丢弃，零比特从右侧进入，因此 `SLLI` 无法保留离开该字的信息。发布的结果始终只是 `SrcL` 与编码移位量的函数。

<!-- PTO-READER-BLOCK: scalar-slli-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 是被移位的值，`shamt` 由载体译出，`RegDst` 接收结果。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，该读取不消耗队列条目。
- `shamt`，指令切片 `[20 +: 6]`：从 `0` 到 `63` 的每个取值都合法，编码零执行恒等移位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcL` 的编码零读取体系结构零 GPR，因此源为零时任何移位量都发布 `0`。

设计要点：由于移位量是编码的，它无法被重命名或压入队列。需要在运行时改变移位量的程序要用 `SLL` 和寄存器，而 `SLLI` 在指令流中固定一个移位量。

<!-- PTO-READER-BLOCK: scalar-slli-effects role=effects -->
## 效果与顺序

`SrcL` 在写目标之前取快照，因此同名目标对执行前的值移位。结果发布后 `TPC` 推进 `4` 字节。

`SLLI` 不访问内存，保留、描述符、数值标志、陷阱、指令束、特权、谓词与控制流状态都保持不变；唯一可能的队列移动是 `30` 或 `31` 目标所选的一次压入。

设计要点：该指令是一个寄存器与其自身编码的纯函数，因此可以在不占用第二个寄存器保存计数的前提下构造形如 `1 << k` 的掩码。

<!-- PTO-READER-BLOCK: scalar-slli-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码以及全部 `64` 个移位量都有定义。除固定位 `31:26` 与 `14:12` 外，该形式没有约束。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`，保留的高位就是这样被拒绝的。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SLLI` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`。每项检查都先于目标效果与 `TPC` 推进。

设计要点：越界的移位量不是非法指令；它根本无法编码。固定位 `31:26` 必须为零，因此表达超过 `63` 的移位的方式根本不存在。

<!-- PTO-READER-BLOCK: scalar-slli-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `1` 时，`slli a0, 4, ->a2` 发布 `16`，`slli a0, 0, ->a2` 发布 `1`。

当 `a0` 为 `1` 时，`slli a0, 63, ->a2` 发布 `0x8000000000000000`。当 `a0` 为 `0xFFFFFFFFFFFFFFFF` 时，`slli a0, 4, ->a2` 发布 `0xFFFFFFFFFFFFFFF0`，因为四个一比特从顶部离开了该字。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
slli SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| slli_32_b43ca2454e3a | L32 | 32 | 0x00007015 / 0xfc00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| slli_32_b43ca2454e3a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| slli_32_b43ca2454e3a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| slli_32_b43ca2454e3a | shamt | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| slli_32_b43ca2454e3a | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| slli_32_b43ca2454e3a | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| slli_32_b43ca2454e3a | shamt | 6 | 0–63 | none | none | six-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| shamt | six-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLLI.asl -->
```asl
readonly func InstructionContractOperation_SLLI()
    => ScalarOperation
begin
    return ScalarOperation_SLLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLLI.asl -->
```asl
readonly func InstructionContractHandler_SLLI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftWidth_SLLI()
    => integer {1..64}
begin
    return 6;
end;

pure func InstructionContractIsWordOperation_SLLI()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, shamt, and RegDst are required fields; no field can be omitted.
- shamt is a 6-bit shift amount from 0 through 63. Encoded zero performs an identity shift.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- Every 6-bit shift amount from 0 through 63 is legal.

## State effects

- Compute the XLEN logical left shift LSL(SrcL, shamt); discard bits shifted beyond bit PTO_XLEN-1 and insert zero bits at the right.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SLLI raises no arithmetic exception; shifted-out bits are discarded and zero bits enter from the right.
- Bits 31:26 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- slli a0, 1, ->a0
- slli t#1, 63, ->u
- slli zero, 0, ->zero
