<!-- GENERATED FROM: asl/block/execution/BSTART.TGEMVMX.ACC.asl -->
# BSTART.TGEMVMX.ACC

**Normative ASL source:** `asl/block/execution/BSTART.TGEMVMX.ACC.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TGEMVMX-ACC}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART.TGEMVMX.ACC DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tgemvmx_acc_32_368647b04bb0 | L32 | 32 | 0x01631181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tgemvmx_acc_32_368647b04bb0 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TGEMVMX.ACC.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TGEMVMX_ACC(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tgemvmx_acc_32_368647b04bb0);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TGEMVMX.ACC.asl -->
```asl
readonly func InstructionContractHandler_BSTART_TGEMVMX_ACC() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
