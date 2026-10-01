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

`C.BSTART.SYS` 是 System 块的 16 位启动命令。它只有一种写法 `C.BSTART.SYS FALL`，没有操作数字段。块（也称指令束）是一组头部命令与主体指令，在 `BSTOP` 或下一条块启动处作为一个整体提交。

System 块总是顺序继续，没有分支目标。模型页面[指令束启动分派](../model/dispatch/start.md)与[开始](../model/lifecycle/begin.md)定义了共用的启动序列。

<!-- PTO-READER-BLOCK: block-c-bstart-sys-mechanism role=mechanism -->
## 编码与启动序列

完整半字 `0x0840` 是唯一编码。掩码 `0xffff` 固定了每一位，因此除形式本身外没有需要译码的内容。

执行遵循共用的启动顺序。任何活动前驱先提交。只有当该提交选择了本 `C.BSTART.SYS` 的地址作为下一 PC 时，才打开新的 System 块。随后头部执行从 `P + 2` 继续，其中 `P` 是该命令的地址。

设计要点：System 类型是标量系统操作（例如 `FENCE.I`、`FENCE.D` 以及数据缓存维护操作）适用的块类型。`ScalarOperationApplicable` 只在活动 System 块的主体中接受它们。`C.BSTART.SYS` 是打开此类块的压缩方式。

<!-- PTO-READER-BLOCK: block-c-bstart-sys-inputs role=inputs-outputs -->
## 字段与 BARG 取值

- 没有编码操作数，因此没有默认值，也没有编码零含义。该编码固定 FALL 转移与零 `BPCN`。
- 启动写入 `BARG.BPC = P` 与 `BlockType = SYS`。
- `BARG.TYPE` 为 FALL，`TAKEN` 为 0，`BPCN` 为 0。

设计要点：对 System 块，`BeginBundleAt` 忽略传入的转移，并存储这一固定的非选择值。因此 System `BARG` 在提交时永远不会选择 `BPCN`。同一规则也意味着 `SETC.TGT` 与 `LSRGET` 标识符 1 在 System 块中不适用，因为只有 Standard 与 Floating 块带有候选字。

<!-- PTO-READER-BLOCK: block-c-bstart-sys-effects role=effects -->
## 状态效果与顺序

成功的启动会清除之前的头部状态，把新块标记为处于头部阶段的活动块，写入 `BARG` 与 `BPC`，并取得新的执行域令牌。`C.BSTART.SYS` 不访问内存，也不写 GPR。

在 `BSTOP` 或下一条块启动处，System 块提交到其顺序后继。

设计要点：前驱先提交，System `BARG` 后安装。若前驱提交失败，前驱保持权威，不安装 System `BARG`。若前驱转移到别处，本命令位于未被选择的路径上，不打开任何块。

<!-- PTO-READER-BLOCK: block-c-bstart-sys-constraints role=constraints -->
## 合法性与故障边界

除 `0x0840` 以外的任何半字都属于其他指令或是非法编码，而不是 `C.BSTART.SYS` 的操作数变体。

`C.BSTART.SYS` 没有可能失败的操作数。共用启动路径仍会检查其顺序目标 `P + 2` 是否为偶数，奇数会引发 `Fault_InstructionPC`。该命令处的其他故障来自分派器对活动前驱的检查（例如未完成的 TGPR2T 或 TIMG2COL 头部流，引发 `Fault_BundleControl`），或来自前驱提交；在这些情况下前驱都保持原位。

主体中的 `ACRC` 请求置位 System 块终止标记后，命令分派器只接受块停止或块启动作为下一条命令。其他任何命令都引发 `Fault_BundleControl`。

<!-- PTO-READER-BLOCK: block-c-bstart-sys-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
C.BSTART.SYS FALL
```

若 `C.BSTART.SYS FALL` 位于 `0x6000`，新块的 `BPC = 0x6000`、`BlockType = SYS`、`BPCN = 0`。头部执行从 `0x6002` 继续。位于 `0x6010` 的 `BSTOP` 提交该块，执行在 `0x6014` 继续，即这条 4 字节 `BSTOP` 之后的指令。
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
