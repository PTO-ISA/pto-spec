<!-- GENERATED FROM: asl/scalar/alu/CTZ.asl -->
# CTZ

**Normative ASL source:** `asl/scalar/alu/CTZ.asl`

CTZ counts trailing zero bits in an independently selected wrapping scalar field and publishes the XLEN count.

## Normative identity {#PTO-INST-SCALAR-CTZ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-ctz-purpose role=purpose -->
## CTZ 的作用

`CTZ` 统计一个 Reg5 源中某个所选字段内、第一个 1 位之后的低端零位个数，并把该计数作为 XLEN 值发布。全零字段没有 1 位，此时发布的计数就是字段宽度。

设计要点：`CTZ` 与 `CLZ` 编码相同的两个字段参数并选出相同的位，只是扫描方向不同。想同时看一个窗口两端的调用者只需用相同的 `M` 和 `N` 写这两条助记符。

<!-- PTO-READER-BLOCK: scalar-ctz-mechanism role=mechanism -->
## 结果形成方式

源被右移起始位 `M`，低 `N` 位成为字段，因此当字段越过寄存器顶端时，它会从位 `63` 回绕到位 `0`。计数从字段位零开始向上走，每遇到一个零加一，直到被 1 位终止。

设计要点：调用共享计数辅助函数时与 `CLZ` 回调的区别只在方向标志，而两条助记符传入的宽度和起始参数相同。因此并不存在单独编码的“从另一端计数”；由助记符来选择。

设计要点：由于扫描向上进行而字段可以回绕，起点靠近寄存器顶端的字段会按源位 `M`、`M+1` 的顺序遍历，并在源位 `0` 处继续。计数是按这个回绕顺序表达的，而不是按从位零开始的源位升序。

<!-- PTO-READER-BLOCK: scalar-ctz-inputs role=inputs-outputs -->
## 输入与目标

- `SrcL` 选择 Reg5 源：编码 `0..23` 为绝对 GPR，`24..27` 为 `T#1..T#4`，`28..31` 为 `U#1..U#4`，读取时不消费队列项。
- `imms` 直接编码字段起始位 `M`，取值 `0` 至 `63`；编码零从源位零开始。
- `imml` 编码字段宽度 `N` 减一，取值 `0` 至 `63`；编码零选择一位宽度。
- `RegDst` 是目标或丢弃选择器：`0` 和 `24..29` 丢弃，`1..23` 写 GPR，`30` 压入 `U`，`31` 压入 `T`。

设计要点：计数作为完整的 XLEN 值发布，尽管它永远不会超过 `64`，因此编码中的这两个字段从不与结果宽度相互作用。一位字段因此只会发布 `0` 或 `1`。

<!-- PTO-READER-BLOCK: scalar-ctz-effects role=effects -->
## 效果与顺序

源在目标效果之前被读取并快照，因此 `ctz a0, 0, 64, ->a0` 统计的是旧的 `a0`，而不是它即将写入的值。XLEN 计数通过 `RegDst` 发布，只有 `T` 或 `U` 目标压入才会移动临时队列。

发布之后，`TPC` 前进 `4` 字节。内存、保留状态、描述符、数值状态、指令束、特权、分支目标和其他控制状态都不改变。

<!-- PTO-READER-BLOCK: scalar-ctz-constraints role=constraints -->
## 合法性与故障边界

每个 `imml` 和 `imms` 取值都已分配：`1` 至 `64` 的宽度和 `0` 至 `63` 的起始位都合法，固定编码位必须匹配规范形式。`CTZ` 没有任何保留或未分配的操作数取值。

所选 `T` 或 `U` 源不可用会在目标效果之前、`TPC` 前进之前引发 `Fault_IllegalInstruction`。对任何字段选择，`CTZ` 都不会引发算术、内存、对齐、权限或控制流异常。

设计要点：即使这条指令只是读取源，源不可用仍会被拒绝。拒绝发生在目标效果之前，因此引发故障的 `CTZ` 会让源、队列和 `TPC` 完全保持原样。

<!-- PTO-READER-BLOCK: scalar-ctz-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

当 `a0` 保存 `256` 时，`ctz a0, 0, 64, ->a1` 压入 `8`，因为位 `0` 至位 `7` 都是零，位 `8` 是第一个 1 位。当 `T#1` 保存 `2^63` 时，`ctz t#1, 62, 4, ->a0` 按升序用源位 `62`、`63`、`0`、`1` 组成字段并压入 `1`，因为第一个字段位是源位 `62`（为零），下一个字段位是源位 `63`（即第一个 1 位）。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ctz SrcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ctz_32_1761cbcc2a89 | L32 | 32 | 0x00004067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ctz_32_1761cbcc2a89 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ctz_32_1761cbcc2a89 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ctz_32_1761cbcc2a89 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| ctz_32_1761cbcc2a89 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ctz_32_1761cbcc2a89 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| ctz_32_1761cbcc2a89 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| ctz_32_1761cbcc2a89 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| ctz_32_1761cbcc2a89 | imms | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| imms | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/CTZ.asl -->
```asl
readonly func InstructionContractOperation_CTZ()
    => ScalarOperation
begin
    return ScalarOperation_CTZ;
end;

pure func InstructionContractWidth_CTZ(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_CTZ(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/CTZ.asl -->
```asl
readonly func InstructionContractHandler_CTZ()
    => ScalarSemanticHandler
begin
    return ScalarHandler_CountBitfield;
end;

pure func InstructionContractResult_CTZ(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return CountBitfield(
        value,
        width,
        offset,
        FALSE,
        FALSE);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, imml, imms, and RegDst are required encoded fields; no field can be omitted.
- imml encodes N minus one, so raw values 0 through 63 select widths 1 through 64; encoded zero selects N=1.
- imms directly encodes M from 0 through 63; encoded zero selects source bit zero.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every imml and imms value is assigned. The selected N-bit field begins at bit M and wraps through bit 63 to bit 0.

## State effects

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0, then count zero bits from selected field bit zero until the first one. An all-zero selected field returns N.
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
- CTZ raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- ctz a0, 0, 64, ->a1
- ctz u#1, 60, 8, ->t
- ctz zero, 0, 1, ->zero
