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

`LSRGET` 从活动 BARG 视图读取一个已分配字，并通过 Reg5 目的地映射发布。

<!-- PTO-READER-BLOCK: scalar-lsrget-mechanism role=mechanism -->
## 块状态机制

ASL DOC 区域选择 `ScalarHandler_ExecuteLocalStateRegisterGet`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

只要所选 BARG 字适用于当前活动块，该指令就可以占用其中一个标量操作位置。

<!-- PTO-READER-BLOCK: scalar-lsrget-inputs-outputs role=inputs-outputs -->
## 输入与输出

`LSR_ID` 承载活动 BARG 字标识符；`RegDst` 承载 Reg5 目的地：丢弃、R1..R23、压入 U 或压入 T。

编码零是已分配的字段值，从不表示省略操作数。

<!-- PTO-READER-BLOCK: scalar-lsrget-effects role=effects -->
## 架构效果

已分配的 ID 选择 `BARG.BPC`、`BARG.BPCN` 或规范打包的 BARG 控制字，并通过 `RegDst` 发布。

读取不会改变 BARG 或系统寄存器状态；只有适用性检查通过后才会发布。

<!-- PTO-READER-BLOCK: scalar-lsrget-constraints role=constraints -->
## 位置与拒绝边界

ID `0`、`1`、`2` 已分配；`1` 只适用于 Standard 与 Floating 块，更高 ID 都是保留值。

块体未激活、ID 未分配或所选 BARG 字不适用于当前活动块时，会在产生目的地、队列、系统状态或 `TPC` 效果之前触发 Illegal Block Exception。

<!-- PTO-READER-BLOCK: scalar-lsrget-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可从 `lsrget LSR_ID, ->{t, u, Rd}` 开始，沿所选 BARG 字完成适用性检查，再查看发布行为。
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
