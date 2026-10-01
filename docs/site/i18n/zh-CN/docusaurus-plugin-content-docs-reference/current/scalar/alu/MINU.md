<!-- GENERATED FROM: asl/scalar/alu/MINU.asl -->
# MINU

**Normative ASL source:** `asl/scalar/alu/MINU.asl`

MINU performs an unsigned full-XLEN comparison and publishes the complete bit pattern of the minimum operand.

## Normative identity {#PTO-INST-SCALAR-MINU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-minu-purpose role=purpose -->
## MINU 的作用

`MINU` 是一条 32 位编码的标量 ALU 指令，它把两个 XLEN 值按无符号整数比较，并通过一个 Reg5 目标原样发布其中较小的那个。

比较使用全部 `64` 位，因此第 `63` 位被置位的源是大的值而不是负值，除非另一个操作数不小于它，它绝不会被选为最小值。

<!-- PTO-READER-BLOCK: scalar-minu-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_MINU`：当 `UInt(left) < UInt(right)` 时返回 `left`，否则返回 `right`；并提供返回假的 `InstructionContractUsesSignedComparison_MINU`。分派路径通过 `ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_MINU, FALSE)` 到达同一个辅助函数。

```asm
minu SrcL, SrcR, ->{t, u, Rd}
```

设计要点：`MIN` 与 `MINU` 共用该辅助函数，只在比较模式上不同，因此 `SrcL = 0xFFFFFFFFFFFFFFFF`、`SrcR = 0` 这一对在 `MIN` 下选择 `SrcL`，在 `MINU` 下选择 `SrcR`。两个结果都是同一个字 `0` 或同一个全 1 字；中间值不会被算出。

<!-- PTO-READER-BLOCK: scalar-minu-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[7 +: 5]`，接收被选中的操作数，或丢弃它。
- `SrcL`，指令切片 `[15 +: 5]`，提供左操作数。
- `SrcR`，指令切片 `[20 +: 5]`，提供右操作数。

源使用通用 Reg5 映射：`0..23` 为绝对 GPR，`24..27` 为 `T#1..T#4`，`28..31` 为 `U#1..U#4`，非消耗读取。编码零读取体系结构零 GPR。

设计要点：两个操作数都只被读取，因此编码零源贡献常量 `0` 而不带任何数据依赖。所以无论另一个操作数是什么，与零源比较的 `minu` 都会通过目标映射发布 `0`，目标为队列推送时也是如此。

<!-- PTO-READER-BLOCK: scalar-minu-effects role=effects -->
## 效果与顺序

两个源都在目标效果之前取快照，因此与其中之一同名的目标收到的仍是从执行前操作数中选出的值。

被选中的操作数通过 `RegDst` 发布，随后 `TPC` 前进 `4` 字节。不访问内存，不设置数值标志，保留、描述符、指令束、特权与控制流状态都不改变；只有目标选择的队列推送能改动队列。

<!-- PTO-READER-BLOCK: scalar-minu-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码与每个 `32` 编码的目标编码都有定义，每个 XLEN 位模式都是合法操作数，因此只有临时源不可用会使操作数检查失败。指令第 `31:25` 位与 `14:12` 位由所接受的形式固定。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。

设计要点：无符号比较没有算术，也没有符号拐角，因此没有任何操作数对能把故障从编码匹配或源可用性检查挪到操作本身。这对有符号最小值输入与其他任何字同样成立。

<!-- PTO-READER-BLOCK: scalar-minu-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 4`、`SrcR = 7` 时 `RegDst` 收到 `4`。取 `SrcL = 0xFFFFFFFFFFFFFFFF`、`SrcR = 0` 时无符号比较为假，因此 `RegDst` 收到 `0`。取 `SrcL = SrcR = 0x8000000000000000` 时比较为假，`RegDst` 收到右操作数，它携带相同的位模式。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
minu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| minu_32_9bdb71ef7b19 | L32 | 32 | 0x0800505b / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| minu_32_9bdb71ef7b19 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| minu_32_9bdb71ef7b19 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| minu_32_9bdb71ef7b19 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| minu_32_9bdb71ef7b19 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| minu_32_9bdb71ef7b19 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| minu_32_9bdb71ef7b19 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MINU.asl -->
```asl
readonly func InstructionContractOperation_MINU()
    => ScalarOperation
begin
    return ScalarOperation_MINU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MINU.asl -->
```asl
readonly func InstructionContractHandler_MINU()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_MINU(left: Word, right: Word)
    => Word
begin
    if UInt(left) < UInt(right) then
        return left;
    else
        return right;
    end;
end;

pure func InstructionContractUsesSignedComparison_MINU()
    => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- Encoded source zero reads the architectural zero GPR; encoded destination zero discards the result.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- The operands use an unsigned full-XLEN comparison; every XLEN bit pattern is legal.

## State effects

- Perform an unsigned full-XLEN comparison and return the complete bit pattern of the minimum operand; equal operands are observationally identical.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so repeated sources, destination aliases, and queue publication use pre-instruction values.
- Publish the selected operand, then advance TPC by four bytes.

## Exceptions

- MINU raises no arithmetic exception; comparison selects one unchanged operand bit pattern.
- Bits 31:25 are fixed by the accepted form. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- minu a0, a1, ->a2
- minu t#1, u#1, ->u
- minu zero, zero, ->zero
