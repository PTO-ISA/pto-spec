<!-- GENERATED FROM: asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDADD.asl -->
# TCOLEXPANDADD

**Normative ASL source:** `asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDADD.asl`

Apply addition while expanding the bound col vector across the source Tile.

## Normative identity {#PTO-INST-TILE-TCOLEXPANDADD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `reduce-and-expand`
- **Execution engine:** `SFU`

## Assembly

```asm
TCOLEXPANDADD <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCOLEXPANDADD | TEPL | 0x055 | 21 | 2 | ExecuteTileExpand |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| source1 | broadcast-source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDADD.asl -->
```asl
readonly func InstructionContractOperation_TCOLEXPANDADD() => TileOperation
begin
    return TileOperation_TCOLEXPANDADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TCOLEXPANDADD, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/reduce-and-expand/column-expansion/TCOLEXPANDADD.asl -->
```asl
readonly func InstructionContractHandler_TCOLEXPANDADD() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileExpand;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_ExecuteTileExpand`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `ExecuteTileExpand`
- **Effect contract:** `ExecuteTileExpand`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source", "operand:source1:broadcast-source"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
