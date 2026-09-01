// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-ALLOCATION","surface":"tile","classification":["model","state","allocation"],"depends_on":["PTO-TILE-MODEL-SHAPE-VALID-REGION","PTO-TILE-MODEL-STATE-FEATURE-MAP-DESCRIPTORS"]}
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
    assert derived_rows * columns <=
        TileLogicalElementCapacity(capacity_bytes, data_type);
    assert LocalTileAllocationFitsExcept(
        index, allocation_mask, capacity_bytes);
    InvalidateTileFeatureMapDescriptor(index);
    _TileAllocationMasks[[index]] = allocation_mask;
    _Tiles[[index]].allocated = TRUE;
    _Tiles[[index]].storage_kind = TileStorage_Numeric;
    // Allocation defines TileInfo but not the payload. A producer must write
    // the tile before any generic payload read is legal.
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].packed_defined_elements =
        ZeroPackedTileDefinedElements();
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = derived_rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = data_type;
    _Tiles[[index]].predicate_basis_type = data_type;
    _Tiles[[index]].layout = layout;
    _Tiles[[index]].location = location;
    _Tiles[[index]].cube_k_repeat = 0;
    _Tiles[[index]].cube_n_repeat = 0;
    _Tiles[[index]].cube_cell_count = 0;
    _Tiles[[index]].cube_storage_bytes = 0;
end;

pure func PredicateTileStorageBytes(
    rows: integer {0..65535},
    columns: integer {0..65535}) => integer
begin
    return ((rows * columns) + 7) DIVRM 8;
end;

func ConfigurePredicateTileForMask(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    rows: integer {0..65535},
    columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    allocation_mask: bits(4))
begin
    assert TileCapacityIsLegal(capacity_bytes);
    assert allocation_mask != Zeros{4};
    assert rows > 0 && columns > 0;
    assert valid_rows <= rows && valid_columns <= columns;
    assert rows * columns <= PTO_MODEL_TILE_ELEMENTS;
    assert PredicateTileStorageBytes(rows, columns) <= capacity_bytes;
    assert LocalTileAllocationFitsExcept(
        index, allocation_mask, capacity_bytes);
    InvalidateTileFeatureMapDescriptor(index);
    _TileAllocationMasks[[index]] = allocation_mask;
    _Tiles[[index]].allocated = TRUE;
    _Tiles[[index]].storage_kind = TileStorage_Predicate;
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].packed_defined_elements =
        ZeroPackedTileDefinedElements();
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = TileDataType_U8;
    _Tiles[[index]].predicate_basis_type = TileDataType_U8;
    _Tiles[[index]].layout = TileLayout_RowMajor;
    _Tiles[[index]].location = TileLocation_Any;
    _Tiles[[index]].cube_k_repeat = 0;
    _Tiles[[index]].cube_n_repeat = 0;
    _Tiles[[index]].cube_cell_count = 0;
    _Tiles[[index]].cube_storage_bytes = 0;
end;

func ConfigurePredicateTile(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    rows: integer {0..65535},
    columns: integer {0..65535},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535})
begin
    ConfigurePredicateTileForMask(
        index,
        capacity_bytes,
        rows,
        columns,
        valid_rows,
        valid_columns,
        '0001');
    InstallRelativeTileFixture(index, index);
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
    InstallRelativeTileFixture(index, index);
end;

func ConfigureCubeTileForMask(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout,
    location: TileLocation,
    allocation_mask: bits(4)) => boolean
