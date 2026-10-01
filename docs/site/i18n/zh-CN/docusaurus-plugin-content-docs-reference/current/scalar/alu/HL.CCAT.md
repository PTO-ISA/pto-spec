<!-- GENERATED FROM: asl/scalar/alu/HL.CCAT.asl -->
# HL.CCAT

**Normative ASL source:** `asl/scalar/alu/HL.CCAT.asl`

HL.CCAT logically right-shifts {SrcL, SrcR}, writes the low 64-bit result to Dst0, then writes the high result to Dst1.

## Normative identity {#PTO-INST-SCALAR-HL-CCAT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ccat-purpose role=purpose -->
## HL.CCAT 的作用

`HL.CCAT` 是一条 48 位标量 ALU 指令。它把 `SrcL` 作为高半部、`SrcR` 作为低半部组成一个 128 位值，对该值做 7 位 `shamt` 指定的逻辑右移，并把位 `63:0` 发布到 `Dst0`、位 `127:64` 发布到 `Dst1`。

设计要点：这个拼接值从不作为寄存器值存在。两个半部分开计算，因此小于 `64` 的移位会把高半部的低位带入低部结果的顶部：当 `SrcL` 为 `1`、`SrcR` 为 `2`、`shamt=8` 时，低部结果为 `0x0100000000000000`。

<!-- PTO-READER-BLOCK: scalar-hl-ccat-mechanism role=mechanism -->
## 结果形成方式

`InstructionContractLowResult_HL_CCAT` 返回位 `63:0`，`InstructionContractHighResult_HL_CCAT` 返回位 `127:64`（`asl/scalar/alu/HL.CCAT.asl:26-55`）。

- 当 `shamt=0` 时，低部结果是 `SrcR`，高部结果是 `SrcL`。
- 当 `shamt` 取 `1..63` 时，低部结果是 `LSR(SrcR, shamt) OR LSL(SrcL, 64 - shamt)`，高部结果是 `LSR(SrcL, shamt)`。
- 当 `shamt` 取 `64..127` 时，低部结果是 `LSR(SrcL, shamt - 64)`，高部结果为零。

设计要点：零移位直接返回两个源，因此 `hl.ccat a0, a1, 0, ->a2, a3` 把 `a1` 发布到 `a2`，把 `a0` 发布到 `a3`。

设计要点：`shamt=127` 只保留位 127，也就是 `SrcL` 的位 63，并把它移到低部结果的位 0。对于 `64` 及以上的 `shamt`，高部结果为零，因此没有任何数据到达高部目标。

<!-- PTO-READER-BLOCK: scalar-hl-ccat-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst0` 接收低部结果，或丢弃它。
- `RegDst1` 接收高部结果，或丢弃它。
- `SrcL` 是高部源，提供位 `127:64`。
- `SrcR` 是低部源，提供位 `63:0`。
- `shamt` 是 7 位无符号逻辑右移量。

两个源都使用完整的源映射：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且不消费队列项。两个目标都使用公共目标映射：编码 `1..23` 写 GPR，编码 `0` 与 `24..29` 丢弃，编码 `30` 压入 `U`，编码 `31` 压入 `T`。

设计要点：在目标位置上，汇编写法 `zero` 是丢弃编码 `0`。元数据示例 `hl.ccat t#1, u#1, 64, ->zero, a0` 丢弃低部结果 `T#1`，并把高部结果 `0` 写到 `a0`。

<!-- PTO-READER-BLOCK: scalar-hl-ccat-effects role=effects -->
## 效果与顺序

两个结果都在任何写入之前计算完成，写入顺序固定：先 `Dst0` 写入位 `63:0`，再 `Dst1` 写入位 `127:64`。

设计要点：当两个目标指向同一位置时，这个顺序是可观察的。指向同一个 GPR 时 `Dst1` 的写入是最终结果，因此该寄存器保存高部结果。指向同一个队列时 `Dst0` 先入队，因此高部结果成为最新项。

`HL.CCAT` 没有内存效果，也不改变其他架构状态；丢弃目标不产生任何效果。两个目标效果之后，`TPC` 前进 `6` 字节。

<!-- PTO-READER-BLOCK: scalar-hl-ccat-constraints role=constraints -->
## 合法性与故障边界

`shamt` 的全部 `128` 个取值都已分配，移位以零填充，因此没有保留的 `shamt` 取值；每个源编码与目标编码同样都已分配。

固定编码位与 `HL48` 形式不匹配的编码不会被译码；不匹配任何已接受形式的编码会在读取任何源之前于 `PC` 处引发 `Fault_IllegalInstruction`。所选 `T` 或 `U` 源不可用会在两个目标效果之前、`TPC` 前进之前于 `PC` 处引发 `Fault_IllegalInstruction`。不适用于当前指令束的指令会在 `TPC` 处触发 `Fault_BundleControl`（`asl/scalar/model/dispatch/top-level.asl:17-37`，`asl/scalar/model/types/operands.asl:6-19`）。

