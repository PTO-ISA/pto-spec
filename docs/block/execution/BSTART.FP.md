<!-- GENERATED FROM: asl/block/execution/BSTART.FP.asl -->
# BSTART.FP

**Normative ASL source:** `asl/block/execution/BSTART.FP.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-FP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART.FP RET
BSTART.FP COND, <label>
BSTART.FP IND
BSTART.FP DIRECT, <label>
BSTART.FP FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_fp_32_0c671a644214 | L32 | 32 | 0x00007101 / 0xffffffff | [] |
| bstart_fp_32_58ad7954fb49 | L32 | 32 | 0x00003101 / 0x00007fff | [] |
| bstart_fp_32_7978795a29a1 | L32 | 32 | 0x00005101 / 0xffffffff | [] |
| bstart_fp_32_d00a708a81f0 | L32 | 32 | 0x00002101 / 0x00007fff | [] |
| bstart_fp_32_face4f238d84 | L32 | 32 | 0x00001101 / 0x00007fff | [{"field":"simm17","operator":"one-of","values":[0]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_fp_32_58ad7954fb49 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_fp_32_d00a708a81f0 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |
| bstart_fp_32_face4f238d84 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| bstart_fp_32_58ad7954fb49 | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_fp_32_d00a708a81f0 | simm17 | 17 | 0–131071 | none | none | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |
| bstart_fp_32_face4f238d84 | simm17 | 17 | 0 | none | 1–131071 | 17-bit signed bundle target displacement | Encoded zero supplies a zero displacement or zero immediate value. |

- `bstart_fp_32_face4f238d84.simm17` reserved values: Reserved encodings raise Fault_IllegalInstruction before architectural effects.

## Operands and results

| Field | Architectural role |
| --- | --- |
| simm17 | 17-bit signed bundle target displacement |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.FP.asl -->
```asl
readonly func InstructionContractMatches_BSTART_FP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_fp_32_0c671a644214) ||
           (operation == CommandOperation_bstart_fp_32_58ad7954fb49) ||
           (operation == CommandOperation_bstart_fp_32_7978795a29a1) ||
           (operation == CommandOperation_bstart_fp_32_d00a708a81f0) ||
           (operation == CommandOperation_bstart_fp_32_face4f238d84);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.FP retires any active predecessor block, then opens one FP block whose header commands execute sequentially until BSTOP or the next BSTART selects the BARG continuation.
COND publishes a candidate BPCN but SETC may update TAKEN before commit; IND requires and snapshots a retiring Standard or Floating BARG.BPCN, while RET snapshots architectural ra before predecessor retirement.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.FP.asl -->
```asl
readonly func InstructionContractHandler_BSTART_FP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- BSTART.FP FALL encodes simm17=0; nonzero values in that family are extension-reserved.

## Legality

- Exactly FALL, DIRECT, COND, IND, and RET are accepted.
- The FALL form accepts only simm17=0; every nonzero FALL payload is extension-reserved.
- Bare CALL and ICALL forms are deleted.

## State effects

- On success BPC records the BSTART address; BARG.BlockType becomes FP; BARG.TYPE records FALL, DIRECT, COND, IND, or RET; BARG.BPCN records the candidate target; and BARG.TAKEN is false only for COND until SETC resolves it.
- Header execution continues at the sequential PC. BSTOP or the next BSTART commits the candidate continuation selected by BARG.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- All target, descriptor, and form checks precede predecessor retirement. New BARG state is installed only after successful retirement.

## Exceptions

- A nonzero FALL simm17, deleted bare CALL/ICALL encoding, reserved BrType, odd target, or unsupported form raises before predecessor retirement or new BARG effects.
- IND without an active retiring Standard or Floating BARG raises Fault_BundleControl before effects.
- If predecessor commit fails, the old block and continuation remain authoritative and no FP block is installed.

## Examples

- BSTART.FP FALL
- BSTART.FP DIRECT, target
- BSTART.FP COND, target
- BSTART.FP IND
- BSTART.FP RET

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
