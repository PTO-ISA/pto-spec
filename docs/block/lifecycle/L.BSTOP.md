<!-- GENERATED FROM: asl/block/lifecycle/L.BSTOP.asl -->
# L.BSTOP

**Normative ASL source:** `asl/block/lifecycle/L.BSTOP.asl`

Commits the current bundle and transfers to its selected continuation.

## Normative identity {#PTO-INST-BLOCK-L-BSTOP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
