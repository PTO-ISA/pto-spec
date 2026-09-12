<!-- GENERATED FROM: asl/block/model/dispatch/shared-cube-matrix.asl -->
# Shared CUBE Matrix

**Normative ASL source:** `asl/block/model/dispatch/shared-cube-matrix.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/shared-cube-matrix.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SHARED-CUBE-MATRIX","surface":"block","classification":["model","dispatch","shared-cube-matrix"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}

readonly func BundleMatrixSharedSourceSchemaLegal(
    ordinal: integer {0..3},
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    columns: integer {1..65535},
    data_type: TileDataType) => boolean
begin
    let shared_tile_id = BundleSharedBindingId(ordinal);
    if BundleSharedBindingIsDestination(ordinal) ||
       !SharedTileCooperativeMatrixReady(shared_tile_id) then
        return FALSE;
    end;
    if _BundleSharedBindings[[ordinal]].source0_subview.valid then
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 looplimit 4 do
            let pe_identity = pe as MemoryAgentId;
            if _BundleSharedBindings[[ordinal]].pe_mask[
                   PTOPEMaskBitOfPEIdentity(pe_identity)] == '1' &&
               !BundleSharedSubviewMatrixMetadataLegalForPE(
                   ordinal, pe_identity, valid_rows, valid_columns,
                   columns, data_type) then
                return FALSE;
            end;
        end;
        return TRUE;
    end;
    let shared = SharedTileRecord(shared_tile_id);
    return SharedTileDescriptorLegal(shared_tile_id) &&
           shared.tile.valid_rows == valid_rows &&
           shared.tile.valid_columns == valid_columns &&
           shared.tile.columns >= columns &&
           shared.tile.data_type == data_type &&
           shared.tile.layout == TileLayout_RowMajor;
end;

// Matrix schema preflight derives Shared CELL views without reading payload.
readonly func BundleSharedSubviewMatrixMetadataLegalForPE(
    binding: BundleSharedBindingIndex, pe_identity: MemoryAgentId,
    valid_rows: integer {1..65535}, valid_columns: integer {1..65535},
    minimum_columns: integer {1..65535}, data_type: TileDataType) => boolean
begin
    if !_BundleSharedBindings[[binding]].valid ||
       !_BundleSharedBindings[[binding]].source0_subview.valid ||
       _BundleSharedBindings[[binding]].size_code != 0 then return FALSE; end;
    let shared_tile_id = _BundleSharedBindings[[binding]].shared_tile_id;
    if !SharedTileDescriptorLegal(shared_tile_id) ||
       !SharedTilePublished(shared_tile_id) then return FALSE; end;
    let parent = SharedTileRecord(shared_tile_id).tile;
    if parent.layout != TileLayout_RowMajor || parent.columns == 0 ||
       parent.data_type != data_type then return FALSE; end;
    let modifier = _BundleSharedBindings[[binding]].source0_subview;
    if modifier.size_code == 0 then return FALSE; end;
    let selected_bytes = TileSizeCodeBytes(
        modifier.size_code as integer {1..12});
    let element_bits = TileElementBits(parent.data_type);
    let bounded_columns = parent.columns as integer {1..65535};
    let raw_offset = UInt(BundleSharedSubviewOffsetRawForPE(
        binding, pe_identity));
    if raw_offset > 2047 then return FALSE; end;
    let offset_cells = raw_offset as integer {0..2047};
    if offset_cells * PTO_TILE_CELL_BYTES + selected_bytes >
           parent.capacity_bytes then return FALSE; end;
    let offset_elements = ((offset_cells * PTO_TILE_CELL_BYTES * 8) DIVRM
        element_bits) as integer {0..524287};
    let selected_elements = ((selected_bytes * 8) DIVRM element_bits)
        as integer {1..524288};
    let origin_row = (offset_elements DIVRM bounded_columns)
        as integer {0..65535};
    let origin_column = (offset_elements MOD bounded_columns)
        as integer {0..65535};
    if selected_elements > bounded_columns - origin_column &&
       (origin_column != 0 || selected_elements MOD bounded_columns != 0) then
        return FALSE;
    end;
    if selected_elements > bounded_columns - origin_column &&
       selected_elements DIVRM bounded_columns > 65535 then return FALSE; end;
    let selected_columns = (if selected_elements <=
        bounded_columns - origin_column then selected_elements
        else bounded_columns) as integer {1..65535};
    let selected_rows = (if selected_elements <=
        bounded_columns - origin_column then 1
        else selected_elements DIVRM bounded_columns) as integer {1..65535};
    let clipped_rows = if origin_row + selected_rows > parent.valid_rows then
        if origin_row < parent.valid_rows then
            (parent.valid_rows - origin_row) as integer {0..65535}
        else 0
    else selected_rows;
    let clipped_columns = if origin_column + selected_columns >
        parent.valid_columns then
        if origin_column < parent.valid_columns then
            (parent.valid_columns - origin_column) as integer {0..65535}
        else 0
    else selected_columns;
    return clipped_rows == valid_rows && clipped_columns == valid_columns &&
           selected_columns >= minimum_columns;
end;

readonly func BundleMatrixSharedSourcesReady(
    shared_count: integer {0..4}) => boolean
begin
    if shared_count == 0 then return TRUE; end;
    for ordinal = 0 to shared_count - 1 looplimit 4 do
        let binding = ordinal as integer {0..3};
        if _BundleSharedBindings[[binding]].valid &&
           !BundleSharedBindingIsDestination(binding) &&
           !SharedTilePublished(BundleSharedBindingId(binding)) then
            return FALSE;
        end;
    end;
    return TRUE;
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

readonly func BundleMatrixSharedBPrimarySchemaLegal(
    ordinal: integer {0..3},
    logical_rows: integer {1..65535},
    logical_columns: integer {1..65535},
    data_type: TileDataType,
    transpose: boolean) => boolean
begin
    // B's stored major order is [N,K] without TransB and [K,N] with it;
    // unlike A, the non-transposed physical rows are the logical columns.
    let stored_rows = if transpose then logical_rows else logical_columns;
    let stored_columns = if transpose then logical_columns else logical_rows;
    return BundleMatrixSharedSourceSchemaLegal(
        ordinal, stored_rows, stored_columns,
        stored_columns, data_type);
end;

pure func BundleMatrixCooperativeMPerPE(
    group_m: integer {1..65535}) => integer {0,16,32}
begin
    if group_m <= 64 then return 16;
    elsif group_m <= 128 then return 32;
    else return 0;
    end;
end;

pure func BundleMatrixCooperativeValidM(
    group_m: integer {1..65535},
    pe_identity: MemoryAgentId) => integer {0..32}
begin
    let m_per_pe = BundleMatrixCooperativeMPerPE(group_m);
    if m_per_pe == 0 then return 0; end;
    let first_row = pe_identity * m_per_pe;
    if first_row >= group_m then return 0; end;
    let remaining = group_m - first_row;
    if remaining < m_per_pe then return remaining as integer {1..31}; end;
    return m_per_pe as integer {16,32};
end;

pure func BundleMatrixCooperativeCurrentPEMask(
    group_m: integer {1..65535},
    pe_identity: MemoryAgentId) => bits(4)
begin
    var mask = Zeros{4};
    if BundleMatrixCooperativeValidM(group_m, pe_identity) != 0 then
        mask[PTOPEMaskBitOfPEIdentity(pe_identity)] = '1';
    end;
    return mask;
end;

readonly func BundleMatrixSharedLeftPrimarySchemaLegal(
    ordinal: integer {0..3},
    group_m: integer {1..65535},
    k: integer {1..65535},
    data_type: TileDataType,
    transpose: boolean) => boolean
begin
    if BundleMatrixCooperativeMPerPE(group_m) == 0 then return FALSE; end;
    return BundleMatrixSharedPrimarySchemaLegal(
        ordinal, group_m, k, data_type, transpose);
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
    let left_scale_groups = if left_scale_present then
        TileMXScaleGroupCount(k, left_type) else 1;
    let right_scale_groups = if right_scale_present then
        TileMXScaleGroupCount(k, right_type) else 1;
    let right_group = TileMatrixRightGroupSourceCount(
        function, right_type);
    let left_shared = shared_count != right_group;
    if _BundleFixedPointAttributes.trans_a && !left_shared then
        return FALSE;
    end;
    var ordinal: integer {0..4} = 0;

    if left_shared then
        if !BundleMatrixSharedLeftPrimarySchemaLegal(
               ordinal as integer {0..3},
               m, k, left_type,
               _BundleFixedPointAttributes.trans_a) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..4};
        if left_scale_present then
            if !BundleMatrixSharedPrimarySchemaLegal(
                   ordinal as integer {0..3},
                   m, left_scale_groups,
                   TileMXScaleCarrierType(left_type),
                   _BundleFixedPointAttributes.trans_a) then
                return FALSE;
            end;
            ordinal = (ordinal + 1) as integer {0..4};
        end;
    end;

    if !BundleMatrixSharedBPrimarySchemaLegal(
           ordinal as integer {0..3},
           k, n, right_type,
           _BundleFixedPointAttributes.trans_b) then
        return FALSE;
    end;
    ordinal = (ordinal + 1) as integer {0..4};
    if right_scale_present then
        if !BundleMatrixSharedBPrimarySchemaLegal(
               ordinal as integer {0..3},
               right_scale_groups, n,
               TileMXScaleCarrierType(right_type),
               _BundleFixedPointAttributes.trans_b) then
            return FALSE;
        end;
        ordinal = (ordinal + 1) as integer {0..4};
    end;
    return ordinal == shared_count;
end;

readonly func MaterializeBundleSharedMatrixLeftPrimary(
    ordinal: integer {0..3},
    group_m: integer {1..65535},
    k: integer {1..65535},
    data_type: TileDataType,
    transpose: boolean,
    pe_identity: MemoryAgentId) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert BundleMatrixSharedLeftPrimarySchemaLegal(
        ordinal, group_m, k, data_type, transpose);
    let m_per_pe = BundleMatrixCooperativeMPerPE(group_m);
    let valid_m = BundleMatrixCooperativeValidM(group_m, pe_identity);
    assert m_per_pe != 0 && valid_m != 0;
    let pe_m = valid_m as integer {1..32};
    let shared_tile_id = BundleSharedBindingId(ordinal);
    let source = if
        _BundleSharedBindings[[ordinal]].source0_subview.valid then
        MaterializeBundleSharedSubview(ordinal)
    else SharedTileRecord(shared_tile_id).tile;
    var tile = source;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.packed_defined_elements = zero_packed_tile_elements;
    tile.defined_valid_elements = 0;
    tile.rows = DerivedTileRows(tile.capacity_bytes, k, data_type);
    tile.columns = k;
    tile.valid_rows = pe_m;
    tile.valid_columns = k;
    tile.data_type = data_type;
    tile.predicate_basis_type = data_type;
    tile.layout = TileLayout_RowMajor;
    tile.location = TileLocation_Any;
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.cube_storage_bytes = 0;
    for row = 0 to pe_m - 1 looplimit 65536 do
        for column = 0 to k - 1 looplimit 65536 do
            let group_row = (pe_identity * m_per_pe + row)
                as integer {0..65535};
            let source_row = if transpose then column else group_row;
            let source_column = if transpose then group_row else column;
            let source_element = TileLogicalLinearIndex(
                source,
                source_row as integer {0..65535},
                source_column as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(
                tile,
                row as integer {0..65535},
                column as integer {0..65535});
            tile = TileInfoWithLogicalElement(tile, destination_element,
                TileReadLogicalElement(source, source_element));
        end;
    end;
    tile.contents_defined = TRUE;
    tile.defined_valid_elements = (pe_m * k) as integer {0..524288};
    return tile;
end;

readonly func MaterializeBundleSharedMatrixLeftScale(
    ordinal: integer {0..3},
    group_m: integer {1..65535},
    k: integer {1..65535},
    primary_type: TileDataType,
    transpose: boolean,
    pe_identity: MemoryAgentId) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    let m_per_pe = BundleMatrixCooperativeMPerPE(group_m);
    let valid_m = BundleMatrixCooperativeValidM(group_m, pe_identity);
    assert m_per_pe != 0 && valid_m != 0;
    let pe_m = valid_m as integer {1..32};
    let scale_groups = TileMXScaleGroupCount(k, primary_type);
    let scale_type = TileMXScaleCarrierType(primary_type);
    let shared_tile_id = BundleSharedBindingId(ordinal);
    let source = if
        _BundleSharedBindings[[ordinal]].source0_subview.valid then
        MaterializeBundleSharedSubview(ordinal)
    else SharedTileRecord(shared_tile_id).tile;
    assert BundleMatrixSharedPrimarySchemaLegal(
        ordinal, group_m, scale_groups, scale_type, transpose);
    var tile = source;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.packed_defined_elements = zero_packed_tile_elements;
    tile.defined_valid_elements = 0;
    tile.rows = DerivedTileRows(
        tile.capacity_bytes, scale_groups, scale_type);
    tile.columns = scale_groups;
    tile.valid_rows = pe_m;
    tile.valid_columns = scale_groups;
    tile.data_type = scale_type;
    tile.predicate_basis_type = scale_type;
    tile.layout = TileLayout_RowMajor;
    tile.location = TileLocation_Any;
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.cube_storage_bytes = 0;
    for row = 0 to pe_m - 1 looplimit 65536 do
        for column = 0 to scale_groups - 1 looplimit 2048 do
            let group_row = (pe_identity * m_per_pe + row)
                as integer {0..65535};
            let source_row = if transpose then column else group_row;
            let source_column = if transpose then group_row else column;
            let source_element = TileLogicalLinearIndex(
                source,
                source_row as integer {0..65535},
                source_column as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(
                tile, row as integer {0..65535},
                column as integer {0..65535});
            tile = TileInfoWithLogicalElement(tile, destination_element,
                TileReadLogicalElement(source, source_element));
        end;
    end;
    tile.contents_defined = TRUE;
    tile.defined_valid_elements =
        (pe_m * scale_groups) as integer {0..524288};
    return tile;
end;

readonly func MaterializeBundleSharedMatrixSource(
    ordinal: integer {0..3},
    valid_rows: integer {1..65535},
    valid_columns: integer {1..65535},
    columns: integer {1..65535},
    data_type: TileDataType) => TileInfo
begin
    let shared_tile_id = BundleSharedBindingId(ordinal);
    var tile = if
        _BundleSharedBindings[[ordinal]].source0_subview.valid then
        MaterializeBundleSharedSubview(ordinal)
    else MaterializeSharedTileForReadSchema(
        shared_tile_id, valid_rows, valid_columns, columns,
        data_type, TileLayout_RowMajor);
    for element = 0 to tile.rows * tile.columns - 1
        looplimit 524288 do
        let index = element as PackedTileElementIndex;
        tile = TileInfoWithLogicalElement(tile, index,
            TileReadLogicalElement(tile, index));
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
    transpose: boolean,
    pe_identity: MemoryAgentId) => TileInfo
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    assert BundleMatrixSharedBPrimarySchemaLegal(
        ordinal, logical_rows, logical_columns, data_type, transpose);
    let shared_tile_id = BundleSharedBindingId(ordinal);
    let source = if
        _BundleSharedBindings[[ordinal]].source0_subview.valid then
        MaterializeBundleSharedSubviewForPE(ordinal, pe_identity)
    else SharedTileRecord(shared_tile_id).tile;
    var tile = source;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.packed_defined_elements = zero_packed_tile_elements;
    tile.defined_valid_elements = 0;
    tile.rows = DerivedTileRows(
        tile.capacity_bytes, logical_columns, data_type);
    tile.columns = logical_columns;
    tile.valid_rows = logical_rows;
    tile.valid_columns = logical_columns;
    tile.data_type = data_type;
    tile.predicate_basis_type = data_type;
    tile.layout = TileLayout_RowMajor;
    tile.location = TileLocation_Any;
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.cube_storage_bytes = 0;
    for row = 0 to logical_rows - 1 looplimit 65536 do
        for column = 0 to logical_columns - 1 looplimit 65536 do
            let source_row = if transpose then row else column;
            let source_column = if transpose then column else row;
            let source_element = TileLogicalLinearIndex(
                source,
                source_row as integer {0..65535},
                source_column as integer {0..65535});
            let destination_element = TileLogicalLinearIndex(
                tile,
                row as integer {0..65535},
                column as integer {0..65535});
            tile = TileInfoWithLogicalElement(tile, destination_element,
                TileReadLogicalElement(source, source_element));
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
```
<!-- GENERATED-ASL-END: unit -->
