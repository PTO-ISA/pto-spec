<!-- GENERATED FROM: asl/scalar/alu/HL.BFI.asl -->
# HL.BFI

**Normative ASL source:** `asl/scalar/alu/HL.BFI.asl`

HL.BFI inserts ascending low source bits into an inclusive wrapping destination interval of a snapshotted base value and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-HL-BFI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-bfi-purpose role=purpose -->
## HL.BFI 的作用

`HL.BFI` 是一条 48 位标量 ALU 指令。它从源的第 0 位开始，把插入源的连续位升序复制到基值快照的一个闭合区间中，并发布一个 XLEN 结果。

设计要点：该区间由两个 6 位字段指定，其宽度为 `(((imms - immr) + 64) MOD 64) + 1`。端点相等时恰好选择一个目标位，而 `imms` 位于 `immr` 之前时，区间会经过位 63 回绕到位 0。

<!-- PTO-READER-BLOCK: scalar-hl-bfi-mechanism role=mechanism -->
## 结果形成方式

`InsertBitfield` 复制基值，计算宽度，并从源位 0 开始升序地把源位 `i` 写到目标位 `(first + i) MOD 64`（`asl/scalar/model/alu/semantics.asl:311-321`）。

取模正是区间能够回绕的原因：当 `immr=63`、`imms=0` 时宽度为 `2`，于是源位 0 落到目标位 63，源位 1 落到位 0。

设计要点：结果以基值的副本为起点，因此只有被选中的位位置会改变；`immr=1, imms=0` 选中全部 `64` 位并替换整个值，而窄区间保留基值的其余位、并让源的高位保持不被使用。

<!-- PTO-READER-BLOCK: scalar-hl-bfi-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst` 选择 Reg5 结果目标，或丢弃结果。
- `SrcL` 是基值源：编码 `0..23` 选择绝对 GPR，`24..27` 选择 `T#1..T#4`，`28..31` 选择 `U#1..U#4`。
- `SrcR` 是插入源，使用同一套映射。
- `immr` 是 6 位首个目标位。
- `imms` 是 6 位最后目标位。

对 `T` 或 `U` 的相对读取不会消费队列项。`SrcL` 或 `SrcR` 的零编码读取架构零 GPR，`RegDst` 的零编码丢弃结果，而 `immr` 或 `imms` 的零编码表示位位置 `0`，不是省略该操作数。

设计要点：`immr` 与 `imms` 是位置而不是标志：`immr=0, imms=0` 选中单个位 `0`，因此 `hl.bfi a0, a1, 0, 0, ->a2` 只改变基值 `a0` 的这一位。

<!-- PTO-READER-BLOCK: scalar-hl-bfi-effects role=effects -->
## 效果与顺序

两个源都在目标效果之前读取，因为派发把这两次读取作为执行写入那次调用的实参传入。

结果只通过 `RegDst` 发布：编码 `1..23` 写该 GPR，编码 `30` 压入 `U`，编码 `31` 压入 `T`；`immr` 与 `imms` 永远不是发布目标。压入使该值成为最新的队列项。

`HL.BFI` 没有内存效果，也不改变其他架构状态。目标效果之后，`TPC` 前进 `6` 字节（`asl/scalar/model/dispatch/top-level.asl:55-57`）。

设计要点：`RegDst` 可能与 `SrcL` 指向同一个 GPR，因此先读后写的顺序是可观察的：`hl.bfi a0, a1, 8, 15, ->a0` 保留旧 `a0` 中所有未被选中的位。

<!-- PTO-READER-BLOCK: scalar-hl-bfi-constraints role=constraints -->
## 合法性与故障边界

`immr` 与 `imms` 从 `0` 至 `63` 的每个取值都已分配，因此宽度范围为 `1` 至 `64`；丢弃编码 `0` 与 `24..29` 是合法的，且不产生写入。

固定编码位与 `HL48` 形式不匹配的编码不会被译码为 `HL.BFI`；不匹配任何已接受形式的编码会在读取任何寄存器之前，于 `PC` 处引发 `Fault_IllegalInstruction`。所选 `T` 或 `U` 源不可用会在目标效果之前、`TPC` 前进之前，于 `PC` 处引发 `Fault_IllegalInstruction`；即使两个源编码相同，它们也都会被预检。不适用于当前指令束的指令会在 `TPC` 处触发 `Fault_BundleControl`（`asl/scalar/model/dispatch/top-level.asl:17-37`，`asl/scalar/model/types/operands.asl:6-19`）。

