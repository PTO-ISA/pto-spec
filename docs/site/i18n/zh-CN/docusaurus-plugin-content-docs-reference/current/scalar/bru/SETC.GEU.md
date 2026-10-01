<!-- GENERATED FROM: asl/scalar/bru/SETC.GEU.asl -->
# SETC.GEU

**Normative ASL source:** `asl/scalar/bru/SETC.GEU.asl`

SETC.GEU - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-GEU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-geu-purpose role=purpose -->
## SETC.GEU 的作用

`SETC.GEU` 把两个标量寄存器当作无符号整数比较，并把结果发布为所在 Conditional 指令束的提交判定。

发布的值不是通用结果：它写入提交参数（commit argument），该指令束在决定是否执行条件转移时读取它，同时它也驱动 `BARG.TAKEN`。

<!-- PTO-READER-BLOCK: scalar-setc-geu-mechanism role=mechanism -->
## GEU 条件如何判定

该指令没有目的寄存器。它对 `SrcL` 和准备好的右侧操作数做快照，测试 `ConditionHolds(ScalarCondition_GEU, left, right)`，关系成立时存入恰好 `1`，不成立时存入恰好 `0`。

`ConditionHolds` 比较 `UInt(left) >= UInt(right)`。两个操作数都是完整 `64` 位字，因此最高位为一的模式表示一个非常大的数，而不是负数。

设计要点：提交值被规范化为 `1` 或 `0`，而不是任意非零值，因此指令束判定不必再检查原始比较残值——只需测试一次提交参数即可。

<!-- PTO-READER-BLOCK: scalar-setc-geu-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供左侧绝对 GPR 源。
- `SrcR` 提供右侧绝对 GPR 源。
- `SrcRType` 选择在测试关系之前施加于 `SrcR` 快照的变换：值 `1` 代入低 `32` 位的符号扩展结果，值 `2` 代入低 `32` 位的零扩展结果，值 `0` 和 `3` 都保持完整值不变。

`SrcL` 或 `SrcR` 中的编码零指向架构零 GPR。两个源都不会被消费，该指令也不写任何 `GPR`、`T` 或 `U` 目的。

<!-- PTO-READER-BLOCK: scalar-setc-geu-effects role=effects -->
## 效果与顺序

成功时该指令把规范化条件写入提交参数，在指令束处于活动状态时把 `BARG.TAKEN` 置为同一真值，标记指令束条件已设置，然后才把 `TPC` 前进 `4` 字节，即 `32` 位形式的编码长度。

它没有内存效果、没有保留状态效果，也没有数值状态标志。`BARG.BPC`、`BARG.BPCN`、`BARG.BlockType` 和 `BARG.TYPE` 保持原值。

设计要点：处理程序先写入提交参数，再从同一个字推导 `BARG.TAKEN`，且处理程序内部不会在这两次写入之间产生故障，因此不存在两者不一致的可观察指令束状态。

<!-- PTO-READER-BLOCK: scalar-setc-geu-constraints role=constraints -->
## 指令束放置、顺序与故障

该操作只适用于活动指令束的束体，且其转移类型为 Conditional；在同一指令束中，`SETC` 条件设置家族只能有一个成员成功完成。

错误的放置位置或第二个成功的设置者会在任何源就绪检查或源读取之前引发 `Fault_BundleControl`（陷阱编号 `5`，`BUNDLE_TRAP`）。固定位不匹配或所选的 `T`、`U` 源不可用会在提交状态、`BARG`、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。被拒绝的一次出现不会消耗共享的“仅一次设置”标记，因此之后一个形式正确的设置者仍可成功。

<!-- PTO-READER-BLOCK: scalar-setc-geu-example role=example -->
## 非规范示例

This example illustrates the current owner and does not create a second semantic definition.

把 `5` 放入 GPR1、`5` 放入 GPR2，然后执行 `setc.geu R1, R2`。无符号关系 `5 >= 5` 成立，因此提交参数和 `BARG.TAKEN` 变为 `1`。把 GPR2 设为 `6`，同一形式则提交 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.geu SrcL, SrcR<{.sw, .uw}>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_geu_32_494f1f79099e | L32 | 32 | 0x00007065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_geu_32_494f1f79099e | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_geu_32_494f1f79099e | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_geu_32_494f1f79099e | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_geu_32_494f1f79099e | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_geu_32_494f1f79099e | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_geu_32_494f1f79099e | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.GEU.asl -->
```asl
readonly func InstructionContractOperation_SETC_GEU() => ScalarOperation
begin
    return ScalarOperation_SETC_GEU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.GEU.asl -->
```asl
readonly func InstructionContractHandler_SETC_GEU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_GEU()
    => ScalarCondition
begin
    return ScalarCondition_GEU;
end;

pure func InstructionContractCommitResult_SETC_GEU(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_GEU(),
        left,
        right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The selected assembly form determines which fields are present; every present field carries its encoded value and no encoded zero means omission.

## Legality

- All SETC condition setters share one block-private successful-occurrence marker; a failed first occurrence does not consume it.

## State effects

- Compute SETC.GEU's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.geu SrcL, SrcR<{.sw, .uw}>
