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
## What BSTART contributes

`BSTART` is a 32-bit block-start command for the standard continuation form. It establishes the pending block identity and selectors; the completed block, not the start command alone, owns body execution and result commitment.

<!-- PTO-READER-BLOCK: block-bstart-mechanism role=mechanism -->
## Placement and mechanism

Header commands execute sequentially after the start, while `BSTOP` or the next `BSTART` is the boundary that validates and retires the completed block. The current owner gives this exact composition checklist:

```text
none
```

After any active predecessor is retired successfully, the command initializes the new pending `BARG` or operation descriptor and continues header execution at the sequential PC. No block destination or memory result becomes visible merely because the start decoded.

<!-- PTO-READER-BLOCK: block-bstart-inputs role=inputs-outputs -->
## Operands and header roles

- `simm25` supplies the encoded offset or addend; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-bstart-effects role=effects -->
## Pending state and completion

The start transition is all-or-nothing with predecessor retirement for applicability and target checks. After the start succeeds, the later completion boundary validates the full composition before any body result can commit.

<!-- PTO-READER-BLOCK: block-bstart-constraints role=constraints -->
## Legality and fault boundary

Reserved selectors, invalid targets, malformed completed composition, or failed predecessor retirement are rejected before new-block or body effects.

<!-- PTO-READER-BLOCK: block-bstart-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART DIRECT, <label>
```

Assume predecessor retirement and target checks succeed. `BSTART DIRECT, <label>` opens the pending `BSTART` form; subsequent header/body commands remain provisional until `BSTOP` or the next `BSTART` validates the complete composition.
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
