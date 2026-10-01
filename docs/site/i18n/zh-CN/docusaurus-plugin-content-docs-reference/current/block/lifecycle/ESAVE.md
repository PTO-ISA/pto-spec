<!-- GENERATED FROM: asl/block/lifecycle/ESAVE.asl -->
# ESAVE

**Normative ASL source:** `asl/block/lifecycle/ESAVE.asl`

Inventories an extension-owned execution-context save family rejected by PTO before effects.

## Normative identity {#PTO-INST-BLOCK-ESAVE}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-esave-purpose role=purpose -->
## ESAVE 的作用

在 PTO 中，`ESAVE` 除了引发故障之外不做任何事。其编码族保留给扩展所有的执行上下文保存命令。PTO 列出该编码族，使任何 PTO 指令都不会被分配冲突的编码，但从不执行它。

匹配指令会引发 `Fault_IllegalInstruction`，但在存在待处理的系统 block 终止请求时例外，详见下文。配套编码族 [ERCOV](ERCOV.md) 以同样方式保留。

<!-- PTO-READER-BLOCK: block-esave-mechanism role=mechanism -->
## 放置与执行机制

该编码族是掩码位 `word & 0x06007fff` 等于 `0x00002031` 的所有 32 位字：位 `14:0` 为 `0x2031`，位 `26:25` 为零。`ESAVE` 在 block 内外都没有合法位置。

命令分派器译码该形式，找到其处理函数 `SaveExecutionContext`，并检查 `CommandHandlerSupported`。该函数对此处理函数返回 false，因此分派器引发 `Fault_IllegalInstruction`，在处理函数主体运行之前返回。

设计要点：ASL 确实在 [帧生命周期](../model/lifecycle/lifetime.md) 中定义了辅助函数 `SaveExecutionContextState`。它在 PTO 中不可达，因为支持检查会先拒绝该命令。其文本不描述 PTO 行为。

<!-- PTO-READER-BLOCK: block-esave-inputs role=inputs-outputs -->
## 载体、绑定与输入

- `RegSrc0`（位 `19:15`）、`RegSrc1`（位 `24:20`）与 `RegSrc2`（位 `31:27`）在规范拼写中显示为 `BasePtr`、`LenBytes` 与 `Kind`。
- PTO 从不解释这些字段，也从不读取它们本应指定的寄存器。
- 每个字段的全部 32 个值（包括零）都属于保留编码族。

设计要点：没有默认值，编码零也没有含义，因为拒绝发生在任何字段被译码为操作数之前。

<!-- PTO-READER-BLOCK: block-esave-effects role=effects -->
## 状态效果与顺序

除每次故障都会执行的陷阱投递之外没有其他效果。不读取任何寄存器，寄存器、内存、block 或内存命令状态都不改变。故障地址就是该 `ESAVE` 本身；`SetFault` 会保存陷阱上下文，并把 `TPC` 写到陷阱向量入口，在未配置陷阱向量基址时该入口就是故障地址。

<!-- PTO-READER-BLOCK: block-esave-constraints role=constraints -->
## 合法性、故障与原子性

在普通上下文中，每个匹配字都在任何效果之前于当前 `TPC` 引发 `Fault_IllegalInstruction`。拒绝是无条件的：它不依赖字段值、特权环或是否有活动 block。没有重启或部分进度路径。

分派器在到达支持检查之前会先检查待处理的系统 block 终止请求。因此在 `ACRC` 把系统 block 标记为终止之后，匹配字改为引发 `Fault_BundleControl`。

下方生成的合法性与异常章节具有权威性。

<!-- PTO-READER-BLOCK: block-esave-example role=example -->
## 非规范示例

这只是拒绝示例；PTO 不接受任何匹配载体作为可执行指令。

```asm
ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind] (reserved in PTO)
```

字 `0x00002031`（三个字段均为零）以及三个字段均设为 31 的同一字都匹配该编码族。二者都在该 `ESAVE` 地址引发 `Fault_IllegalInstruction`，不读取任何寄存器。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| esave_32_4c4f79fe3171 | L32 | 32 | 0x00002031 / 0x06007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| esave_32_4c4f79fe3171 | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| esave_32_4c4f79fe3171 | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| esave_32_4c4f79fe3171 | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| esave_32_4c4f79fe3171 | RegSrc0 | 5 | 0–31 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |
| esave_32_4c4f79fe3171 | RegSrc1 | 5 | 0–31 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |
| esave_32_4c4f79fe3171 | RegSrc2 | 5 | 0–31 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegSrc0 | uninterpreted extension field reserved in PTO |
| RegSrc1 | uninterpreted extension field reserved in PTO |
| RegSrc2 | uninterpreted extension field reserved in PTO |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/ESAVE.asl -->
```asl
readonly func InstructionContractMatches_ESAVE(operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_esave_32_4c4f79fe3171;
end;

pure func InstructionContractSupported_ESAVE() => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
none; ESAVE is not an executable PTO command
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/ESAVE.asl -->
```asl
readonly func InstructionContractHandler_ESAVE() => CommandSemanticHandler
begin
    return CommandHandler_SaveExecutionContext;
end;

pure func InstructionContractRejectsBeforeEffects_ESAVE() => boolean
begin
    return !CommandHandlerSupported(
        CommandHandler_SaveExecutionContext);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No PTO default exists because the complete raw family is reserved and rejected before field interpretation.

## Legality

- The full family selected by mask 0x06007fff and match 0x00002031 is occupied extension space and is not executable in PTO.
- All 32 values of each encoded selector remain collision-protected and PTO must not allocate another instruction in this family.

## State effects

- none; the form always raises Fault_IllegalInstruction before effects in PTO

## Memory effects and ordering

### Memory effects

- none; rejection precedes every memory access

### Ordering

- Decode and profile rejection precede operand interpretation and every architectural effect.

## Exceptions

- Every matching form raises Fault_IllegalInstruction at the current TPC before register reads, memory access, context save, or state changes.

## Examples

- ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind] (reserved in PTO)
