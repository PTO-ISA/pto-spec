<!-- GENERATED FROM: asl/scalar/alu/HL.CCATW.asl -->
# HL.CCATW

**Normative ASL source:** `asl/scalar/alu/HL.CCATW.asl`

HL.CCATW logically right-shifts {SrcL[31:0], SrcR[31:0]}, sign-extends the low then high 32-bit results, and writes them in order.

## Normative identity {#PTO-INST-SCALAR-HL-CCATW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ccatw-purpose role=purpose -->
## HL.CCATW 的作用

`HL.CCATW` 是一条 48 位标量 ALU 指令。它把 `SrcL` 的低字放在 `SrcR` 的低字之上，把这个 64 位值按 `shamt` 做逻辑右移，把每个 32 位半部符号扩展到 XLEN，并把低半部发布到 `Dst0`、高半部发布到 `Dst1`。

设计要点：字形式只读取每个源的位 `31:0`，却向每个目标写入完整的 XLEN 值。符号扩展用移位后半部的位 `31` 补足高位，因此每个目标都收到一个已定义的 XLEN 值。

<!-- PTO-READER-BLOCK: scalar-hl-ccatw-mechanism role=mechanism -->
## 结果形成方式

两个辅助函数构造同一个打包值：位 `31:0` 保存 `SrcR[31:0]`，位 `63:32` 保存 `SrcL[31:0]`（`asl/scalar/alu/HL.CCATW.asl:26-58`）。

- 当 `shamt` 取 `0..63` 时，低部结果是 `LSR(packed, shamt)[31:0]` 的符号扩展。
- 当 `shamt` 取 `0..63` 时，高部结果是 `LSR(packed, shamt)[63:32]` 的符号扩展。
- 当 `shamt` 取 `64..127` 时，两个结果都为零。

设计要点：这个辅助函数在 `shamt=0` 处没有特殊分支，因此 `Dst0` 收到 `SrcR[31:0]` 的符号扩展，`Dst1` 收到 `SrcL[31:0]` 的符号扩展；每个半部的符号取自移位结果的位 `31`，所以符号跟随落入该半部的数据。

<!-- PTO-READER-BLOCK: scalar-hl-ccatw-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst0` 接收低字结果，或丢弃它。
- `RegDst1` 接收高字结果，或丢弃它。
- `SrcL` 是其低字成为打包值位 `63:32` 的源。
- `SrcR` 是其低字成为打包值位 `31:0` 的源。
- `shamt` 是 7 位无符号逻辑右移量。

两个源都使用完整的源映射：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`，且不消费队列项。两个目标都使用公共目标映射：编码 `1..23` 写 GPR，编码 `0` 与 `24..29` 丢弃，编码 `30` 压入 `U`，编码 `31` 压入 `T`。

设计要点：每个源只有位 `31:0` 会到达结果，因此 `hl.ccatw a0, a1, 0, ->a2, a3` 忽略 `a0` 与 `a1` 的位 `63:32`；这些高字永远不会进入已发布的半部。

<!-- PTO-READER-BLOCK: scalar-hl-ccatw-effects role=effects -->
## 效果与顺序

两个结果都在任何写入之前计算完成，写入顺序固定：先 `Dst0` 写入低字结果，再 `Dst1` 写入高字结果。

设计要点：当两个目标指向同一位置时，这个顺序是可观察的。指向同一个 GPR 时 `Dst1` 的写入是最终结果。指向同一个队列时 `Dst0` 先入队，因此高部结果成为最新项。

`HL.CCATW` 没有内存效果，不记录数值状态标志，也不改变其他架构状态；`TPC` 在两个目标效果之后前进 `6` 字节。

设计要点：当 `shamt` 取 `64..127` 时两个结果都为零，但两个目标效果仍然发生：GPR 目标被写入 `0`，而 `T` 或 `U` 目标仍然收到一次零值压入。

<!-- PTO-READER-BLOCK: scalar-hl-ccatw-constraints role=constraints -->
## 合法性与故障边界

`shamt` 的全部 `128` 个取值都已分配：`0..63` 产生两个符号扩展的字结果，`64..127` 产生两个零；每个源编码与目标编码同样都已分配。

固定编码位与 `HL48` 形式不匹配的编码不会被译码；不匹配任何已接受形式的编码会在读取任何源之前于 `PC` 处引发 `Fault_IllegalInstruction`。所选 `T` 或 `U` 源不可用会在两个目标效果之前、`TPC` 前进之前于 `PC` 处引发 `Fault_IllegalInstruction`。不适用于当前指令束的指令会在 `TPC` 处触发 `Fault_BundleControl`（`asl/scalar/model/dispatch/top-level.asl:17-37`，`asl/scalar/model/types/operands.asl:6-19`）。

