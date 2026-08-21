// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX","surface":"block","classification":["model","dispatch","shared-cube-matrix"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS","PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}

readonly func BundleMatrixSharedSourceSchemaLegal(
    ordinal: integer {0..3},
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    return !BundleSharedBindingIsDestination(ordinal) &&
           SharedTileCooperativeMatrixReady(
               BundleSharedBindingId(ordinal)) &&
           SharedTileReadSchemaLegal(
               BundleSharedBindingId(ordinal),
               valid_rows, valid_columns, columns,
               data_type, TileLayout_RowMajor);
end;

readonly func BundleMatrixSharedPrimarySchemaLegal(
    ordinal: integer {0..3},
    logical_rows: integer {1..65535},
    logical_columns: integer {1..65535},
    data_type: TileDataType,
    transpose: boolean) => boolean
begin
    let stored_rows = if transpose then logical_columns else logical_rows;
    let stored_columns = if transpose then logical_rows else logical_columns;
    return BundleMatrixSharedSourceSchemaLegal(
        ordinal, stored_rows, stored_columns,
        stored_columns, data_type);
end;

readonly func BundleMatrixSharedSchemasLegal(
    function: integer {0..31},
    left_type: TileDataType,
    right_type: TileDataType,
    m: integer {1..65535},
    n: integer {1..65535},
    k: integer {1..65535},
    shared_count: integer {0..4}) => boolean
begin
    if shared_count == 0 then
        return !_BundleFixedPointAttributes.trans_a &&
               !_BundleFixedPointAttributes.trans_b;
    end;
    let left_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(left_type);
    let right_scale_present = TileMatrixFunctionUsesMX(function) &&
        TileMXInputTypeNeedsScale(right_type);
    let scale_blocks = ((k + 31) DIVRM 32)
        as integer {1..2048};
    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    let left_shared = shared_count != right_group;
    if _BundleFixedPointAttributes.trans_a && !left_shared then
        return FALSE;
    end;
    var ordinal: integer {0..4} = 0;

    if left_shared then
        if !BundleMatrixSharedPrimarySchemaLegal(
               ordinal as integer {0..3},
               m, k, left_type,
               _BundleFixedPointAttributes.trans_a) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..4};
        if left_scale_present then
            if !BundleMatrixSharedSourceSchemaLegal(
                   ordinal as integer {0..3},
                   m, scale_blocks, scale_blocks,
                   TileDataType_E8M0) then
                return FALSE;
            end;
            ordinal = (ordinal + 1) as integer {0..4};
        end;
    end;

    if !BundleMatrixSharedPrimarySchemaLegal(
           ordinal as integer {0..3},
           k, n, right_type,
           _BundleFixedPointAttributes.trans_b) then
        return FALSE;
    end;
    ordinal = (ordinal + 1) as integer {0..4};
    if right_scale_present then
        if !BundleMatrixSharedSourceSchemaLegal(
               ordinal as integer {0..3},
               scale_blocks, n, n,
               TileDataType_E8M0) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..4};
    end;
    return ordinal == shared_count;
end;

readonly func MaterializeBundleSharedMatrixSource(
    ordinal: integer {0..3},
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    columns: integer {1..65535},
    data_type: TileDataType) => TileInfo
begin
    let shared_id = BundleSharedBindingId(ordinal);
    var tile = MaterializeSharedTileForReadSchema(
        shared_id, valid_rows, valid_columns, columns,
        data_type, TileLayout_RowMajor);
    for element = 0 to tile.rows * tile.columns - 1
        looplimit 524288 do
        let index = element as PackedTileElementIndex;
        tile = TileInfoWithLogicalElement(tile, index,
            ReadSharedTileWord(shared_id, index));
    end;
    tile.contents_defined = TRUE;
    tile.defined_valid_elements =
        (valid_rows * valid_columns) as integer {0..524288};
    return tile;
end;

readonly func MaterializeBundleSharedMatrixPrimary(
    ordinal: integer {0..3},
    logical_rows: integer {1..65535},
    logical_columns: integer {1..65535},
    data_type: TileDataType,
    transpose: boolean) => TileInfo
begin
    assert BundleMatrixSharedPrimarySchemaLegal(
        ordinal, logical_rows, logical_columns, data_type, transpose);
    let shared_id = BundleSharedBindingId(ordinal);
    let shared = SharedTileRecord(shared_id);
    var tile = shared.tile;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.packed_defined_elements = ZeroPackedTileDefinedElements();
    tile.defined_valid_elements = 0;
    tile.rows = DerivedTileRows(
        tile.capacity_bytes, logical_columns, data_type);
    tile.columns = logical_columns;
    tile.valid_rows = logical_rows;
    tile.valid_columns = logical_columns;
    tile.data_type = data_type;
    tile.layout = TileLayout_RowMajor;
    tile.location = TileLocation_Any;
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.cube_storage_bytes = 0;
    for row = 0 to logical_rows - 1 looplimit 65536 do
        for column = 0 to logical_columns - 1 looplimit 65536 do
            let source_row = if transpose then column else row;
            let source_column = if transpose then row else column;
            let source_element = TileLogicalLinearIndex(
                shared.tile,
                source_row as integer {0..65535},
                source_column as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(
                tile,
                row as integer {0..65535},
                column as integer {0..65535});
            tile = TileInfoWithLogicalElement(tile, destination_element,
                ReadSharedTileWord(shared_id, source_element));
        end;
    end;
    tile.contents_defined = TRUE;
    tile.defined_valid_elements =
        (logical_rows * logical_columns) as integer {0..524288};
    return tile;
end;

readonly func BundleMatrixCooperativeMLayout(
    function: integer {0..31},
    right_type: TileDataType,
    m: integer {1..65535},
    shared_count: integer {0..4}) => (boolean, TileLayout)
begin
    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    let local_left_present = shared_count == 0 ||
        shared_count == right_group;
    var layout = TileLayout_RowMajor;
    if local_left_present then
        let left_ordinal = if TileMatrixFunctionUsesAccumulator(function)
            then 1 else 0;
        layout = _Tiles[[BundleMatrixSourceAt(
            left_ordinal as integer {0..7})]].layout;
    elsif TileMatrixFunctionUsesAccumulator(function) then
        layout = _Tiles[[BundleMatrixSourceAt(0)]].layout;
    elsif m <= 16 then
        layout = TileLayout_CUBE_M16;
    elsif m <= 32 then
        layout = TileLayout_CUBE_M32;
    end;
    return (TileMatrixMLayoutLegal(layout, m), layout);
end;
