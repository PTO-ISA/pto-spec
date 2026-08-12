<!-- GENERATED FROM: asl/block/execution/BSTART.TMOV.asl -->
# BSTART.TMOV

**Normative ASL source:** `asl/block/execution/BSTART.TMOV.asl`

Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.

## Normative identity {#PTO-INST-BLOCK-BSTART-TMOV}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
BSTART.TMOV DataType
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tmov_32_211446509efb | L32 | 32 | 0x00211181 / 0x07ffffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28,31]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tmov_32_211446509efb | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.TMOV.asl -->
```asl
readonly func InstructionContractMatches_BSTART_TMOV(operation: CommandOperation) => boolean
begin
    return (operation == CommandOperation_bstart_tmov_32_211446509efb);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.TMOV.asl -->
```asl
// BSTART.TMOV accepts DTYPE_NONE (encoded 31). When neither B.DATR nor BSTART
// contributes a concrete type, Local/Shared TMOV inherits the bound source
// descriptor type. DTYPE_NONE is never installed in a tile descriptor.
readonly func InstructionContractHandler_BSTART_TMOV() => CommandSemanticHandler
begin
    return CommandHandler_ExecuteBundleStart;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Constraints:** `[{"field": "DataType", "operator": "one-of", "values": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 24, 25, 26, 27, 28, 31]}]`

## Operational information

- **Semantic summary:** `Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.`
- **Semantic handler:** `ExecuteBundleStart`

<!-- SUPPLEMENTARY-BEGIN -->
`BSTART.TMOV` accepts DataType code 31, canonically spelled `DTYPE_NONE`. When
neither B.DATR nor BSTART supplies a concrete type, TMOV inherits the bound
Local or Shared source descriptor type. The sentinel itself is never installed
in a tile descriptor and never supplies an element width or numeric default.
<!-- SUPPLEMENTARY-END -->
