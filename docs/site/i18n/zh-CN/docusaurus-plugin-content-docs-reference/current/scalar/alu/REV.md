<!-- GENERATED FROM: asl/scalar/alu/REV.asl -->
# REV

**Normative ASL source:** `asl/scalar/alu/REV.asl`

REV reverses the bytes of an independently selected wrapping scalar field, zero-fills high result bits, and returns zero for a non-byte width.

## Normative identity {#PTO-INST-SCALAR-REV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-rev-purpose role=purpose -->
## REV 的作用

`REV` 选择 `SrcL` 中一个从第 `M` 位开始、绕过第 `63` 位回绕的 `N` 位字段，反转该字段的字节，并把反转后的字节放在结果的 `N-1:0` 位。它有四个字段：`RegDst` 位于 `[7 +: 5]`、`SrcL` 位于 `[15 +: 5]`、`imml` 位于 `[20 +: 6]`、`immr` 位于 `[26 +: 6]`。

该载体在掩码 `0x0000707f` 下匹配 `0x00007067`。`imml` 编码的是宽度减一，`immr` 直接编码起始位，因此两个字段都使用了完整的六位域。

它的两个非寄存器字段都是操作数取值：宽度与起始位彼此独立；这与 `OR` 之类的变换形式不同，后者的两个字段是变换选择子与移位量。

<!-- PTO-READER-BLOCK: scalar-rev-mechanism role=mechanism -->
## 字节反转形成方式

分派路径用快照后的 `SrcL`、译出的宽度与译出的 `immr` 偏移调用 `ReverseBitfieldBytes`（`asl/scalar/model/dispatch/alu.asl:385-391`）。该辅助函数先检查 `width MOD 8`，当宽度不是八的倍数时立即返回 `Zeros{PTO_XLEN}`；否则用 `ExtractBitfield` 提取字段，并把 `field[(byte_index * 8) +: 8]` 复制到 `result[(((byte_count - 1) - byte_index) * 8) +: 8]`（`asl/scalar/model/alu/semantics.asl:194-205`）。

```asm
rev SrcL,  M, N, ->{t, u, Rd}
```

设计要点：`ExtractBitfield` 把 `SrcL` 右旋 `M` 位并保留低 `N` 位，这就是所选字段会回绕的原因：越过第 `63` 位的字段在第 `0` 位继续。该提取是无符号的，因此没有符号位进入反转。

设计要点：模检查在任何提取之前运行，因此像 `7` 这样的宽度是合法编码，其答案是已定义的零，而不是非法指令。

<!-- PTO-READER-BLOCK: scalar-rev-inputs role=inputs-outputs -->
## 输入与目标

`SrcL` 是唯一的寄存器操作数。`imml` 与 `immr` 由载体译出，`RegDst` 接收结果。

- `SrcL`，指令切片 `[15 +: 5]`：`0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`，该读取不消耗条目。
- `imml`，指令切片 `[20 +: 6]`：原始值 `0` 到 `63` 选择宽度 `1` 到 `64`，因此编码零选择 `N = 1`。
- `immr`，指令切片 `[26 +: 6]`：起始位 `M`，取值 `0` 到 `63`；编码零把字段起点放在源的第零位。
- `RegDst`，指令切片 `[7 +: 5]`：`1..23` 写入对应 GPR，`30` 压入 `U`，`31` 压入 `T`，`0` 与 `24..29` 丢弃。

设计要点：辅助函数从 `Zeros{PTO_XLEN}` 开始构建答案，因此所选字段之外的位永远不会进入结果。

<!-- PTO-READER-BLOCK: scalar-rev-effects role=effects -->
## 效果与顺序

`SrcL` 在目标效果之前取快照，因此与源同名的目标反转的是执行前的值。结果发布后 `TPC` 推进 `4` 字节。

`REV` 不读内存，也不改变保留、描述符、数值标志、陷阱、指令束、特权或控制流状态。仅当目标是 `30` 或 `31` 时它才会移动临时队列。

设计要点：发布值中高于 `N-1` 的位为零；当 `N = 64` 时反转占据整个 `PTO_XLEN` 字。

<!-- PTO-READER-BLOCK: scalar-rev-constraints role=constraints -->
## 合法性与故障边界

全部 `64` 个 `imml` 取值、全部 `64` 个 `immr` 取值、全部 `32` 个 `SrcL` 编码与全部 `32` 个 `RegDst` 编码都有定义。该形式没有约束条目；唯一固定要求是字段之外的载体位匹配 `0x00007067`。

不匹配的载体在 `PC` 触发 `Fault_IllegalInstruction`。对活动块不适用的指令在 `TPC` 触发 `Fault_BundleControl`，对 `REV` 而言仅在系统块终止请求挂起期间可达。所选 `T` 或 `U` 源不可用时在 `PC` 触发 `Fault_IllegalInstruction`，先于目标效果与 `TPC` 推进。

设计要点：不是八的倍数的宽度会正常完成并给出零结果，因此 `REV` 没有由操作数选择的陷阱。故障边界是编码有效性与源可用性。

<!-- PTO-READER-BLOCK: scalar-rev-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 为 `0x1122334455667788`、`immr = 8`、`N = 32` 时，所选字段是 `0x44556677`，`rev a0, 8, 32, ->a2` 发布 `0x77665544`：从源第 `8` 位开始的字段字节移动到结果的 `31:24` 位，其余三个字节按源顺序跟随。

同一源、`immr = 8` 但 `N = 7` 时，宽度不是 `8` 的倍数，因此 `rev a0, 8, 7, ->a2` 发布 `0`。高于所选字段的源位在两个结果中都不会出现。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
rev SrcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| rev_32_58badc109d49 | L32 | 32 | 0x00007067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| rev_32_58badc109d49 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| rev_32_58badc109d49 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| rev_32_58badc109d49 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| rev_32_58badc109d49 | immr | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| rev_32_58badc109d49 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| rev_32_58badc109d49 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| rev_32_58badc109d49 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| rev_32_58badc109d49 | immr | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| immr | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REV.asl -->
```asl
readonly func InstructionContractOperation_REV()
    => ScalarOperation
begin
    return ScalarOperation_REV;
end;

pure func InstructionContractWidth_REV(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_REV(encoded_immr: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_immr);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REV.asl -->
```asl
readonly func InstructionContractHandler_REV()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ReverseBitfieldBytes;
end;

pure func InstructionContractResult_REV(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return ReverseBitfieldBytes(
        value,
        width,
        offset);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, imml, immr, and RegDst are required encoded fields; no field can be omitted.
- imml encodes N minus one, so raw values 0 through 63 select widths 1 through 64; encoded zero selects N=1.
- immr directly encodes M from 0 through 63; encoded zero selects source bit zero.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every imml and immr value is assigned. The selected N-bit field begins at bit M and wraps through bit 63 to bit 0.

## State effects

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0. If N is a multiple of eight, reverse the selected bytes into result bits N-1:0 and zero-fill higher bits; otherwise return zero normally.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before any destination effect so a GPR alias or a T/U destination push observes the pre-instruction source value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.
- A width that is not a multiple of eight is assigned and completes normally with a zero result; it is not an illegal instruction.

## Examples

- rev a0, 0, 64, ->a1
- rev u#1, 60, 16, ->t
- rev a0, 0, 7, ->zero
