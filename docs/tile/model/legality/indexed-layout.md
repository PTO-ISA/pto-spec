<!-- GENERATED FROM: asl/tile/model/legality/indexed-layout.asl -->
# Indexed Layout

**Normative ASL source:** `asl/tile/model/legality/indexed-layout.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/indexed-layout.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","surface":"tile","classification":["model","legality","indexed-layout"],"depends_on":["PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}
readonly func TileOperandsLegal_TFMA(
    destination: TileIndex, source_left: TileIndex,
    source_right: TileIndex, addend: TileIndex) => boolean
begin
    return TileElementwiseDescriptorLegal(destination) &&
           TileElementwiseSourceContentsDefined(source_left) &&
           TileElementwiseSourceContentsDefined(source_right) &&
           TileElementwiseSourceContentsDefined(addend) &&
           TileFusedMultiplyAddDataTypeSupported(
               _Tiles[[destination]].data_type) &&
           TileElementwiseShapeAndTypeMatch(destination, source_left) &&
           TileElementwiseShapeAndTypeMatch(destination, source_right) &&
           TileElementwiseShapeAndTypeMatch(destination, addend) &&
           _Tiles[[destination]].data_type == _Tiles[[source_left]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[source_right]].data_type &&
           _Tiles[[destination]].data_type == _Tiles[[addend]].data_type &&
           TileElementwiseLayoutSupported(_Tiles[[destination]].layout) &&
           (!TileDataTypeIsFloating(_Tiles[[destination]].data_type) ||
            (TileElementwiseSourceEncodingsValid(source_left) &&
             TileElementwiseSourceEncodingsValid(source_right) &&
             TileElementwiseSourceEncodingsValid(addend)));
end;

readonly func TileOperandsLegal_GMOV(
    destination: TileIndex, source: TileIndex, peer_tid: Word) => boolean
begin
    return UInt(peer_tid) < 4 &&
           TileDescriptorLegal(destination) &&
           TileSourceContentsDefined(source) &&
           TileLogicalShapeMatch(destination, source) &&
           TileCarrierOrPackedBaselineDataTypeSupported(
               _Tiles[[source]].data_type) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[source]].layout &&
           _Tiles[[destination]].location != TileLocation_Memory &&
           _Tiles[[destination]].location != TileLocation_Matrix &&
           _Tiles[[source]].location != TileLocation_Memory &&
           _Tiles[[source]].location != TileLocation_Matrix;
end;
```
<!-- GENERATED-ASL-END: unit -->
