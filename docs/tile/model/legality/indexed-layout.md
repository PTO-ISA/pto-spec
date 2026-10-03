<!-- GENERATED FROM: asl/tile/model/legality/indexed-layout.asl -->
# Indexed Layout

**Normative ASL source:** `asl/tile/model/legality/indexed-layout.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-indexed-layout-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the layout, type, and shape checks for indexed TLSU operations, and the operand checks for `TFMA` and `GMOV`. Indexed TLSU operations are the Tile load-store unit operations that read or write global memory at per-element addresses taken from an index Tile, such as MGATHER and MSCATTER.

- `IndexedTLSULayoutSupported`, `IndexedTLSUNumericDescriptorLegal`, and `IndexedTLSUNumericContentsDefined` check data Tile layout and descriptor.
- `IndexedTLSUMemoryIndexDataTypeLegal` and `IndexedTLSUOrdinaryTransferDataTypeLegal` check types.
- `IndexedTLSUDataShapeMatchesIndex` and `IndexedTLSUPhysicalShapeLegal` check shapes.
- `TileOperandsLegal_TFMA` and `TileOperandsLegal_GMOV` are full operand predicates.

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-layout-concepts role=concepts-state -->
## Concepts and visible state

All predicates are read-only and raise no fault themselves. The index Tile holds one address or offset per data element; the data Tile holds the values moved.

The supported indexed layouts are RowMajor, CUBE_M16, and CUBE_M32. A memory index Tile must be S32, U32, S64, or U64.

A packed four-bit type, such as E2M1X2 or U4X2, stores two logical elements per byte. For shape matching, one index element covers one packed pair.

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-layout-rules role=rules-interactions -->
## Rules and interactions

`IndexedTLSUNumericDescriptorLegal` requires numeric storage and a supported layout. A CUBE layout must pass `TileCubeDescriptorLegal`; RowMajor must pass `TileDescriptorLegal`.

`IndexedTLSUDataShapeMatchesIndex` requires equal valid rows. For a four-bit data type, the data valid columns must be even and equal to twice the index valid columns; otherwise the valid columns must be equal.

Design point: indexed addresses are byte displacements, and the block schema has no field to select the low or high nibble of a byte. A four-bit transfer therefore moves whole packed pairs, which is why one index covers two data columns and an odd data column count is rejected.

`IndexedTLSUOrdinaryTransferDataTypeLegal` returns TRUE for every data type: it is `IndexedTLSUTransferDataTypeLegal` (non-four-bit) or four-bit. The pair rule above is what constrains four-bit transfers.

`IndexedTLSUPhysicalShapeLegal` checks the bundle's layout and dimensions. For RowMajor, the physical column count must be a power of two and at least ValidCol. For a CUBE layout, the CUBE storage rows and required bytes must be nonzero and pass `TileCubeDescriptorShapeAndPhysicalLegal`.

`TileOperandsLegal_TFMA` requires the destination and three sources (left, right, addend) to share shape, layout, storage kind, and data type; the layout must be RowMajor, CUBE_M16, or CUBE_M32; and the sources must be defined and, for floating types, validly encoded at every valid coordinate (every active coordinate when an ExecutionMask is in force).

`TileOperandsLegal_TFMA` uses `TileFusedMultiplyAddDataTypeSupported` and accepts exactly `FP64`, `S64`, `U64`, `FP16`, `FP32`, and `BF16`. Fixed-width integer forms and the `FP64`, `FP32`, and `FP16` fused floating paths are executable. `ScalarFPFusedProfile` does not admit BF16, so the pre-existing accepted-BF16 finite-FMA gap remains. Other vector-arithmetic types do not enter TFMA execution.

`TileOperandsLegal_GMOV` requires `peer_tid` below 4, a defined source, matching shape, equal type and layout, a supported elementwise layout, and a data type in `TileCarrierOrPackedBaselineDataTypeSupported` (non-packed through 64 bits, or the existing packed baseline).

All of these run in preflight, before any memory request, snapshot, or destination write.

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-layout-boundaries role=boundaries -->
## Architectural boundaries

Callers include the memory schema legality predicates such as `TileOperandsLegal_MGATHER`, the TLSU dispatch units for MGATHER, MSCATTER, their MASK and CAS forms, and GM atomic reduction, and memory execution units such as gather-scatter, which assert some of these predicates. `TFMA` and the fused multiply-add execution call `TileOperandsLegal_TFMA`; GMOV dispatch calls `TileOperandsLegal_GMOV`.

A grep of `asl/` finds no caller of `IndexedTLSUNumericContentsDefined`.

This unit does not check index values against memory bounds, and it does not check B.DATR fields or PE_MASK.

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-layout-example role=example-usage -->
## Non-normative reading example

Consider an MGATHER into an E2M1X2 RowMajor data Tile with valid region 4 by 32, using an S32 index Tile with valid region 4 by 16.

- S32 is a legal memory index type.
- Valid rows are both 4.
- E2M1X2 is four-bit, so 32 must be even and equal to 2 x 16, which holds.
- With `B.DIM` Col 32, RowMajor needs 32 to be a power of two and at least 32, which holds.

An index Tile with valid region 4 by 32 would fail the shape match, because 32 is not 2 x 32.

<!-- PTO-READER-BLOCK: tile-model-legality-indexed-layout-related role=related-owners-navigation -->
## Related owners

- [Memory schema](memory-schema.md) builds the indexed TLSU operand predicates on these checks.
- [Gather and scatter](../memory/gather-scatter.md) executes the transfers.
- [Fused multiply-add](../execution/fused-multiply-add.md) executes `TFMA`.
- [TLSU MGATHER dispatch](../../../block/model/dispatch/tlsu-mgather.md) applies the physical shape check.
- [CUBE cell geometry](../shape/cube-cell.md) owns the CUBE shape checks.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/indexed-layout.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT","surface":"tile","classification":["model","legality","indexed-layout"],"depends_on":["PTO-TILE-MODEL-LEGALITY-OPERAND-SCHEMA"]}
pure func IndexedTLSULayoutSupported(layout: TileLayout) => boolean
begin
    return layout == TileLayout_RowMajor ||
           layout == TileLayout_CUBE_M16 ||
           layout == TileLayout_CUBE_M32;
end;

pure func IndexedTLSUMemoryIndexDataTypeLegal(
    data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_S64 ||
           data_type == TileDataType_U64;
end;

pure func IndexedTLSUOrdinaryTransferDataTypeLegal(
    data_type: TileDataType) => boolean
begin
    return IndexedTLSUTransferDataTypeLegal(data_type) ||
           TileDataTypeIsFourBit(data_type);
end;

readonly func IndexedTLSUNumericDescriptorLegal(index: TileIndex) => boolean
begin
    let tile = _Tiles[[index]];
    if !IndexedTLSULayoutSupported(tile.layout) ||
       tile.storage_kind != TileStorage_Numeric then
        return FALSE;
    end;
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile);
    end;
    return TileDescriptorLegal(index) && tile.layout == TileLayout_RowMajor;
end;

readonly func IndexedTLSUNumericContentsDefined(index: TileIndex) => boolean
begin
    return IndexedTLSUNumericDescriptorLegal(index) &&
           _Tiles[[index]].contents_defined;
end;

pure func IndexedTLSUDataShapeMatchesIndex(
    data_valid_rows: integer {0..65535},
    data_valid_columns: integer {0..65535},
    index_valid_rows: integer {0..65535},
    index_valid_columns: integer {0..65535},
    data_type: TileDataType) => boolean
begin
    if data_valid_rows != index_valid_rows then return FALSE; end;
    if TileDataTypeIsFourBit(data_type) then
        return data_valid_columns MOD 2 == 0 &&
               data_valid_columns == 2 * index_valid_columns;
    end;
    return data_valid_columns == index_valid_columns;
end;

readonly func IndexedTLSUPhysicalShapeLegal(
    layout: TileLayout, data_type: TileDataType,
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    columns: integer {1..65535}) => boolean
begin
    if !IndexedTLSULayoutSupported(layout) then return FALSE; end;
    if layout == TileLayout_RowMajor then
        return valid_columns <= columns && IsNonzeroPowerOfTwo(columns);
    end;
    let physical_rows = TileCubeStorageRows(layout, valid_rows, data_type);
    let required_bytes = TileCubePhysicalRequiredBytes(
        layout, physical_rows, columns, data_type);
    return physical_rows != 0 && required_bytes != 0 &&
           TileCubeDescriptorShapeAndPhysicalLegal(required_bytes,
               physical_rows, columns, valid_rows, valid_columns,
               data_type, layout);
end;

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
           TileElementwiseDescriptorLegal(destination) &&
           TileElementwiseSourceContentsDefined(source) &&
           TileElementwiseShapeMatch(destination, source) &&
           TileElementwiseLayoutSupported(_Tiles[[source]].layout) &&
           TileElementwiseLayoutSupported(_Tiles[[destination]].layout) &&
           TileCarrierOrPackedBaselineDataTypeSupported(
               _Tiles[[source]].data_type) &&
           _Tiles[[destination]].data_type == _Tiles[[source]].data_type &&
           _Tiles[[destination]].layout == _Tiles[[source]].layout;
end;
```
<!-- GENERATED-ASL-END: unit -->
