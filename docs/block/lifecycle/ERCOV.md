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

In PTO, `ERCOV` does nothing except fault. Its encoding family is reserved for an extension-owned execution-context recovery command. PTO lists the family so that no PTO instruction can be assigned a colliding encoding, but it never executes it.

A matching instruction raises `Fault_IllegalInstruction`, except after a pending system-block terminal request as described below. The companion family [ESAVE](ESAVE.md) is reserved in the same way.

<!-- PTO-READER-BLOCK: block-ercov-mechanism role=mechanism -->
## Placement and execution mechanism

The family is every 32-bit word whose masked bits `word & 0x06007fff` equal `0x00003031`: bits `14:0` are `0x3031` and bits `26:25` are zero. `ERCOV` has no legal placement, inside or outside a block.

The command dispatcher decodes the form, finds its handler `RecoverExecutionContext`, and checks `CommandHandlerSupported`. That function returns false for this handler, so the dispatcher raises `Fault_IllegalInstruction` and returns before the handler body runs.

Design point: the ASL does define a helper, `RecoverExecutionContextState`, in [frame lifetime](../model/lifecycle/lifetime.md). It is unreachable in PTO, because the support check rejects the command first. Its text does not describe PTO behavior.

<!-- PTO-READER-BLOCK: block-ercov-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `RegSrc0` (bits `19:15`), `RegSrc1` (bits `24:20`), and `RegSrc2` (bits `31:27`) appear in the canonical spelling as `BasePtr`, `LenBytes`, and `Kind`.
- PTO never interprets these fields and never reads the registers they would name.
- All 32 values of each field, including zero, are part of the reserved family.

Design point: there is no default and no meaning for encoded zero, because rejection happens before any field is decoded as an operand.

<!-- PTO-READER-BLOCK: block-ercov-effects role=effects -->
## State effects and ordering

None beyond the trap delivery that every fault performs. No register is read, and no register, memory, block, or memory-command state changes. The fault address is the `ERCOV` itself; `SetFault` saves the trap context and writes `TPC` to the trap vector entry, which is the fault address when no trap vector base is programmed.

<!-- PTO-READER-BLOCK: block-ercov-constraints role=constraints -->
## Legality, faults, and atomicity

In an ordinary context, every matching word raises `Fault_IllegalInstruction` at the current `TPC` before any effect. Rejection is unconditional: it does not depend on the field values, on the privilege ring, or on whether a block is active. There is no restart or partial-progress path.

The dispatcher checks a pending system-block terminal request before it reaches the support check. After an `ACRC` has marked a system block as terminating, a matching word therefore raises `Fault_BundleControl` instead.

The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: block-ercov-example role=example -->
## Non-normative worked example

This is a rejection example only; PTO accepts no matching carrier as an executable instruction.

```asm
ERCOV [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind] (reserved in PTO)
```

The word `0x00003031` (all three fields zero) and the same word with all three fields set to 31 both match the family. Both raise `Fault_IllegalInstruction` at the `ERCOV` address, and no register is read.
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
    return !CommandHandlerSupported(
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
