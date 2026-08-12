<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_ACC.asl -->
# TMATMUL_MX_ACC

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_ACC.asl`

Multiply scaled matrices and accumulate into the supplied accumulator Tile.

## Normative identity {#PTO-INST-TILE-TMATMUL-MX-ACC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TMATMUL_MX_ACC <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TMATMUL_MX_ACC | CUBE |  | 6 |  | TMATMUL_MX_ACC |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | accumulator |
| source1 | left |
| source2 | row-scale |
| source3 | right |
| source4 | column-scale |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_ACC.asl -->
```asl
readonly func InstructionContractOperation_TMATMUL_MX_ACC() => TileOperation
begin
    return TileOperation_TMATMUL_MX_ACC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.CUBE TMATMULMX.ACC AType
B.DATR BType RMode Sat
B.FPATR
B.DIM LB0 M
B.DIM LB1 N
B.DIM LB2 K
B.IOS Shared operand binder (optional)
B.IOT Local sources and Local outputs
B.IOR scalar PostProcess parameter (optional)
BSTOP
```

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-matrix/TMATMUL_MX_ACC.asl -->
```asl
// Complete-bundle dynamic schema linkage: this static mathematical operand owner participates in the
// conditional B.FPATR schema (scalar QuantParam/LReLUParam, ordered Local
// RowMax/parameter streams, and D/auxiliary destinations) owned by
// PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA and evidenced in
// spec/evidence/bundle-command-totality.json.
readonly func InstructionContractMatrixShapeLegal_TMATMUL_MX_ACC_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TMATMUL_MX_ACC() => TileSemanticHandler
begin
    return TileHandler_TMATMUL_MX_ACC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TMATMUL_MX_ACC`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TMATMUL_MX_ACC`
- **Effect contract:** `TMATMUL_MX_ACC`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:accumulator", "operand:source1:left", "operand:source2:row-scale", "operand:source3:right", "operand:source4:column-scale"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
