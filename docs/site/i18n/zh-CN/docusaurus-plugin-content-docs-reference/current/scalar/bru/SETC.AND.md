<!-- GENERATED FROM: asl/scalar/bru/SETC.AND.asl -->
# SETC.AND

**Normative ASL source:** `asl/scalar/bru/SETC.AND.asl`

SETC.AND - Combine scalar comparison results and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-SETC-AND}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-and-purpose role=purpose -->
## SETC.AND 的作用

`SETC.AND` 用按位与组合两个标量寄存器，并在组合结果非零时提交 `1`。它是带掩码位测试的寄存器形式：结果不存储在任何位置，而是成为所在条件指令束的提交判定。

设计要点：`.not` 只在逻辑设置操作 `setc.and` 与 `setc.or` 上可用，而 `setc.eq`、`setc.ge`、`setc.lt` 只接受 `.sw` 与 `.uw`。因此块可以在某位为 `0` 时直接提交，无需先用单独的指令取反。

<!-- PTO-READER-BLOCK: scalar-setc-and-mechanism role=mechanism -->
## 按位与判定的形成方式

读取 `SrcL` 与 `SrcR`，对右值施加 `SrcRType`，再把两个字按位与组合。组合结果非零时提交 `1`，为零时提交 `0`。

设计要点：提交值在存储之前就规范化为 `1` 或 `0`，因此指令束的判定不取决于由哪些非零操作数产生。

<!-- PTO-READER-BLOCK: scalar-setc-and-inputs-outputs role=inputs-outputs -->
## 操作数与结果位置

- `SrcL` 按 `Reg5` 源规则提供左操作数：编码 `0` 到 `23` 读取绝对 GPR，编码 `24` 到 `27` 读取 T 队列，编码 `28` 到 `31` 读取 U 队列。若队列编码对应的项无效，指令会在任何读取之前被拒绝。

- `SrcR` 按同一套 `Reg5` 源规则提供右操作数。若队列编码对应的项无效，指令会在任何读取之前被拒绝。

- `SrcRType` 选择右源的变换：`00` 保持不变，`01` 是 `.sw`，把低 `32` 位符号扩展，`10` 是 `.uw`，把低 `32` 位零扩展，`11` 是 `.not`，对整个 `64` 位字取反。

设计要点：没有目的寄存器字段。比较判定进入块提交状态，因此条件设置操作无法编码出丢弃型、GPR 或队列目的，也不会与产生值的比较混淆。

设计要点：`.sw` 与 `.uw` 会用右操作数的低 `32` 位重建它，只有 `.not` 会改变这些低位本身。

<!-- PTO-READER-BLOCK: scalar-setc-and-effects role=effects -->
## 提交状态与顺序

规范化的 `1` 或 `0` 写入块提交参数，块的已选中标志接收同一真值，随后置位共享的条件已设置标记。这三处写入在同一步处理中完成。

设计要点：提交参数先写入，再由它导出已选中标志，两者之间不会发生故障，因此不存在二者不一致的可观察指令束状态。

由于处理程序不写 `TPC`，随后由分派边界让 `TPC` 前进 `4` 字节，即该 `32` 位形式的编码长度。不写任何寄存器、内存位置或数值状态。

<!-- PTO-READER-BLOCK: scalar-setc-and-constraints role=constraints -->
## 放置要求、单次设置规则与故障顺序

`SETC.AND` 只在活动的条件指令束尚未设置条件时适用。适用性判定还会要求 body 已激活，而派发入口会在该判定之前就为活动指令束激活 body，因此 body 尚未激活本身并不是被拒绝的情形。指令束未处于活动状态、传递类型不是 `Conditional`，或该指令束已经接受过一个条件设置操作时，都会在读取源之前、写入任何提交状态之前引发 `Fault_BundleControl`（陷阱编号 `5`，`BUNDLE_TRAP`）。

设计要点：块只保留一个共享的条件已设置标记，只有成功的一次执行才会置位它。因编码或操作数检查被拒绝的 `SETC.AND` 不会置位该标记，因此同一块中后续的条件设置操作仍可提交。被拒绝的一次不消耗任何资源。

该形式的固定位必须匹配，且每个所选的源编码都必须可用，否则会引发 `Fault_IllegalInstruction`，`TPC` 保持不变。没有任何保留字段值。

设计要点：进入指令束 body 发生在适用性检查之前，因此被拒绝的条件设置操作会让 body 保持已激活。该拒绝不会回退这次状态转换。

<!-- PTO-READER-BLOCK: scalar-setc-and-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

当 `a0` 持有 `0x000000000000000C`、`a1` 持有 `0x0000000000000008` 时，`setc.and a0, a1.uw` 提交 `1`，因为与结果为 `8`。同一对操作数用 `setc.and a0, a1.not` 也提交 `1`，因为 `a1` 取反后仍与 `a0` 共有第 `2` 位。当 `a1` 持有 `0x0000000000000003` 时，`setc.and a0, a1.uw` 提交 `0`。

在块结束时由已选中标志选择后续去向：已选中的条件指令束在候选的下一个 `PC` 处继续，未选中的则顺序继续。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.and SrcL, SrcR<.sw, .uw, .not>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_and_32_90b4e93ef9d4 | L32 | 32 | 0x00002065 / 0xf8007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_and_32_90b4e93ef9d4 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| setc_and_32_90b4e93ef9d4 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| setc_and_32_90b4e93ef9d4 | SrcRType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_and_32_90b4e93ef9d4 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_and_32_90b4e93ef9d4 | SrcR | 5 | 0–31 | none | none | right absolute GPR source | Encoded zero names the architectural zero GPR. |
| setc_and_32_90b4e93ef9d4 | SrcRType | 2 | 0–3 | none | none | right-source modifier selector | Encoded zero selects value zero of the right-source modifier selector. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| SrcR | right absolute GPR source |
| SrcRType | right-source modifier selector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/SETC.AND.asl -->
```asl
readonly func InstructionContractOperation_SETC_AND() => ScalarOperation
begin
    return ScalarOperation_SETC_AND;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/SETC.AND.asl -->
```asl
readonly func InstructionContractHandler_SETC_AND() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;

pure func InstructionContractCombinesWithOR_SETC_AND()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCommitLogicalValue_SETC_AND(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_SETC_AND() then
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

- Compute SETC.AND's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- setc.and SrcL, SrcR<.sw, .uw, .not>
