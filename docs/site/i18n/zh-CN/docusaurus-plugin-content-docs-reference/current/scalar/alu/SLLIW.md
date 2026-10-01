<!-- GENERATED FROM: asl/scalar/alu/SLLIW.asl -->
# SLLIW

**Normative ASL source:** `asl/scalar/alu/SLLIW.asl`

SLLIW performs a word logical left shift and sign-extends the result.

## Normative identity {#PTO-INST-SCALAR-SLLIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-slliw-purpose role=purpose -->
## SLLIW 的作用

`SLLIW` 按常量 `shamt`（`0` 到 `31`）对 `SrcL` 的低 `32` 位做逻辑左移，并发布符号扩展到 `PTO_XLEN` 的 `32` 位结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、五位的 `shamt` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00007035`；`31:25` 位是固定的，因此移位量恰好是五位宽。

结果通过符号扩展而不是零扩展重建，这就是置起第 `31` 位的移位会发布全一高半部的原因。

<!-- PTO-READER-BLOCK: scalar-slliw-mechanism role=mechanism -->
## 字结果形成方式

分派路径以 `ScalarBinary_SLL` 与为真的 `word_operation` 调用 `ExecuteDecodedShiftImmediate`（`asl/scalar/model/dispatch/alu.asl:190-191`）。`ScalarBinaryW` 把 `left32` 绑定为 `left[31:0]`，用 `UInt(right[4:0])` 移位，并返回 `SignExtend{PTO_XLEN}(result32)`（`asl/scalar/model/alu/semantics.asl:470-487`）。

```asm
slliw SrcL, shamt, ->{t, u, Rd}
```

设计要点：掩码与辅助函数在五位上一致：可编码的移位量是 `0` 到 `31`，而且辅助函数本来也会丢弃计数中更高的位。没有任何编码能请求整整一个字的移位。

设计要点：越过字位 `31` 的比特在符号扩展之前就被丢弃，因此不会在高半部重新出现。发布的高半部始终是结果第 `31` 位的副本。

<!-- PTO-READER-BLOCK: scalar-slliw-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 提供该字，`shamt` 由载体译出，`RegDst` 接收符号扩展后的字。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。只有 `SrcL[31:0]` 参与运算。
- `shamt`，指令切片 `[20 +: 5]`：`0` 到 `31`；编码零执行恒等字移位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcL` 的编码零读取体系结构零 GPR，因此源为零时发布 `0`。

设计要点：低字为 `1` 而高半部非零的源仍然只移位低字：当 `a0 = 0xFFFFFFFF00000001` 时，`slliw a0, 4, ->a2` 发布 `16`，因为源的高半部在移位之前就被丢弃。

<!-- PTO-READER-BLOCK: scalar-slliw-effects role=effects -->
## 效果与顺序

`SrcL` 在写入之前读取，因此同名目标对执行前的值移位。符号扩展后的字发布后 `TPC` 推进 `4` 字节。

`SLLIW` 不读内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权、谓词或控制流状态。唯一的队列移动是 `30` 或 `31` 目标所选的一次压入。

设计要点：收窄发生在移位之前而不是之后，因此 `SrcL` 高半部的比特永远不可能被移入结果。所以 `SLLIW` 是一个完整的字级操作，而不是先做 `PTO_XLEN` 移位再截断。

<!-- PTO-READER-BLOCK: scalar-slliw-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码、全部 `32` 个 `RegDst` 编码以及全部 `32` 个移位量都有定义。该形式除固定位 `31:25` 与 `14:12` 外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SLLIW` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：字级移位与最终的符号扩展都不会触发故障，因此 `SLLIW` 没有由操作数选择的陷阱。除上述块适用性检查外，它的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-slliw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `1` 时，`slliw a0, 4, ->a2` 发布 `16`。

当 `a0` 为 `1` 时，`slliw a0, 31, ->a2` 发布 `0xFFFFFFFF80000000`，因为字位 `31` 被置起，而最终的扩展把它复制到整个高半部。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
slliw SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| slliw_32_c6bf463b97ae | L32 | 32 | 0x00007035 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| slliw_32_c6bf463b97ae | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| slliw_32_c6bf463b97ae | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| slliw_32_c6bf463b97ae | shamt | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| slliw_32_c6bf463b97ae | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| slliw_32_c6bf463b97ae | SrcL | 5 | 0–31 | none | none | Reg5 source; low 32 bits used | Encoded zero reads the architectural zero GPR. |
| slliw_32_c6bf463b97ae | shamt | 5 | 0–31 | none | none | five-bit shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source; low 32 bits used |
| shamt | five-bit shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLLIW.asl -->
```asl
readonly func InstructionContractOperation_SLLIW()
    => ScalarOperation
begin
    return ScalarOperation_SLLIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLLIW.asl -->
```asl
readonly func InstructionContractHandler_SLLIW()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractShiftWidth_SLLIW()
    => integer {1..64}
begin
    return 5;
end;

pure func InstructionContractIsWordOperation_SLLIW()
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

- Compute the 32-bit logical left shift LSL(SrcL[31:0], shamt), then publish the 32-bit result sign-extended to XLEN.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect so aliases read the pre-instruction value.
- Publish the sign-extended word result, then advance TPC by four bytes.

## Exceptions

- SLLIW raises no arithmetic exception; shifted-out word bits are discarded and the final word is sign-extended to XLEN.
- Bits 31:25 are fixed zero. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- slliw a0, 1, ->a0
- slliw u#1, 31, ->t
- slliw zero, 0, ->zero
