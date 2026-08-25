<!-- GENERATED FROM: asl/block/encoding/C.BSTART.SYS.asl -->
# C.BSTART.SYS

**Normative ASL source:** `asl/block/encoding/C.BSTART.SYS.asl`

Starts the fixed compressed sequential System block without a selecting branch continuation.

## Normative identity {#PTO-INST-BLOCK-C-BSTART-SYS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-bstart-sys-purpose role=purpose -->
## C.BSTART.SYS 的作用

`C.BSTART.SYS` 打开一个活动 Block 描述符；Block 体在完成前提供所需属性与绑定。

<!-- PTO-READER-BLOCK: block-c-bstart-sys-mechanism role=mechanism -->
## 放置与执行机制

`C.BSTART.SYS` 必须位于所属 Block 的起始位置。后续属性、维度与绑定会累积到活动描述符中，直到 `BSTOP` 或下一条已接受的 `BSTART` 完成边界。

已接受载体使用 `C16` 编码类别；命令在读取绑定或改变状态前，会先解析所有显示字段。

完成时，只有全部模式与状态预检成功，描述符才会执行所选 Block 操作。

<!-- PTO-READER-BLOCK: block-c-bstart-sys-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 该指令没有编码操作数字段。
- 活动前驱成功提交后，该载体打开一个顺序执行的 System Block；其头部执行到 `BSTOP` 或下一条 `BSTART`。
- 编码零仍是已分配值或明确规定的拒绝值；它不会静默表示省略操作数。

<!-- PTO-READER-BLOCK: block-c-bstart-sys-effects role=effects -->
## 状态效果与顺序

启动 Block 会记录所选载体，并把操作执行推迟到完成边界。

完成全部预检与计算后，所有启用输出按归属单元规定的原子组发布；除非契约明确消费，成功执行后的数学源仍保持可用。

<!-- PTO-READER-BLOCK: block-c-bstart-sys-constraints role=constraints -->
## 合法性、故障与原子性

固定比特、保留值、选择器取值域与必需的 Block 放置关系都在架构效果之前检查。

无效模式、状态、地址或后继条件通过当前归属单元定义的故障行为报告；本页不添加故障规则。

完整模式、绑定、就绪状态、别名、容量与分配预检发生在源快照和所有目的端发布之前。

<!-- PTO-READER-BLOCK: block-c-bstart-sys-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
C.BSTART.SYS FALL
```

起始指令先建立描述符；后续载体按声明模式补充内容，最终完成边界触发验证与操作执行。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
C.BSTART.SYS FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_sys_16_ec213ce96eb7 | C16 | 16 | 0x0840 / 0xffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.SYS.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_sys_16_ec213ce96eb7);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
After any active predecessor block commits successfully, C.BSTART.SYS opens one System block. Its header commands execute sequentially until BSTOP or the next BSTART.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.SYS.asl -->
```asl
pure func InstructionContractKind_C_BSTART_SYS() => BundleKind
begin
    return BundleKind_System;
end;

readonly func InstructionContractHandler_C_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The instruction has no operand field. FALL and zero displacement are fixed by its complete 16-bit encoding.

## Legality

- The complete 16-bit pattern 0x0840 is the only accepted C.BSTART.SYS encoding.
- System blocks have only sequential fallthrough and expose no BPCN, TYPE, or TAKEN continuation.

## State effects

- Installs BARG.BPC=P and BlockType=SYS, advances header execution to P+2, and keeps BPCN zero with canonical non-selecting fallthrough state.
- BSTOP or the next BSTART commits to the sequential continuation.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The predecessor block commits before the new System BARG is installed. C.BSTART.SYS itself performs no memory access.

## Exceptions

- Any different bit pattern belongs to another instruction or is illegal; it is not a C.BSTART.SYS operand variation.
- If predecessor commit fails, the retiring block remains authoritative and no System BARG is installed.

## Examples

- C.BSTART.SYS FALL
