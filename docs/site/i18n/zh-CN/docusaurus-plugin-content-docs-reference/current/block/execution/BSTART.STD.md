<!-- GENERATED FROM: asl/block/execution/BSTART.STD.asl -->
# BSTART.STD

**Normative ASL source:** `asl/block/execution/BSTART.STD.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-STD}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-std-purpose role=purpose -->
## BSTART.STD 的作用

`BSTART.STD` 打开一个 Standard 块。块（也称指令束）是一段 header 命令和标量主体指令，结束于提交边界：`BSTOP` 或下一条 `BSTART`。Standard 块不运行任何 Tile 操作。它的职责是控制流：记录块提交时程序从哪里继续执行。

该助记符有六种被接受的 32 位形式：`FALL`、`DIRECT`、`COND`、`CALL`、`IND` 和 `RET`。匹配值的位 `14:12` 选择形式（`1`、`2`、`3`、`4`、`5` 和 `7`），其中 `FALL`、`DIRECT`、`COND` 和 `CALL` 在位 `31:15` 携带有符号 17 位 `simm17`。

<!-- PTO-READER-BLOCK: block-bstart-std-mechanism role=mechanism -->
## 位置与机制

分派器对每种形式都运行[指令束启动分派](../model/dispatch/start.md)。它先计算候选目标：

- `FALL` 使用顺序地址，即 `BSTART` 地址加 4。
- `DIRECT`、`COND` 和 `CALL` 使用 `BSTART` 地址加上左移 1 位的 `simm17`。
- `IND` 使用即将退休的块的 `BARG.BPCN`。
- `RET` 使用 `_ReturnAddress`。

之后它才提交有效的前驱块，并且只有当该提交选择本 `BSTART` 地址作为下一个 `TPC` 时才打开新块。随后[开始](../model/lifecycle/begin.md)写入 `BARG`：块类型 Standard、转移类型、`BPCN` 中的目标以及 `taken`，并把 `TPC` 移到下一条指令。

设计要点：`BSTART.STD` 执行时从不跳转。目标保存在 `BARG.BPCN` 中直到提交，由 `BARGCommitPC` 选择。主体中的 `SETC.TGT` 仍可替换 `BPCN`，主体中的 `SETC` 条件为 `COND` 设置 `taken`，因此最终决定只在整个块运行之后做出一次。

设计要点：`IND` 和 `RET` 在前驱提交之前读取目标。`IND` 保存退休块 `BPCN` 的快照，因为该提交会重置 `BARG`；`RET` 在同一时点读取 `_ReturnAddress`。

<!-- PTO-READER-BLOCK: block-bstart-std-inputs role=inputs-outputs -->
## 操作数与 header 角色

- `simm17` 是以半字为单位的有符号位移。字节偏移为 `simm17` 乘以 2，因此相对 `BSTART` 的可达范围是 -131072 到 +131070 字节。
- `FALL` 必须编码 `simm17=0`。非零值保留给扩展。
- `IND` 和 `RET` 没有操作数字段；它们的目标来自架构状态。
- `CALL` 还会把返回目标（即顺序地址）记录到 `_ReturnAddress` 和 GPR 10。

Standard 块不安装 Tile 描述符，因此其 header 中的 `B.DIM`、`B.DATR` 或 Tile 绑定不会被任何 Tile 操作使用。

<!-- PTO-READER-BLOCK: block-bstart-std-effects role=effects -->
## 待处理状态与完成

成功的 `BSTART.STD` 把 `BPC` 设为自身地址，把 `BARG` 块类型设为 Standard，记录转移类型和候选 `BPCN`，并且只对 `COND` 把 `taken` 设为假。header 和主体指令随后在顺序 PC 处执行。

提交时，`BARG` 对 `DIRECT`、`CALL`、`IND` 和 `RET` 选择 `BPCN`，对 `COND` 仅在 `taken` 置位时选择。`FALL` 以及 `taken` 为假的 `COND` 在顺序后续地址继续。该形式没有内存效果。

<!-- PTO-READER-BLOCK: block-bstart-std-constraints role=constraints -->
## 合法性与故障边界

以下检查都在前驱提交之前运行，因此被拒绝的 `BSTART.STD` 会保留有效前驱及其后续地址：

- 非零的 `FALL` 载荷不是合法操作数值，引发 `Fault_IllegalInstruction`。
- 没有可退休的有效 Standard 或 Floating 块时，`IND` 引发 `Fault_BundleControl`，因为只有这两类携带候选 `BPCN`。
- 位 0 置位的目标引发 `Fault_InstructionPC`。

设计要点：PC 相对目标总是偶数，因为它是偶数的 `BSTART` 地址加上左移 1 位的位移。因此奇数目标检查实际上针对 `IND` 和 `RET`，它们的目标来自状态。

如果前驱提交失败，或选择了另一个下一 PC，则不会安装 Standard 块，前驱的结果保持有效。

<!-- PTO-READER-BLOCK: block-bstart-std-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART.STD COND, <label>
```

