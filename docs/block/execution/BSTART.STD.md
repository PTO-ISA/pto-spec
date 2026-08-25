<!-- GENERATED FROM: asl/block/execution/BSTART.STD.asl -->
# BSTART.STD

**Normative ASL source:** `asl/block/execution/BSTART.STD.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-STD}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-bstart-std-purpose role=purpose -->
## What BSTART.STD contributes

`BSTART.STD` is a 32-bit block-start command for the STD form. It establishes the pending block identity and selectors; the completed block, not the start command alone, owns body execution and result commitment.

<!-- PTO-READER-BLOCK: block-bstart-std-mechanism role=mechanism -->
## Placement and mechanism

Header commands execute sequentially after the start, while `BSTOP` or the next `BSTART` is the boundary that validates and retires the completed block. The current owner gives this exact composition checklist:

```text
BSTART.STD retires any active predecessor block, then opens one standard block whose header commands execute sequentially until BSTOP or the next BSTART selects the BARG continuation.
COND publishes a candidate BPCN but SETC may update TAKEN before commit; IND requires and snapshots a retiring Standard or Floating BARG.BPCN, while RET snapshots architectural ra before predecessor retirement.
```

After any active predecessor is retired successfully, the command initializes the new pending `BARG` or operation descriptor and continues header execution at the sequential PC. No block destination or memory result becomes visible merely because the start decoded.

<!-- PTO-READER-BLOCK: block-bstart-std-inputs role=inputs-outputs -->
## Operands and header roles

- `simm17` supplies the encoded offset or addend; its exact assigned domain remains in the generated contract below.

<!-- PTO-READER-BLOCK: block-bstart-std-effects role=effects -->
## Pending state and completion

The start transition is all-or-nothing with predecessor retirement for applicability and target checks. After the start succeeds, the later completion boundary validates the full composition before any body result can commit.

<!-- PTO-READER-BLOCK: block-bstart-std-constraints role=constraints -->
## Legality and fault boundary

Reserved selectors, invalid targets, malformed completed composition, or failed predecessor retirement are rejected before new-block or body effects.

<!-- PTO-READER-BLOCK: block-bstart-std-example role=example -->
## Non-normative worked example

This worked example is non-normative; it illustrates the current owner without replacing it.

```asm
BSTART.STD COND, <label>
```

Assume predecessor retirement and target checks succeed. `BSTART.STD COND, <label>` opens the pending `BSTART.STD` form; subsequent header/body commands remain provisional until `BSTOP` or the next `BSTART` validates the complete composition.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
BSTART.STD COND, <label>
BSTART.STD FALL
BSTART.STD RET
BSTART.STD IND
BSTART.STD DIRECT, <label>
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_std_32_1ef99c4cedcb | L32 | 32 | 0x00003001 / 0x00007fff | [] |
| bstart_std_32_441ad677fffe | L32 | 32 | 0x00001001 / 0x00007fff | [{"field":"simm17","operator":"one-of","values":[0]}] |
| bstart_std_32_816dfa76cc4a | L32 | 32 | 0x00007001 / 0xffffffff | [] |
| bstart_std_32_986b7ee2cf6a | L32 | 32 | 0x00005001 / 0xffffffff | [] |
| bstart_std_32_c1de85e06878 | L32 | 32 | 0x00002001 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_std_32_1ef99c4cedcb | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_std_32_441ad677fffe | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_std_32_c1de85e06878 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_std_32_1ef99c4cedcb | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_std_32_441ad677fffe | simm17 | 17 | 0 | none | 1–131071 | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_std_32_c1de85e06878 | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

- `bstart_std_32_441ad677fffe.simm17` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | 17-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.STD.asl -->
```asl
readonly func InstructionContractMatches_BSTART_STD(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_std_32_1ef99c4cedcb) ||
           (operation == CommandOperation_bstart_std_32_441ad677fffe) ||
           (operation == CommandOperation_bstart_std_32_816dfa76cc4a) ||
           (operation == CommandOperation_bstart_std_32_986b7ee2cf6a) ||
           (operation == CommandOperation_bstart_std_32_c1de85e06878);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.STD retires any active predecessor block, then opens one standard block whose header commands execute sequentially until BSTOP or the next BSTART selects the BARG continuation.
COND publishes a candidate BPCN but SETC may update TAKEN before commit; IND requires and snapshots a retiring Standard or Floating BARG.BPCN, while RET snapshots architectural ra before predecessor retirement.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.STD.asl -->
```asl
readonly func InstructionContractHandler_BSTART_STD() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;

readonly func InstructionContractBundleKind_BSTART_STD()
    => BundleKind
begin
    return BundleKind_Standard;
end;

pure func InstructionContractStartsBundle_BSTART_STD()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART.STD FALL encodes simm17=0; nonzero values in that family are extension-reserved.

## Legality

- Exactly FALL, DIRECT, COND, IND, and RET are accepted.
- The FALL form accepts only simm17=0; every nonzero FALL payload is extension-reserved.
- Bare CALL and ICALL forms are deleted.

## State effects

- On success BPC records the BSTART address; BARG.BlockType becomes STD; BARG.TYPE records FALL, DIRECT, COND, IND, or RET; BARG.BPCN records the candidate target; and BARG.TAKEN is false only for COND until SETC resolves it.
- Header execution continues at the sequential PC. BSTOP or the next BSTART commits the candidate continuation selected by BARG.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- All target, descriptor, and form checks precede predecessor retirement. New BARG state is installed only after successful retirement.

## Exceptions

- A nonzero FALL simm17, deleted bare CALL/ICALL encoding, reserved BrType, odd target, or unsupported form raises before predecessor retirement or new BARG effects.
- IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects.
- If predecessor commit fails, the old block and continuation remain authoritative and no standard block is installed.

## Examples

- BSTART.STD FALL
- BSTART.STD DIRECT, target
- BSTART.STD COND, target
- BSTART.STD IND
- BSTART.STD RET
