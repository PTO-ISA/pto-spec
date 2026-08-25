<!-- GENERATED FROM: asl/scalar/sys/SETC.TGT.asl -->
# SETC.TGT

**Normative ASL source:** `asl/scalar/sys/SETC.TGT.asl`

SETC.TGT snapshots SrcL into BARG.BPCN for the active Standard or Floating block.

## Normative identity {#PTO-INST-SCALAR-SETC-TGT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-setc-tgt-purpose role=purpose -->
## SETC.TGT 的作用

`SETC.TGT` 把标量源捕获到活动块的 `BARG.BPCN` 提交目标。

<!-- PTO-READER-BLOCK: scalar-setc-tgt-mechanism role=mechanism -->
## 块状态机制

ASL DOC 区域选择 `ScalarHandler_SetCommitTarget`。读取源或改变系统状态之前，必须先检查位置和编码合法性。

该指令占用活动 Standard 或 Floating 块中的一个标量操作位置，在 SYS 块中不合法。

<!-- PTO-READER-BLOCK: scalar-setc-tgt-inputs-outputs role=inputs-outputs -->
## 输入与输出

`SrcL` 承载 Reg5 源：R0..R23、T#1..T#4 或 U#1..U#4。

编码零是已分配的字段值，从不表示省略操作数。

<!-- PTO-READER-BLOCK: scalar-setc-tgt-effects role=effects -->
## 架构效果

快照得到的源值只替换 `BARG.BPCN`；其他 BARG 与块控制字段全部保持不变。

读取 `SrcL` 之前先检查块适用性，只有新目标写入后 `TPC` 才前进。

<!-- PTO-READER-BLOCK: scalar-setc-tgt-constraints role=constraints -->
## 位置与拒绝边界

该操作只在活动 Standard 或 Floating 块中分配。

块体未激活或块类型不是 Standard 或 Floating 时，会在读取 `SrcL` 或改变 BARG、`TPC` 之前触发 Illegal Block Exception。

<!-- PTO-READER-BLOCK: scalar-setc-tgt-example role=example -->
## 非规范示例

该写法示例只用于说明；确切合法性与效果仍由下方生成契约定义。

可在活动 Standard 或 Floating 块中从 `setc.tgt SrcL` 开始，先跟踪源快照，再查看 BARG 更新。
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
setc.tgt SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| setc_tgt_32_c02656d3a2b8 | L32 | 32 | 0x0000403b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| setc_tgt_32_c02656d3a2b8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| setc_tgt_32_c02656d3a2b8 | SrcL | 5 | 0–31 | none | none | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 | Encoded zero names the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | Reg5 source: R0..R23, T#1..T#4, or U#1..U#4 |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/SETC.TGT.asl -->
```asl
readonly func InstructionContractOperation_SETC_TGT()
    => ScalarOperation
begin
    return ScalarOperation_SETC_TGT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
SETC.TGT is legal in the body of an active Standard or Floating block and is not a SYS-block instruction.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/SETC.TGT.asl -->
```asl
readonly func InstructionContractHandler_SETC_TGT()
    => ScalarSemanticHandler
begin
    return ScalarHandler_SetCommitTarget;
end;

pure func InstructionContractRequiresSystemBlock_SETC_TGT()
    => boolean
begin
    return FALSE;
end;

pure func InstructionContractRequiresCommitTargetBlock_SETC_TGT()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractWritesBARGBPCN_SETC_TGT()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every displayed operand is encoded explicitly. Encoded zero is an assigned value and never denotes omission.

## Legality

- Every available Reg5 source selector is assigned; block applicability is checked before the source read.

## State effects

- Replace only BARG.BPCN with the complete XLEN source; preserve BPC, BlockType, TYPE, TAKEN, and all other block state.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Check block applicability, snapshot SrcL, write BARG.BPCN, and then advance TPC.

## Exceptions

- Invalid block placement raises Illegal Block Exception before encoded-field legality or effects.
- A reserved encoding or rejected access raises Illegal Instruction before destination, queue, system-state, or TPC effects.

## Examples

- setc.tgt SrcL
