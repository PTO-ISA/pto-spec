<!-- GENERATED FROM: asl/block/execution/BSTART.SFU.asl -->
# BSTART.SFU

**Normative ASL source:** `asl/block/execution/BSTART.SFU.asl`

Canonical Block-start spelling for an operation assigned to the SFU execution engine.

## Normative identity {#PTO-INST-BLOCK-BSTART-SFU}

<!-- ndf: kind=executable level=L3 layer=block status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Alias contract

- **Encoding owner:** `BSTART.TEPL`
- **Canonical engine:** `SFU`

## Assembly

```asm
BSTART.SFU Mode, Function, DataType
```

## Encoding

This spelling reuses the exact encoding owned by `BSTART.TEPL`.

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | L32 | 32 | 0x00019181 / 0x000fffff | [{"field":"DataType","operator":"one-of","values":[0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,16,17,18,19,20,24,25,26,27,28]}] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bstart_tepl_32_d022db6dacb3 | DataType | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| bstart_tepl_32_d022db6dacb3 | Mode | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |
| bstart_tepl_32_d022db6dacb3 | Function | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| DataType | encoded operand or control |
| Mode | encoded operand or control |
| Function | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/block/execution/BSTART.SFU.asl -->
```asl
readonly func InstructionContractMatches_BSTART_SFU(
    operation: CommandOperation) => boolean
begin
    return InstructionContractMatches_BSTART_TEPL(operation);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/block/execution/BSTART.SFU.asl -->
```asl
readonly func InstructionContractHandler_BSTART_SFU() => CommandSemanticHandler
begin
    return InstructionContractHandler_BSTART_TEPL();
end;

pure func InstructionContractAliasEngine_BSTART_SFU() => TileExecutionEngine
begin
    return TileEngine_SFU;
end;

pure func InstructionContractAcceptsTileOperation_BSTART_SFU(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    return TileTEPLAliasAcceptsOperation(TileTEPLAlias_SFU, operation);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Constraints:** `[{"field": "DataType", "operator": "one-of", "values": [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 16, 17, 18, 19, 20, 24, 25, 26, 27, 28]}]`

## Operational information

- **Semantic summary:** `Closes the current bundle, initializes the next bundle descriptor, and selects its transfer and execution kind.`
- **Semantic handler:** `ExecuteBundleStart`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