begin
    if allocation_mask == Zeros{4} || location != TileLocation_Matrix ||
       !TileCubeDescriptorShapeLegal(capacity_bytes, valid_rows,
           valid_columns, data_type, layout) then
        return FALSE;
    end;
    if !LocalTileAllocationFitsExcept(
           index, allocation_mask, capacity_bytes) then
        return FALSE;
    end;
    let rows = TileCubeStorageRows(layout, valid_rows, data_type);
    let columns = TileCubeStorageColumns(layout, valid_columns, data_type);
    let k_repeat = TileCubeKRepeat(
        layout, valid_rows, valid_columns, data_type);
    let n_repeat = TileCubeNRepeat(
        layout, valid_rows, valid_columns, data_type);
    let cell_count = TileCubeCellCount(
        layout, valid_rows, valid_columns, data_type);
    let storage_bytes = TileCubeRequiredBytes(
        layout, valid_rows, valid_columns, data_type);
    assert rows != 0 && columns != 0 && k_repeat != 0 &&
           n_repeat != 0 && cell_count != 0 && storage_bytes != 0;
    InvalidateTileFeatureMapDescriptor(index);
    _TileAllocationMasks[[index]] = allocation_mask;
    _Tiles[[index]].allocated = TRUE;
    _Tiles[[index]].storage_kind = TileStorage_Numeric;
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].capacity_bytes = capacity_bytes;
    _Tiles[[index]].rows = rows;
    _Tiles[[index]].columns = columns;
    _Tiles[[index]].valid_rows = valid_rows;
    _Tiles[[index]].valid_columns = valid_columns;
    _Tiles[[index]].data_type = data_type;
    _Tiles[[index]].predicate_basis_type = data_type;
    _Tiles[[index]].layout = layout;
    _Tiles[[index]].location = location;
    _Tiles[[index]].cube_k_repeat = k_repeat;
    _Tiles[[index]].cube_n_repeat = n_repeat;
    _Tiles[[index]].cube_cell_count = cell_count;
    _Tiles[[index]].cube_storage_bytes = storage_bytes;
    return TRUE;
end;

func ConfigureCubeTile(
    index: TileIndex,
    capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535},
    valid_columns: integer {0..65535},
    data_type: TileDataType,
    layout: TileLayout,
    location: TileLocation) => boolean
begin
    let configured = ConfigureCubeTileForMask(index, capacity_bytes, valid_rows,
        valid_columns, data_type, layout, location, '0001');
    if configured then InstallRelativeTileFixture(index, index); end;
    return configured;
end;

func ReleaseTile(index: TileIndex)
begin
    RemoveRelativeTileMapping(index);
    InvalidateTileFeatureMapDescriptor(index);
    _TileAllocationMasks[[index]] = Zeros{4};
    _Tiles[[index]].allocated = FALSE;
    _Tiles[[index]].storage_kind = TileStorage_Numeric;
    _Tiles[[index]].contents_defined = FALSE;
    _Tiles[[index]].defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    _Tiles[[index]].defined_valid_elements = 0;
    _Tiles[[index]].packed_defined_elements =
        ZeroPackedTileDefinedElements();
    _Tiles[[index]].capacity_bytes = 0;
    _Tiles[[index]].rows = 0;
    _Tiles[[index]].columns = 0;
    _Tiles[[index]].valid_rows = 0;
    _Tiles[[index]].valid_columns = 0;
    _Tiles[[index]].data_type = TileDataType_U8;
    _Tiles[[index]].predicate_basis_type = TileDataType_U8;
    _Tiles[[index]].layout = TileLayout_RowMajor;
    _Tiles[[index]].location = TileLocation_Any;
    _Tiles[[index]].cube_k_repeat = 0;
    _Tiles[[index]].cube_n_repeat = 0;
    _Tiles[[index]].cube_cell_count = 0;
    _Tiles[[index]].cube_storage_bytes = 0;
end;

func ConfigurePredicateCellForMask(
    index: TileIndex, capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
    basis_type: TileDataType, layout: TileLayout,
    allocation_mask: bits(4)) => boolean
begin
    if (layout != TileLayout_CUBE_M16 && layout != TileLayout_CUBE_M32) ||
       !TileCubePredicateDataTypeSupported(basis_type) then
        return FALSE;
    end;
    if !ConfigureCubeTileForMask(
           index, capacity_bytes, valid_rows, valid_columns,
           TileDataType_U8, layout, TileLocation_Matrix,
           allocation_mask) then
        return FALSE;
    end;
    _Tiles[[index]].storage_kind = TileStorage_PredicateCell;
    _Tiles[[index]].predicate_basis_type = basis_type;
    return TRUE;
end;

func ConfigurePredicateCell(
    index: TileIndex, capacity_bytes: integer {0..262144},
    valid_rows: integer {0..65535}, valid_columns: integer {0..65535},
    basis_type: TileDataType, layout: TileLayout) => boolean
begin
    return ConfigurePredicateCellForMask(
        index, capacity_bytes, valid_rows, valid_columns,
        basis_type, layout, '0001');
end;
