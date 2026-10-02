<!-- GENERATED FROM: asl/tile/model/memory/gather-scatter.asl -->
# Gather Scatter

**Normative ASL source:** `asl/tile/model/memory/gather-scatter.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-GATHER-SCATTER}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-gather-scatter-purpose role=purpose-scope -->
## Purpose and scope

This unit owns indexed GM transfers and the prefetch body.

- `MGATHER` loads one element per index into a destination Tile.
- `MSCATTER` stores one source element per index to GM.
- `MGATHER_MASK` and `MSCATTER_MASK` add a predicate Tile that switches individual lanes off.
- `TPREFETCHCore` probes and reads a strided region for all four PEs without producing a Tile.

An index Tile holds one GM byte displacement per lane. A lane is one valid coordinate of the index Tile.

<!-- PTO-READER-BLOCK: tile-model-memory-gather-scatter-concepts role=concepts-state -->
## Concepts and visible state

The address of a lane is `base + displacement`, computed by `TileMemoryByteDisplacementAddress`. Index Tiles must be S32, U32, S64, or U64; signed indices sign-extend. The displacement is not scaled by the element size.

The data type is checked by `IndexedTLSUOrdinaryTransferDataTypeLegal`, which accepts the ordinary non-packed types and also the four-bit types. For a four-bit data type, one index addresses one byte that holds two adjacent data columns, so the data Tile has exactly twice as many valid columns as the index Tile.

A lane is active when the ExecutionMask (if any) marks it active and, for the MASK forms, bit 0 of the predicate element is 1.

<!-- PTO-READER-BLOCK: tile-model-memory-gather-scatter-rules role=rules-interactions -->
## Rules and interactions

All four indexed bodies first check their operands by assertion: defined contents, matching valid shapes (twice the index columns for four-bit data), equal layouts, and the index and data types. The two gather bodies also assert destination descriptor legality.

Design point: every body probes all active lanes before the first memory access or event. If any probe fails, the body returns with GM, memory events, and the destination Tile unchanged. The consequence is that a faulting indexed request has no partial memory effect, unlike dense `TSTORE`.

`MGATHER` then fills every physical destination element: inactive valid coordinates receive the ExecutionMask zero or merge value, and every other coordinate receives the `PadValue` for the data type. It then overwrites each active lane with the loaded value, records a load event, and marks the whole physical region defined.

Design point: the destination is fully written before publication, so `MarkTilePhysicalRegionDefined` is correct even with `PadValue` Null. `TilePadValueForDataType` gives zero bits for Null, so a Null pad publishes defined zero bits here, not undefined elements.

`MSCATTER` captures every active lane's address and value during the probe phase, then commits the stores through `CommitIndexedScatterTransactions`. For four-bit data, the two adjacent source nibbles are combined into one byte and the whole byte is stored.

Design point: the commit order is chosen by `ARBITRARY` choices, so row-major order is not guaranteed. When two lanes target the same address, which value remains is implementation-defined. Software that needs a defined result must avoid duplicate scatter addresses or use an atomic form.

`TPREFETCHCore` computes addresses with an element row stride and `TileMemoryIndexedAddress`. It probes every element of all four PEs before recording any load event, and it writes no Tile state.

<!-- PTO-READER-BLOCK: tile-model-memory-gather-scatter-boundaries role=boundaries -->
## Architectural boundaries

Bundle dispatch rejects malformed schemas, allocates the gather destination, and releases it if a fault occurs later. `B.CATR` atomic makes the whole block non-interleavable, but, as the ASL comment says, it does not choose a lane order or a duplicate-address winner.

Indexed gathers and scatters are not atomic read-modify-write operations. The atomic forms are in the atomics and GM atom/red units.

<!-- PTO-READER-BLOCK: tile-model-memory-gather-scatter-example role=example-usage -->
## Non-normative reading example

`MGATHER` of FP32 with base `0x4000` and a 1 by 4 S32 index Tile holding `0, 8, -4, 8`:

- Lane addresses are `0x4000`, `0x4008`, `0x3FFC`, and `0x4008`. All four are multiples of 4, so the 4-byte alignment probe passes.
- The two lanes at `0x4008` each read the same value; duplicate gather addresses are harmless.

`MSCATTER` of FP32 with the same index Tile and source values `1.0, 2.0, 3.0, 4.0` stores four times. The locations `0x4000` and `0x3FFC` receive `1.0` and `3.0`. Location `0x4008` ends with either `2.0` or `4.0`; the ASL does not fix which.

<!-- PTO-READER-BLOCK: tile-model-memory-gather-scatter-related role=related-owners-navigation -->
## Related owners

- [Addressing](addressing.md) owns byte-displacement and indexed address arithmetic.
- [Indexed layout legality](../legality/indexed-layout.md) owns the index and data type rules.
- [Atomics](atomics.md) owns the atomic compare-and-swap gather.
- [Execution mask state](../execution/execution-mask-state.md) owns active lanes and inactive values.
- [Memory atomicity](../../../arch/memory-model/atomicity.md) and [ordering](../../../arch/memory-model/ordering.md) own event semantics.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/gather-scatter.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GATHER-SCATTER","surface":"tile","classification":["model","memory","gather-scatter"],"depends_on":["PTO-TILE-MODEL-MEMORY-LOAD-STORE","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
readonly func IndexedGatherInactiveDestinationValue(
    row: integer {0..65535}, column: integer {0..65535}) => Word
begin
    if _BundleExecutionMask.zero_inactive then
        return Zeros{PTO_XLEN};
    end;
    assert _BundleExecutionMask.merge_base_valid;
    let base = _Tiles[[_BundleExecutionMask.merge_base]];
    let element = TileLogicalLinearIndex(base, row, column);
    return TileReadLogicalElement(base, element);
end;

func MGATHER(destination: TileIndex, base_address: Word,
             indices: TileIndex, pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    assert IndexedTLSUNumericDescriptorLegal(destination);
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUDataShapeMatchesIndex(
        destination_tile.valid_rows, destination_tile.valid_columns,
        index_tile.valid_rows, index_tile.valid_columns,
        destination_tile.data_type);
    assert destination_tile.layout == index_tile.layout;
    assert IndexedTLSUMemoryIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUOrdinaryTransferDataTypeLegal(destination_tile.data_type);
    var translated_addresses: TilePayload;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let index_element = TileStorageIndex(index_tile,
                    row as integer {0..65535},
                    column as integer {0..65535});
                let address = TileMemoryByteDisplacementAddress(base_address,
                    index_tile.payload[[index_element]], index_tile.data_type,
                    destination_tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    destination_tile.data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return; end;
                translated_addresses[[index_element]] =
                    probe.translated_address;
            end;
        end;
    end;
    var result = destination_tile;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var inactive = FALSE;
            if row < destination_tile.valid_rows &&
               column < destination_tile.valid_columns then
                let transfer_column = if TileDataTypeIsFourBit(
                    destination_tile.data_type) then column DIVRM 2 else column;
                inactive = !BundleExecutionMaskActiveAt(
                    destination_tile.layout,
                    row as integer {0..65535},
                    transfer_column as integer {0..65535});
            end;
            let value = if inactive then
                IndexedGatherInactiveDestinationValue(
                    row as integer {0..65535},
                    column as integer {0..65535})
            else TilePadValueForDataType(
                pad_value, destination_tile.data_type);
            result = TileInfoWithLogicalElementAndDefined(
                result, element, value, TRUE);
        end;
    end;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let raw = LoadTranslatedUnsigned(
                translated_addresses[[index_element]],
                TileMemoryElementBytes(destination_tile.data_type));
            RecordLoadEvent(translated_addresses[[index_element]],
                TileMemoryElementBytes(destination_tile.data_type), raw,
                CurrentBundleMemoryOrder());
            let first_column = if TileDataTypeIsFourBit(
                destination_tile.data_type) then 2 * column else column;
            let first = TileLogicalLinearIndex(result,
                row as integer {0..65535},
                first_column as integer {0..65535});
            result = TileInfoWithLogicalElementAndDefined(result, first,
                DecodeTileMemoryElementRaw(
                    raw, destination_tile.data_type, FALSE), TRUE);
            if TileDataTypeIsFourBit(destination_tile.data_type) then
                let second = TileLogicalLinearIndex(result,
                    row as integer {0..65535},
                    (first_column + 1) as integer {0..65535});
                result = TileInfoWithLogicalElementAndDefined(result, second,
                    DecodeTileMemoryElementRaw(
                        raw, destination_tile.data_type, TRUE), TRUE);
            end;
            end;
        end;
    end;
    _Tiles[[destination]] = result;
    MarkTilePhysicalRegionDefined(destination);
end;

func MGATHER(destination: TileIndex, base_address: Word, indices: TileIndex)
begin
    MGATHER(destination, base_address, indices, TilePad_Null);
end;

func CommitIndexedScatterTransactions(
    data_type: TileDataType, lane_order: ScatterLaneOrder,
    lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS},
    original_addresses: TilePayload,
    translated_addresses: TilePayload, values: TilePayload)
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
            var stored_value = values[[element]];
            if TileDataTypeIsFourBit(data_type) then
                StoreTranslated(original_addresses[[element]],
                    translated_addresses[[element]], 1, stored_value);
            else
                stored_value = StoreTileMemoryElement(
                    original_addresses[[element]],
                    translated_addresses[[element]], data_type, FALSE,
                    values[[element]]);
            end;
            RecordStoreEvent(translated_addresses[[element]],
                TileMemoryElementBytes(data_type), stored_value,
                CurrentBundleMemoryOrder());
        end;
    end;
end;

func MSCATTER(base_address: Word, source: TileIndex, indices: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    assert IndexedTLSUExecutionMaskContentsDefined(source);
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUDataShapeMatchesIndex(
        source_tile.valid_rows, source_tile.valid_columns,
        index_tile.valid_rows, index_tile.valid_columns,
        source_tile.data_type);
    assert source_tile.layout == index_tile.layout;
    assert IndexedTLSUMemoryIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUOrdinaryTransferDataTypeLegal(source_tile.data_type);
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var values: TilePayload;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[index_element]], index_tile.data_type,
                source_tile.data_type);
            let probe = ProbeTileMemoryAccess(address,
                source_tile.data_type, TRUE);
            if RaiseDataAccessFault(probe, address) then return; end;
            original_addresses[[index_element]] = address;
            translated_addresses[[index_element]] = probe.translated_address;
            let first_column = if TileDataTypeIsFourBit(source_tile.data_type)
                then 2 * column else column;
            let first = TileLogicalLinearIndex(source_tile,
                row as integer {0..65535},
                first_column as integer {0..65535});
            values[[index_element]] = TileReadLogicalElement(
                source_tile, first);
            if TileDataTypeIsFourBit(source_tile.data_type) then
                let second = TileLogicalLinearIndex(source_tile,
                    row as integer {0..65535},
                    (first_column + 1) as integer {0..65535});
                values[[index_element]][7:4] =
                    TileReadLogicalElement(source_tile, second)[3:0];
            end;
            lane_order[[lane_count]] = NaturalToWord(index_element);
            lane_count = (lane_count + 1) as
                integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    CommitIndexedScatterTransactions(source_tile.data_type, lane_order,
        lane_count, original_addresses, translated_addresses, values);
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
                  indices: TileIndex, mask: TileIndex,
                  pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let mask_tile = _Tiles[[mask]];
    assert IndexedTLSUNumericDescriptorLegal(destination);
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUPredicateValuesLegal(mask);
    assert IndexedTLSUDataShapeMatchesIndex(
        destination_tile.valid_rows, destination_tile.valid_columns,
        index_tile.valid_rows, index_tile.valid_columns,
        destination_tile.data_type);
    assert index_tile.valid_rows == mask_tile.valid_rows;
    assert index_tile.valid_columns == mask_tile.valid_columns;
    assert destination_tile.layout == index_tile.layout;
    assert destination_tile.layout == mask_tile.layout;
    assert IndexedTLSUMemoryIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUOrdinaryTransferDataTypeLegal(destination_tile.data_type);
    var translated_addresses: TilePayload;
    var active_lanes: bits(PTO_MODEL_TILE_ELEMENTS) =
        Zeros{PTO_MODEL_TILE_ELEMENTS};
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) &&
               ReadIndexedTLSUPredicate(mask,
                row as integer {0..65535},
                column as integer {0..65535}) then
                let address = TileMemoryByteDisplacementAddress(base_address,
                    index_tile.payload[[index_element]], index_tile.data_type,
                    destination_tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    destination_tile.data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then return; end;
                translated_addresses[[index_element]] = probe.translated_address;
                active_lanes[index_element] = '1';
            end;
        end;
    end;
    var result = destination_tile;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var inactive = FALSE;
            if row < destination_tile.valid_rows &&
               column < destination_tile.valid_columns then
                let transfer_column = if TileDataTypeIsFourBit(
                    destination_tile.data_type) then column DIVRM 2 else column;
                inactive = !BundleExecutionMaskActiveAt(
                    destination_tile.layout,
                    row as integer {0..65535},
                    transfer_column as integer {0..65535});
            end;
            let value = if inactive then
                IndexedGatherInactiveDestinationValue(
                    row as integer {0..65535},
                    column as integer {0..65535})
            else TilePadValueForDataType(
                pad_value, destination_tile.data_type);
            result = TileInfoWithLogicalElementAndDefined(
                result, element, value, TRUE);
        end;
    end;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if active_lanes[index_element] == '1' then
                let raw = LoadTranslatedUnsigned(
                    translated_addresses[[index_element]],
                    TileMemoryElementBytes(destination_tile.data_type));
                RecordLoadEvent(translated_addresses[[index_element]],
                    TileMemoryElementBytes(destination_tile.data_type), raw,
                    CurrentBundleMemoryOrder());
                let first_column = if TileDataTypeIsFourBit(
                    destination_tile.data_type) then 2 * column else column;
                let first = TileLogicalLinearIndex(result,
                    row as integer {0..65535},
                    first_column as integer {0..65535});
                result = TileInfoWithLogicalElementAndDefined(result, first,
                    DecodeTileMemoryElementRaw(
                        raw, destination_tile.data_type, FALSE), TRUE);
                if TileDataTypeIsFourBit(destination_tile.data_type) then
                    let second = TileLogicalLinearIndex(result,
                        row as integer {0..65535},
                        (first_column + 1) as integer {0..65535});
                    result = TileInfoWithLogicalElementAndDefined(result, second,
                        DecodeTileMemoryElementRaw(
                            raw, destination_tile.data_type, TRUE), TRUE);
                end;
            end;
        end;
    end;
    _Tiles[[destination]] = result;
    MarkTilePhysicalRegionDefined(destination);
end;

func MSCATTER_MASK(base_address: Word, source: TileIndex,
                   indices: TileIndex, mask: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    let index_tile = _Tiles[[indices]];
    let mask_tile = _Tiles[[mask]];
    assert IndexedTLSUExecutionMaskContentsDefined(source);
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUPredicateValuesLegal(mask);
    assert IndexedTLSUDataShapeMatchesIndex(
        source_tile.valid_rows, source_tile.valid_columns,
        index_tile.valid_rows, index_tile.valid_columns,
        source_tile.data_type);
    assert index_tile.valid_rows == mask_tile.valid_rows;
    assert index_tile.valid_columns == mask_tile.valid_columns;
    assert source_tile.layout == index_tile.layout;
    assert source_tile.layout == mask_tile.layout;
    assert IndexedTLSUMemoryIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUOrdinaryTransferDataTypeLegal(source_tile.data_type);
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var values: TilePayload;
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) &&
               ReadIndexedTLSUPredicate(mask,
                row as integer {0..65535},
                column as integer {0..65535}) then
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[index_element]], index_tile.data_type,
                source_tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    source_tile.data_type, TRUE);
                if RaiseDataAccessFault(probe, address) then return; end;
                original_addresses[[index_element]] = address;
                translated_addresses[[index_element]] = probe.translated_address;
                let first_column = if TileDataTypeIsFourBit(
                    source_tile.data_type) then 2 * column else column;
                let first = TileLogicalLinearIndex(source_tile,
                    row as integer {0..65535},
                    first_column as integer {0..65535});
                values[[index_element]] = TileReadLogicalElement(
                    source_tile, first);
                if TileDataTypeIsFourBit(source_tile.data_type) then
                    let second = TileLogicalLinearIndex(source_tile,
                        row as integer {0..65535},
                        (first_column + 1) as integer {0..65535});
                    values[[index_element]][7:4] =
                        TileReadLogicalElement(source_tile, second)[3:0];
                end;
                lane_order[[lane_count]] = NaturalToWord(index_element);
                lane_count = (lane_count + 1) as
                    integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    CommitIndexedScatterTransactions(source_tile.data_type, lane_order,
        lane_count, original_addresses, translated_addresses, values);
end;
```
<!-- GENERATED-ASL-END: unit -->
