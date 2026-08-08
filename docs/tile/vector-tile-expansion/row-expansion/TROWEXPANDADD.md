<!-- GENERATED FROM: asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDADD.asl -->
# TROWEXPANDADD

**Normative ASL source:** `asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDADD.asl`

Apply addition while expanding the bound row vector across the source Tile.

## Normative identity {#PTO-INST-TILE-TROWEXPANDADD}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TROWEXPANDADD <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TROWEXPANDADD | TEPL | 0x045 | 5 | 2 | ExecuteTileExpand |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| source1 | broadcast-source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDADD.asl -->
```asl
readonly func InstructionContractOperation_TROWEXPANDADD() => TileOperation
begin
    return TileOperation_TROWEXPANDADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TEPL TROWEXPANDADD, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/vector-tile-expansion/row-expansion/TROWEXPANDADD.asl -->
```asl
readonly func InstructionContractHandler_TROWEXPANDADD() => TileSemanticHandler
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
