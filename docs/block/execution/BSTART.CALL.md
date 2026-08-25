<!-- GENERATED FROM: asl/block/execution/BSTART.CALL.asl -->
# BSTART.CALL

**Normative ASL source:** `asl/block/execution/BSTART.CALL.asl`

Atomically retires the old block, installs a direct-call BARG, and writes the independent return target to ra.

## Normative identity {#PTO-INST-BLOCK-BSTART-CALL}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-call-purpose role=purpose -->
## What BSTART.CALL contributes

`BSTART.CALL` is a 32-bit block-start command for the CALL form. It establishes the pending block identity and selectors; the completed block, not the start command alone, owns body execution and result commitment.

<!-- PTO-READER-BLOCK: block-bstart-call-mechanism role=mechanism -->
## Placement and mechanism

Header commands execute sequentially after the start, while `BSTOP` or the next `BSTART` is the boundary that validates and retires the completed block. The current owner gives this exact composition checklist:

```text
none
```

After any active predecessor is retired successfully, the command initializes the new pending `BARG` or operation descriptor and continues header execution at the sequential PC. No block destination or memory result becomes visible merely because the start decoded. The return-address result is published only when start applicability, target checks, and predecessor retirement all succeed.

<!-- PTO-READER-BLOCK: block-bstart-call-inputs role=inputs-outputs -->
## Operands and header roles

- `simm12` supplies the encoded offset or addend; its exact assigned domain remains in the generated contract below.
- `uimm5` supplies the encoded offset or addend; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-bstart-call-effects role=effects -->
## Pending state and completion

The start transition is all-or-nothing with predecessor retirement for applicability and target checks. After the start succeeds, the later completion boundary validates the full composition before any body result can commit.

<!-- PTO-READER-BLOCK: block-bstart-call-constraints role=constraints -->
## Legality and fault boundary

Reserved selectors, invalid targets, malformed completed composition, or failed predecessor retirement are rejected before new-block or body effects.

<!-- PTO-READER-BLOCK: block-bstart-call-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.CALL <br_label>, <rt_label>, ->ra
```

Assume predecessor retirement and target checks succeed. `BSTART.CALL <br_label>, <rt_label>, ->ra` opens the pending `BSTART.CALL` form; subsequent header/body commands remain provisional until `BSTOP` or the next `BSTART` validates the complete composition.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.CALL <br_label>, <rt_label>, ->ra
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_call_32_9404418d1ae5 | L32 | 32 | 0x50160002 / 0xf83f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_call_32_9404418d1ae5 | simm12 | 12 | signed | [{"instruction_lsb":4,"value_lsb":0,"width":12}] |
| bstart_call_32_9404418d1ae5 | uimm5 | 5 | unsigned | [{"instruction_lsb":22,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_call_32_9404418d1ae5 | simm12 | 12 | 0–4095 | none | none | 12-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_call_32_9404418d1ae5 | uimm5 | 5 | 0–31 | none | none | unsigned return-address displacement | Encoded zero supplies a zero displacement or zero immediate value. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm12 | 12-bit signed bundle target displacement |
| uimm5 | unsigned return-address displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.CALL.asl -->
```asl
readonly func InstructionContractMatches_BSTART_CALL(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_call_32_9404418d1ae5);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.CALL.asl -->
```asl
readonly func InstructionContractHandler_BSTART_CALL() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractTransfer_BSTART_CALL()
    => BundleTransfer
begin
    return BundleTransfer_Call;
end;

pure func InstructionContractWritesReturnAddress_BSTART_CALL()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- simm12 and uimm5 are both present; encoded zero is a real zero displacement for that field.

## Legality

- All bit patterns not excluded by the form decode are assigned by this instruction contract.

## State effects

- Installs BARG.BPC=P, BlockType=STD, BPCN=call_target, TYPE=DIRECT, TAKEN=1, and writes return_target to ra.
- The call target is selected only when the new block later commits.

## Memory effects and ordering

### Memory effects

- Any memory effects of the retiring block complete before the call BARG and ra are published; BSTART.CALL itself performs no memory access.

### Ordering

- Validate both targets, successfully commit the retiring block, then atomically install the new STD BARG and write ra.

## Exceptions

- An odd call target raises Fault_InstructionPC before retiring-block effects.
- Decode, applicability, target, or retiring-commit failure preserves ra and the retiring BARG and installs no candidate BARG.

## Examples

- BSTART.CALL <br_label>, <rt_label>, ->ra
