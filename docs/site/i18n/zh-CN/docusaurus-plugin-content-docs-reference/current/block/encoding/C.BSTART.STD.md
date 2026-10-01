<!-- GENERATED FROM: asl/block/encoding/C.BSTART.STD.asl -->
# C.BSTART.STD

**Normative ASL source:** `asl/block/encoding/C.BSTART.STD.asl`

Starts a compressed STD block with fallthrough, indirect, or return transfer; every other BrType rejects before effects.

## Normative identity {#PTO-INST-BLOCK-C-BSTART-STD}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-bstart-std-purpose role=purpose -->
## C.BSTART.STD 的作用

`C.BSTART.STD` 是 Standard 块的 16 位启动命令，其后继不是 PC 相对标签。它有三种形式：`C.BSTART.STD FALL`、`C.BSTART.STD IND` 与 `C.BSTART.STD RET`。块（也称指令束）是一组头部命令与主体指令，在 `BSTOP` 或下一条块启动处作为一个整体提交。

该命令把候选后继记录到指令束参数寄存器 `BARG` 中，本身不跳转。模型页面[指令束启动分派](../model/dispatch/start.md)与[开始](../model/lifecycle/begin.md)定义了共用的启动序列。

<!-- PTO-READER-BLOCK: block-c-bstart-std-mechanism role=mechanism -->
## 编码与启动序列

该命令占一个半字，只有一个字段 `BrType`，位于位 13:11。其余位由掩码 `0xc7ff` 下的匹配值 `0x0000` 固定。`BrType` 1 为 FALL，5 为 IND，7 为 RET。

候选目标取决于 `BrType`：

- FALL 使用顺序地址 `P + 2`，其中 `P` 是该 `C.BSTART.STD` 的地址。
- IND 使用退休块 `BARG.BPCN` 的快照。
- RET 使用返回地址状态 `_ReturnAddress` 的快照。例如，`SETRET`、调用启动以及对 `ra` 的帧加载会同时写入它与 GPR 10；普通的 GPR 10 写入不会更新它。

在任何活动前驱提交之前先检查目标对齐。只有当前驱提交选择了本地址作为下一 PC 时，才打开新的 Standard 块。随后头部执行从 `P + 2` 继续。

设计要点：IND 在退休块提交之前读取其 `BPCN`，并把该值保存为提交无法改变的快照。因此前驱留在其 `BPCN` 中的目标（例如通过 `SETC.TGT` 写入）会成为新块的候选目标。

<!-- PTO-READER-BLOCK: block-c-bstart-std-inputs role=inputs-outputs -->
## 字段与 BARG 取值

- `BrType` 总是被编码，没有省略形式或默认形式。
- 每种形式都写入 `BARG.BPC = P` 与 `BlockType = STD`。
- FALL 写入 `TYPE = FALL` 与 `BPCN = P + 2`。`BARGSelectsBPCN` 对 FALL 为假，因此提交在顺序 PC 处继续。
- IND 写入 `TYPE = IND` 与退休 `BPCN` 的快照。RET 写入 `TYPE = RET` 与返回地址的快照。二者在提交时都选择 `BPCN`。

设计要点：FALL、IND 与 RET 以 `TAKEN = 1` 开始；启动路径只对 COND 转移把 `TAKEN` 置为假。`TAKEN` 不影响这些转移类型的后继选择，因为 `BARGSelectsBPCN` 只对 COND 查看它；`LSRGET` 标识符 2 仍在位 7 报告它。

<!-- PTO-READER-BLOCK: block-c-bstart-std-effects role=effects -->
## 状态效果与顺序

成功的启动会清除之前的头部状态，把新块标记为处于头部阶段的活动块，写入 `BARG` 与 `BPC`，并取得新的执行域令牌。`C.BSTART.STD` 不访问内存，也不写 GPR。

写入的候选目标保持挂起，直到 `BSTOP` 或下一条块启动提交新块。由于该块是 Standard 块，主体中的 `SETC.TGT` 仍可在提交前替换 `BPCN`。

设计要点：前驱先提交，新 `BARG` 后安装。若前驱提交失败，前驱保持权威，不安装 Standard `BARG`。若前驱转移到别处，本命令位于未被选择的路径上，不打开任何块。

<!-- PTO-READER-BLOCK: block-c-bstart-std-constraints role=constraints -->
## 合法性、故障与编码重叠

