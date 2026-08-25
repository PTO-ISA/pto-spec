<!-- GENERATED FROM: asl/block/encoding/XB.asl -->
# XB

**Normative ASL source:** `asl/block/encoding/XB.asl`

Inventories an extension-owned cross-block transfer encoding that PTO rejects before field interpretation or architectural effects.

## Normative identity {#PTO-INST-BLOCK-XB}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-xb-purpose role=purpose -->
## XB 的作用

`XB` 标识由扩展拥有的编码空间；PTO 只登记该空间，并始终在解释字段或产生架构效果前拒绝。

<!-- PTO-READER-BLOCK: block-xb-mechanism role=mechanism -->
## 放置与执行机制

`XB` 作为独立的 `32` 位命令执行，不要求放在 `BSTART`/`BSTOP` Block 体内。

匹配的原始编码族使用 `L32` 编码类别，但 PTO 会在解释任一显示字段前拒绝。

解码只保留冲突检测身份；配置拒绝发生在操作数解释、内存、Block 状态与控制流效果之前。

<!-- PTO-READER-BLOCK: block-xb-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 编码操作数：`ACR-ID` — PTO 中保留且不解释的扩展字段; `CROSS-BID` — PTO 中保留且不解释的扩展字段。
- 所有操作数都来自已接受载体或命名架构状态；命令不会创建 Block 体私有的隐藏操作数流。
- 编码零仍是已分配值或明确规定的拒绝值；它不会静默表示省略操作数。

<!-- PTO-READER-BLOCK: block-xb-effects role=effects -->
## 状态效果与顺序

该形式始终引发 `Fault_IllegalInstruction`，且不改变 Block、内存或控制流状态。

该原始编码的完整字段族持续受到冲突保护。

<!-- PTO-READER-BLOCK: block-xb-constraints role=constraints -->
## 合法性、故障与原子性

固定比特、保留值、选择器取值域与必需的 Block 放置关系都在架构效果之前检查。

当前归属单元通过 `Fault_IllegalInstruction` 报告无效模式、状态、地址或后继条件；本页说明文字不创建额外故障规则。

除非当前归属单元明确规定带保留进度的重启边界，否则拒绝发生在效果之前；完成顺序始终采用 ASL 顺序。

<!-- PTO-READER-BLOCK: block-xb-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
XB ACR-ID, C-ID (reserved in PTO)
```

所示拼写只标识已占用的扩展空间；PTO 会在解释任一显示字段之前拒绝所有匹配载体。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
XB ACR-ID, C-ID
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xb_32_40ad190a0a7f | L32 | 32 | 0x00006f81 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xb_32_40ad190a0a7f | ACR-ID | 10 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":10}] |
| xb_32_40ad190a0a7f | CROSS-BID | 7 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":7}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| xb_32_40ad190a0a7f | ACR-ID | 10 | 0–1023 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |
| xb_32_40ad190a0a7f | CROSS-BID | 7 | 0–127 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| ACR-ID | uninterpreted extension field reserved in PTO |
| CROSS-BID | uninterpreted extension field reserved in PTO |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/XB.asl -->
```asl
readonly func InstructionContractMatches_XB(operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_xb_32_40ad190a0a7f;
end;

pure func InstructionContractSupported_XB() => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
none; XB is not an executable PTO block command
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/XB.asl -->
```asl
readonly func InstructionContractHandler_XB() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteCrossBlockTransfer;
end;

pure func InstructionContractRejectsBeforeEffects_XB() => boolean
begin
    return !CommandHandlerSupportedPTOv0(
        CommandHandler_ExecuteCrossBlockTransfer);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No PTO default exists because the complete form is reserved and rejected before ACR-ID or CROSS-BID interpretation.

## Legality

- The full family selected by mask 0x00007fff and match 0x00006f81 is occupied extension space and is not executable in PTO.
- All 1024 ACR-ID values and all 128 CROSS-BID values remain collision-protected; PTO must not allocate another instruction anywhere in this raw family.
- Decode retains the form identity only for collision inventory and fail-closed dispatch. CommandHandlerSupportedPTOv0 returns false for ExecuteCrossBlockTransfer.

## State effects

- none; the form always raises Fault_IllegalInstruction before effects in PTO

## Memory effects and ordering

### Memory effects

- none; rejection precedes every memory access

### Ordering

- Decode and profile rejection precede operand interpretation and every architectural effect.

## Exceptions

- Every matching 32-bit form raises Fault_IllegalInstruction at the current TPC before ACR-ID or CROSS-BID is interpreted and before command, block, memory, or control-flow state changes.

## Examples

- XB ACR-ID, C-ID (reserved in PTO)