设计要点：移位是全域定义的，因此每个 `shamt` 与每一对源都会产生一对已定义的 XLEN 结果，该指令没有算术故障路径。

<!-- PTO-READER-BLOCK: scalar-hl-ccat-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `shamt=0` 时没有移位：`hl.ccat a0, a1, 0, ->a2, a3` 把 `a1` 发布到 `a2`，把 `a0` 发布到 `a3`。

当 `a0` 为 `1`、`a1` 为 `2`、`shamt=8` 时，低部结果是 `LSR(2, 8) OR LSL(1, 56)`，即 `0x0100000000000000`，而高部结果是 `LSR(1, 8)`，即 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ccat SrcL, SrcR, shamt, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ccat_48_a1200d8bf5ac | HL48 | 48 | 0x0000105d000e / 0x0000707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ccat_48_a1200d8bf5ac | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ccat_48_a1200d8bf5ac | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ccat_48_a1200d8bf5ac | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ccat_48_a1200d8bf5ac | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ccat_48_a1200d8bf5ac | shamt | 7 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":7}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ccat_48_a1200d8bf5ac | RegDst0 | 5 | 0–31 | none | none | ordered low-result Reg5 destination or discard | Encoded zero discards the low result. |
| hl_ccat_48_a1200d8bf5ac | RegDst1 | 5 | 0–31 | none | none | ordered high-result Reg5 destination or discard | Encoded zero discards the high result. |
| hl_ccat_48_a1200d8bf5ac | SrcL | 5 | 0–31 | none | none | upper Reg5 source | Encoded zero reads architectural GPR zero. |
| hl_ccat_48_a1200d8bf5ac | SrcR | 5 | 0–31 | none | none | lower Reg5 source | Encoded zero reads architectural GPR zero. |
| hl_ccat_48_a1200d8bf5ac | shamt | 7 | 0–127 | none | none | unsigned seven-bit logical-right shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | ordered low-result Reg5 destination or discard |
| RegDst1 | ordered high-result Reg5 destination or discard |
| SrcL | upper Reg5 source |
| SrcR | lower Reg5 source |
| shamt | unsigned seven-bit logical-right shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.CCAT.asl -->
```asl
readonly func InstructionContractOperation_HL_CCAT() => ScalarOperation
begin
    return ScalarOperation_HL_CCAT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.CCAT.asl -->
```asl
readonly func InstructionContractHandler_HL_CCAT() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteConcatenatePair;
end;

pure func InstructionContractLowResult_HL_CCAT(
    left: Word,
    right: Word,
    shift_amount: integer {0..127})
    => Word
begin
    if shift_amount == 0 then
        return right;
    elsif shift_amount < 64 then
        return LSR(right, shift_amount) OR
            LSL(left, 64 - shift_amount);
    else
        return LSR(left, shift_amount - 64);
    end;
end;

pure func InstructionContractHighResult_HL_CCAT(
    left: Word,
    right: Word,
    shift_amount: integer {0..127})
    => Word
begin
    if shift_amount == 0 then
        return left;
    elsif shift_amount < 64 then
        return LSR(left, shift_amount);
    else
        return Zeros{PTO_XLEN};
    end;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, shamt, RegDst0, and RegDst1 are required encoded fields; no field can be omitted.
- Encoded shamt zero performs no shift.

## Legality

- SrcL and SrcR independently use the complete Reg5 source map: GPR0..GPR23, T#1..T#4, and U#1..U#4.
- RegDst0 and RegDst1 independently use the common destination map: GPR writes, discard codes, U push, or T push.
- shamt 0..127 is fully assigned and zero-filling.

## State effects

- Form {SrcL, SrcR}, logically shift the 128-bit value right by shamt, publish bits 63:0 to Dst0, then publish bits 127:64 to Dst1.
- Apply the complete Reg5 destination map independently in Dst0 then Dst1 order; discard destinations have no effect.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before either destination effect; relative source reads do not consume queue entries.
- Publish Dst0 first and Dst1 second. Equal GPR destinations retain Dst1; equal queue destinations enqueue Dst0 before Dst1.
- After both destination effects, advance TPC by six bytes.

## Exceptions

- The concatenation shift is total for every shamt and raises no arithmetic exception.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before either destination effect and before TPC advances.

## Examples

- hl.ccat a0, a1, 0, ->a2, a3
- hl.ccat t#1, u#1, 64, ->zero, a0
- hl.ccat a0, a1, 127, ->t, t
