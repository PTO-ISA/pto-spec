<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_ACC.asl -->
# TMATMUL_ACC

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_ACC.asl`

Multiply matrices and accumulate into the supplied accumulator Tile.

## Normative identity {#PTO-INST-TILE-TMATMUL-ACC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TMATMUL_ACC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL_ACC | CUBE |  | 2 |  | TMATMUL_ACC |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | accumulator |
| source1 | left |
| source2 | right |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_ACC.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL_ACC() => TileOperation
begin
    return TileOperation_TMATMUL_ACC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.CUBE TMATMUL.ACC AType
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

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_ACC.asl -->
```asl
readonly func InstructionContractMatrixShapeLegal_TMATMUL_ACC_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL_ACC() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_ACC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TMATMUL_ACC`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TMATMUL_ACC`
- **Effect contract:** `TMATMUL_ACC`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:accumulator", "operand:source1:left", "operand:source2:right"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
