<!-- GENERATED FROM: asl/tile/model/state/allocation.asl -->
# Allocation

**Normative ASL source:** `asl/tile/model/state/allocation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-ALLOCATION}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/state/allocation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-ALLOCATION","surface":"tile","classification":["model","state","allocation"],"depends_on":["PTO-TILE-MODEL-SHAPE-VALID-REGION"]}
func ConfigureTileForMask(index: TileIndex,
                   capacity_bytes: integer {0..262144},
                   rows: integer {0..65535}, columns: integer {0..65535},
                   valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
                   data_type: TileDataType, layout: TileLayout,
                   location: TileLocation, allocation_mask: bits(4))
begin
    assert TileCapacityIsLegal(capacity_bytes);
    assert allocation_mask != Zeros{4};
    assert rows > 0;
    assert valid_rows <= rows;
    assert TileDescriptorShapeLegal(capacity_bytes, columns, valid_rows,
        valid_columns, data_type);
    let derived_rows = DerivedTileRows(capacity_bytes, columns, data_type);
    assert rows <= derived_rows;
    assert derived_rows * columns <= PTO_MODEL_TILE_ELEMENTS;
    assert TileCapacityInUseExcept(index) + SharedTileCapacityInUse() +
        TileCoreAllocationBytes(allocation_mask, capacity_bytes) <=
        TileCapacityLimitBytes();
    _TileAllocationMasks[[index]] = allocation_mask;
    _Tiles[[index]].allocated = TRUE;
    // Allocation defines TileInfo but not the payload. A producer must write
    // the tile before any generic payload read is legal.
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = derived_rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = data_type;
    _Tiles[[index]].layout = layout;
    _Tiles[[index]].location = location;
end;

func ConfigureTile(index: TileIndex, capacity_bytes: integer {0..262144},
                   rows: integer {0..65535}, columns: integer {0..65535},
                   valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
                   data_type: TileDataType, layout: TileLayout, location: TileLocation)
begin
    // Direct one-level operations model the already-resolved current-PE
    // fragment and therefore charge one PE of capacity.
    ConfigureTileForMask(index, capacity_bytes, rows, columns,
        valid_rows, valid_columns, data_type, layout, location, '0001');
end;

func ReleaseTile(index: TileIndex)
begin
    _TileAllocationMasks[[index]] = Zeros{4};
    _Tiles[[index]].allocated = FALSE;
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].capacity_bytes = 0;
    _Tiles[[index]].rows = 0;
    _Tiles[[index]].columns = 0;
    _Tiles[[index]].valid_rows = 0;
    _Tiles[[index]].valid_columns = 0;
    _Tiles[[index]].data_type = TileDataType_U8;
    _Tiles[[index]].layout = TileLayout_RowMajor;
    _Tiles[[index]].location = TileLocation_Any;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
