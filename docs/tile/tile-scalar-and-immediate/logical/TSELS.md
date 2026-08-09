<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/logical/TSELS.asl -->
# TSELS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/logical/TSELS.asl`

Select each destination element from the Tile source or scalar alternative under the mask Tile.

## Normative identity {#PTO-INST-TILE-TSELS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TSELS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TSELS | TEPL | 0x03A | 26 | 1 | ExecuteTileSelectScalar |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | mask |
| source1 | source-true |
| scalar0 | scalar-false |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/logical/TSELS.asl -->
```asl
readonly func InstructionContractOperation_TSELS() => TileOperation
begin
    return TileOperation_TSELS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TSELS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/logical/TSELS.asl -->
```asl
readonly func InstructionContractHandler_TSELS() => TileSemanticHandler
begin
    return TileHandler_ExecuteTileSelectScalar;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_ExecuteTileSelectScalar`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `ExecuteTileSelectScalar`
- **Effect contract:** `ExecuteTileSelectScalar`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:mask", "operand:source1:source-true", "operand:scalar0:scalar-false"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
