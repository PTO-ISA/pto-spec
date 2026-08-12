<!-- GENERATED FROM: asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_BIAS.asl -->
# TGEMV_BIAS

**Normative ASL source:** `asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_BIAS.asl`

Multiply the matrix by the vector and add the bias Tile.

## Normative identity {#PTO-INST-TILE-TGEMV-BIAS}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Classification and execution engine

- **Instruction class:** `matrix-and-matrix-vector`
- **Execution engine:** `CUBE`

## Assembly

```asm
TGEMV_BIAS <bundle operands>
```

## Encoding

| Operation | Encoding carrier | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGEMV_BIAS | CUBE |  | 17 |  | TGEMV_BIAS |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | matrix |
| source1 | vector |
| source2 | bias |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_BIAS.asl -->
```asl
readonly func InstructionContractOperation_TGEMV_BIAS() => TileOperation
begin
    return TileOperation_TGEMV_BIAS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.CUBE TGEMV.BIAS AType
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

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix-and-matrix-vector/matrix-vector/TGEMV_BIAS.asl -->
```asl
// Complete-bundle dynamic schema linkage: this static mathematical operand owner participates in the
// conditional B.FPATR schema (scalar QuantParam/LReLUParam, ordered Local
// RowMax/parameter streams, and D/auxiliary destinations) owned by
// PTO-BLOCK-MODEL-DISPATCH-TILE-SCHEMA and evidenced in
// spec/evidence/bundle-command-totality.json.
readonly func InstructionContractMatrixShapeLegal_TGEMV_BIAS_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV_BIAS() => TileSemanticHandler
begin
    return TileHandler_TGEMV_BIAS;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TGEMV_BIAS`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TGEMV_BIAS`
- **Effect contract:** `TGEMV_BIAS`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:matrix", "operand:source1:vector", "operand:source2:bias"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
