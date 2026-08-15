<!-- GENERATED FROM: asl/block/lifecycle/ESAVE.asl -->
# ESAVE

**Normative ASL source:** `asl/block/lifecycle/ESAVE.asl`

Inventories an extension-owned execution-context save family rejected by PTO before effects.

## Normative identity {#PTO-INST-BLOCK-ESAVE}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| esave_32_4c4f79fe3171 | L32 | 32 | 0x00002031 / 0x06007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| esave_32_4c4f79fe3171 | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| esave_32_4c4f79fe3171 | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| esave_32_4c4f79fe3171 | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| esave_32_4c4f79fe3171 | RegSrc0 | 5 | 0–31 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |
| esave_32_4c4f79fe3171 | RegSrc1 | 5 | 0–31 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |
| esave_32_4c4f79fe3171 | RegSrc2 | 5 | 0–31 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegSrc0 | uninterpreted extension field reserved in PTO |
| RegSrc1 | uninterpreted extension field reserved in PTO |
| RegSrc2 | uninterpreted extension field reserved in PTO |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/ESAVE.asl -->
```asl
readonly func InstructionContractMatches_ESAVE(operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_esave_32_4c4f79fe3171;
end;

pure func InstructionContractSupported_ESAVE() => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
none; ESAVE is not an executable PTO command
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/ESAVE.asl -->
```asl
readonly func InstructionContractHandler_ESAVE() => CommandSemanticHandler
begin
    return CommandHandler_SaveExecutionContext;
end;

pure func InstructionContractRejectsBeforeEffects_ESAVE() => boolean
begin
    return !CommandHandlerSupportedPTOv0(
        CommandHandler_SaveExecutionContext);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No PTO default exists because the complete raw family is reserved and rejected before field interpretation.

## Legality

- The full family selected by mask 0x06007fff and match 0x00002031 is occupied extension space and is not executable in PTO.
- All 32 values of each encoded selector remain collision-protected and PTO must not allocate another instruction in this family.

## State effects

- none; the form always raises Fault_IllegalInstruction before effects in PTO

## Memory effects and ordering

### Memory effects

- none; rejection precedes every memory access

### Ordering

- Decode and profile rejection precede operand interpretation and every architectural effect.

## Exceptions

- Every matching form raises Fault_IllegalInstruction at the current TPC before register reads, memory access, context save, or state changes.

## Examples

- ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind] (reserved in PTO)

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