设计要点：这两个辅助函数不对任何操作数取值做断言，因此每个 `shamt` 与每一对源都会产生已定义的 XLEN 结果，该指令没有算术故障路径。

<!-- PTO-READER-BLOCK: scalar-hl-ccatw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `shamt=0`、`SrcL[31:0]` 为 `0x80000000`、`SrcR[31:0]` 为 `0x1` 时没有移位：`Dst0` 收到 `SrcR[31:0]` 的符号扩展，即 `1`；`Dst1` 收到 `SrcL[31:0]` 的符号扩展，即 `0xffffffff80000000`。

当 `shamt=64` 时两个发布结果都为零，因此 `hl.ccatw a0, a1, 64, ->a2, a3` 把 `0` 写到 `a2`，把 `0` 写到 `a3`。当 `shamt=32` 时低部结果是 `SrcL[31:0]` 的符号扩展，同样为 `0xffffffff80000000`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ccatw SrcL, SrcR, shamt, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ccatw_48_24a85ea4659c | HL48 | 48 | 0x0000205d000e / 0x0000707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ccatw_48_24a85ea4659c | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ccatw_48_24a85ea4659c | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_ccatw_48_24a85ea4659c | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ccatw_48_24a85ea4659c | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_ccatw_48_24a85ea4659c | shamt | 7 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":7}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ccatw_48_24a85ea4659c | RegDst0 | 5 | 0–31 | none | none | ordered low-result Reg5 destination or discard | Encoded zero discards the low result. |
| hl_ccatw_48_24a85ea4659c | RegDst1 | 5 | 0–31 | none | none | ordered high-result Reg5 destination or discard | Encoded zero discards the high result. |
| hl_ccatw_48_24a85ea4659c | SrcL | 5 | 0–31 | none | none | upper low-word Reg5 source | Encoded zero reads architectural GPR zero. |
| hl_ccatw_48_24a85ea4659c | SrcR | 5 | 0–31 | none | none | lower low-word Reg5 source | Encoded zero reads architectural GPR zero. |
| hl_ccatw_48_24a85ea4659c | shamt | 7 | 0–127 | none | none | unsigned seven-bit logical-right shift amount | Encoded zero performs no shift. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | ordered low-result Reg5 destination or discard |
| RegDst1 | ordered high-result Reg5 destination or discard |
| SrcL | upper low-word Reg5 source |
| SrcR | lower low-word Reg5 source |
| shamt | unsigned seven-bit logical-right shift amount |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.CCATW.asl -->
```asl
readonly func InstructionContractOperation_HL_CCATW() => ScalarOperation
begin
    return ScalarOperation_HL_CCATW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.CCATW.asl -->
```asl
readonly func InstructionContractHandler_HL_CCATW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteConcatenatePairW;
end;

pure func InstructionContractLowResult_HL_CCATW(
    left: Word,
    right: Word,
    shift_amount: integer {0..127})
    => Word
begin
    if shift_amount < 64 then
        var packed: Word = Zeros{PTO_XLEN};
        packed[31:0] = right[31:0];
        packed[63:32] = left[31:0];
        return SignExtend{PTO_XLEN}(
            LSR(packed, shift_amount)[31:0]);
    else
        return Zeros{PTO_XLEN};
    end;
end;

pure func InstructionContractHighResult_HL_CCATW(
    left: Word,
    right: Word,
    shift_amount: integer {0..127})
    => Word
begin
    if shift_amount < 64 then
        var packed: Word = Zeros{PTO_XLEN};
        packed[31:0] = right[31:0];
        packed[63:32] = left[31:0];
        return SignExtend{PTO_XLEN}(
            LSR(packed, shift_amount)[63:32]);
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
- shamt 0..127 is fully assigned; values 64..127 produce two zeros.

## State effects

- Pack SrcL[31:0] above SrcR[31:0]. For shamt 0..63, logically shift the 64-bit value right, sign-extend result bits 31:0 to Dst0 and bits 63:32 to Dst1; for shamt 64..127 both results are zero.
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

- hl.ccatw a0, a1, 0, ->a2, a3
- hl.ccatw t#1, u#1, 64, ->zero, a0
- hl.ccatw a0, a1, 127, ->t, t
