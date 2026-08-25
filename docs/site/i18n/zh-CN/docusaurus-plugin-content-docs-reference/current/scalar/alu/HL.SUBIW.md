<!-- GENERATED FROM: asl/scalar/alu/HL.SUBIW.asl -->
# HL.SUBIW

**Normative ASL source:** `asl/scalar/alu/HL.SUBIW.asl`

HL.SUBIW applies word subtraction to SrcL[31:0] and the low word of a zero-extended 24-bit immediate, then sign-extends the 32-bit result.

## Normative identity {#PTO-INST-SCALAR-HL-SUBIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-subiw-purpose role=purpose -->
## HL.SUBIW 的作用

`HL.SUBIW` 是一条 48 位标量 ALU 指令。它按照低 32 位字，再符号扩展到 XLEN结果规则执行减法；当前指令契约定义结果发布路径以及任何额外状态效果。

<!-- PTO-READER-BLOCK: scalar-hl-subiw-mechanism role=mechanism -->
## 结果形成方式

执行时先对编码输入做快照，然后按照低 32 位字，再符号扩展到 XLEN结果规则执行减法，最后才产生目标效果。

- 立即数宽度与扩展规则由下方编码字段确定；除非生成契约给出其他零值含义，编码零提供数值零。
- 结果发布使用当前指令契约为该助记符确定的位宽与扩展规则。

<!-- PTO-READER-BLOCK: scalar-hl-subiw-inputs role=inputs-outputs -->
## 输入与目标

- `RegDst` 是 5 位字段，选择 Reg5 标量结果目标，或丢弃结果。
- `SrcL` 是 5 位字段，通过 Reg5 选择标量值，其中只有低 32 位参与。
- `uimm24` 是 24 位无符号字段，携带无符号分段 24 位立即数。

这些角色来自当前指令契约；T/U 源只被读取和快照，不会因源选择而出队。编码零的精确含义列在下方生成的默认值章节中。

<!-- PTO-READER-BLOCK: scalar-hl-subiw-effects role=effects -->
## 效果与顺序

所有标量源都在目标效果前完成快照。完成后的值随后通过 `RegDst` 按当前标量目标映射发布。

该 ALU 操作不产生内存效果。成功完成架构效果后，`TPC` 前进 6 字节。

该操作不会产生隐藏的标量发布目标或隐式内存访问。架构变化仅限于当前契约列出的状态效果。

<!-- PTO-READER-BLOCK: scalar-hl-subiw-constraints role=constraints -->
## 合法性与故障边界

固定宽度算术按当前操作规则回绕，不产生算术异常；固定编码位不匹配或所选 T/U 源不可用时，会在结果发布和 `TPC` 前进之前触发 `Fault_IllegalInstruction`。

下方生成的合法性表是已分配字段值、保留编码和目标丢弃编码的权威说明。解码与源可用性检查先于架构效果完成。

<!-- PTO-READER-BLOCK: scalar-hl-subiw-example role=example -->
## 非规范演算示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

以一个小型 `HL.SUBIW` 示例说明：`SrcL=7` 与 `uimm24=3` 产生 `4`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.subiw SrcL, uimm, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_subiw_48_adc7b127a2f8 | HL48 | 48 | 0x00001035000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_subiw_48_adc7b127a2f8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_subiw_48_adc7b127a2f8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_subiw_48_adc7b127a2f8 | uimm24 | 24 | unsigned | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_subiw_48_adc7b127a2f8 | RegDst | 5 | 0–31 | none | none | Reg5 scalar destination or discard selector | Encoded zero discards the result and does not modify any GPR or queue. |
| hl_subiw_48_adc7b127a2f8 | SrcL | 5 | 0–31 | none | none | Reg5 scalar source; only bits 31:0 participate | Encoded zero reads architectural GPR zero. |
| hl_subiw_48_adc7b127a2f8 | uimm24 | 24 | 0–16777215 | none | none | unsigned split 24-bit immediate | Encoded zero supplies numeric zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 scalar destination or discard selector |
| SrcL | Reg5 scalar source; only bits 31:0 participate |
| uimm24 | unsigned split 24-bit immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.SUBIW.asl -->
```asl
readonly func InstructionContractOperation_HL_SUBIW() => ScalarOperation
begin
    return ScalarOperation_HL_SUBIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.SUBIW.asl -->
```asl
readonly func InstructionContractHandler_HL_SUBIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;

pure func InstructionContractImmediateWidth_HL_SUBIW()
    => integer {1..64}
begin
    return 24;
end;

pure func InstructionContractImmediateIsUnsigned_HL_SUBIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractIsWordOperation_HL_SUBIW()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractResult_HL_SUBIW(
    left: Word,
    immediate: bits(24))
    => Word
begin
    let right = ZeroExtend{PTO_XLEN}(immediate);
    return ScalarBinaryW(
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

- Take SrcL[31:0] and the low 32 bits of the zero-extended uimm24, compute word subtraction modulo 2^32, sign-extend the 32-bit result to PTO_XLEN, and publish it through RegDst.
- Codes 1..23 write a GPR; codes 0 and 24..29 discard; code 30 pushes U; code 31 pushes T. Relative source reads are non-consuming.
- No memory, reservation, descriptor, Tile, block, privilege, numeric-status, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before the destination effect, including GPR aliases and same-queue read-then-push cases.
- Publish the result through RegDst, then advance TPC by six bytes.

## Exceptions

- HL.SUBIW raises no arithmetic exception; fixed-width overflow or underflow is discarded.
- A fixed-bit mismatch or unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.subiw a0, 1, ->a0
- hl.subiw t#1, 16777215, ->u
- hl.subiw zero, 0, ->zero
