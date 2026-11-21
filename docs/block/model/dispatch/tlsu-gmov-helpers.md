<!-- GENERATED FROM: asl/block/model/dispatch/tlsu-gmov-helpers.asl -->
# TLSU Gmov Helpers

**Normative ASL source:** `asl/block/model/dispatch/tlsu-gmov-helpers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV-HELPERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-helpers-purpose role=purpose-scope -->
## Purpose and scope

This unit supplies descriptor checks used while GMOV transfers Tile values between PEs. The checks keep a destination from accepting a source whose visible shape or CUBE metadata differs.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-helpers-concepts role=concepts-state -->
## Source and destination views

A CUBE source must have a legal CUBE descriptor and defined contents. Other layouts use the general Tile descriptor check. Destination matching compares allocation, numeric storage, shape, valid region, data type, and layout.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-helpers-rules role=rules-interactions -->
## Match rules

Two source descriptors match only when capacity, physical and valid shape, data type, layout, storage kind, CUBE repeats, cell count, and CUBE storage bytes all agree.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-helpers-boundaries role=boundaries -->
## Boundaries

These helpers compare descriptor state. They do not select the source PE, reserve a destination, transfer payload bytes, or establish source completion.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-helpers-example role=example-usage -->
## Example

Two CUBE_M32 sources with equal rows and columns still fail the exact-source match if their CUBE cell counts differ.

<!-- PTO-READER-BLOCK: block-model-dispatch-tlsu-gmov-helpers-related role=related-owners-navigation -->
## Related owners

- [GMOV dispatch](tlsu-gmov.md) selects PE sources and destinations.
- [Descriptor legality](descriptor-legality.md) owns general Tile descriptor checks.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/tlsu-gmov-helpers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV-HELPERS","surface":"block","classification":["model","dispatch","tlsu-gmov-helpers"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DESCRIPTOR-SHAPE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-LEGALITY-MATRIX-INFO-DESCRIPTOR","PTO-TILE-MODEL-STATE-TYPES"]}
readonly func BundleGMOVPESourceTileReady(tile: TileInfo) => boolean
begin
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile) && tile.contents_defined;
    end;
    return TileInfoDescriptorLegal(tile);
end;

readonly func BundleGMOVDestinationValueMatches(
    destination: TileInfo, source: TileInfo) => boolean
begin
    return destination.allocated &&
           destination.storage_kind == TileStorage_Numeric &&
           TileCubeDescriptorLegal(destination) &&
           TileElementwiseLayoutSupported(destination.layout) &&
           TileCarrierOrPackedBaselineDataTypeSupported(source.data_type) &&
           destination.rows == source.rows &&
           destination.columns == source.columns &&
           destination.valid_rows == source.valid_rows &&
           destination.valid_columns == source.valid_columns &&
           destination.data_type == source.data_type &&
           destination.layout == source.layout;
end;

readonly func BundleGMOVSourceDescriptorsMatch(left: TileInfo,
                                                right: TileInfo) => boolean
begin
    return left.capacity_bytes == right.capacity_bytes &&
           left.rows == right.rows && left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.data_type == right.data_type &&
           left.layout == right.layout &&
           left.storage_kind == right.storage_kind &&
           left.cube_k_repeat == right.cube_k_repeat &&
           left.cube_n_repeat == right.cube_n_repeat &&
           left.cube_cell_count == right.cube_cell_count &&
           left.cube_storage_bytes == right.cube_storage_bytes;
end;
```
<!-- GENERATED-ASL-END: unit -->
