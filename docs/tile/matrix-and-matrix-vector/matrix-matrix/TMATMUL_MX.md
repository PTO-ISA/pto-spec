<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX.asl -->
# TMATMUL_MX

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX.asl`

Multiply matrices using row and column scale Tiles.

## Normative identity {#PTO-INST-TILE-TMATMUL-MX}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TMATMUL_MX <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL_MX | CUBE |  | 4 |  | TMATMUL_MX |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | left |
| source1 | row-scale |
| source2 | right |
| source3 | column-scale |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL_MX() => TileOperation
begin
    return TileOperation_TMATMUL_MX;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.CUBE TMATMULMX AType
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

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX.asl -->
```asl
// Complete-bundle dynamic schema linkage: this static mathematical operand owner participates in the
// conditional B.FPATR schema (scalar QuantParam/LReLUParam, ordered Local
// RowMax/parameter streams, and D/auxiliary destinations) owned by
// PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA and evidenced in
// spec/evidence/bundle-command-totality.json.
readonly func InstructionContractMatrixShapeLegal_TMATMUL_MX_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL_MX() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TMATMUL_MX`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TMATMUL_MX`
- **Effect contract:** `TMATMUL_MX`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:left", "operand:source1:row-scale", "operand:source2:right", "operand:source3:column-scale"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
