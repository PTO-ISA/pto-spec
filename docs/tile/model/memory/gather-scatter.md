<!-- GENERATED FROM: asl/tile/model/memory/gather-scatter.asl -->
# Gather Scatter

**Normative ASL source:** `asl/tile/model/memory/gather-scatter.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-GATHER-SCATTER}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/gather-scatter.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GATHER-SCATTER","surface":"tile","classification":["model","memory","gather-scatter"],"depends_on":["PTO-TILE-MODEL-MEMORY-LOAD-STORE"]}
func MGATHER(destination: TileIndex, base_address: Word,
             row_stride_elements: Word, indices: TileIndex,
             pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    assert destination_tile.allocated;
    assert index_tile.allocated && index_tile.contents_defined;
    assert CurrentBundleIndexedTLSUModeLegal();
    assert IndexedTLSUIndexShapeLegal(destination, indices);
    assert index_tile.layout == TileLayout_RowMajor;
    assert IndexedTLSUIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUTransferDataTypeLegal(destination_tile.data_type);
    let index_payload = index_tile.payload;
    let element_mode = CurrentBundleIndexedTLSUUsesElementIndices();
    var translated_addresses: TilePayload;
    var result_payload = destination_tile.payload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let index_element = if element_mode then
                TileLinearIndex(index_tile,
                    row as integer {0..65535},
                    column as integer {0..65535})
                else TileLinearIndex(index_tile, 0,
                    row as integer {0..65535});
            let address = if element_mode then
                TileMemoryRelativeElementAddress(
                    base_address, index_payload[[index_element]],
                    index_tile.data_type, destination_tile.data_type)
                else TileMemoryRelativeRowAddress(
                    base_address, index_payload[[index_element]],
                    index_tile.data_type, column as integer {0..65535},
                    row_stride_elements, destination_tile.data_type);
            let probe = ProbeTileMemoryAccess(address,
                destination_tile.data_type, FALSE);
            if RaiseDataAccessFault(probe, address) then return; end;
            translated_addresses[[destination_element]] =
                probe.translated_address;
        end;
    end;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            result_payload[[element]] = TilePadValueForDataType(
                pad_value, destination_tile.data_type);
        end;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let raw = LoadTranslatedUnsigned(translated_addresses[[element]],
                TileMemoryElementBytes(destination_tile.data_type));
            RecordLoadEvent(translated_addresses[[element]],
                TileMemoryElementBytes(destination_tile.data_type), raw,
                CurrentBundleMemoryOrder());
            result_payload[[element]] = DecodeTileMemoryElementRaw(
                raw, destination_tile.data_type, FALSE);
        end;
    end;
    _Tiles[[destination]].payload = result_payload;
    MarkTilePhysicalRegionDefined(destination);
end;

func MGATHER(destination: TileIndex, base_address: Word,
             row_stride_elements: Word, indices: TileIndex)
begin
    MGATHER(destination, base_address, row_stride_elements, indices,
        TilePad_Null);
end;

func CommitScatterLanes(source_tile: TileInfo,
                        source_payload: TilePayload,
                        lane_order: ScatterLaneOrder,
                        lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS},
                        original_addresses: TilePayload,
                        translated_addresses: TilePayload,
                        high_nibbles: bits(PTO_MODEL_TILE_ELEMENTS))
begin
    // Duplicate-address lanes have an implementation-defined winner.  B.CATR
    // atomic makes the whole block non-interleavable, but does not select an
    // internal lane order or a duplicate-address winner.
    var commit_order = lane_order;
    if lane_count > 0 then
        for position = 0 to lane_count - 1
            looplimit PTO_MODEL_TILE_ELEMENTS do
            var selected_position:
                integer {0..PTO_MODEL_TILE_ELEMENTS-1} =
                    position as integer {0..PTO_MODEL_TILE_ELEMENTS-1};
            var selected = FALSE;
            for candidate_position = position to lane_count - 1
                looplimit PTO_MODEL_TILE_ELEMENTS do
                if !selected then
                    if ARBITRARY: boolean then
                        selected_position = candidate_position as
                            integer {0..PTO_MODEL_TILE_ELEMENTS-1};
                        selected = TRUE;
                    end;
                end;
            end;
            let selected_element = commit_order[[selected_position]];
            commit_order[[selected_position]] = commit_order[[position]];
            commit_order[[position]] = selected_element;
            let element = UInt(commit_order[[position]]) as
                ModelTileElementIndex;
            let stored_value = StoreTileMemoryElement(
                original_addresses[[element]], translated_addresses[[element]],
                source_tile.data_type, high_nibbles[element] == '1',
                source_payload[[element]]);
            RecordStoreEvent(translated_addresses[[element]],
                TileMemoryElementBytes(source_tile.data_type), stored_value,
                CurrentBundleMemoryOrder());
        end;
    end;
end;

func MSCATTER(base_address: Word, row_stride_elements: Word,
              source: TileIndex, indices: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    assert source_tile.allocated && source_tile.contents_defined;
    assert index_tile.allocated && index_tile.contents_defined;
    assert CurrentBundleIndexedTLSUModeLegal();
    assert IndexedTLSUIndexShapeLegal(source, indices);
    assert index_tile.layout == TileLayout_RowMajor;
    assert IndexedTLSUIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUTransferDataTypeLegal(source_tile.data_type);
    let source_payload = source_tile.payload;
    let index_payload = index_tile.payload;
    let element_mode = CurrentBundleIndexedTLSUUsesElementIndices();
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var high_nibbles: bits(PTO_MODEL_TILE_ELEMENTS);
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let index_element = if element_mode then
                TileLinearIndex(index_tile,
                    row as integer {0..65535},
                    column as integer {0..65535})
                else TileLinearIndex(index_tile, 0,
                    row as integer {0..65535});
            let address = if element_mode then
                TileMemoryRelativeElementAddress(
                    base_address, index_payload[[index_element]],
                    index_tile.data_type, source_tile.data_type)
                else TileMemoryRelativeRowAddress(
                    base_address, index_payload[[index_element]],
                    index_tile.data_type, column as integer {0..65535},
                    row_stride_elements, source_tile.data_type);
            let probe = ProbeTileMemoryAccess(address,
                source_tile.data_type, TRUE);
            if RaiseDataAccessFault(probe, address) then return; end;
            original_addresses[[source_element]] = address;
            translated_addresses[[source_element]] = probe.translated_address;
            high_nibbles[source_element] = '0';
            lane_order[[lane_count]] =
                NaturalToWord(source_element as integer {0..262144});
            lane_count = (lane_count + 1) as
                integer {0..PTO_MODEL_TILE_ELEMENTS};
        end;
    end;
    CommitScatterLanes(source_tile, source_payload, lane_order, lane_count,
        original_addresses, translated_addresses, high_nibbles);
end;

type CorePEPrefetchAddresses of array [[PTO_MODEL_MEMORY_AGENTS]] of TilePayload;

func TPREFETCHCore(base_addresses: CorePEWords,
                   row_stride_elements: CorePEWords,
                   valid_columns: integer {1..65535},
                   valid_rows: integer {1..65535},
                   columns: integer {1..65535},
                   data_type: TileDataType)
begin
    assert valid_columns <= columns;
    assert IsNonzeroPowerOfTwo(columns);
    assert valid_rows * valid_columns <= PTO_MODEL_TILE_ELEMENTS;
    var translated_addresses: CorePEPrefetchAddresses;
    // TPREFETCH is one four-PE block attempt.  Probe every typed element of
    // every PE before recording the first event so a fault cannot expose a
    // partial request or event prefix from an earlier PE.
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        for row = 0 to valid_rows - 1 looplimit 65536 do
            for column = 0 to valid_columns - 1 looplimit 65536 do
                let element = (row * valid_columns + column) as
                    ModelTileElementIndex;
                let memory_index = TileMemoryStridedIndex(
                    row as integer {0..65535},
                    column as integer {0..65535},
                    row_stride_elements[[agent]]);
                let address = TileMemoryIndexedAddress(
                    base_addresses[[agent]], memory_index, data_type);
                let probe = ProbeTileMemoryAccess(address, data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return; end;
                translated_addresses[[agent]][[element]] =
                    probe.translated_address;
            end;
        end;
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        for row = 0 to valid_rows - 1 looplimit 65536 do
            for column = 0 to valid_columns - 1 looplimit 65536 do
                let element = (row * valid_columns + column) as
                    ModelTileElementIndex;
                let translated_address =
                    translated_addresses[[agent]][[element]];
                let value = LoadTranslatedUnsigned(translated_address,
                    TileMemoryElementBytes(data_type));
                RecordLoadEventForAgent(agent, translated_address,
                    TileMemoryElementBytes(data_type), value,
                    CurrentBundleMemoryOrder());
            end;
        end;
    end;
end;

// The generated direct-operation dispatcher carries one decoded base and
// stride value.  Its wrapper applies those values to all four PEs; complete
// architectural bundles use ExecuteBundleTPREFETCHOperation below to read the
// same selectors independently from each PE-private GPR file.
func TPREFETCHAllPEs(base_address: Word, row_stride_elements: Word,
                     valid_columns: integer {1..65535},
                     valid_rows: integer {1..65535},
                     columns: integer {1..65535},
                     data_type: TileDataType)
begin
    var base_addresses: CorePEWords;
    var row_strides: CorePEWords;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        base_addresses[[agent]] = base_address;
        row_strides[[agent]] = row_stride_elements;
    end;
    TPREFETCHCore(base_addresses, row_strides, valid_columns, valid_rows,
        columns, data_type);
end;

func TPREFETCH(base_address: Word, row_stride_elements: Word,
               valid_columns: integer {1..65535},
               valid_rows: integer {1..65535},
               columns: integer {1..65535})
begin
    TPREFETCHAllPEs(base_address, row_stride_elements, valid_columns,
        valid_rows, columns, TileDataTypeFromEncoding(
            CurrentBundleTileOperationDataTypeCode()
                as TileDataTypeEncoding));
end;

func MGATHER_MASK(destination: TileIndex, base_address: Word,
                  row_stride_elements: Word, indices: TileIndex,
                  mask: TileIndex, pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let mask_tile = _Tiles[[mask]];
    assert destination_tile.allocated;
    assert index_tile.allocated && index_tile.contents_defined;
    assert mask_tile.allocated && mask_tile.contents_defined;
    assert CurrentBundleIndexedTLSUModeLegal();
    assert IndexedTLSUIndexShapeLegal(destination, indices);
    assert destination_tile.valid_rows == mask_tile.valid_rows;
    assert destination_tile.valid_columns == mask_tile.valid_columns;
    assert index_tile.layout == TileLayout_RowMajor;
    assert destination_tile.layout == mask_tile.layout;
    assert IndexedTLSUIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUTransferDataTypeLegal(destination_tile.data_type);
    assert TilePredicateValuesLegal(mask);
    let index_payload = index_tile.payload;
    let element_mode = CurrentBundleIndexedTLSUUsesElementIndices();
    var translated_addresses: TilePayload;
    var active_lanes: bits(PTO_MODEL_TILE_ELEMENTS) =
        Zeros{PTO_MODEL_TILE_ELEMENTS};
    var result_payload = destination_tile.payload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if ReadTilePredicateBit(
                mask,
                row as integer {0..65535},
                column as integer {0..65535}) then
                let index_element = if element_mode then
                    TileLinearIndex(index_tile,
                        row as integer {0..65535},
                        column as integer {0..65535})
                    else TileLinearIndex(index_tile, 0,
                        row as integer {0..65535});
                let address = if element_mode then
                    TileMemoryRelativeElementAddress(
                        base_address, index_payload[[index_element]],
                        index_tile.data_type, destination_tile.data_type)
                    else TileMemoryRelativeRowAddress(
                        base_address, index_payload[[index_element]],
                        index_tile.data_type, column as integer {0..65535},
                        row_stride_elements, destination_tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    destination_tile.data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return; end;
                translated_addresses[[destination_element]] =
                    probe.translated_address;
                active_lanes[destination_element] = '1';
            end;
        end;
    end;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            result_payload[[element]] = TilePadValueForDataType(
                pad_value, destination_tile.data_type);
        end;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if active_lanes[element] == '1' then
                let raw = LoadTranslatedUnsigned(translated_addresses[[element]],
                    TileMemoryElementBytes(destination_tile.data_type));
                RecordLoadEvent(translated_addresses[[element]],
                    TileMemoryElementBytes(destination_tile.data_type), raw,
                    CurrentBundleMemoryOrder());
                result_payload[[element]] = DecodeTileMemoryElementRaw(
                    raw, destination_tile.data_type, FALSE);
            end;
        end;
    end;
    _Tiles[[destination]].payload = result_payload;
    MarkTilePhysicalRegionDefined(destination);
end;

func MSCATTER_MASK(base_address: Word, row_stride_elements: Word,
                   source: TileIndex, indices: TileIndex, mask: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    let mask_tile = _Tiles[[mask]];
    assert source_tile.allocated && source_tile.contents_defined;
    assert index_tile.allocated && index_tile.contents_defined;
    assert mask_tile.allocated && mask_tile.contents_defined;
    assert CurrentBundleIndexedTLSUModeLegal();
    assert IndexedTLSUIndexShapeLegal(source, indices);
    assert source_tile.valid_rows == mask_tile.valid_rows;
    assert source_tile.valid_columns == mask_tile.valid_columns;
    assert index_tile.layout == TileLayout_RowMajor;
    assert source_tile.layout == mask_tile.layout;
    assert IndexedTLSUIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUTransferDataTypeLegal(source_tile.data_type);
    assert TilePredicateValuesLegal(mask);
    let source_payload = source_tile.payload;
    let index_payload = index_tile.payload;
    let element_mode = CurrentBundleIndexedTLSUUsesElementIndices();
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var high_nibbles: bits(PTO_MODEL_TILE_ELEMENTS);
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if ReadTilePredicateBit(
                mask,
                row as integer {0..65535},
                column as integer {0..65535}) then
                let index_element = if element_mode then
                    TileLinearIndex(index_tile,
                        row as integer {0..65535},
                        column as integer {0..65535})
                    else TileLinearIndex(index_tile, 0,
                        row as integer {0..65535});
                let address = if element_mode then
                    TileMemoryRelativeElementAddress(
                        base_address, index_payload[[index_element]],
                        index_tile.data_type, source_tile.data_type)
                    else TileMemoryRelativeRowAddress(
                        base_address, index_payload[[index_element]],
                        index_tile.data_type, column as integer {0..65535},
                        row_stride_elements, source_tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    source_tile.data_type, TRUE);
                if RaiseDataAccessFault(probe, address) then return; end;
                original_addresses[[source_element]] = address;
                translated_addresses[[source_element]] =
                    probe.translated_address;
                high_nibbles[source_element] = '0';
                lane_order[[lane_count]] =
                    NaturalToWord(source_element as integer {0..262144});
                lane_count = (lane_count + 1) as
                    integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    CommitScatterLanes(source_tile, source_payload, lane_order, lane_count,
        original_addresses, translated_addresses, high_nibbles);
end;
```
<!-- GENERATED-ASL-END: unit -->
