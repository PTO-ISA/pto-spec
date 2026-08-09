<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TSEL.asl -->
# TSEL

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TSEL.asl`

Select each destination element from the true or false source under the mask Tile.

## Normative identity {#PTO-INST-TILE-TSEL}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TSEL <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSEL | TEPL | 0x01A | 26 | 0 | ExecuteTileSelect |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | mask |
| source1 | source-true |
| source2 | source-false |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TSEL.asl -->
```asl
readonly func InstructionContractOperation_TSEL() => TileOperation
begin
    return TileOperation_TSEL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSEL, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TSEL.asl -->
```asl
readonly func InstructionContractHandler_TSEL() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelect;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_ExecuteTileSelect`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `ExecuteTileSelect`
- **Effect contract:** `ExecuteTileSelect`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:mask", "operand:source1:source-true", "operand:source2:source-false"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
