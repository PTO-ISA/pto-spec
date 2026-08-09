<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_ACC.asl -->
# TGEMV_ACC

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_ACC.asl`

Multiply the matrix by the vector and accumulate into the supplied Tile.

## Normative identity {#PTO-INST-TILE-TGEMV-ACC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TGEMV_ACC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGEMV_ACC | CUBE |  | 18 |  | TGEMV_ACC |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | accumulator |
| source1 | matrix |
| source2 | vector |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_ACC.asl -->
```asl
readonly func InstructionContractOperation_TGEMV_ACC() => TileOperation
begin
    return TileOperation_TGEMV_ACC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.CUBE TGEMV.ACC AType
B.DATR BType RMode Sat
B.FPATR
B.DIM LB0 N
B.DIM LB1 M
B.DIM LB2 Col
B.IOT Local sources and Local outputs
B.IOR scalar PostProcess parameter (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_ACC.asl -->
```asl
readonly func InstructionContractMatrixShapeLegal_TGEMV_ACC_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV_ACC() => TileSemanticHandler
begin
    return TileHandler_TGEMV_ACC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TGEMV_ACC`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TGEMV_ACC`
- **Effect contract:** `TGEMV_ACC`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:accumulator", "operand:source1:matrix", "operand:source2:vector"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
