<!-- GENERATED FROM: asl/scalar/alu/HL.XORI.asl -->
# HL.XORI

**Normative ASL source:** `asl/scalar/alu/HL.XORI.asl`

HL.XORI applies XLEN bitwise exclusive-or to SrcL and a sign-extended 24-bit immediate.

## Normative identity {#PTO-INST-SCALAR-HL-XORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-xori-purpose role=purpose -->
## HL.XORI 的作用

`HL.XORI` 是一条 48 位标量 ALU 指令，它计算 `SrcL` 与符号扩展的 24 位立即数的按位异或，并通过一个 Reg5 目标发布 XLEN 结果。

由于操作数由 `SignExtend{PTO_XLEN}` 构造，负立即数除了翻转它直接编码的那些位，还会翻转整个上半部。

<!-- PTO-READER-BLOCK: scalar-hl-xori-mechanism role=mechanism -->
## 结果形成方式

所属 ASL 提供 `InstructionContractResult_HL_XORI`，它构造 `right = SignExtend{PTO_XLEN}(immediate)` 并返回 `ScalarBinary(ScalarBinary_XOR, left, right)`。分派路径用 `ExecuteDecodedImmediateBinary(instruction, form, ScalarBinary_XOR, ScalarField_simm24, FALSE)` 选择同一条路径。

```asm
hl.xori SrcL, simm, ->{t, u, Rd}
```

设计要点：与符号扩展字段做异或是一种成片的取反，而不只是局部修改。`simm24 = -1` 扩展为 `0xFFFFFFFFFFFFFFFF`，因此 `hl.xori a0, -1, ->a0` 发布整个 XLEN 寄存器的按位取反。

<!-- PTO-READER-BLOCK: scalar-hl-xori-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst`，指令切片 `[23 +: 5]`，接收 XLEN 结果，或丢弃它。
- `SrcL`，指令切片 `[31 +: 5]`，提供待合并的值。
- `simm24`，指令切片 `[36 +: 12]` 与 `[4 +: 12]`，提供数值位 `11:0` 与 `23:12`。

`SrcL` 使用通用 Reg5 映射：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4` 且不消耗表项。编码零读取体系结构零 GPR。

设计要点：立即数是有符号的，因此字段范围是 `-8388608` 到 `8388607`，每个取值翻转一组不同的高位。`simm24` 没有无符号读法，因此不存在只掩蔽低位、而在第 `23` 位为 1 时不触及上半部的编码。

<!-- PTO-READER-BLOCK: scalar-hl-xori-effects role=effects -->
## 效果与顺序

`SrcL` 在目标效果之前取快照，因此 `SrcL` 与 `RegDst` 同名时不会把刚发布的值回送给同一条指令。

结果通过 `RegDst` 发布，随后 `TPC` 前进 `6` 字节。`HL.XORI` 不读写内存，数值状态、保留、描述符、Tile、指令束、特权与控制流状态都不改变；唯一可能的队列变化是目标选择的 `T` 或 `U` 推送。

<!-- PTO-READER-BLOCK: scalar-hl-xori-constraints role=constraints -->
## 合法性与故障边界

全部 `32` 个 `SrcL` 编码与全部 `32` 个 `RegDst` 编码都有定义，每个有符号 24 位立即数也都合法，因此操作数检查只可能因临时源不可用而失败。固定编码位必须与规范的 48 位形式匹配；两段立即数重建出一个精确值，没有任何编码被保留。

适用性只在系统块终止请求挂起时失败，并在 `TPC` 触发 `Fault_BundleControl`。否则，不匹配的编码在进入指令束主体之前于 `PC` 触发 `Fault_IllegalInstruction`，所选 `T` 或 `U` 源不可用时则在目标写入之前于 `PC` 触发 `Fault_IllegalInstruction`。异或本身不触发异常。

设计要点：逻辑运算没有溢出拐角，因此整个故障面就是编码匹配加上临时源可用性。操作数值无法把故障从这两项检查中的任何一项挪到算术上。

<!-- PTO-READER-BLOCK: scalar-hl-xori-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

取 `SrcL = 0x0F`、`simm24 = -1` 时扩展后的操作数为 `0xFFFFFFFFFFFFFFFF`，因此 `RegDst` 收到 `0xFFFFFFFFFFFFFFF0`。取 `SrcL = 0`、`simm24 = 8388607` 时扩展后的操作数为 `0x00000000007FFFFF`，`RegDst` 收到 `0x00000000007FFFFF`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.xori SrcL, simm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_xori_48_b4d85f91aad8 | HL48 | 48 | 0x00004015000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_xori_48_b4d85f91aad8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_xori_48_b4d85f91aad8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_xori_48_b4d85f91aad8 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_xori_48_b4d85f91aad8 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_xori_48_b4d85f91aad8 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source | Encoded zero reads architectural GPR zero. |
| hl_xori_48_b4d85f91aad8 | simm24 | 24 | 0–16777215 | none | none | signed split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source |
| simm24 | signed split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.XORI.asl -->
```asl
readonly func InstructionContractOperation_HL_XORI() => ScalarOperation
begin
    return ScalarOperation_HL_XORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.XORI.asl -->
```asl
readonly func InstructionContractHandler_HL_XORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;

pure func InstructionContractImmediateWidth_HL_XORI()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsSigned_HL_XORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_XORI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractResult_HL_XORI(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = SignExtend{PTO_XLEN}(immediate);
    return ScalarBinary(
        ScalarBinary_XOR,
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

- Sign-extend simm24 to PTO_XLEN, compute bitwise exclusive-or with the snapshotted SrcL value modulo 2^PTO_XLEN where applicable, and publish the result through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.XORI raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.xori a0, -1, ->a0
- hl.xori t#1, -8388608, ->u
- hl.xori zero, 8388607, ->zero
