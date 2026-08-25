<!-- GENERATED FROM: asl/block/encoding/C.BSTART.SYS.asl -->
# C.BSTART.SYS

**Normative ASL source:** `asl/block/encoding/C.BSTART.SYS.asl`

Starts the fixed compressed sequential System block without a selecting branch continuation.

## Normative identity {#PTO-INST-BLOCK-C-BSTART-SYS}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-c-bstart-sys-purpose role=purpose -->
## What C.BSTART.SYS does

`C.BSTART.SYS` opens an active Block descriptor; the body supplies the attributes and bindings required before completion.

<!-- PTO-READER-BLOCK: block-c-bstart-sys-mechanism role=mechanism -->
## Placement and execution mechanism

`C.BSTART.SYS` must appear as the starter of its Block. Later attributes, dimensions, and bindings accumulate in the active descriptor until `BSTOP` or the next accepted `BSTART` completion boundary.

The accepted carrier uses the `C16` encoding class and resolves every displayed field before the command reads bindings or changes state.

At completion, the descriptor runs its selected Block operation only after all schema and state preflight succeeds.

<!-- PTO-READER-BLOCK: block-c-bstart-sys-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- The instruction has no encoded operand field.
- After an active predecessor commits successfully, this carrier opens one sequential System Block whose header runs until `BSTOP` or the next `BSTART`.
- Encoded zero remains an assigned value or a specifically documented rejection; it never silently means an omitted operand.

<!-- PTO-READER-BLOCK: block-c-bstart-sys-effects role=effects -->
## State effects and ordering

Starting the Block records the selected carrier and leaves operation execution deferred until the completion boundary.

After complete preflight and computation, every enabled output publishes as the owner-defined atomic group; successful mathematical sources remain available unless the contract explicitly consumes them.

<!-- PTO-READER-BLOCK: block-c-bstart-sys-constraints role=constraints -->
## Legality, faults, and atomicity

Fixed bits, reserved values, selector domains, and required Block placement are checked before architectural effects.

The current owner reports invalid schema, state, address, or continuation conditions through the owner-defined fault; no prose on this page creates an additional fault rule.

Complete schema, binding, readiness, alias, capacity, and allocation preflight precedes source snapshots and every destination publication.

<!-- PTO-READER-BLOCK: block-c-bstart-sys-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
C.BSTART.SYS FALL
```

The starter establishes the descriptor first; the following carriers fill its declared schema, and the final completion boundary triggers validation and operation execution.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
C.BSTART.SYS FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_sys_16_ec213ce96eb7 | C16 | 16 | 0x0840 / 0xffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.SYS.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_SYS(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_sys_16_ec213ce96eb7);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
After any active predecessor block commits successfully, C.BSTART.SYS opens one System block. Its header commands execute sequentially until BSTOP or the next BSTART.
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.SYS.asl -->
```asl
pure func InstructionContractKind_C_BSTART_SYS() => BundleKind
begin
    return BundleKind_System;
end;

readonly func InstructionContractHandler_C_BSTART_SYS() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The instruction has no operand field. FALL and zero displacement are fixed by its complete 16-bit encoding.

## Legality

- The complete 16-bit pattern 0x0840 is the only accepted C.BSTART.SYS encoding.
- System blocks have only sequential fallthrough and expose no BPCN, TYPE, or TAKEN continuation.

## State effects

- Installs BARG.BPC=P and BlockType=SYS, advances header execution to P+2, and keeps BPCN zero with canonical non-selecting fallthrough state.
- BSTOP or the next BSTART commits to the sequential continuation.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- The predecessor block commits before the new System BARG is installed. C.BSTART.SYS itself performs no memory access.

## Exceptions

- Any different bit pattern belongs to another instruction or is illegal; it is not a C.BSTART.SYS operand variation.
- If predecessor commit fails, the retiring block remains authoritative and no System BARG is installed.

## Examples

- C.BSTART.SYS FALL
