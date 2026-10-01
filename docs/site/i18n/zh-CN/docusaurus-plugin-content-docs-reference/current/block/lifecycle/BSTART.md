<!-- GENERATED FROM: asl/block/lifecycle/BSTART.asl -->
# BSTART

**Normative ASL source:** `asl/block/lifecycle/BSTART.asl`

Initializes the single BARG continuation record after any retiring block commits successfully.

## Normative identity {#PTO-INST-BLOCK-BSTART}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-purpose role=purpose -->
## BSTART 的作用

`BSTART` 打开一个标准 block。block（也称为指令束）是一组头部命令和主体指令，它在 `BSTOP` 或下一个 block 启动处作为一个整体提交。`BSTART` 有两种 32 位形式：用于无条件转移的 `BSTART DIRECT, <label>`，以及用于条件转移的 `BSTART COND, <label>`。

`BSTART` 记录 block 提交时程序将去往何处，但它本身不跳转。该记录是 `BARG`，即 block 参数寄存器，见 [BARG 辅助函数](../model/state/barg.md)。

<!-- PTO-READER-BLOCK: block-bstart-mechanism role=mechanism -->
## 编码与启动顺序

两种形式都只携带一个字段 `simm25`，即位于位 `31:7` 的 25 位有符号位移。低七位选择形式：`0010001`（`0x11`）为 `DIRECT`，`0100001`（`0x21`）为 `COND`。候选目标为 `P + (SignExtend(simm25) << 1)`，其中 `P` 是该 `BSTART` 的地址。位移以 2 字节为单位计数。

[启动分派](../model/dispatch/start.md)按以下顺序执行：

1. 检查操作描述符并计算候选目标。奇数目标引发 `Fault_InstructionPC`。
2. 若已有活动 block，以 `P` 作为顺序延续提交该前驱。
3. 若前驱提交发生故障，或选择了 `P` 以外的下一 PC，则停止。此 `BSTART` 位于程序未走的路径上，不会被安装。
4. 清除头部状态，并通过 [begin](../model/lifecycle/begin.md) 打开新 block。`TPC` 移到 `P + 4`，即第一条头部命令。

设计要点：对新 `BSTART` 的所有检查都在前驱提交之前完成。因此，被拒绝的 `BSTART` 会让前驱保持活动且不变。

<!-- PTO-READER-BLOCK: block-bstart-inputs role=inputs-outputs -->
## 字段与 BARG 记录

- `simm25` 是唯一的编码操作数。它总是存在，没有省略形式。
- `DIRECT` 写入 `BARG.BPC = P`、`BlockType = STD`、`BPCN = target`、`TYPE = DIRECT` 以及 `TAKEN = 1`。
- `COND` 写入相同的 `BPC`、`BlockType` 和 `BPCN`，并写入 `TYPE = COND` 与 `TAKEN = 0`。

设计要点：编码为零的 `simm25` 是真正的零位移，因此 `BPCN` 等于 `P`。位移为零的 `DIRECT` block 在提交时回到自己的 `BSTART`。零从不表示“没有目标”。

<!-- PTO-READER-BLOCK: block-bstart-effects role=effects -->
## 何时变得可见

`BSTART` 本身不访问内存。退役前驱的所有内存效果都在新 `BARG` 安装之前完成。

转移发生在提交时，而不是 `BSTART` 时。主体中的 `SETC.*` 指令可以设置 `TAKEN`，但只在 `COND` block 内；[SETC.TGT](../../scalar/sys/SETC.TGT.md) 在 `DIRECT` block 与 `COND` block 中都可以替换 `BPCN`。随后，`BSTOP` 或下一个 block 启动对 `DIRECT` block 会选择 `BPCN`，对 `COND` block 仅在 `TAKEN` 被设置时才选择 `BPCN`；否则选择顺序地址。

设计要点：由于选择被推迟，提交前发生故障的 block 尚未重定向程序。最终的 `BPCN` 会在提交时再次检查，因此被 `SETC.TGT` 修改的目标仍会在任何 block 效果之前得到验证。

<!-- PTO-READER-BLOCK: block-bstart-constraints role=constraints -->
## 合法性与故障边界

- `0x11` 形式只表示 `DIRECT`；`CALL` 不是它的别名。`0x21` 形式只表示 `COND`。
- 计算出的 `BPCN` 为奇数时，在 `BARG` 改变之前引发 `Fault_InstructionPC`。
- 前驱提交失败时，保留前驱的 `BARG` 及其故障，新 `BARG` 不会被安装。

下方生成的合法性、状态效果与异常章节具有权威性。

<!-- PTO-READER-BLOCK: block-bstart-example role=example -->
## 非规范示例

以下为非规范示例，仅用于说明当前所有者，不替代其定义。

```asm
BSTART DIRECT, <label>
```

一条 `BSTART DIRECT, <label>` 位于 `0x1000`，标签位于 `0x2000`。编码的 `simm25` 为 `(0x2000 - 0x1000) >> 1 = 0x800`。启动之后，`BPC` 为 `0x1000`，`BPCN` 为 `0x2000`，`TAKEN` 为 1，`TPC` 为 `0x1004`。头部从 `0x1004` 开始执行；跳转到 `0x2000` 发生在 `BSTOP` 提交该 block 时。若改用 `BSTART COND, <label>`，`TAKEN` 初始为 0，除非主体中的 `SETC.*` 设置它，否则 block 顺序继续。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART DIRECT, <label>
BSTART COND, <label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_32_7eb93b649748 | L32 | 32 | 0x00000011 / 0x0000007f | [] |
| bstart_32_e11e678a32ac | L32 | 32 | 0x00000021 / 0x0000007f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_32_7eb93b649748 | simm25 | 25 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25}] |
| bstart_32_e11e678a32ac | simm25 | 25 | signed | [{"instruction_lsb":7,"value_lsb":0,"width":25}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_32_7eb93b649748 | simm25 | 25 | 0–33554431 | none | none | 25-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_32_e11e678a32ac | simm25 | 25 | 0–33554431 | none | none | 25-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm25 | 25-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/BSTART.asl -->
```asl
readonly func InstructionContractMatches_BSTART(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_32_7eb93b649748) ||
           (operation == CommandOperation_bstart_32_e11e678a32ac);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/BSTART.asl -->
```asl
readonly func InstructionContractHandler_BSTART() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART()
    => BundleKind
begin
    return BundleKind_Standard;
end;

pure func InstructionContractStartsBundle_BSTART()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- simm25 zero is a real zero displacement, so BARG.BPCN equals the BSTART address P.

## Legality

- The low-seven-bit 0010001 form is DIRECT only; CALL is not an alias.
- The low-seven-bit 0100001 form is COND only.

## State effects

- DIRECT installs BARG.BPC=P, BlockType=STD, BPCN=P+(SignExtend(simm25)<<1), TYPE=DIRECT, TAKEN=1.
- COND installs the same BPC/BlockType/BPCN fields with TYPE=COND and TAKEN=0; SETC.* may update TAKEN and SETC.TGT may update BPCN before commit.
- Neither form selects BPCN at decode; BSTOP or the next BSTART is the continuation boundary.

## Memory effects and ordering

### Memory effects

- Any memory effects of the retiring block complete before the new BARG is installed; BSTART itself performs no memory access.

### Ordering

- Decode and candidate-target validation precede retiring-block commit; successful commit precedes atomic publication of the new BARG.

## Exceptions

- An odd computed BARG.BPCN raises Fault_InstructionPC before changing BARG.
- A failed retiring-block commit preserves the retiring BARG and does not install the candidate BARG.

## Examples

- BSTART DIRECT, <label>
