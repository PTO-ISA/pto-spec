<!-- GENERATED FROM: asl/block/encoding/C.BSTART.MPAR.asl -->
# C.BSTART.MPAR

**Normative ASL source:** `asl/block/encoding/C.BSTART.MPAR.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-C-BSTART-MPAR}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
C.BSTART.MPAR FALL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_bstart_mpar_16_66c3ef2226ec | C16 | 16 | 0x08c0 / 0xffff | [] |

## Operands and results

This instruction has no explicit operand fields.

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/encoding/C.BSTART.MPAR.asl -->
```asl
readonly func InstructionContractMatches_C_BSTART_MPAR(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_c_bstart_mpar_16_66c3ef2226ec);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/encoding/C.BSTART.MPAR.asl -->
```asl
readonly func InstructionContractHandler_C_BSTART_MPAR() => CommandSemanticHandler
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
