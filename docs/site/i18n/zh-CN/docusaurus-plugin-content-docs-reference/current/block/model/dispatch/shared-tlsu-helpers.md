<!-- GENERATED FROM: asl/block/model/dispatch/shared-tlsu-helpers.asl -->
# Shared TLSU Helpers

**Normative ASL source:** `asl/block/model/dispatch/shared-tlsu-helpers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU-HELPERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/shared-tlsu-helpers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU-HELPERS","surface":"block","classification":["model","dispatch","shared-tlsu-helpers"],"depends_on":["PTO-ARCH-DATA-TYPES-INTEGER","PTO-ARCH-DATA-TYPES-NUMERIC-CLASSIFICATION","PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS"]}
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
```
<!-- GENERATED-ASL-END: unit -->
