<!-- GENERATED FROM: asl/scalar/bru/SETC.ORI.asl -->
# SETC.ORI

**Normative ASL source:** `asl/scalar/bru/SETC.ORI.asl`

SETC.ORI - Combine scalar comparison results and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-ORI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-ori-purpose role=purpose -->
## SETC.ORI 的作用

`SETC.ORI` 用一个编码立即数对某个标量寄存器做按位 OR 组合，并把组合结果是否非零发布为所在 Conditional 指令束的提交判定。

立即数是由指令携带的常量掩码，因此“任何非零寄存器都满足”的测试不需要第二个寄存器。

<!-- PTO-READER-BLOCK: scalar-setc-ori-mechanism role=mechanism -->
## 符号扩展后的常量掩码

有符号字段 `simm12` 先符号扩展到完整字宽，再按 `shamt`（模型读作该编码字段的低 `6` 位）逻辑左移。该指令把完整左侧字与该移位后的值做 OR，组合为零时存入恰好 `0`，否则存入恰好 `1`。

左侧操作数按完整字读取，从不移位。

设计要点：由于立即数在移位之前先做符号扩展，全一立即数经缩放后仍然保留，使 OR 对左侧操作数的任何取值都非零；这是用立即数形式无条件提交一个条件的方法。

<!-- PTO-READER-BLOCK: scalar-setc-ori-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供左侧绝对 GPR 源，按完整字读取。
- `shamt` 提供施加于立即数的移位量；编码零表示不移位。
- `simm12` 提供有符号编码立即数；编码零提供数值零。

`SrcL` 不会被消费，也不写任何 `GPR`、`T` 或 `U` 目的。

<!-- PTO-READER-BLOCK: scalar-setc-ori-effects role=effects -->
## 效果与顺序

成功时提交参数保存恰好 `1` 或 `0`，指令束处于活动状态时 `BARG.TAKEN` 镜像该真值，指令束条件标记变为已设置，`TPC` 前进 `4` 字节。

没有内存、保留状态、描述符或数值状态效果，`BARG.BPC`、`BARG.BPCN`、`BARG.BlockType` 和 `BARG.TYPE` 保持不变。

<!-- PTO-READER-BLOCK: scalar-setc-ori-constraints role=constraints -->
## 设置者标记与放置检查拒绝什么

该操作只适用于活动 Conditional 指令束的束体，那里最多只能有一个成功的 `SETC` 条件设置者完成。

错误的放置位置或重复的成功设置者会在操作数合法性检查和任何源读取之前引发 `Fault_BundleControl`（陷阱编号 `5`，`BUNDLE_TRAP`）。固定位不匹配或所选的 `T`、`U` 源不可用会在提交状态、`BARG`、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。被拒绝的一次出现不会消耗共享标记。

<!-- PTO-READER-BLOCK: scalar-setc-ori-example role=example -->
## 非规范示例

This example illustrates the current owner and does not create a second semantic definition.

把 `0` 放入 GPR1，并执行编码字段为 `SrcL=1`、`shamt=0`、`simm12=-1` 的形式。立即数符号扩展为全一字，OR 对任何左侧操作数都非零，因此该形式提交 `1`。若 `simm12=0` 且 GPR1 仍为 `0`，同一形式则提交 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.ori SrcL, simm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_ori_32_183dc15fad54 | L32 | 32 | 0x00003075 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_ori_32_183dc15fad54 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_ori_32_183dc15fad54 | shamt | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| setc_ori_32_183dc15fad54 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_ori_32_183dc15fad54 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_ori_32_183dc15fad54 | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| setc_ori_32_183dc15fad54 | simm12 | 12 | 0–4095 | none | none | 12-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| simm12 | 12-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.ORI.asl -->
```asl
readonly func InstructionContractOperation_SETC_ORI() => ScalarOperation
begin
    return ScalarOperation_SETC_ORI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.ORI.asl -->
```asl
readonly func InstructionContractHandler_SETC_ORI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;

pure func InstructionContractCombinesWithOR_SETC_ORI()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCommitLogicalValue_SETC_ORI(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_SETC_ORI() then
        return left OR right;
    end;
    return left AND right;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- All SETC condition setters share one block-private successful-occurrence marker; a failed first occurrence does not consume it.

## State effects

- Compute SETC.ORI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
- Atomically write that value to the commit argument and BARG.TAKEN, then mark the block condition as set. Preserve BARG.BPC, BARG.BPCN, BARG.BlockType, and BARG.TYPE.
- No memory, reservation, descriptor, numeric-status, or destination-register effect occurs. Successful execution advances TPC by the encoded instruction length.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check Conditional-block applicability and the shared occurrence marker before scalar source readiness or reads.
- Snapshot all sources, compute the canonical zero-or-one condition, then atomically update the commit argument, BARG.TAKEN, and the occurrence marker.

## Exceptions

- Wrong block placement or a second successful SETC condition setter raises Illegal Block Exception before scalar source readiness or any architectural or pending-block effect.
- A fixed-bit mismatch or unavailable selected relative source raises Fault_IllegalInstruction before commit state, BARG, queues, or TPC effects.

## Examples

- setc.ori SrcL, simm
