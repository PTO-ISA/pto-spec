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

`C.BSTART.STD` 打开一个活动 Block 描述符；Block 体在完成前提供所需属性与绑定。

<!-- PTO-READER-BLOCK: block-c-bstart-std-mechanism role=mechanism -->
## 放置与执行机制

`C.BSTART.STD` 必须位于所属 Block 的起始位置。后续属性、维度与绑定会累积到活动描述符中，直到 `BSTOP` 或下一条已接受的 `BSTART` 完成边界。

已接受载体使用 `C16` 编码类别；命令在读取绑定或改变状态前，会先解析所有显示字段。

完成时，只有全部模式与状态预检成功，描述符才会执行所选 Block 操作。

<!-- PTO-READER-BLOCK: block-c-bstart-std-inputs role=inputs-outputs -->
## 载体、绑定与输入

- 编码操作数：`BrType` — 编码的转移类型：FALL、IND 或 RET。
- 前驱退休后，该载体打开一个 Standard Block；FALL 和 RET 可在没有前驱时启动，IND 则要求活动的退役 Standard 或 Floating BARG。
- 编码零仍是已分配值或明确规定的拒绝值；它不会静默表示省略操作数。

<!-- PTO-READER-BLOCK: block-c-bstart-std-effects role=effects -->
## 状态效果与顺序

启动 Block 会记录所选载体，并把操作执行推迟到完成边界。

完成全部预检与计算后，所有启用输出按归属单元规定的原子组发布；除非契约明确消费，成功执行后的数学源仍保持可用。

<!-- PTO-READER-BLOCK: block-c-bstart-std-constraints role=constraints -->
## 合法性、故障与原子性

固定比特、保留值、选择器取值域与必需的 Block 放置关系都在架构效果之前检查。

当前归属单元通过 `Fault_BundleControl`, `Fault_IllegalInstruction`, `Fault_InstructionPC` 报告无效模式、状态、地址或后继条件；本页说明文字不创建额外故障规则。

完整模式、绑定、就绪状态、别名、容量与分配预检发生在源快照和所有目的端发布之前。

<!-- PTO-READER-BLOCK: block-c-bstart-std-example role=example -->
## 非规范示例

该示例只演示放置关系与载体流；精确行为仍由当前 ASL 和指令契约定义。

```asm
C.BSTART.STD FALL
```

起始指令先建立描述符；后续载体按声明模式补充内容，最终完成边界触发验证与操作执行。
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
