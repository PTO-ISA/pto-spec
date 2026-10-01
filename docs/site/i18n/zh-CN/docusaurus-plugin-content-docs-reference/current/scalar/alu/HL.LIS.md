<!-- GENERATED FROM: asl/scalar/alu/HL.LIS.asl -->
# HL.LIS

**Normative ASL source:** `asl/scalar/alu/HL.LIS.asl`

HL.LIS sign-extends its split encoded 32-bit immediate to XLEN and publishes the result through RegDst.

## Normative identity {#PTO-INST-SCALAR-HL-LIS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-lis-purpose role=purpose -->
## HL.LIS 的作用

`HL.LIS` 物化一个有符号常数。它不编码任何源寄存器：唯一的操作数是立即数 `simm32` 和目标 `RegDst`。译码从两个片段重组立即数，把第 `31` 位符号扩展到第 `63` 位，并通过 `RegDst` 发布该值。成功执行会使 `TPC` 前进 `6` 字节。

设计要点：有符号性来自助记符而不是编码。`HL.LIS` 与 `HL.LIU` 携带相同的 `32` 个编码位，只在扩展方式上不同：`HL.LIS` 做符号扩展，结果落在 `-2147483648` 至 `2147483647`；`HL.LIU` 做零填充，可达 `4294967295`。

<!-- PTO-READER-BLOCK: scalar-hl-lis-mechanism role=mechanism -->
## 常数的形成方式

一个立即数片段携带值位 `19:0`，另一个携带第 `31:20` 位，因此重组的 `32` 位模式是精确的，每个模式都是已分配取值。发布值就是这个模式，其中第 `31` 位被复制到第 `63` 位。

设计要点：由于结果的第 `63` 位是立即数第 `31` 位的副本，`HL.LIS` 能物化最高 `PTO_XLEN` 位被置位的值，而且这个常数只需装在 `32` 个编码位里。发布之前不读取任何东西，因此发布值只是编码的函数。

<!-- PTO-READER-BLOCK: scalar-hl-lis-inputs role=inputs-outputs -->
## 输入与目标

- `simm32` 携带有符号 `32` 位值。
- `RegDst` 发布它：编码 `1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：本形式没有 `SrcL` 字段，因此不读取任何寄存器和队列项，目标也不可能与源别名。于是像 `RegDst=0` 这样的丢弃型目标会完成物化和 `TPC` 前进，同时让所有寄存器和队列状态保持原样。

<!-- PTO-READER-BLOCK: scalar-hl-lis-effects role=effects -->
## 效果与顺序

没有源读取需要与发布排序：值由指令位组装而成，然后写入所选目标。`T` 或 `U` 目标压入会让新值成为该队列的下标 `1`，并丢弃原来位于下标 `4` 的项；GPR 目标只写那一个寄存器。

发布之后是 `TPC` 前进 `6` 字节。`HL.LIS` 不访问内存，也不改变保留状态、描述符、数值状态、`Tile`、指令束、特权或分支目标状态。

<!-- PTO-READER-BLOCK: scalar-hl-lis-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `RegDst` 编码，以及 `32` 位字段的全部 `4294967296` 个立即数模式。

有两处可达的拒绝，按模型顺序如下。固定位不匹配任何形式的 `48` 位字在 `PC` 处引发 `Fault_IllegalInstruction`。不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。两者都先于目标效果和 `TPC` 前进。

设计要点：寄存器形式可能引发的第三处拒绝，即所选 `T` 或 `U` 源不可用，在这里不可达。本形式不编码源选择符，模型没有源选择符可测，而目标编码全部被目标映射接受。

`HL.LIS` 不增加算术异常：`32` 位值的符号扩展不会溢出。

<!-- PTO-READER-BLOCK: scalar-hl-lis-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当立即数位为 `0xFFFFFFFF` 时，`hl.lis -1, ->a0` 写入 `18446744073709551615`。当立即数位为 `0x7FFFFFFF` 时，`hl.lis 2147483647, ->a0` 写入 `2147483647`；`hl.lis 0, ->t` 把 `0` 作为最新的 `T` 项压入。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.lis simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lis_48_908853d6ef87 | HL48 | 48 | 0x0000000d000e / 0x0000007f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lis_48_908853d6ef87 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lis_48_908853d6ef87 | simm32 | 32 | signed | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_lis_48_908853d6ef87 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_lis_48_908853d6ef87 | simm32 | 32 | 0–4294967295 | none | none | signed split 32-bit immediate | Encoded zero materializes numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| simm32 | signed split 32-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.LIS.asl -->
```asl
readonly func InstructionContractOperation_HL_LIS() => ScalarOperation
begin
    return ScalarOperation_HL_LIS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.LIS.asl -->
```asl
readonly func InstructionContractHandler_HL_LIS() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongSigned;
end;

pure func InstructionContractResult_HL_LIS(
    encoded_immediate: bits(32))
    => Word
begin
    return MaterializeLongSigned(encoded_immediate);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded source, immediate, and explicit destination field is required; no field can be omitted.
- The mnemonic fixes immediate signedness, selected source width, and implicit-versus-explicit destination behavior.

## Legality

- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every encoded operand value is assigned; fixed encoding bits must match the canonical form.

## State effects

- Reassemble simm32 from its two encoded pieces and sign-extend bit 31 through XLEN.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot any Reg5 source before the destination effect.
- Publish the result, then advance TPC by the encoded instruction length.

## Exceptions

- Materialization is a total fixed-width operation and raises no arithmetic exception.
- A fixed-bit mismatch raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- hl.lis simm, ->{t, u, rd}
