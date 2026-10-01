<!-- GENERATED FROM: asl/scalar/sys/LSRGET.asl -->
# LSRGET

**Normative ASL source:** `asl/scalar/sys/LSRGET.asl`

LSRGET reads one assigned word from the active block BARG view.

## Normative identity {#PTO-INST-SCALAR-LSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-lsrget-purpose role=purpose -->
## LSRGET 的作用

`LSRGET` 读取活动块参数（BARG）视图中的一个字。12 位 `LSR_ID` 选择是哪个字，Reg5 目的地接收它。共有三个标识符已分配：`BARG.BPC`、候选下一 PC `BARG.BPCN`，以及一个打包控制字，它报告块的种类、传送与控制属性。

<!-- PTO-READER-BLOCK: scalar-lsrget-mechanism role=mechanism -->
## 系统机制

`InstructionContractHandler_LSRGET` 选择 `ScalarHandler_ExecuteLocalStateRegisterGet`（`asl/scalar/sys/LSRGET.asl:17`），而 `InstructionContractRequiresSystemBlock_LSRGET` 返回 `FALSE`（`asl/scalar/sys/LSRGET.asl:23`），因此它不是 SYS 块指令：它需要任意活动的块体。派发器解码 `RegDst`，并把标识符的低 12 位传给辅助函数（`asl/scalar/model/dispatch/sys.asl:101`）。

该辅助函数先询问 `CurrentBARGWordApplicable`，当答案为否时引发 `Fault_BundleControl`（`asl/scalar/model/sys/semantics.asl:172`）。

<!-- PTO-READER-BLOCK: scalar-lsrget-inputs-outputs role=inputs-outputs -->
## 输入与输出

`LSR_ID` 是 12 位 BARG 字标识符，`RegDst` 是 Reg5 目的地（`asl/scalar/sys/LSRGET.asl:1`）。标识符 0 选择 `BARG.BPC`，标识符 1 选择 `BARG.BPCN`，标识符 2 选择打包控制字；标识符 3 到 4095 为保留。`InstructionContractLocalRegisterIDLegal_LSRGET` 把该限制写成 `UInt(identifier) <= 2`（`asl/scalar/sys/LSRGET.asl:29`）。

设计要点：标识符 1 只对 Standard 与 Floating 块适用，因为 `BARGHasCandidateWord` 仅对这两个块种类为真（`asl/block/model/state/barg.asl:31`）。`InstructionContractBPCNApplicable_LSRGET` 规定了同样这两个种类（`asl/scalar/sys/LSRGET.asl:35`），因此没有 `BARG.BPCN` 的块种类无法被索取该字。

<!-- PTO-READER-BLOCK: scalar-lsrget-effects role=effects -->
## 架构效果

成功的读取把所选字发布到目的地，并把 `TPC` 推进 4 字节。打包字是按需组装的：第 3:0 位用于块种类，第 8 到 12 位用于 atomic、acquire、release、far 和维度归约属性；第 6:4 位用于传送种类、第 7 位用于 `TAKEN`，但这两项只在 Standard 或 Floating 块中填充，其余所有位为零（`asl/block/model/state/barg.asl:37`）。

设计要点：打包字是活动块状态的投影而不是存储状态。读取 `BARG.BPC`、`BARG.BPCN` 或打包字从不修改 `BARG`，因此观察与延续不会互相干扰。

`LSRGET` 不写系统寄存器，也不执行普通标量内存访问。

<!-- PTO-READER-BLOCK: scalar-lsrget-constraints role=constraints -->
## 位置与拒绝边界

`LSRGET` 要求活动 bundle 且块体活动。在其他情况下 `CurrentBARGWordApplicable` 返回 `FALSE`，该次尝试在任何目的地效果之前引发 `Fault_BundleControl`。保留标识符，或在没有候选字的块种类中使用标识符 1，都以同样方式被拒绝（`asl/block/model/state/barg.asl:54`）。

设计要点：适用性测试同时覆盖 bundle 与块体状态以及标识符，因此同一条 `LSRGET` 编码在一种块种类中合法而在另一种中被拒绝。读取 `BARG.BPCN` 的代码因此只在具有候选字的块中合法。

<!-- PTO-READER-BLOCK: scalar-lsrget-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

在活动的 Standard 块体内，`lsrget LSR_ID, ->{t, u, Rd}` 在 `LSR_ID` 为 1 且目的地为 R3 时把 `BARG.BPCN` 读入 R3。同一指令在 `LSR_ID` 为 3 时引发 `Fault_BundleControl`，因为大于 2 的标识符为保留，且不写 `RegDst`。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
lsrget LSR_ID, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lsrget_32_448b17d7c20a | L32 | 32 | 0x0000303b / 0x000ff07f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lsrget_32_448b17d7c20a | LSR_ID | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |
| lsrget_32_448b17d7c20a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| lsrget_32_448b17d7c20a | LSR_ID | 12 | 0–4095 | none | none | active BARG word identifier | Encoded zero selects BARG.BPC; it is not omission. |
| lsrget_32_448b17d7c20a | RegDst | 5 | 0–31 | none | none | Reg5 destination: discard, R1..R23, push U, or push T | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| LSR_ID | active BARG word identifier |
| RegDst | Reg5 destination: discard, R1..R23, push U, or push T |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/LSRGET.asl -->
```asl
readonly func InstructionContractOperation_LSRGET()
    => ScalarOperation
begin
    return ScalarOperation_LSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
LSRGET is legal in any active block body for which the selected BARG word exists.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/LSRGET.asl -->
```asl
readonly func InstructionContractHandler_LSRGET()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteLocalStateRegisterGet;
end;

pure func InstructionContractRequiresSystemBlock_LSRGET()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractLocalRegisterIDLegal_LSRGET(
    identifier: bits(12)) => boolean
begin
    return UInt(identifier) <= 2;
end;

pure func InstructionContractBPCNApplicable_LSRGET(
    kind: BundleKind) => boolean
begin
    return kind == BundleKind_Standard ||
           kind == BundleKind_Floating;
end;

pure func InstructionContractReadsBARG_LSRGET()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- IDs 0, 1, and 2 select BPC, BPCN, and the packed BARG control word; IDs 3 through 4095 are reserved.
- ID 1 is applicable only to Standard and Floating blocks because other block types have no selecting BPCN.

## State effects

- ID 0 returns BARG.BPC; ID 1 returns BARG.BPCN; ID 2 returns the canonical packed control word.
- The packed word contains BlockType, applicable TYPE and TAKEN, atomic, acquire, release, far, and dimension-reduction fields, with all higher bits zero.
- LSRGET does not modify BARG or the system-register file.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check active-body placement, ID assignment, and selected-word applicability before any destination or queue effect.
- Snapshot the BARG word, publish it through RegDst, and then advance TPC.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- An unassigned or block-inapplicable BARG word raises Illegal Block Exception before destination, queue, system-state, or TPC effects.

## Examples

- lsrget LSR_ID, ->{t, u, Rd}
