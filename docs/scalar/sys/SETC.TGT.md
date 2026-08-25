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

`SETC.TGT` captures a scalar source into the active block's `BARG.BPCN` commit target.

<!-- PTO-READER-BLOCK: scalar-setc-tgt-mechanism role=mechanism -->
## Block-state mechanism

The ASL DOC region selects `ScalarHandler_SetCommitTarget`. Placement and encoded legality are checked before sources or system state can change.

The instruction occupies one scalar operation position in an active Standard or Floating block and is not legal in a SYS block.

<!-- PTO-READER-BLOCK: scalar-setc-tgt-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`SrcL` carries the Reg5 source: R0..R23, T#1..T#4, or U#1..U#4.

Encoded zero is an assigned field value, never an omitted operand.

<!-- PTO-READER-BLOCK: scalar-setc-tgt-effects role=effects -->
## Architectural effects

The snapshotted source replaces only `BARG.BPCN`; every other BARG and block-control field is preserved.

Block applicability is checked before reading `SrcL`, and `TPC` advances only after the new target is stored.

<!-- PTO-READER-BLOCK: scalar-setc-tgt-constraints role=constraints -->
## Placement and rejection

The operation is assigned only in an active Standard or Floating block.

An inactive body or any block kind other than Standard or Floating raises Illegal Block Exception before reading `SrcL` or changing BARG or `TPC`.

<!-- PTO-READER-BLOCK: scalar-setc-tgt-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Start with `setc.tgt SrcL` in an active Standard or Floating block and trace the source snapshot before the BARG update.
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
