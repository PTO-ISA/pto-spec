<!-- GENERATED FROM: asl/block/lifecycle/C.BSTOP.asl -->
# C.BSTOP

**Normative ASL source:** `asl/block/lifecycle/C.BSTOP.asl`

Commits the current bundle and transfers to its selected continuation.

## Normative identity {#PTO-INST-BLOCK-C-BSTOP}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
C.BSTOP
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstop_16_ca4743d8a95e | C16 | 16 | 0x0000 / 0xffff | [] |

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/lifecycle/C.BSTOP.asl -->
```asl
readonly func InstructionContractMatches_C_BSTOP(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstop_16_ca4743d8a95e);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/lifecycle/C.BSTOP.asl -->
```asl
readonly func InstructionContractHandler_C_BSTOP() => CommandSemanticHandler
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
