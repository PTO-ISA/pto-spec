<!-- GENERATED FROM: asl/block/model/operands/subview-descriptor.asl -->
# Subview Descriptor

**Normative ASL source:** `asl/block/model/operands/subview-descriptor.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/subview-descriptor.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-SUBVIEW-DESCRIPTOR","surface":"block","classification":["model","operands","subview-descriptor"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESCRIPTOR-LEGALITY","PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS","PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-TILE-MODEL-SHAPE-CUBE-CELL"]}

// NDF-BEGIN: PTO-B-SUBVIEW-DESCRIPTOR-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A legal Local CUBE B.SUBVIEW MUST derive a bounded descriptor from the
// parent descriptor, XLEN offset, and encoded view capacity in CELL order.
// Parent lifetime and payload remain unchanged; non-CUBE, zero-valid, and
// out-of-range geometry is rejected with Fault_TileLegality before effects.
// NDF-END: PTO-B-SUBVIEW-DESCRIPTOR-001

// NDF-BEGIN: PTO-BLOCK-TILE-OPERATION-APPLICABILITY-001
// ndf: kind=contract level=L1 layer=block status=accepted
// B.SUBVIEW applicability is total over accepted Tile operations; the
// selected operation handler retains ownership of dtype, layout, shape, and
// definedness legality.
// NDF-END: PTO-BLOCK-TILE-OPERATION-APPLICABILITY-001

pure func EmptyBundleSubviewDescriptor(parent: TileIndex)
    => BundleSubviewDescriptor
begin
    return BundleSubviewDescriptor {
        valid = FALSE,
        parent = parent,
        offset_cells = 0,
        origin_row = 0,
        origin_column = 0,
        rows = 0,
        columns = 0,
        valid_rows = 0,
        valid_columns = 0,
        cell_count = 0,
        capacity_bytes = 0
    };
end;

readonly func BundleCubeSubviewDescriptorOf(
    parent_index: TileIndex,
    offset: Word,
    size_code: integer {1..12}) => BundleSubviewDescriptor
begin
    let empty = EmptyBundleSubviewDescriptor(parent_index);
    let parent = _Tiles[[parent_index]];
    if !parent.allocated || parent.location != TileLocation_Matrix ||
       !TileLayoutIsCube(parent.layout) || parent.valid_rows == 0 ||
       parent.valid_columns == 0 || parent.cube_cell_count == 0 then
        return empty;
    end;
    let raw_offset = UInt(offset);
    if raw_offset > 65535 || raw_offset >= parent.cube_cell_count then
        return empty;
    end;
    let offset_cells = raw_offset as integer {0..65535};
    let requested_cells = (TileSizeCodeBytes(size_code) DIVRM PTO_TILE_CELL_BYTES)
        as integer {1..2048};
    let remaining = (parent.cube_cell_count - offset_cells)
        as integer {1..16384};
    let cell_count = if requested_cells < remaining then requested_cells
        else remaining;
    let cell_rows = TileCubeCellRows(parent.layout, parent.data_type);
    let cell_columns = TileCubeCellColumns(parent.layout, parent.data_type);
    if cell_rows == 0 || cell_columns == 0 then return empty; end;
    var origin_row: integer {0..65535} = 0;
    var origin_column: integer {0..65535} = 0;
    var view_cell_count: integer {1..16384} = cell_count;
    if parent.layout == TileLayout_CUBE_N8 then
        let k_repeat = parent.cube_k_repeat;
        if k_repeat == 0 || k_repeat > 16384 then return empty; end;
        let bounded_k_repeat = k_repeat as integer {1..16384};
        let cell_k = (offset_cells MOD bounded_k_repeat)
            as integer {0..16383};
        let cell_n = (offset_cells DIVRM bounded_k_repeat)
            as integer {0..8191};
        let cells_until_n_boundary = (bounded_k_repeat - cell_k)
            as integer {1..16384};
        if view_cell_count > cells_until_n_boundary then
            view_cell_count = cells_until_n_boundary;
        end;
        origin_row = (cell_k * cell_rows) as integer {0..65535};
        origin_column = (cell_n * cell_columns) as integer {0..65535};
    else
        origin_column = (offset_cells * cell_columns)
            as integer {0..65535};
    end;
    if origin_row >= parent.valid_rows || origin_column >= parent.valid_columns then
        return empty;
    end;
    var valid_rows: integer {0..65535} = parent.valid_rows;
    if origin_row < parent.valid_rows then
        valid_rows = (parent.valid_rows - origin_row) as integer {0..65535};
    end;
    if parent.layout == TileLayout_CUBE_N8 then
        let requested_rows = (view_cell_count * cell_rows)
            as integer {1..65535};
        if valid_rows > requested_rows then valid_rows = requested_rows; end;
    end;
    let requested_columns: integer {1..65535} =
        if parent.layout == TileLayout_CUBE_N8 then cell_columns as integer {1..65535}
        else (view_cell_count * cell_columns) as integer {1..65535};
    var valid_columns: integer {0..65535} = requested_columns;
    if origin_column < parent.valid_columns &&
       parent.valid_columns - origin_column < requested_columns then
        valid_columns = (parent.valid_columns - origin_column) as integer {0..65535};
    end;
    if valid_rows == 0 || valid_columns == 0 then return empty; end;
    let rows = TileCubeStorageRows(parent.layout, valid_rows, parent.data_type);
    let columns = TileCubeStorageColumns(parent.layout, valid_columns, parent.data_type);
    let derived_cells = TileCubeCellCount(parent.layout, valid_rows, valid_columns, parent.data_type);
    let derived_capacity = TileCubeRequiredBytes(parent.layout, valid_rows, valid_columns, parent.data_type);
    if rows == 0 || columns == 0 || derived_cells == 0 || derived_capacity == 0 ||
       derived_cells > view_cell_count then return empty; end;
    return BundleSubviewDescriptor {
        valid = TRUE,
        parent = parent_index,
        offset_cells = offset_cells,
        origin_row = origin_row,
        origin_column = origin_column,
        rows = rows,
        columns = columns,
        valid_rows = valid_rows,
        valid_columns = valid_columns,
        cell_count = derived_cells,
        capacity_bytes = derived_capacity
    };
end;

pure func BundleSubviewElementInBounds(
    descriptor: BundleSubviewDescriptor,
    row: integer {0..65535}, column: integer {0..65535}) => boolean
begin
    return descriptor.valid && row < descriptor.valid_rows && column < descriptor.valid_columns;
end;

readonly func BundleSubviewOperationApplicabilityIsTotal(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    // Every accepted Tile operation is a legal dispatch candidate. The
    // selected operation's existing dtype/layout/shape/definedness checks
    // remain authoritative; this helper has no private family allowlist.
    return operation < PTO_TILE_OPERATION_COUNT;
end;

func PrepareSelectedBundleStage2() => boolean
begin
    if !_BundleOperation.valid then return TRUE; end;
    if !ResolveBundleRelativeTileSources() then return FALSE; end;
    let family = BundleTileDecodeFamily(_BundleOperation.operation_class);
    let code = BundleOperationDecodeCode(_BundleOperation);
    let decoded = DecodeTileOperation(family, code);
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if !PrepareBundleSubviewDescriptors(operation) then return FALSE; end;
    if !ValidateBundleLocalGeneration() then return FALSE; end;
    if !ValidateBundleSharedGeneration() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    return TRUE;
end;

func PrepareBundleSubviewDescriptors(
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    if !BundleSubviewOperationApplicabilityIsTotal(operation) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    // Bind readiness before materialization. A waiting consumer is a
    // non-faulting no-effect outcome and must never copy unready source cells
    // into a temporary view.
    if !PrepareBundleConsumerDependencies() then return FALSE; end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_subview.valid &&
               !_BundleTileBindings[[binding]].source0_subview.derived.valid then
                let encoded_size = _BundleTileBindings[[binding]]
                    .source0_subview.size_code;
                if encoded_size == 0 then
                    SetFault(Fault_TileLegality, ReadTPC());
                    return FALSE;
                end;
                let descriptor = BundleCubeSubviewDescriptorOf(
                    _BundleTileBindings[[binding]].source0,
                    _BundleTileBindings[[binding]].source0_subview.offset,
                    encoded_size as integer {1..12});
                if !descriptor.valid then
                    SetFault(Fault_TileLegality, ReadTPC());
                    return FALSE;
                end;
                _BundleTileBindings[[binding]].source0_subview.derived =
                    descriptor;
                if !MaterializeBundleSubview(
                        binding as BundleTileBindingIndex, FALSE,
                        descriptor, operation) then return FALSE; end;
            end;
            if _BundleTileBindings[[binding]].source1_subview.valid &&
               !_BundleTileBindings[[binding]].source1_subview.derived.valid then
                let encoded_size = _BundleTileBindings[[binding]]
                    .source1_subview.size_code;
                if encoded_size == 0 then
                    SetFault(Fault_TileLegality, ReadTPC());
                    return FALSE;
                end;
                let descriptor = BundleCubeSubviewDescriptorOf(
                    _BundleTileBindings[[binding]].source1,
                    _BundleTileBindings[[binding]].source1_subview.offset,
                    encoded_size as integer {1..12});
                if !descriptor.valid then
                    SetFault(Fault_TileLegality, ReadTPC());
                    return FALSE;
                end;
                _BundleTileBindings[[binding]].source1_subview.derived =
                    descriptor;
                if !MaterializeBundleSubview(
                        binding as BundleTileBindingIndex, TRUE,
                        descriptor, operation) then return FALSE; end;
            end;
        end;
    end;
    return TRUE;
end;

readonly func BundleReadSubviewElement(
    binding: BundleTileBindingIndex,
    source_select: boolean,
    row: integer {0..65535},
    column: integer {0..65535}) => Word
begin
    let descriptor = if source_select then
        _BundleTileBindings[[binding]].source1_subview.derived
        else _BundleTileBindings[[binding]].source0_subview.derived;
    assert BundleSubviewElementInBounds(descriptor, row, column);
    return ReadTileElement(descriptor.parent,
        (descriptor.origin_row + row) as integer {0..65535},
        (descriptor.origin_column + column) as integer {0..65535});
end;

readonly func BundleTileSourceIndex(
    binding: BundleTileBindingIndex, source_select: boolean) => TileIndex
begin
    let modifier = if source_select then
        _BundleTileBindings[[binding]].source1_subview
        else _BundleTileBindings[[binding]].source0_subview;
    if modifier.materialized then return modifier.materialized_index; end;
    return if source_select then _BundleTileBindings[[binding]].source1
        else _BundleTileBindings[[binding]].source0;
end;

readonly func BundleTileArchitecturalSourceIndex(
    binding: BundleTileBindingIndex, source_select: boolean) => TileIndex
begin
    let modifier = if source_select then
        _BundleTileBindings[[binding]].source1_subview
        else _BundleTileBindings[[binding]].source0_subview;
    if modifier.valid && modifier.derived.valid then
        return modifier.derived.parent;
    end;
    return if source_select then _BundleTileBindings[[binding]].source1
        else _BundleTileBindings[[binding]].source0;
end;

func MaterializeBundleSubview(
    binding: BundleTileBindingIndex, source_select: boolean,
    descriptor: BundleSubviewDescriptor,
    operation: integer {0..PTO_TILE_OPERATION_COUNT-1}) => boolean
begin
    let parent = descriptor.parent;
    let mask = _TileAllocationMasks[[parent]];
    if mask == Zeros{4} then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let parent_hand = (parent DIVRM 16) as integer {0..3};
    var materialized_index: TileIndex = 0;
    var found = FALSE;
    for offset = 0 to 15 do
        let candidate = (parent_hand * 16 + offset) as integer {0..63};
        if !found && !_Tiles[[candidate]].allocated then
            materialized_index = candidate as TileIndex;
            found = TRUE;
        end;
    end;
    if !found then
        SetFault(Fault_TileAllocation, ReadTPC());
        return FALSE;
    end;
    // The CUBE parent is the architectural source of the CELL-order view.
    // A non-CUBE Tile handler consumes the bounded view in its ordinary
    // row-major operand representation; CUBE handlers retain the CUBE view
    // so their matrix legality and CELL geometry remain authoritative.
    let operation_is_cube = _BundleOperation.valid &&
        BundleTileDecodeFamily(_BundleOperation.operation_class) ==
            TileDecode_CUBE;
    // Matrix bias operands retain the existing handler contract: the
    // primary matrix sources remain CUBE views, while the bias source is a
    // bounded RowMajor view.  The parent is still always the accepted CUBE
    // fixture; only the materialized representation follows the authoritative
    // bias legality rule.
    var source_ordinal: integer {0..7} = 0;
    for prior = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 looplimit 64 do
        if _BundleTileBindings[[prior]].valid then
            if prior < binding then
                if _BundleTileBindings[[prior]].source0_valid then
                    source_ordinal = (source_ordinal + 1) as integer {0..7};
                end;
                if _BundleTileBindings[[prior]].source1_valid then
                    source_ordinal = (source_ordinal + 1) as integer {0..7};
                end;
            elsif prior == binding && source_select &&
                  _BundleTileBindings[[prior]].source0_valid then
                source_ordinal = (source_ordinal + 1) as integer {0..7};
            end;
        end;
    end;
    let operation_kind = if _BundleOperation.valid then
        TileOperationOfIndex(
            DecodeTileOperation(
                BundleTileDecodeFamily(_BundleOperation.operation_class),
                BundleOperationDecodeCode(_BundleOperation))
                as integer {0..PTO_TILE_OPERATION_COUNT-1})
        else TileOperation_TADD;
    let bias_source =
        (operation_kind == TileOperation_TMATMUL_BIAS && source_ordinal == 2) ||
        (operation_kind == TileOperation_TGEMV_BIAS && source_ordinal == 2) ||
        (operation_kind == TileOperation_TMATMUL_MX_BIAS && source_ordinal == 4) ||
        (operation_kind == TileOperation_TGEMV_MX_BIAS && source_ordinal == 4);
    let row_major_auxiliary = bias_source;
    if operation_is_cube && !row_major_auxiliary then
        if !ConfigureCubeTileForMask(materialized_index,
                descriptor.capacity_bytes, descriptor.valid_rows,
                descriptor.valid_columns, _Tiles[[parent]].data_type,
                _Tiles[[parent]].layout, TileLocation_Matrix, mask) then
            SetFault(Fault_TileAllocation, ReadTPC());
            return FALSE;
        end;
    else
        let row_broadcast =
            (operation_kind == TileOperation_TROWEXPAND &&
             source_ordinal == 0) ||
            ((operation_kind == TileOperation_TROWEXPANDADD ||
              operation_kind == TileOperation_TROWEXPANDSUB ||
              operation_kind == TileOperation_TROWEXPANDMUL ||
              operation_kind == TileOperation_TROWEXPANDDIV ||
              operation_kind == TileOperation_TROWEXPANDMAX ||
              operation_kind == TileOperation_TROWEXPANDMIN ||
              operation_kind == TileOperation_TROWEXPANDEXPDIF) &&
             source_ordinal == 1);
        assert descriptor.valid_columns >= 1;
        var row_major_columns: integer {1..65535} =
            if row_broadcast then 1
            else descriptor.valid_columns as integer {1..65535};
        let physical_columns_raw = UInt(_BundleDimensions[[2]]);
        if !row_broadcast && _BundleDimensionPresent[[2]] &&
           physical_columns_raw >= descriptor.valid_columns &&
           physical_columns_raw <= 65535 then
            row_major_columns =
                physical_columns_raw as integer {1..65535};
        elsif !row_broadcast then
            var candidate: integer = 1;
            for exponent = 0 to 15 do
                if candidate < descriptor.valid_columns then
                    candidate = candidate * 2;
                end;
            end;
            if candidate > 65535 then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            row_major_columns = candidate as integer {1..65535};
        end;
        let row_major_rows = DerivedTileRows(descriptor.capacity_bytes,
            row_major_columns, _Tiles[[parent]].data_type);
        if row_major_rows == 0 ||
           !TileDescriptorShapeLegal(descriptor.capacity_bytes,
               row_major_columns, descriptor.valid_rows,
               descriptor.valid_columns, _Tiles[[parent]].data_type) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        ConfigureTileForMask(materialized_index, descriptor.capacity_bytes,
            row_major_rows, row_major_columns, descriptor.valid_rows,
            descriptor.valid_columns, _Tiles[[parent]].data_type,
            TileLayout_RowMajor,
            (if operation_is_cube then TileLocation_Matrix
             else TileLocation_Any), mask);
    end;
    for row = 0 to descriptor.valid_rows - 1 looplimit 65536 do
        for column = 0 to descriptor.valid_columns - 1 looplimit 65536 do
            let source_row = (descriptor.origin_row + row)
                as integer {0..65535};
            let source_column = (descriptor.origin_column + column)
                as integer {0..65535};
            if TileElementDefined(parent, source_row, source_column) then
                WriteTileElement(materialized_index as TileIndex,
                    row as integer {0..65535}, column as integer {0..65535},
                    ReadTileElement(parent, source_row, source_column));
            end;
        end;
    end;
    // A materialized view is a derived temporary source, so its readiness
    // follows the parent validity proven by the descriptor preflight.  Keep
    // undefined parent regions undefined; a fully defined parent publishes
    // the copied valid view as a normal readable Tile source.
    if TileSourceContentsDefined(parent) then
        MarkTileValidRegionDefined(materialized_index as TileIndex);
    end;
    if source_select then
        _BundleTileBindings[[binding]].source1_subview.materialized = TRUE;
        _BundleTileBindings[[binding]].source1_subview.materialized_index =
            materialized_index as TileIndex;
        _BundleTileBindings[[binding]].source1 =
            materialized_index as TileIndex;
    else
        _BundleTileBindings[[binding]].source0_subview.materialized = TRUE;
        _BundleTileBindings[[binding]].source0_subview.materialized_index =
            materialized_index as TileIndex;
        _BundleTileBindings[[binding]].source0 =
            materialized_index as TileIndex;
    end;
    return TRUE;
end;

func DiscardBundleSubviewMaterializations()
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_subview.materialized then
                _BundleTileBindings[[binding]].source0 =
                    _BundleTileBindings[[binding]].source0_subview
                        .derived.parent;
                ReleaseTile(_BundleTileBindings[[binding]].source0_subview
                    .materialized_index);
                _BundleTileBindings[[binding]].source0_subview.materialized =
                    FALSE;
            end;
            if _BundleTileBindings[[binding]].source1_subview.materialized then
                _BundleTileBindings[[binding]].source1 =
                    _BundleTileBindings[[binding]].source1_subview
                        .derived.parent;
                ReleaseTile(_BundleTileBindings[[binding]].source1_subview
                    .materialized_index);
                _BundleTileBindings[[binding]].source1_subview.materialized =
                    FALSE;
            end;
        end;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
