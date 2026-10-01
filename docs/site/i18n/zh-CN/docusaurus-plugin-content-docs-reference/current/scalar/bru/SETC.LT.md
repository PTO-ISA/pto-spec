<!-- GENERATED FROM: asl/scalar/bru/SETC.LT.asl -->
# SETC.LT

**Normative ASL source:** `asl/scalar/bru/SETC.LT.asl`

SETC.LT - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-LT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-lt-purpose role=purpose -->
## SETC.LT 的作用

`SETC.LT` 把两个标量寄存器当作有符号整数比较，并把结果发布为所在 Conditional 指令束的提交判定。

该判定写入提交参数（commit argument），指令束在条件转移时读取它，同时它也驱动 `BARG.TAKEN`。

<!-- PTO-READER-BLOCK: scalar-setc-lt-mechanism role=mechanism -->
## 在同一设置者路径下的有符号小于

该指令没有目的寄存器。它对 `SrcL` 和准备好的右侧操作数做快照，测试 `ConditionHolds(ScalarCondition_LT, left, right)`，关系成立时存入恰好 `1`，不成立时存入恰好 `0`。

`ConditionHolds` 比较 `SInt(left) < SInt(right)`，因此两个字都按二进制补码有符号值解释。最高位为一的字表示负数。

设计要点：有符号解释正是与 `SETC.LTU` 的全部区别。两个助记符运行同一设置者路径，只是契约返回的条件不同，因此程序选择的是它想要比较的语义，而不是它手头操作数的排布。

<!-- PTO-READER-BLOCK: scalar-setc-lt-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供左侧绝对 GPR 源。
- `SrcR` 提供右侧绝对 GPR 源。
- `SrcRType` 在测试关系之前变换 `SrcR` 快照：值 `1` 代入低 `32` 位的符号扩展结果，值 `2` 代入低 `32` 位的零扩展结果，值 `0` 和 `3` 保持完整字不变。

`SrcL` 或 `SrcR` 中的编码零指向架构零 GPR。源按值读取且不会被消费，也不写任何 `GPR`、`T` 或 `U` 目的。

<!-- PTO-READER-BLOCK: scalar-setc-lt-effects role=effects -->
## 效果与顺序

成功时提交参数收到规范化条件，指令束处于活动状态时 `BARG.TAKEN` 取同一真值，指令束条件标记变为已设置，随后 `TPC` 前进 `4` 字节。

该指令没有内存、保留状态、描述符或数值状态效果。`BARG.BPC`、`BARG.BPCN`、`BARG.BlockType` 和 `BARG.TYPE` 保持不变。

<!-- PTO-READER-BLOCK: scalar-setc-lt-constraints role=constraints -->
## 合法性、放置与故障顺序

适用性限于活动 Conditional 指令束的束体，共享标记允许该指令束中最多一个成功的 `SETC` 条件设置者。

错误的放置位置或第二个成功的设置者会在操作数合法性检查和任何源读取之前引发 `Fault_BundleControl`（陷阱编号 `5`，`BUNDLE_TRAP`）。固定位不匹配或所选的 `T`、`U` 源不可用会在提交状态、`BARG`、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。被拒绝的一次出现不会消耗共享标记。

<!-- PTO-READER-BLOCK: scalar-setc-lt-example role=example -->
## 非规范示例

This example illustrates the current owner and does not create a second semantic definition.

把 `-1` 放入 GPR1、`1` 放入 GPR2，然后执行 `setc.lt R1, R2`。有符号比较 `-1 < 1` 成立，因此提交参数和 `BARG.TAKEN` 变为 `1`。同样的操作数在无符号形式 `SETC.LTU` 下提交 `0`，因为 `-1` 表示最大的无符号值。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.lt SrcL, SrcR<{.sw, .uw}>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_lt_32_10de99f3ad6a | L32 | 32 | 0x00004065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_lt_32_10de99f3ad6a | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_lt_32_10de99f3ad6a | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_lt_32_10de99f3ad6a | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_lt_32_10de99f3ad6a | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_lt_32_10de99f3ad6a | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_lt_32_10de99f3ad6a | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.LT.asl -->
```asl
readonly func InstructionContractOperation_SETC_LT() => ScalarOperation
begin
    return ScalarOperation_SETC_LT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.LT.asl -->
```asl
readonly func InstructionContractHandler_SETC_LT() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_LT()
    => ScalarCondition
begin
    return ScalarCondition_LT;
end;

pure func InstructionContractCommitResult_SETC_LT(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_LT(),
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

- Compute SETC.LT's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.lt SrcL, SrcR<{.sw, .uw}>
