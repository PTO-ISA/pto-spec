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

`XB` 指的是一个属于扩展而非 PTO 的 32 位编码族。列出 `XB ACR-ID, C-ID` 这一写法，是为了登记该编码族并防止编码冲突。在 PTO 中它不可执行：匹配的指令会引发 `Fault_IllegalInstruction`，除非下文所述的更早的块控制检查先拒绝它。

<!-- PTO-READER-BLOCK: block-xb-mechanism role=mechanism -->
## 译码与拒绝机制

该编码族包含低 15 位在掩码 `0x00007fff` 下匹配 `0x6f81` 的每个 32 位字。位 24:15 是 10 位字段 `ACR-ID`，位 31:25 是 7 位字段 `CROSS-BID`。汇编写法把第二个字段写作 `C-ID`。

译码仍会识别该形式，并把它映射到处理程序 `ExecuteCrossBlockTransfer`。随后命令分派器调用 `CommandHandlerSupported`，它对该处理程序返回假。分派器在当前 `TPC` 处引发 `Fault_IllegalInstruction`，并在到达处理程序分支之前返回。

设计要点：即使 PTO 从不执行该形式，它仍保留译码身份。ASL 说明保留该身份只用于冲突登记与失败即关闭的分派。因此检查编码重叠的工具会把该编码族视为已占用，而任何匹配的字都会到达显式的 `CommandHandlerSupported` 拒绝。

<!-- PTO-READER-BLOCK: block-xb-inputs role=inputs-outputs -->
## 字段与操作数

- `ACR-ID` 宽 10 位。PTO 不解释它，包括编码零。
- `CROSS-BID` 宽 7 位。PTO 不解释它，包括编码零。
- `XB` 在 PTO 中没有默认值，也没有放置规则。它不是头部命令，其拒绝也不取决于是否有活动块。

设计要点：`ACR-ID` 的全部 1024 个取值与 `CROSS-BID` 的全部 128 个取值都保持保留。PTO 不得在这个原始编码族中分配任何其他指令，因此后续扩展可以定义这些字段而不与 PTO 冲突。

<!-- PTO-READER-BLOCK: block-xb-effects role=effects -->
## 状态效果与顺序

在 PTO 中该形式没有状态效果。拒绝先于操作数解释、内存访问、块状态变化以及控制流变化。

分派器本应调用的处理程序主体会记录两个字段，并把 `BARG` 的转移标记为间接转移。该主体在 PTO 中不可达，因为 `CommandHandlerSupported` 会先拒绝 `ExecuteCrossBlockTransfer`。

<!-- PTO-READER-BLOCK: block-xb-constraints role=constraints -->
## 合法性、故障与原子性

每个匹配的 32 位字都以当前 `TPC` 引发 `Fault_IllegalInstruction`，`TPC` 不前进。有一项更早的顶层检查可能优先：当 `ACRC` 请求使 System 块终止标记保持置位时，顶层分派器会以 `Fault_BundleControl` 拒绝除块启动或块停止之外的每条命令，且该检查在处理程序支持检查之前执行。

故障发生在读取 `ACR-ID` 或 `CROSS-BID` 之前。任何字段值都不能改变结果，因此没有针对字段的故障。

<!-- PTO-READER-BLOCK: block-xb-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
XB ACR-ID, C-ID (reserved in PTO)
```

字 `0x00006f81` 的两个字段均为零，匹配该编码族。字 `0x0202ef81` 的 `ACR-ID = 5`、`CROSS-BID = 1`，同样匹配。二者都在各自地址处引发 `Fault_IllegalInstruction`，都不改变任何块、内存或控制流状态。
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
    return !CommandHandlerSupported(
        CommandHandler_ExecuteCrossBlockTransfer);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No PTO default exists because the complete form is reserved and rejected before ACR-ID or CROSS-BID interpretation.

## Legality

- The full family selected by mask 0x00007fff and match 0x00006f81 is occupied extension space and is not executable in PTO.
- All 1024 ACR-ID values and all 128 CROSS-BID values remain collision-protected; PTO must not allocate another instruction anywhere in this raw family.
- Decode retains the form identity only for collision inventory and fail-closed dispatch. CommandHandlerSupported returns false for ExecuteCrossBlockTransfer.

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
