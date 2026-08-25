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

`LSRGET` reads an assigned word from the active BARG view and publishes it through Reg5 destination mapping.

<!-- PTO-READER-BLOCK: scalar-lsrget-mechanism role=mechanism -->
## Block-state mechanism

The ASL DOC region selects `ScalarHandler_ExecuteLocalStateRegisterGet`. Placement and encoded legality are checked before sources or system state can change.

The instruction occupies one scalar operation position in any active block for which the selected BARG word is applicable.

<!-- PTO-READER-BLOCK: scalar-lsrget-inputs-outputs role=inputs-outputs -->
## Inputs and outputs

`LSR_ID` carries the active BARG word identifier; `RegDst` carries the Reg5 destination: discard, R1..R23, push U, or push T.

Encoded zero is an assigned field value, never an omitted operand.

<!-- PTO-READER-BLOCK: scalar-lsrget-effects role=effects -->
## Architectural effects

Assigned IDs select `BARG.BPC`, `BARG.BPCN`, or the canonical packed BARG control word and publish it through `RegDst`.

The read leaves BARG and system-register state unchanged; publication occurs only after applicability checks.

<!-- PTO-READER-BLOCK: scalar-lsrget-constraints role=constraints -->
## Placement and rejection

IDs `0`, `1`, and `2` are assigned; `1` applies only to Standard and Floating blocks, and higher IDs are reserved.

An inactive body, an unassigned ID, or a selected BARG word that does not apply to the active block raises Illegal Block Exception before destination, queue, system-state, or `TPC` effects.

<!-- PTO-READER-BLOCK: scalar-lsrget-example role=example -->
## Non-normative example

This spelling example is illustrative; exact legality and effects remain in the generated contract below.

Start with `lsrget LSR_ID, ->{t, u, Rd}` and trace the selected BARG word through applicability checks before publication.
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
