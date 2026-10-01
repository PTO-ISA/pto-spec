<!-- GENERATED FROM: asl/block/lifecycle/ESAVE.asl -->
# ESAVE

**Normative ASL source:** `asl/block/lifecycle/ESAVE.asl`

Inventories an extension-owned execution-context save family rejected by PTO before effects.

## Normative identity {#PTO-INST-BLOCK-ESAVE}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-esave-purpose role=purpose -->
## What ESAVE does

In PTO, `ESAVE` does nothing except fault. Its encoding family is reserved for an extension-owned execution-context save command. PTO lists the family so that no PTO instruction can be assigned a colliding encoding, but it never executes it.

A matching instruction raises `Fault_IllegalInstruction`, except after a pending system-block terminal request as described below. The companion family [ERCOV](ERCOV.md) is reserved in the same way.

<!-- PTO-READER-BLOCK: block-esave-mechanism role=mechanism -->
## Placement and execution mechanism

The family is every 32-bit word whose masked bits `word & 0x06007fff` equal `0x00002031`: bits `14:0` are `0x2031` and bits `26:25` are zero. `ESAVE` has no legal placement, inside or outside a block.

The command dispatcher decodes the form, finds its handler `SaveExecutionContext`, and checks `CommandHandlerSupported`. That function returns false for this handler, so the dispatcher raises `Fault_IllegalInstruction` and returns before the handler body runs.

Design point: the ASL does define a helper, `SaveExecutionContextState`, in [frame lifetime](../model/lifecycle/lifetime.md). It is unreachable in PTO, because the support check rejects the command first. Its text does not describe PTO behavior.

<!-- PTO-READER-BLOCK: block-esave-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- `RegSrc0` (bits `19:15`), `RegSrc1` (bits `24:20`), and `RegSrc2` (bits `31:27`) appear in the canonical spelling as `BasePtr`, `LenBytes`, and `Kind`.
- PTO never interprets these fields and never reads the registers they would name.
- All 32 values of each field, including zero, are part of the reserved family.

Design point: there is no default and no meaning for encoded zero, because rejection happens before any field is decoded as an operand.

<!-- PTO-READER-BLOCK: block-esave-effects role=effects -->
## State effects and ordering

None beyond the trap delivery that every fault performs. No register is read, and no register, memory, block, or memory-command state changes. The fault address is the `ESAVE` itself; `SetFault` saves the trap context and writes `TPC` to the trap vector entry, which is the fault address when no trap vector base is programmed.

<!-- PTO-READER-BLOCK: block-esave-constraints role=constraints -->
## Legality, faults, and atomicity

In an ordinary context, every matching word raises `Fault_IllegalInstruction` at the current `TPC` before any effect. Rejection is unconditional: it does not depend on the field values, on the privilege ring, or on whether a block is active. There is no restart or partial-progress path.

The dispatcher checks a pending system-block terminal request before it reaches the support check. After an `ACRC` has marked a system block as terminating, a matching word therefore raises `Fault_BundleControl` instead.

The generated legality and exception sections below are authoritative.

<!-- PTO-READER-BLOCK: block-esave-example role=example -->
## Non-normative worked example

This is a rejection example only; PTO accepts no matching carrier as an executable instruction.

```asm
ESAVE [RegSrc0=BasePtr, RegSrc1=LenBytes, RegSrc2=Kind] (reserved in PTO)
```

The word `0x00002031` (all three fields zero) and the same word with all three fields set to 31 both match the family. Both raise `Fault_IllegalInstruction` at the `ESAVE` address, and no register is read.
<!-- SUPPLEMENTARY-END -->

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
    return !CommandHandlerSupported(
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
