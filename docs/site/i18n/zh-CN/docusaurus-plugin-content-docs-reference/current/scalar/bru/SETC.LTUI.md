<!-- GENERATED FROM: asl/scalar/bru/SETC.LTUI.asl -->
# SETC.LTUI

**Normative ASL source:** `asl/scalar/bru/SETC.LTUI.asl`

SETC.LTUI - Compare scalar operands and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-LTUI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-ltui-purpose role=purpose -->
## SETC.LTUI 的作用

`SETC.LTUI` 判断无符号小于，并把结果发布为当前条件指令束的提交判定。

<!-- PTO-READER-BLOCK: scalar-setc-ltui-mechanism role=mechanism -->
## 执行机制

在检查源就绪状态或读取源之前，先检查放置和单次设置规则。

`uimm12` 会在任何移位或比较前零扩展到 XLEN。

在计算条件前，解码立即数会按 `shamt` 进行逻辑左移。

指令对源取快照，判断无符号小于，再规范化为 XLEN 一或零。

<!-- PTO-READER-BLOCK: scalar-setc-ltui-inputs-outputs role=inputs-outputs -->
## 输入与输出

- `SrcL` 提供左侧标量源。

- `shamt` 提供编码指定的移位量。

- `uimm12` 提供无符号编码立即数。

<!-- PTO-READER-BLOCK: scalar-setc-ltui-effects role=effects -->
## 效果与顺序

规范化条件会原子写入 `_CommitArgument` 和 `BARG.TAKEN`，同时置位条件已设置标记。

成功时，`SETC.LTUI` 让 `TPC` 前进 `4` 字节；它没有标量目的位置，也不产生内存或保留状态效果。

<!-- PTO-READER-BLOCK: scalar-setc-ltui-constraints role=constraints -->
## 合法性与故障顺序

该指令只在适用的条件指令束上下文中合法，并且只能有一个条件设置操作成功。

放置错误或重复设置会在读取源之前引发非法指令束异常；编码或源不可用会在提交状态或 `TPC` 效果前引发 `Fault_IllegalInstruction`。

<!-- PTO-READER-BLOCK: scalar-setc-ltui-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

`setc.ltui SrcL, uimm` 按上述规则计算条件，把规范化判定写入提交状态，并且只在更新完成后推进 `TPC`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.ltui SrcL, uimm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_ltui_32_7908d25901c6 | L32 | 32 | 0x00006075 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_ltui_32_7908d25901c6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_ltui_32_7908d25901c6 | shamt | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| setc_ltui_32_7908d25901c6 | uimm12 | 12 | unsigned | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_ltui_32_7908d25901c6 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_ltui_32_7908d25901c6 | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| setc_ltui_32_7908d25901c6 | uimm12 | 12 | 0–4095 | none | none | 12-bit unsigned immediate | Encoded zero supplies numeric zero for the 12-bit unsigned immediate. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| uimm12 | 12-bit unsigned immediate |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.LTUI.asl -->
```asl
readonly func InstructionContractOperation_SETC_LTUI() => ScalarOperation
begin
    return ScalarOperation_SETC_LTUI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.LTUI.asl -->
```asl
readonly func InstructionContractHandler_SETC_LTUI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommit;
end;

pure func InstructionContractCondition_SETC_LTUI()
    => ScalarCondition
begin
    return ScalarCondition_LTU;
end;

pure func InstructionContractCommitResult_SETC_LTUI(
    left: Word,
    right: Word)
    => boolean
begin
    return ConditionHolds(
        InstructionContractCondition_SETC_LTUI(),
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

- Compute SETC.LTUI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.ltui SrcL, uimm
