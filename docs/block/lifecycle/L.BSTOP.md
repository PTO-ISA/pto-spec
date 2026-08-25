<!-- GENERATED FROM: asl/block/lifecycle/L.BSTOP.asl -->
# L.BSTOP

**Normative ASL source:** `asl/block/lifecycle/L.BSTOP.asl`

Commits the current bundle and transfers to its selected continuation.

## Normative identity {#PTO-INST-BLOCK-L-BSTOP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-l-bstop-purpose role=purpose -->
## What L.BSTOP does

`L.BSTOP` is a Block completion boundary that validates and commits the active descriptor before selecting the next architectural PC.

<!-- PTO-READER-BLOCK: block-l-bstop-mechanism role=mechanism -->
## Placement and execution mechanism

`L.BSTOP` is not a body attribute: it consumes the already active Block and is illegal when no compatible Block is active.

The accepted carrier uses the `L64` encoding class and resolves every displayed field before the command reads bindings or changes state.

The command snapshots every required source before its first visible effect, then follows the owner-defined commit or restart boundary.

<!-- PTO-READER-BLOCK: block-l-bstop-inputs role=inputs-outputs -->
## Carrier, bindings, and inputs

- The instruction has no encoded operand field.
- All operands are resolved from the accepted carrier or named architectural state; no body-local hidden operand stream is created.
- Encoded zero remains an assigned value or a specifically documented rejection; it never silently means an omitted operand.

<!-- PTO-READER-BLOCK: block-l-bstop-effects role=effects -->
## State effects and ordering

Completion executes the selected active operation before clearing Block-private descriptor, binding, attribute, and active-state fields.

The validated continuation is published only after the Block commit; a rejected completion preserves the state required by the fault contract.

<!-- PTO-READER-BLOCK: block-l-bstop-constraints role=constraints -->
## Legality, faults, and atomicity

Fixed bits, reserved values, selector domains, and required Block placement are checked before architectural effects.

The current owner reports invalid schema, state, address, or continuation conditions through `Fault_BundleControl`; no prose on this page creates an additional fault rule.

Rejection occurs before effects unless the current owner explicitly defines a restart boundary with retained progress; completion order remains the ASL order.

<!-- PTO-READER-BLOCK: block-l-bstop-example role=example -->
## Non-normative worked example

This example demonstrates placement and carrier flow only; exact behavior remains in the current ASL and instruction contract.

```asm
L.BSTOP
```

Here the completion instruction acts on an already active compatible Block; without that active state the same encoding faults before commit.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
L.BSTOP
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| l_bstop_64_94c7f0a5e8b3 | L64 | 32 | 0x0000000f / 0xffffffff | [] |
| l_bstop_64_94c7f0a5e8b3 | L64 | 32 | 0x00000001 / 0xffffffff | [] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/L.BSTOP.asl -->
```asl
readonly func InstructionContractMatches_L_BSTOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_l_bstop_64_94c7f0a5e8b3);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/L.BSTOP.asl -->
```asl
readonly func InstructionContractHandler_L_BSTOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStop;
end;

pure func InstructionContractCommitsActiveBundle_L_BSTOP()
    => boolean
begin
    return TRUE;
end;

pure func InstructionContractClearsHeaderState_L_BSTOP()
    => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- The instruction has no encoded operand field and therefore no operand default.

## Legality

- The low 32-bit word is exactly 0x0000000f and the high 32-bit word is exactly 0x00000001.

## State effects

- Commits the active block, selects BARG.BPCN for DIRECT/CALL/IND/ICALL/RET or taken COND, otherwise selects the sequential PC.
- After successful commit, clears BARG, BPC, descriptor fields, dimensions, operand bindings, attributes, and active/body state.

## Memory effects and ordering

### Memory effects

- Commits every architecture-visible memory effect of the active block before selecting its continuation.

### Ordering

- Validate the active block and final BARG continuation, execute the selected block operation, then select BARG.BPCN or the sequential PC and clear block-private state.

## Exceptions

- No active block raises Fault_BundleControl.
- Schema, applicability, execution, or final-PC faults reject before block-private state is cleared.

## Examples

- L.BSTOP
