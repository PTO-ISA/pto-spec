<!-- GENERATED FROM: asl/scalar/alu/HL.SUBI.asl -->
# HL.SUBI

**Normative ASL source:** `asl/scalar/alu/HL.SUBI.asl`

HL.SUBI applies XLEN subtraction to SrcL and a zero-extended 24-bit immediate.

## Normative identity {#PTO-INST-SCALAR-HL-SUBI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-subi-purpose role=purpose -->
## HL.SUBI 的作用

`HL.SUBI` 是一条 48 位标量 ALU 指令，它从 `SrcL` 中减去零扩展的 24 位立即数并按模 `2^PTO_XLEN` 回绕，再通过一个 Reg5 目标发布结果。

立即数是无符号的。每个 `uimm24` 取值都作为 `0` 到 `16777215` 范围内的正数被减去。

<!-- PTO-READER-BLOCK: scalar-hl-subi-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_HL_SUBI`，它构造 `right = ZeroExtend{PTO_XLEN}(immediate)` 并返回 `ScalarBinary(ScalarBinary_SUB, left, right)`。分派路径用 `ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_SUB, ScalarField_uimm24, FALSE)` 选择同一条路径。

```asm
hl.subi SrcL, uimm, ->{t, u, Rd}
```

设计要点：本家族的算术立即数与逻辑立即数拼写恰好在这一条扩展规则上分道。`HL.SUBI` 对它 24 位字段做零扩展，而 `HL.ORI` 与 `HL.XORI` 做符号扩展，因此同样的 24 个编码位在一个助记符下表示 `16777215`，在另一个下表示 `-1`。

<!-- PTO-READER-BLOCK: scalar-hl-subi-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[23 +: 5]`，接收 XLEN 结果，或丢弃它。
- `SrcL`，指令切片 `[31 +: 5]`，提供被减去立即数的值。
- `uimm24`，指令切片 `[36 +: 12]` 与 `[4 +: 12]`，提供数值位 `11:0` 与 `23:12`。

`SrcL` 使用通用 Reg5 映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4` 且不消耗表项。编码零读取体系结构 GPR 零。

设计要点：立即数的两段 12 位分别位于指令 `[47:36]` 与 `[15:4]`。它们并不相邻，任何单独一段都不是立即数；译码器必须先把 24 位值重组出来再扩展。

<!-- PTO-READER-BLOCK: scalar-hl-subi-effects role=effects -->
## 效果与顺序

`SrcL` 在目标效果之前取快照，因此 `hl.subi a0, 1, ->a0` 递减的是执行前的 `a0`，同队列先读后推的情形发布的也是推送之前读到的值。

结果通过 `RegDst` 发布，随后 `TPC` 前进 `6` 字节。`HL.SUBI` 不读写内存，数值状态、保留、描述符、Tile、指令束、特权与控制流状态都不改变；只有目标选择的队列推送能改动临时队列。

<!-- PTO-READER-BLOCK: scalar-hl-subi-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码与全部 `32` 个 `RegDst` 编码都有定义，`0` 到 `16777215` 之间的每个无符号 24 位立即数也都合法，因此只有临时源不可用会使操作数检查失败。固定编码位必须与规范的 48 位形式匹配。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。下溢的减法会回绕，不触发任何故障。

设计要点：由于该字段是无符号的，不存在负立即数拼写。减一与减 `16777215` 是同一字段的不同编码，而一条指令只能减去 `0` 到 `16777215` 之间的值。

<!-- PTO-READER-BLOCK: scalar-hl-subi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 3`、`uimm24 = 5` 时差值为 `-2`，因此 `RegDst` 收到 `0xFFFFFFFFFFFFFFFE`。取 `SrcL = 3`、`uimm24 = 16777215` 时差值为 `-16777212`，`RegDst` 收到 `0xFFFFFFFFFF000004`。取 `uimm24 = 0` 时发布值就是原样的 `SrcL`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.subi SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_subi_48_e1f491a8aead | HL48 | 48 | 0x00001015000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_subi_48_e1f491a8aead | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_subi_48_e1f491a8aead | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_subi_48_e1f491a8aead | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_subi_48_e1f491a8aead | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_subi_48_e1f491a8aead | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads architectural GPR zero. |
| hl_subi_48_e1f491a8aead | uimm24 | 24 | 0–16777215 | none | none | unsigned split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| uimm24 | unsigned split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.SUBI.asl -->
```asl
readonly func InstructionContractOperation_HL_SUBI() => ScalarOperation
begin
    return ScalarOperation_HL_SUBI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.SUBI.asl -->
```asl
readonly func InstructionContractHandler_HL_SUBI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_HL_SUBI()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsUnsigned_HL_SUBI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_SUBI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractResult_HL_SUBI(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = ZeroExtend{PTO_XLEN}(immediate);
    return ScalarBinary(
        ScalarBinary_SUB,
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, uimm24, and RegDst are required encoded fields; no field can be omitted.
- uimm24 has the complete unsigned 24-bit range 0 through 16777215; encoded zero is numeric zero.

## Legality

- All 32 SrcL encodings are assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consuming a queue entry.
- All 32 RegDst encodings are assigned: codes 0 and 24..29 discard, codes 1..23 write absolute GPRs, code 30 pushes U, and code 31 pushes T.
- Every unsigned 24-bit value is assigned. The two 12-bit pieces reconstruct one exact 24-bit value.

## State effects

- Zero-extend uimm24 to PTO_XLEN, compute subtraction with the snapshotted SrcL value modulo 2^PTO_XLEN where applicable, and publish the result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.SUBI raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.subi a0, 1, ->a0
- hl.subi t#1, 16777215, ->u
- hl.subi zero, 0, ->zero
