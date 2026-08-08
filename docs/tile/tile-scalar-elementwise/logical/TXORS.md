<!-- GENERATED FROM: asl/tile/tile-scalar-elementwise/logical/TXORS.asl -->
# TXORS

**Normative ASL source:** `asl/tile/tile-scalar-elementwise/logical/TXORS.asl`

Apply elementwise bitwise XOR between the source Tile and bound scalar.

## Normative identity {#PTO-INST-TILE-TXORS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TXORS <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TXORS | TEPL | 0x028 | 8 | 1 | ExecuteTileScalar |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| scalar0 | scalar |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-elementwise/logical/TXORS.asl -->
```asl
readonly func InstructionContractOperation_TXORS() => TileOperation
begin
    return TileOperation_TXORS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TEPL TXORS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-elementwise/logical/TXORS.asl -->
```asl
readonly func InstructionContractHandler_TXORS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileScalar;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_ExecuteTileScalar`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `ExecuteTileScalar`
- **Effect contract:** `ExecuteTileScalar`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:source", "operand:scalar0:scalar"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
