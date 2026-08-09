<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/logical/TCMP.asl -->
# TCMP

**Normative ASL source:** `asl/tile/elementwise-tile-tile/logical/TCMP.asl`

Apply elementwise comparison to the two source Tiles.

## Normative identity {#PTO-INST-TILE-TCMP}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `VEC`

## Assembly

```asm
TCMP <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TCMP | TEPL | 0x00D | 13 | 0 | ExecuteTileCompare |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source-left |
| source1 | source-right |
| comparison | comparison |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/logical/TCMP.asl -->
```asl
readonly func InstructionContractOperation_TCMP() => TileOperation
begin
    return TileOperation_TCMP;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TCMP, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/logical/TCMP.asl -->
```asl
readonly func InstructionContractHandler_TCMP() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileCompare;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_ExecuteTileCompare`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": ["CMode"], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `ExecuteTileCompare`
- **Effect contract:** `ExecuteTileCompare`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source-left", "operand:source1:source-right", "operand:comparison:comparison"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
