<!-- GENERATED FROM: asl/tile/model/legality/memory-schema.asl -->
# Memory Schema

**Normative ASL source:** `asl/tile/model/legality/memory-schema.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/memory-schema.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA","surface":"tile","classification":["model","legality","memory-schema"],"depends_on":["PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT"]}
readonly func TileOperandsLegal_TMOV(destination: TileIndex,
                                     source: TileIndex) => boolean
begin
    return TileShapeAndTypeMatch(destination, source);
end;

readonly func TileOperandsLegal_TLOAD(destination: TileIndex,
                                      base_address: Word,
                                      row_stride_elements: Word) => boolean
begin
    return TileDescriptorLegal(destination);
end;

readonly func TileOperandsLegal_TSTORE(base_address: Word,
                                       row_stride_elements: Word,
                                       source: TileIndex) => boolean
begin
    return TileDescriptorLegal(source);
end;

readonly func TileOperandsLegal_MGATHER(
    destination: TileIndex, base_address: Word,
    indices: TileIndex) => boolean
begin
    return TileLogicalShapeMatch(destination, indices);
end;

readonly func TileOperandsLegal_MSCATTER(
    base_address: Word, source: TileIndex, indices: TileIndex) => boolean
begin
    return TileLogicalShapeMatch(source, indices);
end;

readonly func TileOperandsLegal_MGATHER_MASK(
    destination: TileIndex, base_address: Word,
    indices: TileIndex, mask: TileIndex, pad_value: TilePadValue) => boolean
begin
    return TileLogicalShapeMatch(destination, indices) &&
           TileLogicalShapeMatch(destination, mask);
end;

readonly func TileOperandsLegal_MSCATTER_MASK(
    base_address: Word, source: TileIndex, indices: TileIndex,
    mask: TileIndex) => boolean
begin
    return TileLogicalShapeMatch(source, indices) &&
           TileLogicalShapeMatch(source, mask);
end;

readonly func TileOperandsLegal_MGATHER_CAS(
    destination: TileIndex, base_address: Word, indices: TileIndex,
    expected: TileIndex, replacement: TileIndex) => boolean
begin
    return TileLogicalShapeMatch(destination, indices) &&
           TileShapeAndTypeMatch(destination, expected) &&
           TileShapeAndTypeMatch(destination, replacement);
end;

readonly func TileOperandsLegal_TPREFETCH(
    base_address: Word, byte_count: integer {0..262144}) => boolean
begin
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
