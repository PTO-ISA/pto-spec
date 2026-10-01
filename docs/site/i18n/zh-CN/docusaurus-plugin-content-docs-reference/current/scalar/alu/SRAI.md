<!-- GENERATED FROM: asl/scalar/alu/SRAI.asl -->
# SRAI

**Normative ASL source:** `asl/scalar/alu/SRAI.asl`

SRAI performs an XLEN arithmetic right shift by a six-bit immediate.

## Normative identity {#PTO-INST-SCALAR-SRAI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-srai-purpose role=purpose -->
## SRAI 的作用

`SRAI` 按常量 `shamt`（`0` 到 `63`）对 `SrcL` 做算术右移，把符号位复制到空出的位置。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、六位的 `shamt` 位于 `[20 +: 6]`。

该载体在掩码 `0xfc00707f` 下匹配 `0x00006015`。

该助记符保持完整的 `PTO_XLEN` 宽度：被复制的符号位始终是第 `63` 位，没有任何字段选择更窄的宽度。

<!-- PTO-READER-BLOCK: scalar-srai-mechanism role=mechanism -->
## 移位形成方式

分派路径在 `asl/scalar/model/dispatch/alu.asl:196-197` 处以 `ScalarBinary_SRA` 调用 `ExecuteDecodedShiftImmediate`。译出的 `shamt` 成为右操作数，`ScalarBinary` 返回 `ASR(left, UInt(right[5:0]))`（`asl/scalar/model/alu/semantics.asl:458`）。

```asm
srai SrcL, shamt, ->{t, u, Rd}
```

设计要点：由于移位是 `64` 位算术移位，结果是该有符号值除以二的 `shamt` 次幂后的向下取整值，而不是向零截断的商。`SRAI` 对 `-1` 及 `1` 到 `63` 的任意移位量都发布 `-1`。

设计要点：移位量是编码中的常量，因此该移位是一种固定的字段提取：`shamt = 8` 时，发布值是把 `SrcL[63:8]` 当作有符号 `56` 位字段读取的结果，其高 `8` 位是 `SrcL[63]` 的副本。

<!-- PTO-READER-BLOCK: scalar-srai-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 是被移位的值，`shamt` 由载体译出，`RegDst` 接收结果。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，该读取永不消耗条目。
- `shamt`，指令切片 `[20 +: 6]`：`0` 到 `63`；编码零执行恒等移位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcL` 的编码零读取体系结构零 GPR，其符号位为零，因此任何移位量都发布 `0`。

设计要点：符号来源由形式固定，不可选择。需要更窄字段符号的程序必须先把该字段的最高位放到第 `63` 位，例如用一对移位，因为 `SRAI` 没有宽度选择子。

<!-- PTO-READER-BLOCK: scalar-srai-effects role=effects -->
## 效果与顺序

`SrcL` 在目标效果之前取快照，因此与源同名的目标对执行前的值移位。结果发布后 `TPC` 推进 `4` 字节。

`SRAI` 不访问内存，保留、描述符、数值标志、陷阱、指令束、特权、谓词与控制流状态都保持不变；唯一可能的队列移动是 `30` 或 `31` 目标所选的一次压入。

设计要点：该指令既不报告也不记录是否有比特被移出。它的全部体系结构效果就是发布的那一个字。

<!-- PTO-READER-BLOCK: scalar-srai-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码以及全部 `64` 个移位量都有定义，该形式除固定位 `31:26` 与 `14:12` 外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`，保留字段 `31:26` 中出现非零位也会被拒绝。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SRAI` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`。所有检查都先于目标效果与 `TPC` 推进。

设计要点：由于每个可编码的移位量都有定义结果，`SRAI` 没有由操作数选择的陷阱。除上述块适用性检查外，它的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-srai-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `-16` 时，`srai a0, 2, ->a2` 发布 `-4`。

当 `a0` 为 `0x00000000000000FF`、移位量为 `4` 时，结果是 `15`。当 `a0` 为 `-1` 时，`1` 到 `63` 的每个移位量都发布 `-1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
srai SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srai_32_e471ea84d4fd | L32 | 32 | 0x00006015 / 0xfc00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srai_32_e471ea84d4fd | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srai_32_e471ea84d4fd | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srai_32_e471ea84d4fd | shamt | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srai_32_e471ea84d4fd | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srai_32_e471ea84d4fd | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| srai_32_e471ea84d4fd | shamt | 6 | 0–63 | none | none | six-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| shamt | six-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRAI.asl -->
```asl
readonly func InstructionContractOperation_SRAI()
    => ScalarOperation
begin
    return ScalarOperation_SRAI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRAI.asl -->
```asl
readonly func InstructionContractHandler_SRAI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftWidth_SRAI()
    => integer {1..64}
begin
    return 6;
end;

pure func InstructionContractIsWordOperation_SRAI()
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

- Compute the XLEN arithmetic right shift ASR(SrcL, shamt), inserting copies of the source sign bit at the left.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRAI raises no arithmetic exception; shifted-out bits are discarded and copies of SrcL[PTO_XLEN-1] enter from the left.
- Bits 31:26 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- srai a0, 1, ->a0
- srai t#1, 63, ->u
- srai zero, 0, ->zero