假设这条 `BSTART.STD COND` 位于 `0x1000`，`<label>` 为 `0x1040`。汇编器编码 `simm17 = 0x20`，指令字为 `0x00103001`。开始之后，`BPC` 为 `0x1000`，`BPCN` 为 `0x1040`，`taken` 为假，`TPC` 为 `0x1004`。如果主体中的 `SETC` 置位 `taken`，并由位于 `0x1010` 的 4 字节 `BSTOP` 提交，`TPC` 变为 `0x1040`。如果 `taken` 保持为假，`TPC` 变为 `0x1014`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.STD COND, <label>
BSTART.STD FALL
BSTART.STD RET
BSTART.STD IND
BSTART.STD DIRECT, <label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_std_32_1ef99c4cedcb | L32 | 32 | 0x00003001 / 0x00007fff | [] |
| bstart_std_32_441ad677fffe | L32 | 32 | 0x00001001 / 0x00007fff | [{"field":"simm17","operator":"one-of","values":[0]}] |
| bstart_std_32_816dfa76cc4a | L32 | 32 | 0x00007001 / 0xffffffff | [] |
| bstart_std_32_986b7ee2cf6a | L32 | 32 | 0x00005001 / 0xffffffff | [] |
| bstart_std_32_c1de85e06878 | L32 | 32 | 0x00002001 / 0x00007fff | [] |
| bstart_std_32_b05390d367cf | L32 | 32 | 0x00004001 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_std_32_1ef99c4cedcb | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_std_32_441ad677fffe | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_std_32_c1de85e06878 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_std_32_b05390d367cf | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_std_32_1ef99c4cedcb | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_std_32_441ad677fffe | simm17 | 17 | 0 | none | 1–131071 | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_std_32_c1de85e06878 | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_std_32_b05390d367cf | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

- `bstart_std_32_441ad677fffe.simm17` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | 17-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_std_32_1ef99c4cedcb) ||
           (operation == CommandOperation_bstart_std_32_441ad677fffe) ||
           (operation == CommandOperation_bstart_std_32_816dfa76cc4a) ||
           (operation == CommandOperation_bstart_std_32_986b7ee2cf6a) ||
           (operation == CommandOperation_bstart_std_32_b05390d367cf) ||
           (operation == CommandOperation_bstart_std_32_c1de85e06878);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.STD retires any active predecessor block, then opens one standard block whose header commands execute sequentially until BSTOP or the next BSTART selects the BARG continuation.
COND publishes a candidate BPCN but SETC may update TAKEN before commit; IND requires and snapshots a retiring Standard or Floating BARG.BPCN, while RET snapshots architectural ra before predecessor retirement.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.STD.asl -->
```asl
readonly func InstructionContractHandler_BSTART_STD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART_STD()
    => BundleKind
begin
    return BundleKind_Standard;
end;

pure func InstructionContractStartsBundle_BSTART_STD()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART.STD FALL encodes simm17=0; nonzero values in that family are extension-reserved.

## Legality

- Exactly FALL, DIRECT, COND, CALL, IND, and RET are accepted.
- The FALL form accepts only simm17=0; every nonzero FALL payload is extension-reserved.
- Bare ICALL forms are deleted.

## State effects

- On success BPC records the BSTART address; BARG.BlockType becomes STD; BARG.TYPE records FALL, DIRECT, COND, IND, or RET; BARG.BPCN records the candidate target; and BARG.TAKEN is false only for COND until SETC resolves it.
- Header execution continues at the sequential PC. BSTOP or the next BSTART commits the candidate continuation selected by BARG.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- All target, descriptor, and form checks precede predecessor retirement. New BARG state is installed only after successful retirement.

## Exceptions

- A nonzero FALL simm17, deleted bare ICALL encoding, reserved BrType, odd target, or unsupported form raises before predecessor retirement or new BARG effects.
- IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects.
- If predecessor commit fails, the old block and continuation remain authoritative and no standard block is installed.

## Examples

- BSTART.STD FALL
- BSTART.STD DIRECT, target
- BSTART.STD COND, target
- BSTART.STD IND
- BSTART.STD RET
