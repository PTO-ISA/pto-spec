<!-- GENERATED FROM: asl/scalar/alu/SRL.asl -->
# SRL

**Normative ASL source:** `asl/scalar/alu/SRL.asl`

SRL performs a logical right shift of the PTO_XLEN source by the low six bits of the snapshotted SrcR; the XLEN result is published directly.

## Normative identity {#PTO-INST-SCALAR-SRL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-srl-purpose role=purpose -->
## SRL 的作用

`SRL` 按 `SrcR` 低六位给出的移位量对 `SrcL` 做逻辑右移，在左侧插入零比特，并发布完整的 `PTO_XLEN` 结果。它有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00005005`。

逻辑右移是无符号位模式的保值移位：不涉及符号位，每个空出的位置都填零。

<!-- PTO-READER-BLOCK: scalar-srl-mechanism role=mechanism -->
## 移位形成方式

分派路径通过 `ExecuteDecodedSimpleBinary` 调用 `ScalarBinary(ScalarBinary_SRL, left, right)`（`asl/scalar/model/dispatch/alu.asl:180-181`）。该辅助函数返回 `LSR(left, UInt(right[5:0]))`（`asl/scalar/model/alu/semantics.asl:457`）。

```asm
srl SrcL, SrcR, ->{t, u, Rd}
```

设计要点：逻辑右移把负值的第 `63` 位搬进低位，因此对负源执行 `SRL` 等同于对一个大无符号数移位。`SrcL` 为 `-1`、计数为 `1` 时，`SRL` 发布 `0x7FFFFFFFFFFFFFFF`。

设计要点：计数掩码把移位限制在 `PTO_XLEN` 字内。计数 `64` 提供零并原样返回源，因此程序无法用 `SRL` 清空整个字。

<!-- PTO-READER-BLOCK: scalar-srl-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 是被移位的值，`SrcR` 提供计数，`RegDst` 接收结果。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。
- `SrcR`，指令切片 `[20 +: 5]`：计数源，同样的映射；每个取值都合法，只使用第 `5:0` 位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcR` 的编码零读取体系结构零 GPR，它提供移位量 `0`，因此是恒等移位。

设计要点：结果的最高位可能变成零，而 `SRL` 不为此记录任何数值状态。需要知道源是否足够小的调用者必须自行比较源或结果。

<!-- PTO-READER-BLOCK: scalar-srl-effects role=effects -->
## 效果与顺序

两个源都在写目标之前读取，因此同名目标观察到的是执行前的值。结果发布后 `TPC` 推进 `4` 字节。

`SRL` 不读内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权、谓词或控制流状态。仅当目标是 `30` 或 `31` 时它才会移动临时队列。

设计要点：`SRL` 移位的是完整的 `PTO_XLEN` 取值，而不是一个字，并且发布时不做任何符号扩展。低六位非零的计数会清零第 `63` 位，因此这样的结果永远不会为负。低六位为 `0` 的计数保持源不变，因此为负的源也可能原样发布：`SrcL` 为 `-1`、计数为 `1` 时，`srl` 发布 `0x7FFFFFFFFFFFFFFF`。

<!-- PTO-READER-BLOCK: scalar-srl-constraints role=constraints -->
## 合法性与故障边界

Reg5 域中的每个源编码与每个目标编码都有定义，该形式除固定载体位外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SRL` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：计数字段与移位都是全定义的，因此 `SRL` 没有由操作数选择的陷阱。它的故障边界是编码有效性加上源可用性。

<!-- PTO-READER-BLOCK: scalar-srl-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `16`、`a1` 为 `2` 时，`srl a0, a1, ->a2` 发布 `4`。

当 `a0` 为 `-1`、`a1` 为 `1` 时，`a2` 收到 `0x7FFFFFFFFFFFFFFF`。当 `a1` 为 `64` 时，计数的低六位是 `0`，`a2` 原样收到 `-1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
srl SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srl_32_5cfca42c59f3 | L32 | 32 | 0x00005005 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srl_32_5cfca42c59f3 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srl_32_5cfca42c59f3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srl_32_5cfca42c59f3 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| srl_32_5cfca42c59f3 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| srl_32_5cfca42c59f3 | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| srl_32_5cfca42c59f3 | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRL.asl -->
```asl
readonly func InstructionContractOperation_SRL()
    => ScalarOperation
begin
    return ScalarOperation_SRL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRL.asl -->
```asl
readonly func InstructionContractHandler_SRL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftAmount_SRL(right: Word)
    => integer {0..63}
begin
    return UInt(right[5:0]);
end;

pure func InstructionContractResult_SRL(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SRL(right);
    let shifted = LSR(left, amount);
    return shifted;
end;

pure func InstructionContractIsWordOperation_SRL()
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

- Compute the logical right shift using the low six bits of the snapshotted SrcR. The PTO_XLEN result is written unchanged.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SRL raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- srl a0, a1, ->a2
- srl t#1, u#1, ->u
- srl zero, zero, ->zero
