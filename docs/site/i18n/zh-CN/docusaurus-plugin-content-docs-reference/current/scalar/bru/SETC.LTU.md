<!-- GENERATED FROM: asl/scalar/bru/SETC.LTU.asl -->
# SETC.LTU

**Normative ASL source:** `asl/scalar/bru/SETC.LTU.asl`

SETC.LTU - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-LTU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-ltu-purpose role=purpose -->
## SETC.LTU 的作用

`SETC.LTU` 把两个标量寄存器当作无符号整数比较，并把结果发布为所在 Conditional 指令束的提交判定。

正是无符号读法使该指令适用于类似地址和长度的值，其中最高位是量值位而不是符号位。

<!-- PTO-READER-BLOCK: scalar-setc-ltu-mechanism role=mechanism -->
## 在同一设置者路径下的无符号小于

该指令不持有目的寄存器。它对 `SrcL` 和准备好的右侧操作数做快照，测试 `ConditionHolds(ScalarCondition_LTU, left, right)`，关系成立时存入恰好 `1`，不成立时存入恰好 `0`。

`ConditionHolds` 比较 `UInt(left) < UInt(right)`，因此任何字都不会是负数，全一模式表示最大值而不是 `-1`。

设计要点：`SrcRType` 值 `0` 和 `3` 都保持完整 `64` 位字不变，而 `.sw` 与 `.uw` 编码会用右操作数低 `32` 位的扩展结果替换它。修饰符改变的是操作数而不是关系：在任何编码下 `SETC.LTU` 都保持无符号。

<!-- PTO-READER-BLOCK: scalar-setc-ltu-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 是 Reg5 源：编码 `0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。
- `SrcR` 使用相同的 Reg5 映射。
- `SrcRType` 在测试关系之前变换 `SrcR` 快照：值 `1` 代入低 `32` 位的符号扩展结果，值 `2` 代入低 `32` 位的零扩展结果，值 `0` 和 `3` 保持完整字不变。

`SrcL` 或 `SrcR` 中的编码零指向架构零 GPR。两个源都不会被消费，也不写任何 `GPR`、`T` 或 `U` 目的。

<!-- PTO-READER-BLOCK: scalar-setc-ltu-effects role=effects -->
## 效果与顺序

成功时规范化条件写入提交参数，指令束处于活动状态时 `BARG.TAKEN` 取同一真值，指令束条件标记变为已设置，`TPC` 前进 `4` 字节。

没有内存、保留状态、描述符或数值状态效果，`BARG.BPC`、`BARG.BPCN`、`BARG.BlockType` 和 `BARG.TYPE` 保持不变。

<!-- PTO-READER-BLOCK: scalar-setc-ltu-constraints role=constraints -->
## 设置者标记与放置检查拒绝什么

适用性限于活动 Conditional 指令束的束体，那里最多只能有一个成功的 `SETC` 条件设置者完成。

错误的放置位置或第二个成功的设置者会在操作数合法性检查和任何源读取之前引发 `Fault_BundleControl`（陷阱编号 `5`，`BUNDLE_TRAP`）。固定位不匹配或所选的 `T`、`U` 源不可用会在提交状态、`BARG`、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。被拒绝的一次出现不会消耗共享标记。

<!-- PTO-READER-BLOCK: scalar-setc-ltu-example role=example -->
## 非规范示例

本示例用于说明当前所有者，不会建立第二套语义定义。

把 `0` 放入 GPR1、`0` 放入 GPR2，然后执行 `setc.ltu R1, R2`。无符号关系 `0 < 0` 不成立，因此该形式提交 `0`。把 GPR2 设为 `1`，同一形式提交 `1`，因为无符号 `0 < 1` 成立。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.ltu SrcL, SrcR<{.sw, .uw}>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_ltu_32_4a1ff65ecafb | L32 | 32 | 0x00006065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_ltu_32_4a1ff65ecafb | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_ltu_32_4a1ff65ecafb | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_ltu_32_4a1ff65ecafb | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_ltu_32_4a1ff65ecafb | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_ltu_32_4a1ff65ecafb | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_ltu_32_4a1ff65ecafb | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.LTU.asl -->
```asl
readonly func InstructionContractOperation_SETC_LTU() => ScalarOperation
begin
    return ScalarOperation_SETC_LTU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.LTU.asl -->
```asl
readonly func InstructionContractHandler_SETC_LTU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_LTU()
    => ScalarCondition
begin
    return ScalarCondition_LTU;
end;

pure func InstructionContractCommitResult_SETC_LTU(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_LTU(),
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

- Compute SETC.LTU's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.ltu SrcL, SrcR<{.sw, .uw}>
