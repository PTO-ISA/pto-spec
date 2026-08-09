<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_BIAS.asl -->
# TMATMUL_BIAS

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_BIAS.asl`

Multiply matrices and add the bias Tile into the destination.

## Normative identity {#PTO-INST-TILE-TMATMUL-BIAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TMATMUL_BIAS <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL_BIAS | CUBE |  | 1 |  | TMATMUL_BIAS |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | left |
| source1 | right |
| source2 | bias |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_BIAS.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL_BIAS() => TileOperation
begin
    return TileOperation_TMATMUL_BIAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.CUBE TMATMUL.BIAS AType
B.DATR BType RMode Sat
B.FPATR
B.DIM LB0 N
B.DIM LB1 M
B.DIM LB2 Col
B.IOS Shared operand binder (optional)
B.IOT Local sources and Local outputs
B.IOR scalar PostProcess parameter (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_BIAS.asl -->
```asl
readonly func InstructionContractMatrixShapeLegal_TMATMUL_BIAS_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL_BIAS() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_BIAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TMATMUL_BIAS`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TMATMUL_BIAS`
- **Effect contract:** `TMATMUL_BIAS`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:left", "operand:source1:right", "operand:source2:bias"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