设计要点：区间由两个 6 位字段和一次取模得到，因此任何操作数取值都不会让它变成未定义。`HL.BFI` 不会引发算术、内存、对齐、权限或控制流异常。

<!-- PTO-READER-BLOCK: scalar-hl-bfi-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

基值 `a0` 为 `0`、插入源 `a1` 为 `0xff`、`immr=8`、`imms=15` 时宽度为 `8`：源位 `0..7` 落到目标位 `8..15`，因此 `hl.bfi a0, a1, 8, 15, ->a2` 发布 `0xff00`。

当 `immr=63`、`imms=0` 时宽度为 `2`，因此元数据示例 `hl.bfi t#1, u#1, 63, 0, ->t` 把 `U#1` 的位 0 放入结果的位 63、位 1 放入结果的位 0，其余各位都取自基值 `T#1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_bfi_48_8adfd476aacc | HL48 | 48 | 0x0000204d000e / 0xfe00707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_bfi_48_8adfd476aacc | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | immr | 6 | encoding-defined | [{"instruction_lsb":4,"value_lsb":0,"width":6}] |
| hl_bfi_48_8adfd476aacc | imms | 6 | encoding-defined | [{"instruction_lsb":10,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_bfi_48_8adfd476aacc | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| hl_bfi_48_8adfd476aacc | SrcL | 5 | 0–31 | none | none | Reg5 base source | Encoded zero reads the architectural zero GPR base. |
| hl_bfi_48_8adfd476aacc | SrcR | 5 | 0–31 | none | none | Reg5 insertion source | Encoded zero reads the architectural zero GPR insertion source. |
| hl_bfi_48_8adfd476aacc | immr | 6 | 0–63 | none | none | first destination bit | Encoded zero begins the destination interval at bit zero. |
| hl_bfi_48_8adfd476aacc | imms | 6 | 0–63 | none | none | last destination bit | Encoded zero ends the destination interval at bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 base source |
| SrcR | Reg5 insertion source |
| immr | first destination bit |
| imms | last destination bit |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.BFI.asl -->
```asl
readonly func InstructionContractOperation_HL_BFI()
    => ScalarOperation
begin
    return ScalarOperation_HL_BFI;
end;

pure func InstructionContractFirstBit_HL_BFI(encoded_immr: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_immr);
end;

pure func InstructionContractLastBit_HL_BFI(encoded_imms: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_imms);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.BFI.asl -->
```asl
readonly func InstructionContractHandler_HL_BFI()
    => ScalarSemanticHandler
begin
    return ScalarHandler_InsertBitfield;
end;

pure func InstructionContractResult_HL_BFI(
    base: Word,
    source: Word,
    first: integer {0..63},
    last: integer {0..63})
    => Word
begin
    return InsertBitfield(
        base,
        source,
        first,
        last);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, immr, imms, and RegDst are required encoded fields; no field can be omitted.
- immr directly encodes the first destination bit from 0 through 63. imms directly encodes the last destination bit from 0 through 63.
- When imms precedes immr, the inclusive destination interval wraps through bit 63 to bit 0. Equal endpoints select one destination bit.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every immr and imms value is assigned. The inclusive wrapping interval has a width from 1 through 64.

## State effects

- Snapshot the base and insertion sources. Starting with source bit zero, replace ascending bits of the inclusive destination interval from immr through imms, wrapping through bit 63 when required; preserve every base bit outside that interval.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before any destination effect, including when RegDst aliases SrcL or SrcR.
- Publish the result, then advance TPC by six bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances. Both sources are preflighted even when their encoded values are equal.
- HL.BFI raises no arithmetic, memory, alignment, permission, or control-flow exception.

## Examples

- hl.bfi a0, a1, 8, 15, ->a2
- hl.bfi t#1, u#1, 63, 0, ->t
- hl.bfi a0, zero, 0, 63, ->a0
