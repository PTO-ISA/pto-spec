<!-- GENERATED FROM: asl/scalar/alu/SLL.asl -->
# SLL

**Normative ASL source:** `asl/scalar/alu/SLL.asl`

SLL performs a logical left shift of the PTO_XLEN source by the low six bits of the snapshotted SrcR; the XLEN result is published directly.

## Normative identity {#PTO-INST-SCALAR-SLL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-sll-purpose role=purpose -->
## SLL 的作用

`SLL` 按取自 `SrcR` 低六位的移位量对 `SrcL` 做逻辑左移，并发布完整的 `PTO_XLEN` 结果。它恰好有三个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`SrcR` 位于 `[20 +: 5]`。

该载体在掩码 `0xfe00707f` 下匹配 `0x00007005`。这里没有 `shamt` 字段，也没有修饰字段，因此移位量是寄存器取值而不是常量。

`SrcR` 的第 `5:0` 位承载移位量；更高的位对移位被忽略，但仍属于源操作数。

<!-- PTO-READER-BLOCK: scalar-sll-mechanism role=mechanism -->
## 移位形成方式

分派路径以 `ScalarBinary_SLL` 与为假的 `word_operation` 调用 `ExecuteDecodedSimpleBinary`（`asl/scalar/model/dispatch/alu.asl:176-177`）。`ScalarBinary` 返回 `LSL(left, UInt(right[5:0]))`（`asl/scalar/model/alu/semantics.asl:456`），因此移位量是快照后右源的低六位，左操作数按完整宽度移位。

```asm
sll SrcL, SrcR, ->{t, u, Rd}
```

设计要点：把移位量掩码到六位意味着每个原始 `SrcR` 取值都合法，没有任何移位量会被拒绝。低六位为 `0` 的右源即使高位非零也执行恒等移位。

设计要点：被移出第 `PTO_XLEN-1` 位的比特被丢弃，零比特从右侧进入。辅助函数不报告被丢弃的比特，因此 `SLL` 无法表明信息已丢失。

<!-- PTO-READER-BLOCK: scalar-sll-inputs role=inputs-outputs -->
## 输入与目标

两个操作数都使用 Reg5 源映射，结果通过 Reg5 目标映射发布。

- `SrcL`，指令切片 `[15 +: 5]`：被移位的值；`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，非消耗。
- `SrcR`，指令切片 `[20 +: 5]`：移位计数源，使用同样的五位映射。每个取值都合法；只使用第 `5:0` 位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。
- `SrcR` 的编码零读取体系结构零 GPR，它提供移位量 `0`，因此是恒等移位。

设计要点：从 `T` 或 `U` 队列槽位选取的 `SrcR` 读取时不消耗，因此同一个计数可以驱动多次移位。只有 `30` 或 `31` 目标才会压入新的队列条目。

<!-- PTO-READER-BLOCK: scalar-sll-effects role=effects -->
## 效果与顺序

两个源都在写目标之前取快照，因此与 `SrcL` 或 `SrcR` 同名的目标对执行前的值移位。结果发布后 `TPC` 推进 `4` 字节。

`SLL` 不读内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权、谓词或控制流状态。唯一的队列移动是 `30` 或 `31` 目标所选的一次压入。

设计要点：移位量来自寄存器，因此可以在运行时计算，但它也会随 `SrcR` 一起被重命名：`31` 目标写入 `T` 队列的是移位结果，而不是移位量。

<!-- PTO-READER-BLOCK: scalar-sll-constraints role=constraints -->
## 合法性与故障边界

每个 `SrcL`、`SrcR` 与 `RegDst` 编码都有定义，除固定载体位外没有约束条目。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `SLL` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：移位计数是全定义的：掩码到六位覆盖 `0` 到 `63`，移位本身不会触发故障。`SLL` 中没有任何操作数取值会选择陷阱。

<!-- PTO-READER-BLOCK: scalar-sll-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `1`、`a1` 为 `4` 时，`sll a0, a1, ->a2` 发布 `16`。

当 `a0` 为 `1`、`a1` 为 `64` 时，移位量的低六位是 `0`，因此 `a2` 原样收到 `1`；计数为 `63` 时发布 `0x8000000000000000`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
sll SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sll_32_a100b8961e21 | L32 | 32 | 0x00007005 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sll_32_a100b8961e21 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| sll_32_a100b8961e21 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sll_32_a100b8961e21 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| sll_32_a100b8961e21 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| sll_32_a100b8961e21 | SrcL | 5 | 0–31 | none | none | Reg5 value source | Encoded zero reads the architectural zero GPR. |
| sll_32_a100b8961e21 | SrcR | 5 | 0–31 | none | none | Reg5 shift-count source | Encoded zero reads zero and therefore selects shift amount zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 value source |
| SrcR | Reg5 shift-count source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SLL.asl -->
```asl
readonly func InstructionContractOperation_SLL()
    => ScalarOperation
begin
    return ScalarOperation_SLL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SLL.asl -->
```asl
readonly func InstructionContractHandler_SLL()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractShiftAmount_SLL(right: Word)
    => integer {0..63}
begin
    return UInt(right[5:0]);
end;

pure func InstructionContractResult_SLL(left: Word, right: Word)
    => Word
begin
    let amount = InstructionContractShiftAmount_SLL(right);
    let shifted = LSL(left, amount);
    return shifted;
end;

pure func InstructionContractIsWordOperation_SLL()
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

- Compute the logical left shift using the low six bits of the snapshotted SrcR. The PTO_XLEN result is written unchanged.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, flag, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so aliases and T/U publication use pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- SLL raises no arithmetic exception; shifted-out bits are discarded.
- An unavailable T/U source raises Fault_IllegalInstruction before the destination effect and successful TPC advance.

## Examples

- sll a0, a1, ->a2
- sll t#1, u#1, ->u
- sll zero, zero, ->zero
