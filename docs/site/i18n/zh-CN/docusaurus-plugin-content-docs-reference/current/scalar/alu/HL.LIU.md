<!-- GENERATED FROM: asl/scalar/alu/HL.LIU.asl -->
# HL.LIU

**Normative ASL source:** `asl/scalar/alu/HL.LIU.asl`

HL.LIU zero-extends its split encoded 32-bit immediate to XLEN and publishes the result through RegDst.

## Normative identity {#PTO-INST-SCALAR-HL-LIU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-liu-purpose role=purpose -->
## HL.LIU 的作用

`HL.LIU` 物化一个无符号常数。它不编码任何源寄存器。译码从两个片段重组 `uimm32` 立即数，把第 `31` 位以上的每个结果位零填充，并通过 `RegDst` 发布该值。成功执行会使 `TPC` 前进 `6` 字节。

设计要点：零填充是无条件的，因此本助记符的任何结果都不会在第 `31` 位以上置位，每个发布值都落在 `0` 至 `4294967295` 内。`hl.liu 4294967295, ->a0` 写入 `4294967295`，而同样的 `32` 个编码位经 `hl.lis -1, ->a0` 会写入 `18446744073709551615`。

<!-- PTO-READER-BLOCK: scalar-hl-liu-mechanism role=mechanism -->
## 常数的形成方式

一个立即数片段携带值位 `19:0`，另一个携带第 `31:20` 位；重组出的模式是精确的。随后该 `32` 位模式被放进 `PTO_XLEN` 字的低半部分，高位全部为零。

设计要点：编码字段宽 `32` 位，而目标字宽 `64` 位，因此第 `63:32` 位根本没有被编码，永远为零。需要这些位中某一位置位的常数必须来自其他形式，因为没有任何 `uimm32` 模式能提供它。

<!-- PTO-READER-BLOCK: scalar-hl-liu-inputs role=inputs-outputs -->
## 输入与目标

- `uimm32` 携带无符号 `32` 位值。
- `RegDst` 发布它：编码 `1..23` 写入该 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 一起丢弃结果。

设计要点：`uimm32=0` 物化数值 `0`，因此 `hl.liu 0, ->t` 压入一个为零的 `T` 项，而不是什么都不做。被压入的项是有效的，所以之后对 `T#1` 的相对读取会读到这个 `0`。

<!-- PTO-READER-BLOCK: scalar-hl-liu-effects role=effects -->
## 效果与顺序

发布之前不读取任何东西，因为本形式不选择源。物化出的值送往所选目标：GPR 写入；`U` 或 `T` 压入会让新值成为下标 `1`，并丢弃原来位于下标 `4` 的项；丢弃则让寄存器和队列状态保持原样。

发布之后是 `TPC` 前进 `6` 字节。`HL.LIU` 不访问内存，也不改变保留状态、描述符、数值状态、`Tile`、指令束、特权或分支目标状态。

<!-- PTO-READER-BLOCK: scalar-hl-liu-constraints role=constraints -->
## 合法性与故障边界

每个编码取值都已分配：全部 `32` 个 `RegDst` 编码，以及 `32` 位立即数字段的全部 `4294967296` 个模式。

有两处可达的拒绝，按模型顺序如下。固定位不匹配任何形式的 `48` 位字在 `PC` 处引发 `Fault_IllegalInstruction`。不适用于当前指令束的指令在 `TPC` 处引发 `Fault_BundleControl`。两者都先于目标效果和 `TPC` 前进。

设计要点：寄存器形式的源可用性拒绝在这里不存在，因为模型没有源选择符可测。目标一侧同样完全开放：全部 `32` 个目标编码都已分配，编码 `24..29` 是目标映射的丢弃取值，而不是保留编码。

`HL.LIU` 不增加算术异常：`32` 位值的零扩展不会溢出。

<!-- PTO-READER-BLOCK: scalar-hl-liu-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`hl.liu 4294967295, ->u` 把 `4294967295` 作为最新的 `U` 项压入，第 `63:32` 位保持为零。`hl.liu 1, ->a0` 写入 `1`，这与 `hl.lis 1, ->a0` 写入的值相同，因为两个形式只有在立即数第 `31` 位被置位之后才分道扬镳。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.liu uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_liu_48_9dd207ce3aea | HL48 | 48 | 0x0000001d000e / 0x0000007f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_liu_48_9dd207ce3aea | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_liu_48_9dd207ce3aea | uimm32 | 32 | unsigned | [{"instruction_lsb":28,"value_lsb":0,"width":20},{"instruction_lsb":4,"value_lsb":20,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_liu_48_9dd207ce3aea | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_liu_48_9dd207ce3aea | uimm32 | 32 | 0–4294967295 | none | none | unsigned split 32-bit immediate | Encoded zero materializes numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| uimm32 | unsigned split 32-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.LIU.asl -->
```asl
readonly func InstructionContractOperation_HL_LIU() => ScalarOperation
begin
    return ScalarOperation_HL_LIU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.LIU.asl -->
```asl
readonly func InstructionContractHandler_HL_LIU() => ScalarSemanticHandler
begin
    return ScalarHandler_MaterializeLongUnsigned;
end;

pure func InstructionContractResult_HL_LIU(
    encoded_immediate: bits(32))
    => Word
begin
    return MaterializeLongUnsigned(encoded_immediate);
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

- Reassemble uimm32 from its two encoded pieces and zero-fill result bits 63:32.
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

- hl.liu uimm, ->{t, u, rd}
