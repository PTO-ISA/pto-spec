<!-- GENERATED FROM: asl/block/model/dispatch/binary-operation-classification.asl -->
# Binary Operation Classification

**Normative ASL source:** `asl/block/model/dispatch/binary-operation-classification.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-BINARY-OP-CLASSIFICATION}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/binary-operation-classification.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-BINARY-OP-CLASSIFICATION","surface":"block","classification":["model","dispatch","binary-operation-classification"],"depends_on":[]}
pure func TileOperationUsesClosedBinarySchema(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let decoded = TileOperationOfIndex(operation);
    return decoded == TileOperation_TADD ||
           decoded == TileOperation_TSUB ||
           decoded == TileOperation_TMUL ||
           decoded == TileOperation_TDIV ||
           decoded == TileOperation_TREM ||
           decoded == TileOperation_TMAX ||
           decoded == TileOperation_TMIN ||
           decoded == TileOperation_TEXPDIF;
end;
```
<!-- GENERATED-ASL-END: unit -->
