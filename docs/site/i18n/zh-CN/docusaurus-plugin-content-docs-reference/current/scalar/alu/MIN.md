<!-- GENERATED FROM: asl/scalar/alu/MIN.asl -->
# MIN

**Normative ASL source:** `asl/scalar/alu/MIN.asl`

MIN performs a signed full-XLEN comparison and publishes the complete bit pattern of the minimum operand.

## Normative identity {#PTO-INST-SCALAR-MIN}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-min-purpose role=purpose -->
## MIN 的作用

`MIN` 是一条 32 位编码的标量 ALU 指令，它把两个 XLEN 值按有符号整数比较，并通过一个 Reg5 目标原样发布其中较小的那个。

与 `MAX` 一样，结果是操作数位模式之一而不是计算值，并且比较使用每个源的全部 `64` 位。

<!-- PTO-READER-BLOCK: scalar-min-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_MIN`：当 `SInt(left) < SInt(right)` 时返回 `left`，否则返回 `right`；并提供返回真的 `InstructionContractUsesSignedComparison_MIN`。分派路径通过 `ExecuteDecodedSimpleBinary(instruction, form, ScalarBinary_MIN, FALSE)` 到达同一个辅助函数。

```asm
min SrcL, SrcR, ->{t, u, Rd}
```

设计要点：最小值按有符号读法取得，因此它与「清零高位」不是一回事。取 `SrcL = 0xFFFFFFFFFFFFFFFF`、`SrcR = 0` 得到 `SrcL`，因为 `-1 < 0`，尽管两者都按无符号读时 `SrcR` 才是更小的字。

<!-- PTO-READER-BLOCK: scalar-min-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[7 +: 5]`，接收被选中的操作数，或丢弃它。
- `SrcL`，指令切片 `[15 +: 5]`，提供左操作数。
- `SrcR`，指令切片 `[20 +: 5]`，提供右操作数。

两个源都使用通用 Reg5 映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4` 且不消耗表项。编码零读取体系结构零 GPR。

设计要点：只有两个 5 位源字段进入比较；该形式不带立即数、修饰或移位字段。因此与常量比较的 `MIN` 需要把该常量放进寄存器，而该寄存器可以是从队列读到的临时项。

<!-- PTO-READER-BLOCK: scalar-min-effects role=effects -->
## 效果与顺序

两个源在目标效果之前取快照。向某个源刚刚读取的同一队列推送目标，会发布被选中的操作数，而不会扰动被读取的那个表项。

被选中的操作数通过 `RegDst` 写入，随后 `TPC` 前进 `4` 字节。该指令没有内存效果，没有数值状态效果，也不影响保留、描述符、指令束、特权与控制流状态。

<!-- PTO-READER-BLOCK: scalar-min-constraints role=constraints -->
## 合法性与故障边界

每个 `32` 编码的源编码与每个 `32` 编码的目标编码都有定义，每个 XLEN 位模式都合法，因此只有临时源不可用会使操作数检查失败。指令第 `31:25` 位与 `14:12` 位由所接受的形式固定。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。

设计要点：故障面与 `MAX` 完全相同，因为两个助记符共用选择辅助函数，只在比较算子上不同。不存在某个操作数对会让其中之一按值触发故障而另一个不触发。

<!-- PTO-READER-BLOCK: scalar-min-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 0xFFFFFFFFFFFFFFFF`、`SrcR = 0` 时有符号值为 `-1` 与 `0`，因此 `RegDst` 收到 `0xFFFFFFFFFFFFFFFF`。取 `SrcL = 4`、`SrcR = 7` 时 `RegDst` 收到 `4`。取 `SrcL = SrcR = 0x8000000000000000` 时严格比较为假，`RegDst` 收到右操作数，其位模式完全相同。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
min SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| min_32_25692b799267 | L32 | 32 | 0x0000505b / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| min_32_25692b799267 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| min_32_25692b799267 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| min_32_25692b799267 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| min_32_25692b799267 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| min_32_25692b799267 | SrcL | 5 | 0–31 | none | none | left Reg5 source | Encoded zero reads the architectural zero GPR. |
| min_32_25692b799267 | SrcR | 5 | 0–31 | none | none | right Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | left Reg5 source |
| SrcR | right Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MIN.asl -->
```asl
readonly func InstructionContractOperation_MIN()
    => ScalarOperation
begin
    return ScalarOperation_MIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MIN.asl -->
```asl
readonly func InstructionContractHandler_MIN()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractResult_MIN(left: Word, right: Word)
    => Word
begin
    if SInt(left) < SInt(right) then
        return left;
    else
        return right;
    end;
end;

pure func InstructionContractUsesSignedComparison_MIN()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required fields; no field can be omitted.
- Encoded source zero reads the architectural zero GPR; encoded destination zero discards the result.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs.
- The operands use a signed full-XLEN comparison; every XLEN bit pattern is legal.

## State effects

- Perform a signed full-XLEN comparison and return the complete bit pattern of the minimum operand; equal operands are observationally identical.
- Destination codes 0 and 24..29 discard, code 30 pushes U, code 31 pushes T, and codes 1..23 write GPRs; source queues are non-consuming.
- No memory, reservation, descriptor, numeric-flag, trap, block, privilege, or control-flow state changes except the successful TPC advance.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so repeated sources, destination aliases, and queue publication use pre-instruction values.
- Publish the selected operand, then advance TPC by four bytes.

## Exceptions

- MIN raises no arithmetic exception; comparison selects one unchanged operand bit pattern.
- Bits 31:25 are fixed by the accepted form. A mismatch or unavailable T/U source raises Fault_IllegalInstruction before the destination effect and TPC advance.

## Examples

- min a0, a1, ->a2
- min t#1, u#1, ->u
- min zero, zero, ->zero
