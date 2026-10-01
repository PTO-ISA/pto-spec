<!-- GENERATED FROM: asl/block/lifecycle/B.HINT.asl -->
# B.HINT

**Normative ASL source:** `asl/block/lifecycle/B.HINT.asl`

Records one optional per-block branch, temperature, prefetch-size, or trace-boundary hint without changing functional results.

## Normative identity {#PTO-INST-BLOCK-B-HINT}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-b-hint-purpose role=purpose -->
## B.HINT 的作用

`B.HINT` 为 block 附加建议性信息。block（也称为指令束）由 block 启动命令打开，从头部命令收集配置，执行其主体，并作为一个整体提交。`B.HINT` 有两种 32 位形式：

- 普通形式为活动 block 携带分支、温度与预取提示。
- `TRACE` 形式标记一个 trace 边界。它本身就是一个 block 启动：它打开一个新的空顺序 block。

<!-- PTO-READER-BLOCK: block-b-hint-mechanism role=mechanism -->
## 位置与机制

普通形式是头部命令。当 block 处于活动状态且仍在头部阶段、即第一条主体指令之前时，它才合法。一个 block 最多只能有一个提示。

`TRACE` 形式遵循 [启动分派](../model/dispatch/start.md) 中的 block 启动规则。若有活动 block，它先以 `TRACE` 地址作为顺序延续提交该 block。若该提交发生故障，故障保留，不会打开 trace block。若提交选择了其他 PC，则该 `TRACE` 位于程序未走的路径上，不改变任何提示或 trace 状态。否则，以及没有活动 block 时，它打开一个转移类型为顺序的标准 block，并记录边界种类。

设计要点：已安装的 `TRACE` 不会完成它打开的新 block。该 block 与其他 block 一样，在 `BSTOP` 或下一个 block 启动处结束。

<!-- PTO-READER-BLOCK: block-b-hint-inputs role=inputs-outputs -->
## 编码字段

普通形式（位 `14:0` 为 `0x033`，位 19 为零）：

- `V`，位 15：分支提示有效性。0 表示没有分支提示。
- `L/UL`，位 16：当 `V` 为 1 时，0 表示不太可能（顺序），1 表示很可能（跳转）。
- `temp`，位 `18:17`：温度。0 为无，1 为 cool，2 为 warm，3 为 hot。
- `prefetch_size`，位 `31:20`：要预取的缓存行数，从包含当前 block 指令的那一行开始。0 表示不预取。

`TRACE` 形式：位 `14:0` 为 `0x1033`，位 15 为 `B/E`。0 表示 `TRACE.begin`，1 表示 `TRACE.end`。其余各位均为零。

设计要点：省略 `B.HINT` 与编码全零的普通提示都不提供指导。但二者仍有区别：显式提示会占用 block 唯一的提示位置，因此同一 block 中之后的普通 `B.HINT` 会被拒绝。

<!-- PTO-READER-BLOCK: block-b-hint-effects role=effects -->
## 状态效果

成功的 `B.HINT` 把其字段记录为活动 block 的待处理状态，把原始指令保存到 `_LastBundleHintPayload`，并递增非功能性的提示纪元。block 提交时，提示随其余头部状态一起被清除。

设计要点：提示从不改变功能结果。在当前 ASL 中，记录的提示会被清除、复位，并随陷阱上下文保存与恢复。除单一提示检查之外，没有任何执行或提交规则读取分支、温度、预取或 trace 字段。因此无论有无提示，程序行为都相同。

`B.HINT` 没有内存效果。普通形式把 `TPC` 推进到下一条指令。已安装的 `TRACE` 通过新 block 的启动把 `TPC` 移到自身之后的指令。

<!-- PTO-READER-BLOCK: block-b-hint-constraints role=constraints -->
## 合法性与故障边界

没有活动 block、主体已经开始，或 block 已有提示时，普通 `B.HINT` 在任何提示状态改变之前引发 `Fault_BundleControl`。第一个提示保持不变。

`TRACE` 提示也会设置它所打开 block 的提示位置。因此 trace block 中的普通 `B.HINT` 会作为重复提示被拒绝。

设计要点：拒绝第二个提示而不是替换第一个，使记录的提示始终等于头部最先声明的那个。下方生成的合法性与异常章节具有权威性。

