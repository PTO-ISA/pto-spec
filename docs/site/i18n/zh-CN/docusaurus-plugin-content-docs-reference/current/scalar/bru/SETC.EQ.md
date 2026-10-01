<!-- GENERATED FROM: asl/scalar/bru/SETC.EQ.asl -->
# SETC.EQ

**Normative ASL source:** `asl/scalar/bru/SETC.EQ.asl`

SETC.EQ - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-EQ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-eq-purpose role=purpose -->
## SETC.EQ 的作用

`SETC.EQ` 比较两个标量寄存器是否相等，并把结果提交给所在的条件指令束。它是相等条件的寄存器形式：不写任何目的，判定本身就是块的提交值。

设计要点：相等是在完整 `64` 位字上判定的，因此只有当右操作数在第 `31` 位或更高位上有 `1` 时，`.sw` 与 `.uw` 才会彼此不同。比较绝不会被收窄到 `32` 位。

<!-- PTO-READER-BLOCK: scalar-setc-eq-mechanism role=mechanism -->
## 相等判定的形成方式

读取 `SrcL` 与 `SrcR`，对右值施加 `SrcRType`。处理程序判断两个 `64` 位字是否相等，相等时提交 `1`，不相等时提交 `0`。

设计要点：两个源都在写入任何提交状态之前读取，因此指向该块自身要更新的寄存器是安全的：比较用的始终是更新前的值。

设计要点：提交值在存储之前就规范化为 `1` 或 `0`，因此指令束的判定不取决于由哪些非零操作数产生。

<!-- PTO-READER-BLOCK: scalar-setc-eq-inputs-outputs role=inputs-outputs -->
## 操作数与结果位置

- `SrcL` 按 `Reg5` 源规则提供左操作数：编码 `0` 到 `23` 读取绝对 GPR，编码 `24` 到 `27` 读取 T 队列，编码 `28` 到 `31` 读取 U 队列。若队列编码对应的项无效，指令会在任何读取之前被拒绝。

- `SrcR` 按同一套 `Reg5` 源规则提供右操作数。若队列编码对应的项无效，指令会在任何读取之前被拒绝。

- `SrcRType` 选择右源的变换：`01` 是 `.sw`，把低 `32` 位符号扩展；`10` 是 `.uw`，把低 `32` 位零扩展。

设计要点：没有目的寄存器字段。比较判定进入块提交状态，因此条件设置操作无法编码出丢弃型、GPR 或队列目的，也不会与产生值的比较混淆。

设计要点：规范汇编在此只给出 `.sw` 与 `.uw` 两个后缀，因此原始值 `00` 与 `11` 没有各自的后缀。但两者都不是保留值：`ApplyRestrictedCompareModifier` 对二者都让右源保持不变，因此原始 `11` 的编码提交的结果与原始 `00` 完全相同。

<!-- PTO-READER-BLOCK: scalar-setc-eq-effects role=effects -->
## 提交状态与顺序

规范化的 `1` 或 `0` 写入块提交参数，块的已选中标志接收同一真值，随后置位共享的条件已设置标记。这三处写入在同一步处理中完成。

设计要点：提交参数先写入，再由它导出已选中标志，两者之间不会发生故障，因此不存在二者不一致的可观察指令束状态。

由于处理程序不写 `TPC`，随后由分派边界让 `TPC` 前进 `4` 字节，即该 `32` 位形式的编码长度。不写任何寄存器、内存位置或数值状态。

<!-- PTO-READER-BLOCK: scalar-setc-eq-constraints role=constraints -->
## 放置要求、单次设置规则与故障顺序

`SETC.EQ` 只在活动的条件指令束尚未设置条件时适用。适用性判定还会要求 body 已激活，而派发入口会在该判定之前就为活动指令束激活 body，因此 body 尚未激活本身并不是被拒绝的情形。指令束未处于活动状态、传递类型不是 `Conditional`，或该指令束已经接受过一个条件设置操作时，都会在读取源之前、写入任何提交状态之前引发 `Fault_BundleControl`（陷阱编号 `5`，`BUNDLE_TRAP`）。

设计要点：块只保留一个共享的条件已设置标记，只有成功的一次执行才会置位它。因编码或操作数检查被拒绝的 `SETC.EQ` 不会置位该标记，因此同一块中后续的条件设置操作仍可提交。被拒绝的一次不消耗任何资源。

该形式的固定位必须匹配，且每个所选的源编码都必须可用，否则会引发 `Fault_IllegalInstruction`，`TPC` 保持不变。没有任何保留字段值。

设计要点：进入指令束 body 发生在适用性检查之前，因此被拒绝的条件设置操作会让 body 保持已激活。该拒绝不会回退这次状态转换。

<!-- PTO-READER-BLOCK: scalar-setc-eq-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

当 `a0` 持有 `0x0000000000000005`、`a1` 持有 `0x0000000000000005` 时，`setc.eq a0, a1.uw` 把 `1` 写入提交参数并把该块标记为已选中。当 `a1` 持有 `0x0000000000000006` 时，同一编码写入 `0` 并标记为未选中。

在块结束时由已选中标志选择后续去向：已选中的条件指令束在候选的下一个 `PC` 处继续，未选中的则顺序继续。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.eq SrcL, SrcR<{.sw, .uw}>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_eq_32_fb06e1dddc5c | L32 | 32 | 0x00000065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_eq_32_fb06e1dddc5c | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_eq_32_fb06e1dddc5c | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_eq_32_fb06e1dddc5c | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_eq_32_fb06e1dddc5c | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_eq_32_fb06e1dddc5c | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_eq_32_fb06e1dddc5c | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.EQ.asl -->
```asl
readonly func InstructionContractOperation_SETC_EQ() => ScalarOperation
begin
    return ScalarOperation_SETC_EQ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.EQ.asl -->
```asl
readonly func InstructionContractHandler_SETC_EQ() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_EQ()
    => ScalarCondition
begin
    return ScalarCondition_EQ;
end;

pure func InstructionContractCommitResult_SETC_EQ(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_EQ(),
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

- Compute SETC.EQ's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.eq SrcL, SrcR<{.sw, .uw}>
