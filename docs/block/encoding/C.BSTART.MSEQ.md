<!-- GENERATED FROM: asl/block/encoding/C.BSTART.MSEQ.asl -->
# C.BSTART.MSEQ

**Normative ASL source:** `asl/block/encoding/C.BSTART.MSEQ.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-C-BSTART-MSEQ}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
C.BSTART.MSEQ FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_mseq_16_b5597e0e41c2 | C16 | 16 | 0x48c0 / 0xffff | [] |

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.MSEQ.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_MSEQ(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_mseq_16_b5597e0e41c2);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.MSEQ.asl -->
```asl
readonly func InstructionContractHandler_C_BSTART_MSEQ() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.`
- **Semantic handler:** `ExecuteBundleStart`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
