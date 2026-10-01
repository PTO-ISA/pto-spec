<!-- GENERATED FROM: asl/scalar/alu/HL.ORI.asl -->
# HL.ORI

**Normative ASL source:** `asl/scalar/alu/HL.ORI.asl`

HL.ORI applies XLEN bitwise inclusive-or to SrcL and a sign-extended 24-bit immediate.

## Normative identity {#PTO-INST-SCALAR-HL-ORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-ori-purpose role=purpose -->
## HL.ORI 的作用

`HL.ORI` 是一条 48 位标量 ALU 指令，它计算 `SrcL` 与符号扩展的 24 位立即数的按位或，并通过一个 Reg5 目标发布 XLEN 结果。

立即数不是简单的 24 位掩码。`SignExtend{PTO_XLEN}` 把它的第 `23` 位复制到操作数的每一个更高位，因此负立即数进入或运算时上半部全为 `1` 位。

<!-- PTO-READER-BLOCK: scalar-hl-ori-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_HL_ORI`，它构造 `right = SignExtend{PTO_XLEN}(immediate)` 并返回 `ScalarBinary(ScalarBinary_OR, left, right)`。分派路径用 `ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_OR, ScalarField_simm24, FALSE)` 选择同一条路径。

```asm
hl.ori SrcL, simm, ->{t, u, Rd}
```

设计要点：符号扩展把立即数变成由 24 个编码位构造出的完整 XLEN 掩码。`simm24 = -8388608` 符号扩展为 `0xFFFFFFFFFF800000`，因此即使编码字段在第 `23` 位以上不携带任何信息，或运算仍会把结果的 `63:23` 位置为 1。

<!-- PTO-READER-BLOCK: scalar-hl-ori-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[23 +: 5]`，接收 XLEN 结果，或丢弃它。
- `SrcL`，指令切片 `[31 +: 5]`，提供待合并的值。
- `simm24`，指令切片 `[36 +: 12]` 与 `[4 +: 12]`，提供数值位 `11:0` 与 `23:12`。

`SrcL` 使用通用 Reg5 映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4` 且不消耗表项。编码零读取体系结构零 GPR，因此 `hl.ori zero, -1, ->a0` 完全没有数据依赖。

设计要点：24 位立即数被拆成两段不相邻的 12 位，符号位是指令第 `47` 位，而不是第 `35` 位。只读取低位连续段的译码器会得到另一个数。

<!-- PTO-READER-BLOCK: scalar-hl-ori-effects role=effects -->
## 效果与顺序

`SrcL` 在目标效果之前取快照，因此 `SrcL` 与 `RegDst` 同名时不会把部分更新的值回送给或运算。

结果通过 `RegDst` 发布，随后 `TPC` 前进 `6` 字节。`HL.ORI` 不访问内存，数值状态、保留、描述符、Tile、指令束、特权与控制流状态都不改变；唯一可能的队列变化是由 `RegDst` 选择的 `T` 或 `U` 推送。

<!-- PTO-READER-BLOCK: scalar-hl-ori-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码都有定义，全部 `32` 个 `RegDst` 编码都被接受，`-8388608` 到 `8388607` 之间的每个有符号 24 位值也都合法，因此操作数检查只可能因临时源不可用而失败。两段立即数重建出一个精确值；该字段没有任何保留编码。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。

设计要点：按位或不可能会溢出，因此任何操作数对都不存在算术故障，立即数范围是该操作唯一的边界。

<!-- PTO-READER-BLOCK: scalar-hl-ori-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

`SrcL` 取体系结构零 GPR、`simm24 = -1` 时，扩展后的操作数是 `0xFFFFFFFFFFFFFFFF`，`RegDst` 收到 `0xFFFFFFFFFFFFFFFF`。取 `SrcL = 0`、`simm24 = -8388608` 时扩展后的操作数是 `0xFFFFFFFFFF800000`，因此发布值的 `63:23` 位为 `1`，其余为 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.ori SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ori_48_c6d8ce28a78b | HL48 | 48 | 0x00003015000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ori_48_c6d8ce28a78b | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ori_48_c6d8ce28a78b | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_ori_48_c6d8ce28a78b | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_ori_48_c6d8ce28a78b | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_ori_48_c6d8ce28a78b | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads architectural GPR zero. |
| hl_ori_48_c6d8ce28a78b | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.ORI.asl -->
```asl
readonly func InstructionContractOperation_HL_ORI() => ScalarOperation
begin
    return ScalarOperation_HL_ORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.ORI.asl -->
```asl
readonly func InstructionContractHandler_HL_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_HL_ORI()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_ORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_ORI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractResult_HL_ORI(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinary(
        ScalarBinary_OR,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, simm24, and RegDst are required encoded fields; no field can be omitted.
- simm24 has the complete signed 24-bit range -8388608 through 8388607; encoded zero is numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, codes 1..23 write absolute GPRs, code 30 pushes U, and code 31 pushes T.
- Every signed 24-bit two's-complement value is assigned. The two 12-bit pieces reconstruct one exact 24-bit value.

## State effects

- Sign-extend simm24 to PTO_XLEN, compute bitwise inclusive-or with the snapshotted SrcL value modulo 2^PTO_XLEN where applicable, and publish the result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.ORI raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.ori a0, -1, ->a0
- hl.ori t#1, -8388608, ->u
- hl.ori zero, 8388607, ->zero
