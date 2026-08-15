<!-- GENERATED FROM: asl/block/lifecycle/ERCOV.asl -->
# ERCOV

**Normative ASL source:** `asl/block/lifecycle/ERCOV.asl`

Inventories an extension-owned execution-context recovery family rejected by PTO before effects.

## Normative identity {#PTO-INST-BLOCK-ERCOV}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ERCOV [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ercov_32_dc0be14a2d8b | L32 | 32 | 0x00003031 / 0x06007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ercov_32_dc0be14a2d8b | RegSrc0 | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ercov_32_dc0be14a2d8b | RegSrc1 | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| ercov_32_dc0be14a2d8b | RegSrc2 | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| ercov_32_dc0be14a2d8b | RegSrc0 | 5 | 0–31 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |
| ercov_32_dc0be14a2d8b | RegSrc1 | 5 | 0–31 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |
| ercov_32_dc0be14a2d8b | RegSrc2 | 5 | 0–31 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegSrc0 | uninterpreted extension field reserved in PTO |
| RegSrc1 | uninterpreted extension field reserved in PTO |
| RegSrc2 | uninterpreted extension field reserved in PTO |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/ERCOV.asl -->
```asl
readonly func InstructionContractMatches_ERCOV(operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_ercov_32_dc0be14a2d8b;
end;

pure func InstructionContractSupported_ERCOV() => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
none; ERCOV is not an executable PTO command
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/ERCOV.asl -->
```asl
readonly func InstructionContractHandler_ERCOV() => CommandSemanticHandler
begin
    return CommandHandler_RecoverExecutionContext;
end;

pure func InstructionContractRejectsBeforeEffects_ERCOV() => boolean
begin
    return !CommandHandlerSupportedPTOv0(
        CommandHandler_RecoverExecutionContext);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No PTO default exists because the complete raw family is reserved and rejected before field interpretation.

## Legality

- The full family selected by mask 0x06007fff and match 0x00003031 is occupied extension space and is not executable in PTO.
- All 32 values of each encoded selector remain collision-protected and PTO must not allocate another instruction in this family.

## State effects

- none; the form always raises Fault_IllegalInstruction before effects in PTO

## Memory effects and ordering

### Memory effects

- none; rejection precedes every memory access

### Ordering

- Decode and profile rejection precede operand interpretation and every architectural effect.

## Exceptions

- Every matching form raises Fault_IllegalInstruction at the current TPC before register reads, memory access, context recovery, or state changes.

## Examples

- ERCOV [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind] (reserved in PTO)

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
