<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX.asl -->
# TGEMV_MX

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX.asl`

Multiply the matrix by the vector using row and column scale Tiles.

## Normative identity {#PTO-INST-TILE-TGEMV-MX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TGEMV_MX <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGEMV_MX | CUBE |  | 20 |  | TGEMV_MX |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | matrix |
| source1 | row-scale |
| source2 | vector |
| source3 | column-scale |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX.asl -->
```asl
readonly func InstructionContractOperation_TGEMV_MX() => TileOperation
begin
    return TileOperation_TGEMV_MX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.CUBE TGEMVMX AType
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

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_MX.asl -->
```asl
readonly func InstructionContractMatrixShapeLegal_TGEMV_MX_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV_MX() => TileSemanticHandler
begin
    return TileHandler_TGEMV_MX;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TGEMV_MX`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TGEMV_MX`
- **Effect contract:** `TGEMV_MX`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:matrix", "operand:source1:row-scale", "operand:source2:vector", "operand:source3:column-scale"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
