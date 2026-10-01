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
## What SETC.TGT does

`SETC.TGT` sets the candidate next PC of the active block. It snapshots the Reg5 source `SrcL` into `BARG.BPCN`, the field that a block boundary later selects as the next PC when the block's continuation rule calls for the candidate.

<!-- PTO-READER-BLOCK: scalar-setc-tgt-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_SETC_TGT` selects `ScalarHandler_SetCommitTarget` (`asl/scalar/sys/SETC.TGT.asl:18`), and `InstructionContractRequiresCommitTargetBlock_SETC_TGT` returns `TRUE` (`asl/scalar/sys/SETC.TGT.asl:30`). The applicability rule for the operation is `BundleCommitTargetWritable`, which requires an active bundle whose block type is Standard or Floating (`asl/scalar/model/sys/semantics.asl:316`).

`InstructionContractRequiresSystemBlock_SETC_TGT` returns `FALSE` (`asl/scalar/sys/SETC.TGT.asl:24`), so this instruction is not a SYS-block operation: it runs in the very block whose target it changes.

<!-- PTO-READER-BLOCK: scalar-setc-tgt-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` is the single operand, a Reg5 source from R0..R23, T#1..T#4, or U#1..U#4 (`asl/scalar/sys/SETC.TGT.asl:1`). It supplies the complete XLEN value that becomes the new candidate PC.

There is no destination operand. The output is the block state field `BARG.BPCN` itself. Encoded zero in `SrcL` names the architectural zero GPR, so zero is written as a real value rather than as an omission.

<!-- PTO-READER-BLOCK: scalar-setc-tgt-effects role=effects -->
## Architectural effects

On success the instruction replaces `BARG.BPCN` with the snapshotted source value and advances `TPC` by 4 bytes (`asl/scalar/model/sys/semantics.asl:336`, `asl/scalar/model/dispatch/top-level.asl:56`). Everything else in `BARG` is preserved: `BPC`, the block type, the transfer type, and `TAKEN` are untouched.

Design point: `BARG.BPCN` is only a candidate. A block boundary selects it through the continuation rule, which picks the candidate for direct, call, indirect, indirect-call, and return transfers, and for a conditional transfer only when `TAKEN` is set (`asl/block/model/state/barg.asl:14`). Writing the candidate therefore does not by itself change where the block continues.

The instruction performs no ordinary scalar memory access, writes no register, and does not consume the source; the source keeps its value.

<!-- PTO-READER-BLOCK: scalar-setc-tgt-constraints role=constraints -->
## Placement and rejection

Placement is the only gate, and it is unusually strict in kind rather than in position: the attempt needs an active Standard or Floating block, and any other block kind raises `Fault_BundleControl` at the active block's `TPC` value. The source is read only after that verdict, and a rejected attempt leaves `BARG.BPCN` and the pending continuation state unchanged, as the owner NDF clause requires.

There is no reserved source encoding to reject, because every Reg5 source selector is assigned, and no access-ring restriction applies.

<!-- PTO-READER-BLOCK: scalar-setc-tgt-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Inside an active Standard block body with a GPR holding 0x1000, `setc.tgt SrcL` snapshots 0x1000 into `BARG.BPCN`. If the block leaves through a direct transfer, the boundary selects `BARG.BPCN`, so execution continues at 0x1000; if it leaves through a conditional transfer whose `TAKEN` is clear, the sequential continuation wins and the new `BARG.BPCN` is not used. Running the same instruction in a SYS block body raises `Fault_BundleControl` instead.
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
