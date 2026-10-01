<!-- GENERATED FROM: asl/block/encoding/C.BSTART.asl -->
# C.BSTART

**Normative ASL source:** `asl/block/encoding/C.BSTART.asl`

Starts a compressed standard block with a PC-relative direct or conditional candidate target.

## Normative identity {#PTO-INST-BLOCK-C-BSTART}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-bstart-purpose role=purpose -->
## C.BSTART 的作用

`C.BSTART` 是带 PC 相对目标的 Standard 块的 16 位启动命令，有两种形式：`C.BSTART DIRECT, label` 与 `C.BSTART COND, label`。块（也称指令束）是一组头部命令与主体指令，在 `BSTOP` 或下一条块启动处作为一个整体提交。

该命令本身不跳转。它把候选目标记录到指令束参数寄存器 `BARG` 中，跳转只在新块提交时发生。模型页面[指令束启动分派](../model/dispatch/start.md)与[开始](../model/lifecycle/begin.md)定义了共用的启动序列。

<!-- PTO-READER-BLOCK: block-c-bstart-mechanism role=mechanism -->
## 编码与启动序列

两种形式都只占一个半字。低四位选择形式：`0x2` 为 DIRECT，`0x4` 为 COND。位 15:4 保存 `simm12`，即以半字计数的 12 位有符号位移。

候选目标为 `P + (SignExtend(simm12) << 1)`，其中 `P` 是该 `C.BSTART` 自身的地址。因此可达范围是相对 `P` 的 -4096 至 +4094 字节。

执行遵循共用的启动顺序。首先计算目标并检查对齐。然后提交任何活动前驱块。只有当该提交选择了本 `C.BSTART` 的地址作为下一 PC 时，才会打开新的 Standard 块。随后头部执行从 `P + 2` 继续。

设计要点：位移加在 `P` 上，而不是加在下一条指令地址上。编码零是真实的零位移，因此 `simm12 = 0` 的 `C.BSTART DIRECT` 以自身地址为目标，提交时执行回到这条 `C.BSTART`。

<!-- PTO-READER-BLOCK: block-c-bstart-inputs role=inputs-outputs -->
## 字段与 BARG 取值

- `simm12` 总是被编码，没有省略形式，也没有默认值。
- DIRECT 写入 `BARG.BPC = P`、`BlockType = STD`、`BPCN =` 计算出的目标、`TYPE = DIRECT` 与 `TAKEN = 1`。
- COND 写入相同的 `BPC`、`BlockType` 与 `BPCN`，并写入 `TYPE = COND` 与 `TAKEN = 0`。

设计要点：COND 以 `TAKEN = 0` 开始，因此没有执行任何 `SETC` 条件的条件块在提交时顺序继续。在块提交之前，主体中的 `SETC` 条件可以置位 `TAKEN`，`SETC.TGT` 可以替换 `BPCN`。参见 [BARG 辅助函数](../model/state/barg.md)。

<!-- PTO-READER-BLOCK: block-c-bstart-effects role=effects -->
## 状态效果与顺序

成功的启动会清除之前的头部状态，把新块标记为处于头部阶段的活动块，写入 `BARG` 与 `BPC`，并取得新的执行域令牌。`C.BSTART` 不访问内存，也不写 GPR。

候选目标只在 `BSTOP` 或下一条块启动处被选择。`BARGSelectsBPCN` 对 DIRECT 为真，对 COND 仅在 `TAKEN` 置位时为真；否则提交在顺序 PC 处继续。

设计要点：前驱先提交，新 `BARG` 后安装。若前驱提交失败，前驱保持权威，不安装 Standard `BARG`。若前驱转移到别处，本 `C.BSTART` 位于未被选择的路径上，不打开任何块。

<!-- PTO-READER-BLOCK: block-c-bstart-constraints role=constraints -->
## 合法性与故障边界

只有低四位值 `0x2` 与 `0x4` 属于 `C.BSTART`。`simm12` 的每个取值都已分配。

计算出的目标为奇数时，在前驱提交之前、任何新 `BARG` 效果之前引发 `Fault_InstructionPC`。由于启动检查在前驱退休之前执行，被拒绝的 `C.BSTART` 会保留活动前驱。

由 `SETC.TGT` 改写的最终 `BPCN` 会在提交时再次检查；被选中的奇数目标会在块效果可见之前引发 `Fault_InstructionPC`。

<!-- PTO-READER-BLOCK: block-c-bstart-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
C.BSTART COND, label
```

假设这条 `C.BSTART COND` 位于 `0x1000`，`label` 为 `0x1040`。编码的 `simm12` 为 `0x20`，因为 `0x1000 + (0x20 << 1) = 0x1040`。启动后，`BARG.BPCN` 为 `0x1040`，`TAKEN` 为 0，头部执行从 `0x1002` 继续。若主体中的 `SETC` 条件置位 `TAKEN`，提交在 `0x1040` 继续；否则在块之后继续。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
C.BSTART COND,  label
C.BSTART DIRECT, label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_16_c4e238a9227a | C16 | 16 | 0x0004 / 0x000f | [] |
| c_bstart_16_f833d2a4753c | C16 | 16 | 0x0002 / 0x000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_bstart_16_c4e238a9227a | simm12 | 12 | signed | [{"instruction_lsb":4,"value_lsb":0,"width":12}] |
| c_bstart_16_f833d2a4753c | simm12 | 12 | signed | [{"instruction_lsb":4,"value_lsb":0,"width":12}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_bstart_16_c4e238a9227a | simm12 | 12 | 0–4095 | none | none | 12-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| c_bstart_16_f833d2a4753c | simm12 | 12 | 0–4095 | none | none | 12-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm12 | 12-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_16_c4e238a9227a) ||
           (operation == CommandOperation_c_bstart_16_f833d2a4753c);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
After any active predecessor block commits successfully, C.BSTART opens one Standard block. Header commands execute sequentially until BSTOP or the next BSTART commits the new BARG continuation.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.asl -->
```asl
pure func InstructionContractTarget_C_BSTART(
    instruction_pc: Word,
    displacement: bits(12))
    => Word
begin
    return instruction_pc +
        LSL(SignExtend{PTO_XLEN}(displacement), 1);
end;

readonly func InstructionContractHandler_C_BSTART() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- simm12 is always encoded. Encoded zero computes the candidate target P and is not omission.
- The conditional form initializes BARG.TAKEN to false; the direct form initializes it to true.

## Legality

- Exactly the low-nibble forms 0x2 (DIRECT) and 0x4 (COND) are assigned to C.BSTART.
- simm12 accepts every signed 12-bit value and computes P + (SignExtend(simm12) << 1).

## State effects

- Installs BARG.BPC=P, BlockType=STD, BPCN=the computed candidate target, and TYPE=DIRECT or COND.
- DIRECT installs TAKEN=1; COND installs TAKEN=0 until an applicable SETC operation resolves it. The candidate continuation is selected only at BSTOP or the next BSTART.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode, target calculation, and target alignment checks precede predecessor retirement. New BARG state is installed only after successful retirement.

## Exceptions

- An odd computed candidate target raises Fault_InstructionPC before predecessor retirement or new BARG effects.
- If predecessor commit fails, the retiring block remains authoritative and no Standard BARG is installed.

## Examples

- C.BSTART DIRECT, label
- C.BSTART COND, label
