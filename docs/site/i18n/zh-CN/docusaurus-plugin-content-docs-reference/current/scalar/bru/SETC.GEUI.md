<!-- GENERATED FROM: asl/scalar/bru/SETC.GEUI.asl -->
# SETC.GEUI

**Normative ASL source:** `asl/scalar/bru/SETC.GEUI.asl`

SETC.GEUI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-GEUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-geui-purpose role=purpose -->
## SETC.GEUI 的作用

`SETC.GEUI` 把一个标量寄存器与一个编码立即数当作无符号整数比较，并把结果发布为所在 Conditional 指令束的提交判定。

右侧操作数由指令字构造，而不是来自寄存器，因此汇编期已知的边界不需要占用寄存器。

<!-- PTO-READER-BLOCK: scalar-setc-geui-mechanism role=mechanism -->
## 由 `uimm12` 与 `shamt` 构造右侧操作数

`uimm12` 先零扩展到完整字宽，再按 `shamt` 字段逻辑左移，模型把该字段读作其编码值的低 `6` 位。移位后的字就是无符号关系 `UInt(left) >= UInt(right)` 所测试的值。

左侧操作数 `SrcL` 作为完整字读取，从不移位。

设计要点：移位让立即数字段覆盖普通 `12` 位字段无法达到的值，同时 `shamt` 把比较值的低位固定为零——立即数总是按 `2` 的 `shamt` 次幂的倍数比较，因此在非零移位下没有任何编码对能产生奇数值。

<!-- PTO-READER-BLOCK: scalar-setc-geui-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 是按完整字读取的 Reg5 源：编码 `0..23` 读取绝对 GPR，`24..27` 读取 `T#1..T#4`，`28..31` 读取 `U#1..U#4`。
- `shamt` 提供施加于立即数的移位量；编码零表示不移位。
- `uimm12` 提供无符号编码立即数；编码零提供数值零。

`SrcL` 不会被消费，该指令也不写任何 `GPR`、`T` 或 `U` 目的。

<!-- PTO-READER-BLOCK: scalar-setc-geui-effects role=effects -->
## 效果与顺序

成功时提交参数收到恰好 `1` 或 `0`，在指令束处于活动状态时 `BARG.TAKEN` 跟随同一真值，并把指令束条件标记为已设置。随后 `TPC` 前进 `4` 字节。

内存、保留状态、描述符和数值状态都不改变，`BARG.BPC`、`BARG.BPCN`、`BARG.BlockType` 和 `BARG.TYPE` 均保持不变。

<!-- PTO-READER-BLOCK: scalar-setc-geui-constraints role=constraints -->
## 指令束放置、顺序与故障

适用性限于活动 Conditional 指令束的束体，共享的“仅一次设置”标记允许每个指令束最多一个成功的 `SETC` 条件设置者。

错误的放置位置或重复的成功设置者会在操作数合法性检查和任何源读取之前引发 `Fault_BundleControl`（陷阱编号 `5`，`BUNDLE_TRAP`）。固定位不匹配或所选的 `T`、`U` 源不可用会在提交状态、`BARG`、队列或 `TPC` 效果之前引发 `Fault_IllegalInstruction`。被拒绝的一次出现不会消耗共享标记。

<!-- PTO-READER-BLOCK: scalar-setc-geui-example role=example -->
## 非规范示例

本示例用于说明当前所有者，不会建立第二套语义定义。

把 `128` 放入 GPR1 并执行编码字段为 `SrcL=1`、`shamt=4`、`uimm12=8` 的形式。立即数变为 `8` 左移 `4` 位，即 `128`，无符号关系 `128 >= 128` 提交 `1`。把 GPR1 设为 `127`，同一形式则提交 `0`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.geui SrcL, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_geui_32_6c34bc4ad314 | L32 | 32 | 0x00007075 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_geui_32_6c34bc4ad314 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_geui_32_6c34bc4ad314 | shamt | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| setc_geui_32_6c34bc4ad314 | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_geui_32_6c34bc4ad314 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_geui_32_6c34bc4ad314 | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| setc_geui_32_6c34bc4ad314 | uimm12 | 12 | 0–4095 | none | none | 12-bit unsigned immediate | Encoded zero supplies numeric zero for the 12-bit unsigned immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| uimm12 | 12-bit unsigned immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.GEUI.asl -->
```asl
readonly func InstructionContractOperation_SETC_GEUI() => ScalarOperation
begin
    return ScalarOperation_SETC_GEUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.GEUI.asl -->
```asl
readonly func InstructionContractHandler_SETC_GEUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_GEUI()
    => ScalarCondition
begin
    return ScalarCondition_GEU;
end;

pure func InstructionContractCommitResult_SETC_GEUI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_GEUI(),
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

- Compute SETC.GEUI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.geui SrcL, uimm
