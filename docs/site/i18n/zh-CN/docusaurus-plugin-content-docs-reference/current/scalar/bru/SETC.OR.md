<!-- GENERATED FROM: asl/scalar/bru/SETC.OR.asl -->
# SETC.OR

**Normative ASL source:** `asl/scalar/bru/SETC.OR.asl`

SETC.OR - Combine scalar comparison results and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-OR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-or-purpose role=purpose -->
## SETC.OR 的作用

`SETC.OR` 用按位 OR 组合两个标量寄存器，并把组合结果是否非零发布为所在 Conditional 指令束的提交判定。

这使该助记符成为对两个字的析取：只要任一操作数贡献了至少一个置位比特，指令束就提交。

<!-- PTO-READER-BLOCK: scalar-setc-or-mechanism role=mechanism -->
## 用按位 OR 组合两个字

该指令对 `SrcL` 和准备好的右侧操作数做快照，计算两个完整字的按位 OR，组合为零时存入恰好 `0`，否则存入恰好 `1`。

与家族中的关系类成员不同，这里不涉及数值条件：被测试的性质是 OR 是否产生了任何置位比特。

设计要点：提交的是归约后的真值，而不是 OR 结果。组合产生的字不会写入任何位置，因此需要组合后比特的程序必须另行计算。

<!-- PTO-READER-BLOCK: scalar-setc-or-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供左侧绝对 GPR 源。
- `SrcR` 提供右侧绝对 GPR 源。
- `SrcRType` 在组合之前变换 `SrcR` 快照：值 `0` 保持完整字不变，值 `1` 代入低 `32` 位的符号扩展结果，值 `2` 代入低 `32` 位的零扩展结果，值 `3` 代入完整字的按位取反，即规范汇编上的 `.not` 标注。

`SrcL` 或 `SrcR` 中的编码零指向架构零 GPR。源不会被消费，也不写任何 `GPR`、`T` 或 `U` 目的。

<!-- PTO-READER-BLOCK: scalar-setc-or-effects role=effects -->
## 效果与顺序

成功时提交参数收到恰好 `1` 或 `0`，指令束处于活动状态时 `BARG.TAKEN` 取同一真值，指令束条件标记变为已设置，`TPC` 前进 `4` 字节。

不产生内存、保留状态、描述符或数值状态效果，`BARG.BPC`、`BARG.BPCN`、`BARG.BlockType` 和 `BARG.TYPE` 保持不变。

<!-- PTO-READER-BLOCK: scalar-setc-or-constraints role=constraints -->
## 设置者标记与放置检查拒绝什么

适用性限于活动 Conditional 指令束的束体，共享标记允许该指令束中最多一个成功的 `SETC` 条件设置者。

错误的放置位置或第二个成功的设置者会在操作数合法性检查和任何源读取之前引发 `Fault_BundleControl`（陷阱编号 `5`，`BUNDLE_TRAP`）。固定位不匹配或所选的 `T`、`U` 源不可用会在提交状态、`BARG`、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。被拒绝的一次出现不会消耗共享标记。

<!-- PTO-READER-BLOCK: scalar-setc-or-example role=example -->
## 非规范示例

This example illustrates the current owner and does not create a second semantic definition.

把 `0` 放入 GPR1、`0` 放入 GPR2，然后执行 `setc.or R1, R2`。两个零字的 OR 为零，因此该形式提交 `0`。把 GPR1 设为 `4`，同一形式提交 `1`，尽管只置位了一个比特。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.or SrcL, SrcR<.sw, .uw, .not>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_or_32_740134c709d2 | L32 | 32 | 0x00003065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_or_32_740134c709d2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_or_32_740134c709d2 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_or_32_740134c709d2 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_or_32_740134c709d2 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_or_32_740134c709d2 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_or_32_740134c709d2 | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.OR.asl -->
```asl
readonly func InstructionContractOperation_SETC_OR() => ScalarOperation
begin
    return ScalarOperation_SETC_OR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.OR.asl -->
```asl
readonly func InstructionContractHandler_SETC_OR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;

pure func InstructionContractCombinesWithOR_SETC_OR()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractCommitLogicalValue_SETC_OR(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_SETC_OR() then
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

- Compute SETC.OR's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.or SrcL, SrcR<.sw, .uw, .not>
