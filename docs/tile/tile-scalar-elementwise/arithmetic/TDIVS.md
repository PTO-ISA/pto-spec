<!-- GENERATED FROM: asl/tile/tile-scalar-elementwise/arithmetic/TDIVS.asl -->
# TDIVS

**Normative ASL source:** `asl/tile/tile-scalar-elementwise/arithmetic/TDIVS.asl`

Apply elementwise division between the source Tile and bound scalar.

## Normative identity {#PTO-INST-TILE-TDIVS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TDIVS <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TDIVS | TEPL | 0x023 | 3 | 1 | ExecuteTileScalar |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| scalar0 | scalar |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-elementwise/arithmetic/TDIVS.asl -->
```asl
readonly func InstructionContractOperation_TDIVS() => TileOperation
begin
    return TileOperation_TDIVS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.TEPL TDIVS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-elementwise/arithmetic/TDIVS.asl -->
```asl
readonly func InstructionContractHandler_TDIVS() => TileSemanticHandler
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