<!-- PTO-READER-BLOCK: block-b-hint-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
B.HINT {BR.likely, TEMP.hot, 64}
```

在活动 block 的头部中，此提示把 `V` 设为 1，`L/UL` 设为 1，`temp` 设为 3，`prefetch_size` 设为 64。编码字为 `0x00000033 | 1<<15 | 1<<16 | 3<<17 | 64<<20 = 0x04078033`。同一头部中的第二条 `B.HINT` 引发 `Fault_BundleControl`。相比之下，放在顺序 block 之后的 `B.HINT TRACE.begin`（`0x00001033`）会提交该 block，并在自身地址处打开一个新的空 block。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
B.HINT {BR.{likely, unlikely}, TEMP.{hot, warm, cool, none}, PRFSIZE}
B.HINT TRACE.{begin, end}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_hint_32_69d942ff1583 | L32 | 32 | 0x00000033 / 0x00087fff | [] |
| b_hint_32_f7d01d734925 | L32 | 32 | 0x00001033 / 0xffff7fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_hint_32_69d942ff1583 | L/UL | 1 | encoding-defined | [{"instruction_lsb":16,"value_lsb":0,"width":1}] |
| b_hint_32_69d942ff1583 | V | 1 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":1}] |
| b_hint_32_69d942ff1583 | prefetch_size | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |
| b_hint_32_69d942ff1583 | temp | 2 | encoding-defined | [{"instruction_lsb":17,"value_lsb":0,"width":2}] |
| b_hint_32_f7d01d734925 | B/E | 1 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":1}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| b_hint_32_69d942ff1583 | L/UL | 1 | 0–1 | none | none | when V=1, 0 unlikely/fallthrough and 1 likely/taken | unlikely branch / likely fallthrough when V is one |
| b_hint_32_69d942ff1583 | V | 1 | 0–1 | none | none | branch-hint validity: 0 invalid, 1 valid | branch hint invalid; implementation predicts normally |
| b_hint_32_69d942ff1583 | prefetch_size | 12 | 0–4095 | none | none | number of cache lines to prefetch beginning with the cache line containing the current block instruction | no cache-line prefetch |
| b_hint_32_69d942ff1583 | temp | 2 | 0–3 | none | none | temperature: 0 none, 1 cool, 2 warm, 3 hot | none |
| b_hint_32_f7d01d734925 | B/E | 1 | 0–1 | none | none | trace boundary: 0 begin, 1 end | TRACE.begin |

## Operands and results

| Field | Architectural role |
| --- | --- |
| V | branch-hint validity: 0 invalid, 1 valid |
| L/UL | when V=1, 0 unlikely/fallthrough and 1 likely/taken |
| temp | temperature: 0 none, 1 cool, 2 warm, 3 hot |
| prefetch_size | number of cache lines to prefetch beginning with the cache line containing the current block instruction |
| B/E | trace boundary: 0 begin, 1 end |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/B.HINT.asl -->
```asl
readonly func InstructionContractMatches_B_HINT(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_b_hint_32_69d942ff1583) ||
           (operation == CommandOperation_b_hint_32_f7d01d734925);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
Ordinary form: optional once after BSTART and before the block body.
TRACE form: acts as a block start only when predecessor commit selects the fetched TRACE PC, and an installed trace block must later be terminated by BSTOP or the next block start.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/B.HINT.asl -->
```asl
readonly func InstructionContractHandler_B_HINT() => CommandSemanticHandler
begin
    return CommandHandler_SetBundleHint;
end;

pure func InstructionContractIsBundleHint_B_HINT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractTraceFormMayTerminate_B_HINT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- An ordinary block may omit B.HINT; omission supplies no branch, temperature, or prefetch guidance.
- For the ordinary form V=0 disables branch guidance, L/UL=0 denotes unlikely/fallthrough, temp=0 denotes none, and prefetch_size=0 requests no cache-line prefetch.
- For TRACE, B/E=0 denotes begin and B/E=1 denotes end.

## Legality

- An ordinary B.HINT is legal only after BSTART and before the block body, and at most one B.HINT may belong to that block header.
- A second ordinary B.HINT raises Illegal Block Exception before replacing the first hint.
- B.HINT TRACE is a special block-start operation. It first retires any active predecessor block and opens a new empty fallthrough block only when the committed TPC equals the fetched TRACE PC.

## State effects

- Decode and retain the selected hint fields as pending state of the active block and increment the non-functional hint epoch.
- TRACE.begin or TRACE.end opens an empty block and records its boundary kind only at a predecessor-selected boundary; skipped TRACE changes no hint state. An installed TRACE does not complete its new block.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Ordinary hints update the active header in place. TRACE first commits any active predecessor, verifies that its selected TPC is the fetched TRACE PC, and only then installs and records the empty trace block.

## Exceptions

- An ordinary B.HINT outside an active block header or a duplicate ordinary B.HINT raises Illegal Block Exception before hint state changes.
- If TRACE cannot retire an active predecessor block, the predecessor fault is preserved and the trace block is not opened. If predecessor commit selects another PC, TRACE changes no hint or trace state.

## Examples

- B.HINT {BR.likely, TEMP.hot, 64}
- B.HINT TRACE.begin
