<!-- GENERATED FROM: asl/block/lifecycle/ERCOV.asl -->
# ERCOV

**Normative ASL source:** `asl/block/lifecycle/ERCOV.asl`

Inventories an extension-owned execution-context recovery family rejected by PTO before effects.

## Normative identity {#PTO-INST-BLOCK-ERCOV}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-ercov-purpose role=purpose -->
## What ERCOV does

`ERCOV` identifies an extension-owned raw carrier family that PTO inventories but never accepts for execution.

<!-- PTO-READER-BLOCK: block-ercov-mechanism role=mechanism -->
## Placement and execution mechanism

Every raw carrier matching the `ERCOV` family is reserved in PTO; it is not a standalone command or a Block-body member.

The matched raw carrier uses the `L32` encoding class, but `RegSrc0`, `RegSrc1`, and `RegSrc2` remain uninterpreted.

Profile rejection raises `Fault_IllegalInstruction` unconditionally before register reads, field interpretation, memory access, or architectural effects.

<!-- PTO-READER-BLOCK: block-ercov-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- Encoded operands: `RegSrc0` — uninterpreted extension field reserved in PTO; `RegSrc1` — uninterpreted extension field reserved in PTO; `RegSrc2` — uninterpreted extension field reserved in PTO.
- The three displayed fields are collision-protected extension bits, not PTO operands, and are never read.
- All `32` values of each displayed field remain reserved; zero has no PTO operand meaning.

<!-- PTO-READER-BLOCK: block-ercov-effects role=effects -->
## State effects and ordering

No source is read and no register, memory, recovery/save, Block, event, or control-flow state changes.

Decode retains only the occupied-family identity so PTO cannot allocate a colliding instruction.

<!-- PTO-READER-BLOCK: block-ercov-constraints role=constraints -->
## Legality, faults, and atomicity

The complete matched family is reserved and rejection precedes every architectural effect.

The current owner reports invalid schema, state, address, or continuation conditions through `Fault_IllegalInstruction`; no prose on this page creates an additional fault rule.

Rejection is unconditional and has no restart or retained-progress path.

<!-- PTO-READER-BLOCK: block-ercov-example role=example -->
## Non-normative worked example

This is a rejection example only; PTO accepts no matching carrier as an executable instruction.

```asm
ERCOV [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind] (reserved in PTO)
```

The shown spelling names reserved extension space; PTO rejects it before interpreting any displayed field.
<!-- SUPPLEMENTARY-END -->

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
