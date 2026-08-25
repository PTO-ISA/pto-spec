<!-- GENERATED FROM: asl/block/encoding/XB.asl -->
# XB

**Normative ASL source:** `asl/block/encoding/XB.asl`

Inventories an extension-owned cross-block transfer encoding that PTO rejects before field interpretation or architectural effects.

## Normative identity {#PTO-INST-BLOCK-XB}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-xb-purpose role=purpose -->
## What XB does

`XB` identifies extension-owned encoding space that PTO inventories but always rejects before field interpretation or architectural effects.

<!-- PTO-READER-BLOCK: block-xb-mechanism role=mechanism -->
## Placement and execution mechanism

`XB` executes as a standalone `32`-bit command and does not require placement inside a `BSTART`/`BSTOP` body.

The matched raw family uses the `L32` encoding class, but PTO rejects it before either displayed field is interpreted.

Decode retains only collision identity; profile rejection precedes operand interpretation, memory, Block state, and control-flow effects.

<!-- PTO-READER-BLOCK: block-xb-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- Encoded operands: `ACR-ID` — uninterpreted extension field reserved in PTO; `CROSS-BID` — uninterpreted extension field reserved in PTO.
- All operands are resolved from the accepted carrier or named architectural state; no body-local hidden operand stream is created.
- Encoded zero remains an assigned value or a specifically documented rejection; it never silently means an omitted operand.

<!-- PTO-READER-BLOCK: block-xb-effects role=effects -->
## State effects and ordering

The form always raises `Fault_IllegalInstruction` and changes no Block, memory, or control-flow state.

The occupied raw encoding remains collision-protected for its complete field family.

<!-- PTO-READER-BLOCK: block-xb-constraints role=constraints -->
## Legality, faults, and atomicity

Fixed bits, reserved values, selector domains, and required Block placement are checked before architectural effects.

The current owner reports invalid schema, state, address, or continuation conditions through `Fault_IllegalInstruction`; no prose on this page creates an additional fault rule.

Rejection occurs before effects unless the current owner explicitly defines a restart boundary with retained progress; completion order remains the ASL order.

<!-- PTO-READER-BLOCK: block-xb-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
XB ACR-ID, C-ID (reserved in PTO)
```

The shown spelling identifies occupied extension space only; PTO rejects every matching carrier before interpreting either displayed field.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
XB ACR-ID, C-ID
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| xb_32_40ad190a0a7f | L32 | 32 | 0x00006f81 / 0x00007fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| xb_32_40ad190a0a7f | ACR-ID | 10 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":10}] |
| xb_32_40ad190a0a7f | CROSS-BID | 7 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":7}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| xb_32_40ad190a0a7f | ACR-ID | 10 | 0–1023 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |
| xb_32_40ad190a0a7f | CROSS-BID | 7 | 0–127 | none | none | uninterpreted extension field reserved in PTO | Uninterpreted in PTO, including encoded zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| ACR-ID | uninterpreted extension field reserved in PTO |
| CROSS-BID | uninterpreted extension field reserved in PTO |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/XB.asl -->
```asl
readonly func InstructionContractMatches_XB(operation: CommandOperation)
    => boolean
begin
    return operation == CommandOperation_xb_32_40ad190a0a7f;
end;

pure func InstructionContractSupported_XB() => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
none; XB is not an executable PTO block command
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/XB.asl -->
```asl
readonly func InstructionContractHandler_XB() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteCrossBlockTransfer;
end;

pure func InstructionContractRejectsBeforeEffects_XB() => boolean
begin
    return !CommandHandlerSupportedPTOv0(
        CommandHandler_ExecuteCrossBlockTransfer);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No PTO default exists because the complete form is reserved and rejected before ACR-ID or CROSS-BID interpretation.

## Legality

- The full family selected by mask 0x00007fff and match 0x00006f81 is occupied extension space and is not executable in PTO.
- All 1024 ACR-ID values and all 128 CROSS-BID values remain collision-protected; PTO must not allocate another instruction anywhere in this raw family.
- Decode retains the form identity only for collision inventory and fail-closed dispatch. CommandHandlerSupportedPTOv0 returns false for ExecuteCrossBlockTransfer.

## State effects

- none; the form always raises Fault_IllegalInstruction before effects in PTO

## Memory effects and ordering

### Memory effects

- none; rejection precedes every memory access

### Ordering

- Decode and profile rejection precede operand interpretation and every architectural effect.

## Exceptions

- Every matching 32-bit form raises Fault_IllegalInstruction at the current TPC before ACR-ID or CROSS-BID is interpreted and before command, block, memory, or control-flow state changes.

## Examples

- XB ACR-ID, C-ID (reserved in PTO)
