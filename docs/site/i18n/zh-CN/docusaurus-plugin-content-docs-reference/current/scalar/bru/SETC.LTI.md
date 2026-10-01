<!-- GENERATED FROM: asl/scalar/bru/SETC.LTI.asl -->
# SETC.LTI

**Normative ASL source:** `asl/scalar/bru/SETC.LTI.asl`

SETC.LTI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-LTI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-lti-purpose role=purpose -->
## SETC.LTI 的作用

`SETC.LTI` 把一个标量寄存器与一个编码立即数当作有符号整数比较，并把结果发布为所在 Conditional 指令束的提交判定。

边界值存放在指令字中，因此不需要占用寄存器来保存它。

<!-- PTO-READER-BLOCK: scalar-setc-lti-mechanism role=mechanism -->
## 立即数移位之前的符号扩展

由于该字段是有符号的，模型在移位之前先把 `simm12` 符号扩展到完整字宽。符号扩展后的字再按 `shamt`（模型读作该编码字段的低 `6` 位）逻辑左移，并以移位后的值测试关系 `SInt(left) < SInt(right)`。

`SrcL` 按完整字读取，从不移位，因此即使立即数一侧被缩放，关系左侧始终是完整的寄存器值。`SrcL` 中的编码零指向架构零 GPR，该值不会被本条指令改写。

设计要点：符号扩展发生在移位之前，因此负立即数在缩放之后仍为负，而不会变成很大的正数。

<!-- PTO-READER-BLOCK: scalar-setc-lti-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 是按完整字读取的 Reg5 源：编码 `0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。
- `shamt` 提供施加于立即数的移位量；编码零表示不移位。
- `simm12` 提供有符号编码立即数；编码零提供数值零。

`SrcL` 不会被消费，也不写任何 `GPR`、`T` 或 `U` 目的。

<!-- PTO-READER-BLOCK: scalar-setc-lti-effects role=effects -->
## 效果与顺序

成功时提交参数保存恰好 `1` 或 `0`，指令束处于活动状态时 `BARG.TAKEN` 镜像该真值，指令束条件标记变为已设置，`TPC` 前进 `4` 字节。

内存、保留状态、描述符和数值状态都不改变，`BARG.BPC`、`BARG.BPCN`、`BARG.BlockType` 和 `BARG.TYPE` 保持不变。

<!-- PTO-READER-BLOCK: scalar-setc-lti-constraints role=constraints -->
## 合法性、放置与故障顺序

该操作只适用于活动 Conditional 指令束的束体，并且在那里最多只能有一个成功的 `SETC` 条件设置者完成。

错误的放置位置或重复的成功设置者会在操作数合法性检查和任何 `SrcL` 读取之前引发 `Fault_BundleControl`（陷阱编号 `5`，`BUNDLE_TRAP`）。固定位不匹配或所选的 `T`、`U` 源不可用会在提交状态、`BARG`、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。被拒绝的一次出现不会消耗共享标记。

<!-- PTO-READER-BLOCK: scalar-setc-lti-example role=example -->
## 非规范示例

本示例用于说明当前所有者，不会建立第二套语义定义。

把 `-16` 放入 GPR1，并执行编码字段为 `SrcL=1`、`shamt=2`、`simm12=-4` 的形式。符号扩展后的立即数 `-4` 按 `4` 缩放得到 `-16`，而有符号关系 `-16 < -16` 不成立，因此该形式提交 `0`。把 GPR1 设为 `-17`，同一形式则提交 `1`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.lti SrcL, simm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_lti_32_89d74d948b74 | L32 | 32 | 0x00004075 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_lti_32_89d74d948b74 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_lti_32_89d74d948b74 | shamt | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| setc_lti_32_89d74d948b74 | simm12 | 12 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_lti_32_89d74d948b74 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_lti_32_89d74d948b74 | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| setc_lti_32_89d74d948b74 | simm12 | 12 | 0–4095 | none | none | 12-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 12-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| simm12 | 12-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.LTI.asl -->
```asl
readonly func InstructionContractOperation_SETC_LTI() => ScalarOperation
begin
    return ScalarOperation_SETC_LTI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.LTI.asl -->
```asl
readonly func InstructionContractHandler_SETC_LTI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_LTI()
    => ScalarCondition
begin
    return ScalarCondition_LT;
end;

pure func InstructionContractCommitResult_SETC_LTI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_LTI(),
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

- Compute SETC.LTI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.lti SrcL, simm
