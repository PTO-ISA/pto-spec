<!-- GENERATED FROM: asl/tile/unary-tile-elementwise/transcendental/TDIV.asl -->
# TDIV

**Normative ASL source:** `asl/tile/unary-tile-elementwise/transcendental/TDIV.asl`

Apply elementwise division to the two source Tiles.

## Normative identity {#PTO-INST-TILE-TDIV}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TDIV <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TDIV | TEPL | 0x003 | 3 | 0 | ExecuteTileBinary |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source-left |
| source1 | source-right |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/unary-tile-elementwise/transcendental/TDIV.asl -->
```asl
readonly func InstructionContractOperation_TDIV() => TileOperation
begin
    return TileOperation_TDIV;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TEPL TDIV, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/unary-tile-elementwise/transcendental/TDIV.asl -->
```asl
readonly func InstructionContractHandler_TDIV() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_ExecuteTileBinary`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `ExecuteTileBinary`
- **Effect contract:** `ExecuteTileBinary`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source-left", "operand:source1:source-right"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
