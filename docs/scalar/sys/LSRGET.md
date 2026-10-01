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
## What LSRGET does

`LSRGET` reads one word of the active block argument (BARG) view. The 12-bit `LSR_ID` selects which word, and the Reg5 destination receives it. Three identifiers are assigned: `BARG.BPC`, the candidate next PC `BARG.BPCN`, and a packed control word that reports the block's kind, transfer, and control attributes.

<!-- PTO-READER-BLOCK: scalar-lsrget-mechanism role=mechanism -->
## System mechanism

`InstructionContractHandler_LSRGET` selects `ScalarHandler_ExecuteLocalStateRegisterGet` (`asl/scalar/sys/LSRGET.asl:17`), and `InstructionContractRequiresSystemBlock_LSRGET` returns `FALSE` (`asl/scalar/sys/LSRGET.asl:23`), so this is not a SYS-block instruction: it needs any active block body. The dispatcher decodes `RegDst` and passes the low 12 bits of the identifier to the helper (`asl/scalar/model/dispatch/sys.asl:101`).

The helper asks `CurrentBARGWordApplicable` first and raises `Fault_BundleControl` when the answer is no (`asl/scalar/model/sys/semantics.asl:172`).

<!-- PTO-READER-BLOCK: scalar-lsrget-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`LSR_ID` is the 12-bit BARG word identifier and `RegDst` is the Reg5 destination (`asl/scalar/sys/LSRGET.asl:1`). Identifier 0 selects `BARG.BPC`, identifier 1 selects `BARG.BPCN`, and identifier 2 selects the packed control word; identifiers 3 through 4095 are reserved. `InstructionContractLocalRegisterIDLegal_LSRGET` encodes that limit as `UInt(identifier) <= 2` (`asl/scalar/sys/LSRGET.asl:29`).

Design point: identifier 1 is applicable only to Standard and Floating blocks, because `BARGHasCandidateWord` is true for those kinds only (`asl/block/model/state/barg.asl:31`). `InstructionContractBPCNApplicable_LSRGET` states the same two kinds (`asl/scalar/sys/LSRGET.asl:35`), so a block type without a `BARG.BPCN` cannot be asked for one.

<!-- PTO-READER-BLOCK: scalar-lsrget-effects role=effects -->
## Architectural effects

A successful read publishes the selected word to the destination and advances `TPC` by 4 bytes. The packed word is assembled on demand and uses bits 3:0 for the block type and bits 8 through 12 for the atomic, acquire, release, far, and dimension-reduction attributes; bits 6:4 for the transfer type and bit 7 for `TAKEN` are filled only for a Standard or Floating block, and every other bit is zero (`asl/block/model/state/barg.asl:37`).

Design point: the packed word is a projection of live block state rather than stored state. Reading `BARG.BPC`, `BARG.BPCN`, or the packed word never modifies `BARG`, so observation and continuation cannot interfere.

`LSRGET` writes no system register and performs no ordinary scalar memory access.

<!-- PTO-READER-BLOCK: scalar-lsrget-constraints role=constraints -->
## Placement and rejection

`LSRGET` requires an active bundle with an active body. Outside one, `CurrentBARGWordApplicable` returns `FALSE` and the attempt raises `Fault_BundleControl` before any destination effect. A reserved identifier, or identifier 1 in a block kind without a candidate word, is rejected the same way (`asl/block/model/state/barg.asl:54`).

Design point: the applicability test covers the bundle and body state as well as the identifier, so the same `LSRGET` encoding can be legal in one block kind and rejected in another. Code that reads `BARG.BPCN` is therefore legal only in blocks that have a candidate word.

<!-- PTO-READER-BLOCK: scalar-lsrget-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Inside an active Standard block body, `lsrget LSR_ID, ->{t, u, Rd}` with `LSR_ID` 1 and a destination of R3 reads `BARG.BPCN` into R3. The same instruction with `LSR_ID` 3 raises `Fault_BundleControl`, because identifiers above 2 are reserved, and `RegDst` is not written.
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
