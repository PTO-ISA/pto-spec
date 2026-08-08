<!-- GENERATED FROM: asl/tile/matrix/matrix-vector/TGEMV_MX_ACC.asl -->
# TGEMV_MX_ACC

**Normative ASL source:** `asl/tile/matrix/matrix-vector/TGEMV_MX_ACC.asl`

Multiply the scaled matrix and vector and accumulate into the supplied Tile.

## Normative identity {#PTO-INST-TILE-TGEMV-MX-ACC}

<!-- ndf: kind=executable level=L3 layer=tile status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
TGEMV_MX_ACC <bundle operands>
```

## Encoding

| Operation | Family | Selector | Function | Mode | Handler |
| --- | --- | --- | ---: | ---: | --- |
| TGEMV_MX_ACC | CUBE |  | 22 |  | TGEMV_MX_ACC |

## Operands and results

| Field | Architectural role |
| --- | --- |
| destination0 | destination |
| source0 | accumulator |
| source1 | matrix |
| source2 | row-scale |
| source3 | vector |
| source4 | column-scale |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/tile/matrix/matrix-vector/TGEMV_MX_ACC.asl -->
```asl
readonly func InstructionContractOperation_TGEMV_MX_ACC() => TileOperation
begin
    return TileOperation_TGEMV_MX_ACC;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Block composition

```asm
BSTART.CUBE TGEMVMX.ACC AType
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

<!-- GENERATED-ASL-BEGIN: operation source=asl/tile/matrix/matrix-vector/TGEMV_MX_ACC.asl -->
```asl
readonly func InstructionContractMatrixShapeLegal_TGEMV_MX_ACC_(left: TileIndex, right: TileIndex) => boolean
begin
    return TileMatrixShapeLegal(left, right);
end;

readonly func InstructionContractHandler_TGEMV_MX_ACC() => TileSemanticHandler
begin
    return TileHandler_TGEMV_MX_ACC;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- **Legality handler:** `TileOperandsLegal_TGEMV_MX_ACC`
- **Fault contract:** `ExecuteTileInstruction`
- **Datr contract:** `{"allowed_nonzero_fields": [], "pad_union": "must-zero"}`

## Operational information

- **Semantic handler:** `TGEMV_MX_ACC`
- **Effect contract:** `TGEMV_MX_ACC`
- **Restart contract:** `CompleteBundleAtWithAcceptedApplicabilityRules`
- **State effects:** `["operand:destination0:destination", "operand:source0:accumulator", "operand:source1:matrix", "operand:source2:row-scale", "operand:source3:vector", "operand:source4:column-scale"]`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
