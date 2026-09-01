<!-- GENERATED FROM: asl/tile/model/memory/atomics.asl -->
# Atomics

**Normative ASL source:** `asl/tile/model/memory/atomics.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-ATOMICS}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/atomics.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-ATOMICS","surface":"tile","classification":["model","memory","atomics"],"depends_on":["PTO-TILE-MODEL-MEMORY-GATHER-SCATTER","PTO-ARCH-MEMORY-MODEL-ATOMICITY"]}
func MGATHER_CAS(destination: TileIndex, base_address: Word,
                 row_stride_elements: Word, indices: TileIndex,
                 expected: TileIndex, replacement: TileIndex,
                 pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let expected_payload = _Tiles[[expected]].payload;
    let replacement_payload = _Tiles[[replacement]].payload;
    assert destination_tile.allocated;
    assert index_tile.allocated && index_tile.contents_defined;
    assert _Tiles[[expected]].allocated && _Tiles[[expected]].contents_defined;
    assert _Tiles[[replacement]].allocated &&
        _Tiles[[replacement]].contents_defined;
    assert destination_tile.valid_rows == index_tile.valid_rows;
    assert destination_tile.valid_columns == index_tile.valid_columns;
    assert IndexedTLSUIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUTransferDataTypeLegal(destination_tile.data_type);
    let index_payload = index_tile.payload;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var write_translated_addresses: TilePayload;
    var expected_values: TilePayload;
    var replacement_values: TilePayload;
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var result_payload = destination_tile.payload;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let index_element = TileLinearIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let expected_element = TileLinearIndex(_Tiles[[expected]],
                row as integer {0..65535}, column as integer {0..65535});
            let replacement_element = TileLinearIndex(_Tiles[[replacement]],
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryIndexedStridedAddress(
                base_address, index_payload[[index_element]],
                index_tile.data_type, index_tile.valid_columns,
                row_stride_elements, destination_tile.data_type);
            let read_probe = ProbeTileMemoryAccess(address,
                destination_tile.data_type, FALSE);
            if RaiseDataAccessFault(read_probe, address) then return; end;
            let write_probe = ProbeTileMemoryAccess(address,
                destination_tile.data_type, TRUE);
            if RaiseDataAccessFault(write_probe, address) then return; end;
            if read_probe.translated_address != write_probe.translated_address then
                SetFault(Fault_DataPage, address);
                return;
            end;
            original_addresses[[destination_element]] = address;
            translated_addresses[[destination_element]] =
                read_probe.translated_address;
            write_translated_addresses[[destination_element]] =
                write_probe.translated_address;
            expected_values[[destination_element]] =
                expected_payload[[expected_element]];
            replacement_values[[destination_element]] =
                replacement_payload[[replacement_element]];
            lane_order[[lane_count]] = NaturalToWord(destination_element);
            lane_count = (lane_count + 1) as
                integer {0..PTO_MODEL_TILE_ELEMENTS};
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
    // Duplicate addresses are serialized in an implementation-defined order.
    // Each selected lane remains one atomic read-modify-write, but neither
    // row-major order nor another fixed order becomes architectural.
    for position = 0 to lane_count - 1 looplimit PTO_MODEL_TILE_ELEMENTS do
            var selected_position:
                integer {0..PTO_MODEL_TILE_ELEMENTS-1} =
                    position as integer {0..PTO_MODEL_TILE_ELEMENTS-1};
            var selected = FALSE;
            for candidate_position = position to lane_count - 1
                looplimit PTO_MODEL_TILE_ELEMENTS do
                if !selected && ARBITRARY: boolean then
                    selected_position = candidate_position as
                        integer {0..PTO_MODEL_TILE_ELEMENTS-1};
                    selected = TRUE;
                end;
            end;
            let selected_element = lane_order[[selected_position]];
            lane_order[[selected_position]] = lane_order[[position]];
            lane_order[[position]] = selected_element;
            let element = UInt(lane_order[[position]]) as
                ModelTileElementIndex;
            let old_raw = LoadTranslatedUnsigned(
                translated_addresses[[element]],
                TileMemoryElementBytes(destination_tile.data_type));
            let old_value = DecodeTileMemoryElementRaw(
                old_raw, destination_tile.data_type, FALSE);
            result_payload[[element]] = old_value;
            let succeeds = NormalizeMemoryAccessValue(old_value,
                TileMemoryElementBytes(destination_tile.data_type)) ==
                NormalizeMemoryAccessValue(expected_values[[element]],
                    TileMemoryElementBytes(destination_tile.data_type));
            let write_value = NormalizeMemoryAccessValue(
                replacement_values[[element]],
                TileMemoryElementBytes(destination_tile.data_type));
            if succeeds then
                - = StoreTileMemoryElement(original_addresses[[element]],
                    write_translated_addresses[[element]],
                    destination_tile.data_type, FALSE,
                    replacement_values[[element]]);
            end;
            RecordAtomicEvent(write_translated_addresses[[element]],
                TileMemoryElementBytes(destination_tile.data_type), old_raw,
                write_value, CurrentBundleMemoryOrder(), succeeds);
    end;
    _Tiles[[destination]].payload = result_payload;
    MarkTilePhysicalRegionDefined(destination);
end;

func MGATHER_CAS(destination: TileIndex, base_address: Word,
                 row_stride_elements: Word, indices: TileIndex,
                 expected: TileIndex,
                 replacement: TileIndex)
begin
    MGATHER_CAS(destination, base_address, row_stride_elements, indices,
        expected, replacement, TilePad_Null);
end;
```
<!-- GENERATED-ASL-END: unit -->
