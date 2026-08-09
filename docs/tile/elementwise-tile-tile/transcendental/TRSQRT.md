<!-- GENERATED FROM: asl/tile/elementwise-tile-tile/transcendental/TRSQRT.asl -->
# TRSQRT

**Normative ASL source:** `asl/tile/elementwise-tile-tile/transcendental/TRSQRT.asl`

Apply elementwise reciprocal square root to the source Tile.

## Normative identity {#PTO-INST-TILE-TRSQRT}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `elementwise-tile-tile`
- **Execution engine:** `SFU`

## Assembly

```asm
TRSQRT <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TRSQRT | TEPL | 0x016 | 22 | 0 | ExecuteTileUnary |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/elementwise-tile-tile/transcendental/TRSQRT.asl -->
```asl
readonly func InstructionContractOperation_TRSQRT() => TileOperation
begin
    return TileOperation_TRSQRT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.SFU TRSQRT, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/elementwise-tile-tile/transcendental/TRSQRT.asl -->
```asl
readonly func InstructionContractHandler_TRSQRT() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileUnary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_ExecuteTileUnary`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `ExecuteTileUnary`
- **Effect contract:** `ExecuteTileUnary`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
