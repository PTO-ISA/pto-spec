<!-- GENERATED FROM: asl/block/lifecycle/BSTOP.asl -->
# BSTOP

**Normative ASL source:** `asl/block/lifecycle/BSTOP.asl`

Commits the current bundle and transfers to its selected continuation.

## Normative identity {#PTO-INST-BLOCK-BSTOP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTOP
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstop_32_d25b09fdd59c | L32 | 32 | 0x00000001 / 0xffffffff | [] |

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/BSTOP.asl -->
```asl
readonly func InstructionContractMatches_BSTOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstop_32_d25b09fdd59c);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/BSTOP.asl -->
```asl
readonly func InstructionContractHandler_BSTOP() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStop;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `Commits the current bundle and transfers to its selected continuation.`
- **Semantic handler:** `ExecuteBundleStop`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
