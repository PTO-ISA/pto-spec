<!-- GENERATED FROM: asl/scalar/alu/SRLI.asl -->
# SRLI

**Normative ASL source:** `asl/scalar/alu/SRLI.asl`

SRLI performs an XLEN logical right shift by a six-bit immediate.

## Normative identity {#PTO-INST-SCALAR-SRLI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-srli-purpose role=purpose -->
## SRLI 的作用

`SRLI` 按常量 `shamt`（`0` 到 `63`）对 `SrcL` 做逻辑右移，在左侧插入零。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、六位的 `shamt` 位于 `[20 +: 6]`。

该载体在掩码 `0xfc00707f` 下匹配 `0x00005015`，因此 `31:26` 位是固定的，移位量使用其余全部六位。

固定移位量使该指令成为按已知距离的移位，这正是程序提取从常量位位置开始的字段所需要的。

<!-- PTO-READER-BLOCK: scalar-srli-mechanism role=mechanism -->
## 移位形成方式

分派路径在 `asl/scalar/model/dispatch/alu.asl:192-193` 处以 `ScalarBinary_SRL` 调用 `ExecuteDecodedShiftImmediate`。译出的 `shamt` 成为右操作数，`ScalarBinary` 返回 `LSR(left, UInt(right[5:0]))`（`asl/scalar/model/alu/semantics.asl:457`）。

```asm
srli SrcL, shamt, ->{t, u, Rd}
```

设计要点：由于移位量是常量，该移位从不读取计数寄存器，因此 `srli a0, 8, ->a2` 这一编码就是该操作的完整描述，不需要第二个源。发布值只取决于 `a0` 与编码。

设计要点：`shamt` 为 `63` 时，源的符号位被移到第 `0` 位，其余各位被清零。这是 `64` 位值最小的非零逻辑移位结果，而没有移位量能产生更彻底的清零，因为 `64` 无法编码。

<!-- PTO-READER-BLOCK: scalar-srli-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 是被移位的值，`shamt` 由载体译出，`RegDst` 接收结果。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，该读取永不消耗条目。
- `shamt`，指令切片 `[20 +: 6]`：`0` 到 `63`；编码零执行恒等移位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcL` 的编码零读取体系结构零 GPR，因此任何移位量都发布 `0`。

设计要点：移位量在汇编时固定，无法被重命名，而被移位的值从 Reg5 映射读取，可以来自队列槽位。因此该指令只需要一个寄存器操作数，但仍参与单层源/目标模型。

<!-- PTO-READER-BLOCK: scalar-srli-effects role=effects -->
## 效果与顺序

`SrcL` 在写入之前取快照，因此同名目标对执行前的值移位。结果发布后 `TPC` 推进 `4` 字节。

`SRLI` 不访问内存，保留、描述符、数值标志、陷阱、指令束、特权、谓词与控制流状态都保持不变；唯一可能的队列移动是 `30` 或 `31` 目标所选的一次压入。

设计要点：该指令清除源的高 `shamt` 位并保留其余部分。由于它没有掩码操作数，只需要保留中间字段的程序要使用一对移位，而不是一次带掩码的移位。

<!-- PTO-READER-BLOCK: scalar-srli-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码以及全部 `64` 个移位量都有定义；该形式除固定位 `31:26` 与 `14:12` 外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SRLI` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：每个可编码的移位量都有定义结果，逻辑移位也不会触发故障，因此 `SRLI` 没有依赖取值的陷阱路径。它的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-srli-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `16` 时，`srli a0, 2, ->a2` 发布 `4`。

当 `a0` 为 `-1` 时，`srli a0, 63, ->a2` 发布 `1`，因为源的符号位被移到第 `0` 位，而其余各位被清零。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
srli SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srli_32_dd29ca058cfe | L32 | 32 | 0x00005015 / 0xfc00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srli_32_dd29ca058cfe | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srli_32_dd29ca058cfe | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srli_32_dd29ca058cfe | shamt | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srli_32_dd29ca058cfe | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srli_32_dd29ca058cfe | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| srli_32_dd29ca058cfe | shamt | 6 | 0–63 | none | none | six-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| shamt | six-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRLI.asl -->
```asl
readonly func InstructionContractOperation_SRLI()
    => ScalarOperation
begin
    return ScalarOperation_SRLI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRLI.asl -->
```asl
readonly func InstructionContractHandler_SRLI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftWidth_SRLI()
    => integer {1..64}
begin
    return 6;
end;

pure func InstructionContractIsWordOperation_SRLI()
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

- Compute the XLEN logical right shift LSR(SrcL, shamt); discard low shifted-out bits and insert zero bits at the left.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRLI raises no arithmetic exception; shifted-out bits are discarded and zero bits enter from the left.
- Bits 31:26 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- srli a0, 1, ->a0
- srli t#1, 63, ->u
- srli zero, 0, ->zero
