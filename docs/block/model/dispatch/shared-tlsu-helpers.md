<!-- GENERATED FROM: asl/block/model/dispatch/shared-tlsu-helpers.asl -->
# Shared TLSU Helpers

**Normative ASL source:** `asl/block/model/dispatch/shared-tlsu-helpers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU-HELPERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-dispatch-shared-tlsu-helpers-purpose role=purpose-scope -->
## Purpose and scope

This unit provides shape and carrier checks shared by Shared-store and Shared-to-Local TMOV dispatch. Centralizing them keeps both directions aligned with one resolved bundle schema.

<!-- PTO-READER-BLOCK: block-model-dispatch-shared-tlsu-helpers-concepts role=concepts-state -->
## Shared schema

Bundle dimensions supply valid columns, valid rows, and physical columns when each value fits 16 bits. TMOV also compares capacity, shape, data type, layout, and the resolved operation carrier.

<!-- PTO-READER-BLOCK: block-model-dispatch-shared-tlsu-helpers-rules role=rules-interactions -->
## Compatibility rules

E6M2 and RCPE6M2 require carrier-width compatibility with the Shared source interpretation. A Shared-to-Local destination needs exactly one Shared binding and one last Local destination with matching PE mask and schema.

<!-- PTO-READER-BLOCK: block-model-dispatch-shared-tlsu-helpers-boundaries role=boundaries -->
## Boundaries

A dimension greater than 65535 maps to zero and is rejected by later positive-shape checks. Empty participant masks are handled before any Shared record is read.

<!-- PTO-READER-BLOCK: block-model-dispatch-shared-tlsu-helpers-example role=example-usage -->
## Example

A Shared E6M2 source can populate a matching Local destination when capacity, valid region, physical columns, layout, PE mask, and carrier width all agree.

<!-- PTO-READER-BLOCK: block-model-dispatch-shared-tlsu-helpers-related role=related-owners-navigation -->
## Related owners

- [Shared generation](../operands/shared-generation.md) resolves Shared subviews and participant masks.
- [Destination shape](destination-shape.md) resolves the Local destination geometry.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/shared-tlsu-helpers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU-HELPERS","surface":"block","classification":["model","dispatch","shared-tlsu-helpers"],"depends_on":["PTO-ARCH-DATA-TYPES-INTEGER","PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION","PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
readonly func BundleSharedStoreValidColumns(shared_tile_id: SharedTileID)
    => integer {0..65535}
begin
    if UInt(_BundleDimensions[[0]]) <= 65535 then
        return UInt(_BundleDimensions[[0]]) as integer {0..65535};
    end;
    return 0;
end;

readonly func BundleSharedStoreValidRows(shared_tile_id: SharedTileID)
    => integer {0..65535}
begin
    if UInt(_BundleDimensions[[1]]) <= 65535 then
        return UInt(_BundleDimensions[[1]]) as integer {0..65535};
    end;
    return 0;
end;

readonly func BundleSharedStoreColumns(shared_tile_id: SharedTileID,
                                        valid_columns: integer {0..65535})
    => integer {0..65535}
begin
    if UInt(_BundleDimensions[[2]]) <= 65535 then
        return UInt(_BundleDimensions[[2]]) as integer {0..65535};
    end;
    return 0;
end;

readonly func BundleSharedTMOVNormalCarrierCompatible(
    source_type: TileDataType) => boolean
begin
    let (operation_type_valid, operation_type) =
        ResolveBundleEffectiveDataType();
    if !operation_type_valid then return FALSE; end;
    // The newly accepted typed NORM starts add E6M2 and its source-only
    // RCPE6M2 interpretation. Use the existing carrier relation in both
    // Shared directions without narrowing established NORM forms.
    if operation_type != TileDataType_E6M2 &&
       operation_type != TileDataType_RCPE6M2 then return TRUE; end;
    return TileCarrierWidthCompatible(source_type, operation_type);
end;

readonly func BundleSharedTMOVDestinationSchemaLegal(
    shared_tile_id: SharedTileID, function: integer {0..31}) => boolean
begin
    if BundleSharedBindingCount() != 1 ||
       BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let shared_mask = BundleSharedBindingMask(0);
    if !binding.valid || !binding.destination_valid ||
       binding.source0_valid || binding.source1_valid || !binding.last ||
       !LocalTileSizeCodeIsLegal(binding.destination_size) ||
       BundleSharedBindingIsDestination(0) ||
       binding.pe_mask != shared_mask then return FALSE; end;
    if shared_mask == Zeros{4} then return TRUE; end;
    let capacity_bytes = TileSizeCodeBytes(
        binding.destination_size as integer {1..12});
    let valid_rows = BundleDestinationValidRows(FALSE, 0);
    let valid_columns = BundleDestinationValidColumns(FALSE, 0);
    let columns = BundleDestinationPhysicalColumns(FALSE, 0);
    if valid_rows < 1 || valid_columns < 1 || columns < 1 ||
       valid_columns > columns then return FALSE; end;
    let (data_type_valid, operation_type) = ResolveBundleEffectiveDataType();
    if !data_type_valid then return FALSE; end;
    var data_type = operation_type;
    let source_interpretation = operation_type == TileDataType_E6M2 || operation_type == TileDataType_RCPE6M2;
    let layout = CurrentBundleTileLayout();
    if _BundleSharedBindings[[0]].source0_subview.valid then
        if !BundleSharedSubviewLegal(0) then return FALSE; end;
        let view = MaterializeBundleSharedSubview(0);
        if !BundleSharedTMOVNormalCarrierCompatible(view.data_type) then return FALSE; end;
        if source_interpretation then data_type = view.data_type; end;
        if view.capacity_bytes != capacity_bytes ||
           view.valid_rows != valid_rows ||
           view.valid_columns != valid_columns ||
           view.columns != columns || view.data_type != data_type ||
           view.layout != layout then
            return FALSE;
        end;
        return function == 2;
    end;
    let source_type = SharedTileRecord(shared_tile_id).tile.data_type;
    if !BundleSharedTMOVNormalCarrierCompatible(source_type) then return FALSE; end;
    if source_interpretation then data_type = source_type; end;
    if !SharedTileReadSchemaLegalAtCapacity(shared_tile_id, valid_rows, valid_columns, columns, data_type, layout, capacity_bytes) then return FALSE; end;
    return function == 2;
end;
```
<!-- GENERATED-ASL-END: unit -->