`BrType` 编码 0 不是 `C.BSTART.STD` 的取值。半字 `0x0000` 译码为 `C.BSTOP`。编码 2、3、4 与 6 不会译码为独立的 `C.BSTART.STD`，并在效果之前引发 `Fault_IllegalInstruction`。融合的 `BSTART.ICALL` 形式不使用该字段：它是独立的 32 位形式，其间接调用转移由形式本身固定。

设计要点：经评审的编码重叠把 `BrType` 0 分配给 `C.BSTOP`，因此全零半字是块停止，而不是带未分配转移的启动。

没有活动的退休 Standard 或 Floating 块时，IND 引发 `Fault_BundleControl`。System 块没有候选字，因此无法提供间接目标。快照目标为奇数时引发 `Fault_InstructionPC`。这两种故障都发生在前驱提交之前。

<!-- PTO-READER-BLOCK: block-c-bstart-std-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
C.BSTART.STD FALL
```

`C.BSTART.STD FALL` 编码 `BrType = 1`，即半字 `0x0800`。若它位于 `0x2000`，新块的 `BPC = 0x2000`、`BPCN = 0x2002`、`TYPE = FALL`。头部执行从 `0x2002` 继续，提交在块之后的指令处继续。改设前驱是一个未采纳的条件块，其 `BPCN` 为 `0x3000`，因此它的提交在 `0x2000` 继续。此时位于 `0x2000` 的 `C.BSTART.STD IND` 把 `0x3000` 快照为目标，新块提交时在 `0x3000` 继续。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
C.BSTART.STD FALL
C.BSTART.STD IND
C.BSTART.STD RET
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_std_16_8b40f078c14a | C16 | 16 | 0x0000 / 0xc7ff | [{"field":"BrType","operator":"one-of","values":[1,5,7]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_bstart_std_16_8b40f078c14a | BrType | 3 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":3}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| c_bstart_std_16_8b40f078c14a | BrType | 3 | 1, 5, 7 | 0 (C.BSTOP) | 2–4, 6 | encoded transfer kind: FALL, IND, or RET | Encoded zero is owned by C.BSTOP, not C.BSTART.STD. |

- `c_bstart_std_16_8b40f078c14a.BrType` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| BrType | encoded transfer kind: FALL, IND, or RET |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_std_16_8b40f078c14a);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
After any active predecessor block commits successfully, C.BSTART.STD opens one Standard block. FALL and RET may start without a predecessor; IND requires an active retiring Standard or Floating BARG.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.STD.asl -->
```asl
pure func InstructionContractBranchTypeLegal_C_BSTART_STD(
    branch_type: bits(3))
    => boolean
begin
    return branch_type == '001' ||
           branch_type == '101' ||
           branch_type == '111';
end;

pure func InstructionContractTransfer_C_BSTART_STD(
    branch_type: bits(3))
    => BundleTransfer
begin
    assert InstructionContractBranchTypeLegal_C_BSTART_STD(branch_type);
    if branch_type == '001' then
        return BundleTransfer_Fallthrough;
    elsif branch_type == '101' then
        return BundleTransfer_Indirect;
    else
        return BundleTransfer_Return;
    end;
end;

readonly func InstructionContractHandler_C_BSTART_STD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BrType is always encoded; it has no omitted or default form.

## Legality

- c_bstart_std_16_8b40f078c14a.BrType accepts exactly 1 (FALL), 5 (IND), or 7 (RET). Code 0 decodes as C.BSTOP, while codes 2, 3, 4, and 6 do not decode as standalone C.BSTART.STD; code 6 is used only inside fused BSTART.ICALL.

## State effects

- FALL installs a non-selecting sequential Standard BARG. IND installs the snapshotted retiring BARG.BPCN; RET installs the snapshotted architectural return address.
- The installed candidate continuation remains pending until BSTOP or the next BSTART commits the new block.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Decode and transfer legality precede source selection. IND snapshots retiring BARG.BPCN and RET snapshots architectural ra before predecessor retirement.
- Target alignment is checked before retirement; the new Standard BARG is installed only after successful retirement.

## Exceptions

- BrType code 0 is C.BSTOP. Codes 2, 3, 4, and 6 do not decode as standalone C.BSTART.STD and raise Fault_IllegalInstruction before effects.
- IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects. An odd snapshotted BARG.BPCN or return address raises Fault_InstructionPC before predecessor retirement.
- If predecessor commit fails, the retiring block remains authoritative and no Standard BARG is installed.

## Examples

- C.BSTART.STD FALL
- C.BSTART.STD IND
- C.BSTART.STD RET
