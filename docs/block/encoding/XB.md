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

`XB` names a 32-bit encoding family that belongs to an extension, not to PTO. The spelling `XB ACR-ID, C-ID` is listed so that the family is inventoried and protected from collisions. In PTO it is not executable: a matching instruction raises `Fault_IllegalInstruction`, unless an earlier block-control check described below rejects it first.

<!-- PTO-READER-BLOCK: block-xb-mechanism role=mechanism -->
## Decode and rejection mechanism

The family is every 32-bit word whose low 15 bits match `0x6f81` under mask `0x00007fff`. Bits 24:15 hold a 10-bit field `ACR-ID`, and bits 31:25 hold a 7-bit field `CROSS-BID`. The assembly spelling writes the second field as `C-ID`.

Decode still recognizes the form and maps it to the handler `ExecuteCrossBlockTransfer`. The command dispatcher then asks `CommandHandlerSupported`, which returns false for this handler. The dispatcher raises `Fault_IllegalInstruction` at the current `TPC` and returns before the handler case is reached.

Design point: the form keeps a decode identity even though PTO never executes it. The ASL states that the identity is retained only for collision inventory and fail-closed dispatch. A tool that checks encoding overlaps therefore sees the family as occupied, and any matching word reaches the explicit `CommandHandlerSupported` rejection.

<!-- PTO-READER-BLOCK: block-xb-inputs role=inputs-outputs -->
## Fields and operands

- `ACR-ID` is 10 bits wide. PTO does not interpret it, including encoded zero.
- `CROSS-BID` is 7 bits wide. PTO does not interpret it, including encoded zero.
- `XB` has no PTO default and no placement rule. It is not a header command, and its rejection does not depend on whether a block is active.

Design point: all 1024 `ACR-ID` values and all 128 `CROSS-BID` values stay reserved. PTO must not allocate another instruction anywhere in this raw family, so a later extension can define the fields without colliding with PTO.

<!-- PTO-READER-BLOCK: block-xb-effects role=effects -->
## State effects and ordering

In PTO the form has no state effect. The rejection precedes operand interpretation, memory access, block state changes, and control-flow changes.

The handler body that the dispatcher would call records the two fields and marks the `BARG` transfer as indirect. That body is unreachable in PTO, because `CommandHandlerSupported` rejects `ExecuteCrossBlockTransfer` first.

<!-- PTO-READER-BLOCK: block-xb-constraints role=constraints -->
## Legality, faults, and atomicity

Every matching 32-bit word raises `Fault_IllegalInstruction` with the current `TPC`. `TPC` does not advance. One earlier top-level check can take precedence: while an `ACRC` request has left the system-block terminal marker set, the top-level dispatcher rejects every command other than a block start or stop with `Fault_BundleControl`, and that check runs before the handler-support check.

The fault comes before `ACR-ID` or `CROSS-BID` is read. No field value can change the outcome, so there is no field-specific fault.

<!-- PTO-READER-BLOCK: block-xb-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
XB ACR-ID, C-ID (reserved in PTO)
```

The word `0x00006f81` has both fields zero and matches the family. The word `0x0202ef81` has `ACR-ID = 5` and `CROSS-BID = 1` and also matches. Both raise `Fault_IllegalInstruction` at their own address, and neither changes any block, memory, or control-flow state.
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
    return !CommandHandlerSupported(
        CommandHandler_ExecuteCrossBlockTransfer);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- No PTO default exists because the complete form is reserved and rejected before ACR-ID or CROSS-BID interpretation.

## Legality

- The full family selected by mask 0x00007fff and match 0x00006f81 is occupied extension space and is not executable in PTO.
- All 1024 ACR-ID values and all 128 CROSS-BID values remain collision-protected; PTO must not allocate another instruction anywhere in this raw family.
- Decode retains the form identity only for collision inventory and fail-closed dispatch. CommandHandlerSupported returns false for ExecuteCrossBlockTransfer.

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
