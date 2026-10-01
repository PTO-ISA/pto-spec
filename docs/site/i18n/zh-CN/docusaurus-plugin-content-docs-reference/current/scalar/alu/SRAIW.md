<!-- GENERATED FROM: asl/scalar/alu/SRAIW.asl -->
# SRAIW

**Normative ASL source:** `asl/scalar/alu/SRAIW.asl`

SRAIW performs a word arithmetic right shift and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-SRAIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sraiw-purpose role=purpose -->
## SRAIW 的作用

`SRAIW` 按常量 `shamt`（`0` 到 `31`）对 `SrcL` 的低 `32` 位做算术右移，并发布符号扩展到 `PTO_XLEN` 的 `32` 位结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、五位的 `shamt` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00006035`，因此 `31:25` 位是固定的，移位量是五位。

被复制的符号是字的第 `31` 位，因为移位在最终扩展之前按 `32` 位宽度进行。

<!-- PTO-READER-BLOCK: scalar-sraiw-mechanism role=mechanism -->
## 字移位形成方式

分派路径以为真的 `word_operation` 调用 `ExecuteDecodedShiftImmediate`（`asl/scalar/model/dispatch/alu.asl:198-199`）。`ScalarBinaryW` 把 `left32` 绑定为 `left[31:0]`，执行 `ASR(left32, UInt(right[4:0]))`，并返回 `SignExtend{PTO_XLEN}(result32)`（`asl/scalar/model/alu/semantics.asl:483`）。

```asm
sraiw SrcL, shamt, ->{t, u, Rd}
```

设计要点：收窄发生在移位之前，因此即使 `SrcL` 的第 `63` 位不同，字的第 `31` 位仍是符号来源。低字为 `0x80000000` 的源移位后得到负字，而字位 `31` 为零的同一源移位后得到非负字。

设计要点：最终的符号扩展把负值恢复到完整宽度。字为 `0xFFFFFFF0`、移位量为 `1` 时，`SRAIW` 发布 `0xFFFFFFFFFFFFFFF8`，而不是 `0x00000000FFFFFFF8`。

<!-- PTO-READER-BLOCK: scalar-sraiw-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 提供该字，`shamt` 由载体译出，`RegDst` 接收符号扩展后的字。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。只有 `SrcL[31:0]` 参与运算。
- `shamt`，指令切片 `[20 +: 5]`：`0` 到 `31`；编码零执行恒等字移位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcL` 的编码零读取体系结构零 GPR，其字符号位为零，因此任何移位量都发布 `0`。

设计要点：只有当被移位的值已经是其低字的符号扩展时，字形式才与全宽度 `SRAI` 得到相同结果。对于 `0x00000000FFFFFFFF` 这样的取值，两种形式并不一致，因为 `SRAIW` 把它当作 `-1`，而 `SRAI` 把它当作一个很大的正数。

<!-- PTO-READER-BLOCK: scalar-sraiw-effects role=effects -->
## 效果与顺序

`SrcL` 在写入之前读取，因此同名目标对执行前的值移位。符号扩展后的字发布后 `TPC` 推进 `4` 字节。

`SRAIW` 不读内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权、谓词或控制流状态；仅当目标是 `30` 或 `31` 时临时队列才会移动。

设计要点：该指令只写入一个 `PTO_XLEN` 字，不记录其他内容。由于字级移位不可能产生超出有符号字范围的取值，发布的高半部始终是字位 `31` 的副本。

<!-- PTO-READER-BLOCK: scalar-sraiw-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码以及全部 `32` 个移位量都有定义；该形式除固定位 `31:25` 与 `14:12` 外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SRAIW` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：每个可编码的移位量都有定义的字结果，最终的扩展也不会触发故障，因此 `SRAIW` 没有依赖取值的陷阱路径。

<!-- PTO-READER-BLOCK: scalar-sraiw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `-16` 时，`sraiw a0, 2, ->a2` 发布 `-4`。

当 `a0` 为 `0x00000000FFFFFFF0`、移位量为 `1` 时，该字为负，因此 `a2` 收到 `0xFFFFFFFFFFFFFFF8`。当 `a0` 为 `0x00000000FFFFFFFF`、移位量为 `0` 时，`a2` 收到 `0xFFFFFFFFFFFFFFFF`，因为最终的扩展复制了字位 `31`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sraiw SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sraiw_32_db04a6299504 | L32 | 32 | 0x00006035 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sraiw_32_db04a6299504 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sraiw_32_db04a6299504 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sraiw_32_db04a6299504 | shamt | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sraiw_32_db04a6299504 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sraiw_32_db04a6299504 | SrcL | 5 | 0–31 | none | none | Reg5 source; low 32 bits used | Encoded zero reads the architectural zero GPR. |
| sraiw_32_db04a6299504 | shamt | 5 | 0–31 | none | none | five-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source; low 32 bits used |
| shamt | five-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRAIW.asl -->
```asl
readonly func InstructionContractOperation_SRAIW()
    => ScalarOperation
begin
    return ScalarOperation_SRAIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRAIW.asl -->
```asl
readonly func InstructionContractHandler_SRAIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftWidth_SRAIW()
    => integer {1..64}
begin
    return 5;
end;

pure func InstructionContractIsWordOperation_SRAIW()
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

- Compute the 32-bit arithmetic right shift ASR(SrcL[31:0], shamt), then publish the 32-bit result sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the sign-extended word result, then advance TPC by four bytes.

## Exceptions

- SRAIW raises no arithmetic exception; copies of SrcL[31] enter from the left and the final word is sign-extended to XLEN.
- Bits 31:25 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- sraiw a0, 1, ->a0
- sraiw u#1, 31, ->t
- sraiw zero, 0, ->zero
