<!-- GENERATED FROM: asl/tile/tile-scalar-and-immediate/arithmetic/TMAXS.asl -->
# TMAXS

**Normative ASL source:** `asl/tile/tile-scalar-and-immediate/arithmetic/TMAXS.asl`

Apply elementwise maximum selection between the source Tile and bound scalar.

## Normative identity {#PTO-INST-TILE-TMAXS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `tile-scalar-and-immediate`
- **Execution engine:** `VEC`

## Assembly

```asm
TMAXS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMAXS | TEPL | 0x02B | 11 | 1 | ExecuteTileScalar |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | source |
| scalar0 | scalar |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/tile-scalar-and-immediate/arithmetic/TMAXS.asl -->
```asl
readonly func InstructionContractOperation_TMAXS() => TileOperation
begin
    return TileOperation_TMAXS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.VEC TMAXS, DataType
B.DATR (optional)
B.DIM LB0
B.DIM (LB1/LB2 for 2D)
B.IOT
B.IOR
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/tile-scalar-and-immediate/arithmetic/TMAXS.asl -->
```asl
readonly func InstructionContractHandler_TMAXS() => TileSemanticHandler
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
