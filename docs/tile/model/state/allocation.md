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
    assert !TileLayoutIsCube(layout);
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
    _Tiles[[index]].storage_rows = derived_rows;
    _Tiles[[index]].storage_columns = columns;
    _Tiles[[index]].storage_bytes = TileStorageBytes(derived_rows, columns,
        data_type) as integer {0..262144};
    _Tiles[[index]].cube_k_repeat = 0;
    _Tiles[[index]].cube_n_repeat = 0;
    _Tiles[[index]].cube_cell_count = 0;
    _Tiles[[index]].cube_role = TileCubeOperand_None;
    _Tiles[[index]].data_type = data_type;
    _Tiles[[index]].layout = layout;
    _Tiles[[index]].location = location;
end;

func ConfigureCubeTileForMask(index: TileIndex,
                              capacity_bytes: integer {0..262144},
                              valid_rows: integer {0..65535},
                              valid_columns: integer {0..65535},
                              data_type: TileDataType, layout: TileLayout,
                              role: TileCubeOperandRole,
                              location: TileLocation,
                              allocation_mask: bits(4))
begin
    assert TileCubeDescriptorShapeLegal(capacity_bytes, valid_rows,
        valid_columns, data_type, layout, role);
    assert allocation_mask != Zeros{4};
    let storage_rows = TileCubeStorageRows(layout, role, valid_rows,
        data_type);
    let storage_columns = TileCubeStorageColumns(layout, role,
        valid_columns, data_type);
    let storage_bytes = TileCubeRequiredBytes(layout, role, valid_rows,
        valid_columns, data_type);
    let k_repeat = TileCubeKRepeat(layout, role, valid_rows, valid_columns,
        data_type);
    let n_repeat = TileCubeNRepeat(layout, role, valid_columns, data_type);
    let cell_count = TileCubeCellCount(layout, role, valid_rows,
        valid_columns, data_type);
    assert TileCapacityInUseExcept(index) + SharedTileCapacityInUse() +
        TileCoreAllocationBytes(allocation_mask, capacity_bytes) <=
        TileCapacityLimitBytes();
    _TileAllocationMasks[[index]] = allocation_mask;
    _Tiles[[index]].allocated = TRUE;
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = storage_rows;
    _Tiles[[index]].columns = storage_columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].storage_rows = storage_rows;
    _Tiles[[index]].storage_columns = storage_columns;
    _Tiles[[index]].storage_bytes = storage_bytes;
    _Tiles[[index]].cube_k_repeat = k_repeat;
    _Tiles[[index]].cube_n_repeat = n_repeat;
    _Tiles[[index]].cube_cell_count = cell_count;
    _Tiles[[index]].cube_role = role;
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

func ConfigureCubeTile(index: TileIndex, capacity_bytes: integer {0..262144},
                       valid_rows: integer {0..65535},
                       valid_columns: integer {0..65535},
                       data_type: TileDataType, layout: TileLayout,
                       role: TileCubeOperandRole, location: TileLocation)
begin
    ConfigureCubeTileForMask(index, capacity_bytes, valid_rows,
        valid_columns, data_type, layout, role, location, '0001');
end;

readonly func CubeValidRegionUpdateLegal(tile: TileInfo,
                                         valid_rows: integer {0..65535},
                                         valid_columns: integer {0..65535})
                                         => boolean
begin
    if !tile.allocated || !TileLayoutIsCube(tile.layout) ||
       valid_rows == 0 || valid_columns == 0 ||
       valid_rows > tile.storage_rows ||
       valid_columns > tile.storage_columns then return FALSE; end;
    return TileCubeKRepeat(tile.layout, tile.cube_role, valid_rows,
               valid_columns, tile.data_type) == tile.cube_k_repeat &&
           TileCubeNRepeat(tile.layout, tile.cube_role, valid_columns,
               tile.data_type) ==
               tile.cube_n_repeat;
end;

func RefreshCubeTileDefinednessForValidRegion(index: TileIndex)
begin
    let tile = _Tiles[[index]];
    var defined_count: integer = 0;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileCubePayloadIndex(tile.layout, tile.data_type,
                tile.cube_role, tile.cube_k_repeat,
                row as integer {0..65535},
                column as integer {0..65535});
            if _Tiles[[index]].defined_elements[element] == '1' then
                defined_count = defined_count + 1;
            end;
        end;
    end;
    _Tiles[[index]].defined_valid_elements =
        defined_count as integer {0..16384};
    _Tiles[[index]].contents_defined =
        defined_count == tile.valid_rows * tile.valid_columns;
end;

func UpdateCubeTileValidRegion(index: TileIndex,
                               valid_rows: integer {0..65535},
                               valid_columns: integer {0..65535})
begin
    let tile = _Tiles[[index]];
    if !CubeValidRegionUpdateLegal(tile, valid_rows, valid_columns) then
        return;
    end;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    RefreshCubeTileDefinednessForValidRegion(index);
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
    _Tiles[[index]].storage_rows = 0;
    _Tiles[[index]].storage_columns = 0;
    _Tiles[[index]].storage_bytes = 0;
    _Tiles[[index]].cube_k_repeat = 0;
    _Tiles[[index]].cube_n_repeat = 0;
    _Tiles[[index]].cube_cell_count = 0;
    _Tiles[[index]].cube_role = TileCubeOperand_None;
    _Tiles[[index]].data_type = TileDataType_U8;
    _Tiles[[index]].layout = TileLayout_RowMajor;
    _Tiles[[index]].location = TileLocation_Any;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
