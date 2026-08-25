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

`ESAVE` 标识扩展拥有的原始载体族；PTO 只登记该族，从不接受其执行。

<!-- PTO-READER-BLOCK: block-esave-mechanism role=mechanism -->
## 放置与执行机制

所有匹配 `ESAVE` 族的原始载体在 PTO 中均属保留；它既不是独立命令，也不是 Block 体成员。

匹配的原始载体使用 `L32` 编码类别，但 `RegSrc0`、`RegSrc1` 和 `RegSrc2` 始终不作解释。

配置拒绝无条件引发 `Fault_IllegalInstruction`，并发生在寄存器读取、字段解释、内存访问或架构效果之前。

<!-- PTO-READER-BLOCK: block-esave-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 编码操作数：`RegSrc0` — PTO 中保留且不解释的扩展字段; `RegSrc1` — PTO 中保留且不解释的扩展字段; `RegSrc2` — PTO 中保留且不解释的扩展字段。
- 三个显示字段只是受冲突保护的扩展比特，不是 PTO 操作数，也不会被读取。
- 每个显示字段的全部 `32` 个值都保持保留；零在 PTO 中没有操作数含义。

<!-- PTO-READER-BLOCK: block-esave-effects role=effects -->
## 状态效果与顺序

不会读取任何源，也不会改变寄存器、内存、恢复/保存、Block、事件或控制流状态。

解码只保留已占用编码族的身份，以防 PTO 分配发生冲突的指令。

<!-- PTO-READER-BLOCK: block-esave-constraints role=constraints -->
## 合法性、故障与原子性

完整匹配族均属保留，拒绝发生在所有架构效果之前。

当前归属单元通过 `Fault_IllegalInstruction` 报告无效模式、状态、地址或后继条件；本页说明文字不创建额外故障规则。

拒绝是无条件的，不存在重启或保留进度路径。

<!-- PTO-READER-BLOCK: block-esave-example role=example -->
## 非规范示例

这只是拒绝示例；PTO 不接受任何匹配载体作为可执行指令。

```asm
ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind] (reserved in PTO)
```

所示拼写命名保留扩展空间；PTO 会在解释任何显示字段之前拒绝。
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
    return !CommandHandlerSupportedPTOv0(
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
