<!-- GENERATED FROM: asl/scalar/bru/HL.SETC.ANDI.asl -->
# HL.SETC.ANDI

**Normative ASL source:** `asl/scalar/bru/HL.SETC.ANDI.asl`

HL.SETC.ANDI - Combine scalar comparison results and update the bundle commit condition.

## Normative identity {#PTO-INST-SCALAR-HL-SETC-ANDI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-setc-andi-purpose role=purpose -->
## HL.SETC.ANDI 的作用

`HL.SETC.ANDI` 用按位与组合一个标量寄存器与经过移位的 `24` 位立即数，并在组合结果非零时提交 `1`。它是 `48` 位条件设置操作族中的 AND 成员：它不写寄存器，而是设置所在条件指令束的提交判定。

设计要点：与运算的结果不存储在任何位置。唯一可观察的结果是那一个提交位，因此该指令把带掩码的位测试直接变成分支判定。

<!-- PTO-READER-BLOCK: scalar-hl-setc-andi-mechanism role=mechanism -->
## 按位与判定的形成方式

读取 `SrcL`，把 `simm24` 符号扩展到 `PTO_XLEN` 并左移 `shamt` 位。两个字按位与组合，组合结果非零时提交值为 `1`，为零时为 `0`。

设计要点：立即数采用符号扩展，因此 `hl.setc.andi a0, -1` 与全 `1` 字组合，退化为对 `SrcL` 的普通非零判定；当 `shamt` 为 `24` 时，同一立即数写法 `1` 测试的是第 `24` 位。

设计要点：提交值在存储之前就规范化为 `1` 或 `0`，因此无论是由哪些非零操作数产生，指令束的判定都一致。

<!-- PTO-READER-BLOCK: scalar-hl-setc-andi-inputs-outputs role=inputs-outputs -->
## 操作数与移位字段

- `SrcL` 按 `Reg5` 源规则提供左操作数：编码 `0` 到 `23` 读取绝对 GPR，编码 `24` 到 `27` 读取 T 队列，编码 `28` 到 `31` 读取 U 队列。若队列编码对应的项无效，指令会在任何读取之前被拒绝。

- `shamt` 是作用于立即数的 `5` 位译码移位量。它占用的正是比较形式用作目的的位，因为条件设置操作不写寄存器。其取值范围为 `0` 到 `31`。

- `simm24` 提供 `24` 位有符号掩码，编码在两个 `12` 位片段中。

设计要点：没有目的寄存器字段。比较结果进入块提交状态，因此条件设置操作无法编码出丢弃型、GPR 或队列目的，也不会与产生值的比较混淆。

<!-- PTO-READER-BLOCK: scalar-hl-setc-andi-effects role=effects -->
## 提交状态与顺序

规范化的 `1` 或 `0` 写入块提交参数，块的已选中标志接收同一真值，随后置位共享的条件已设置标记。这三处写入在同一步处理中完成。

设计要点：提交参数先写入，再由它导出已选中标志，两者之间不会发生故障，因此不存在二者不一致的可观察指令束状态。

由于处理程序不写 `TPC`，随后由分派边界让 `TPC` 前进 `6` 字节，即该 `48` 位形式的编码长度。不写任何寄存器、内存位置或数值状态。

<!-- PTO-READER-BLOCK: scalar-hl-setc-andi-constraints role=constraints -->
## 放置要求、单次设置规则与故障顺序

`HL.SETC.ANDI` 只在活动的条件指令束尚未设置条件时适用。适用性判定还会要求 body 已激活，而派发入口会在该判定之前就为活动指令束激活 body，因此 body 尚未激活本身并不是被拒绝的情形。指令束未处于活动状态、传递类型不是 `Conditional`，或该指令束已经接受过一个条件设置操作时，都会在读取源之前、写入任何提交状态之前引发 `Fault_BundleControl`（陷阱编号 `5`，`BUNDLE_TRAP`）。

设计要点：块只保留一个共享的条件已设置标记，只有成功的一次执行才会置位它。因编码或操作数检查被拒绝的 `HL.SETC.ANDI` 不会置位该标记，因此同一块中后续的条件设置操作仍可提交。被拒绝的一次不消耗任何资源。

该形式的固定位必须匹配，且所选的 `SrcL` 编码必须可用，否则会引发 `Fault_IllegalInstruction`，`TPC` 保持不变。没有保留字段值：全部 `32` 个 `SrcL` 编码、全部 `32` 个 `shamt` 取值以及 `24` 位立即数字段的所有取值都已分配。

设计要点：进入指令束 body 发生在适用性检查之前，因此被拒绝的条件设置操作会让 body 保持已激活。该拒绝不会回退这次状态转换。

<!-- PTO-READER-BLOCK: scalar-hl-setc-andi-example role=example -->
## 非规范示例

下面的示例只帮助理解当前所有者，不构成第二份语义定义。

当 `a0` 持有 `0x000000000000000C` 且 `shamt` 为零时，`hl.setc.andi a0, 8` 提交 `1`，因为与结果为 `8`；`hl.setc.andi a0, 3` 提交 `0`，因为与结果为零。

在块结束时由已选中标志选择后续去向：已选中的条件指令束在候选的下一个 `PC` 处继续，未选中的则顺序继续。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.setc.andi SrcL, simm
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_setc_andi_48_f27796612fb3 | HL48 | 48 | 0x00002075000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_setc_andi_48_f27796612fb3 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_setc_andi_48_f27796612fb3 | shamt | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_setc_andi_48_f27796612fb3 | simm24 | 24 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_setc_andi_48_f27796612fb3 | SrcL | 5 | 0–31 | none | none | left absolute GPR source | Encoded zero names the architectural zero GPR. |
| hl_setc_andi_48_f27796612fb3 | shamt | 5 | 0–31 | none | none | shift amount | Encoded zero performs no shift. |
| hl_setc_andi_48_f27796612fb3 | simm24 | 24 | 0–16777215 | none | none | 24-bit signed immediate or displacement | Encoded zero supplies numeric zero for the 24-bit signed immediate or displacement. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | left absolute GPR source |
| shamt | shift amount |
| simm24 | 24-bit signed immediate or displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/HL.SETC.ANDI.asl -->
```asl
readonly func InstructionContractOperation_HL_SETC_ANDI() => ScalarOperation
begin
    return ScalarOperation_HL_SETC_ANDI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Applicable only in the body of an active block whose BARG.TYPE is Conditional. Across the entire SETC condition-setting family, at most one occurrence may complete successfully in that block.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/HL.SETC.ANDI.asl -->
```asl
readonly func InstructionContractHandler_HL_SETC_ANDI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSetCommitLogical;
end;

pure func InstructionContractCombinesWithOR_HL_SETC_ANDI()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractCommitLogicalValue_HL_SETC_ANDI(
    left: Word,
    right: Word)
    => Word
begin
    if InstructionContractCombinesWithOR_HL_SETC_ANDI() then
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

- Compute HL.SETC.ANDI's local comparison or logical condition from source snapshots and canonicalize it to zero or one.
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

- hl.setc.andi SrcL, simm
