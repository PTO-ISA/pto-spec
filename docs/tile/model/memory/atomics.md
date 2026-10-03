<!-- GENERATED FROM: asl/tile/model/memory/atomics.asl -->
# Atomics

**Normative ASL source:** `asl/tile/model/memory/atomics.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-ATOMICS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-atomics-purpose role=purpose-scope -->
## Purpose and scope

This unit owns `MGATHER_CAS`, the indexed atomic compare-and-swap gather. For each active lane it reads a GM element, compares it with an expected value, writes a replacement if they are equal, and returns the value it observed in a destination Tile.

A second overload without a `pad_value` argument calls the first with `TilePad_Null`.

<!-- PTO-READER-BLOCK: tile-model-memory-atomics-concepts role=concepts-state -->
## Concepts and visible state

`MGATHER_CAS` takes four Tiles, one base address, and a pad value:

- `indices` holds a byte displacement per lane (S32, U32, S64, or U64).
- `expected` and `replacement` hold the compare value and the new value per lane.
- `destination` receives the old value observed by each lane.

An atomic event is one read-modify-write on one address. `RecordAtomicEvent` records the old raw value, the value that would be written, the bundle memory order, and whether the write happened.

The block dispatcher for Function 8 accepts only U16, U32, and U64 transfer types. The assertions in this body are weaker: `IndexedTLSUTransferDataTypeLegal` only excludes four-bit types.

<!-- PTO-READER-BLOCK: tile-model-memory-atomics-rules role=rules-interactions -->
## Rules and interactions

Phase 1, preflight: for every active lane the body computes `base + displacement`, probes it for read and then for write, and faults with `Fault_DataPage` if the two translations differ. It records addresses and snapshots the expected and replacement values.

Phase 2, initialization: every physical destination element receives the pad value, except inactive valid coordinates, which receive the ExecutionMask zero or merge value.

Phase 3, atomic updates: lanes are processed in an order chosen by `ARBITRARY` choices. Each lane loads the old value, stores it in the destination, compares it with `expected` at element width, stores `replacement` only on a match, and records one atomic event. Finally the whole physical region is marked defined.

Design point: all read and write probes complete before the first atomic effect (NDF `PTO-MGATHER-CAS-PUBLICATION-001`). A fault therefore leaves GM unchanged and produces no atomic event. Bundle dispatch then releases the destination it allocated.

Design point: expected and replacement values are snapshotted in phase 1. If one of those Tiles is also the destination, phase 2 and phase 3 writes cannot change the values being compared.

Design point: duplicate addresses serialize in an implementation-defined order, and row-major order is not architectural (NDF `PTO-MGATHER-CAS-ATOMIC-001`). Each lane is still one complete atomic read-modify-write, so each lane observes the value left by whichever lane ran before it.

<!-- PTO-READER-BLOCK: tile-model-memory-atomics-boundaries role=boundaries -->
## Architectural boundaries

Atomicity is per lane. The body does not make the whole request atomic, and it does not add ordering beyond the per-lane events tagged with `CurrentBundleMemoryOrder()`. The memory-model atomicity and ordering units own those event rules.

The generic GM atom/red family has its own CAS path, `GM_ATOM_CAS`. In the current block dispatcher, Function 8 is recognized by the `MGATHER_CAS` selector first and reaches the body in this unit.

<!-- PTO-READER-BLOCK: tile-model-memory-atomics-example role=example-usage -->
## Non-normative reading example

U32 `MGATHER_CAS` with base `0x8000` and a 1 by 2 index Tile holding `0, 0`. GM at `0x8000` holds 5. Lane 0 has expected 5 and replacement 9; lane 1 has expected 5 and replacement 3.

Both lanes target `0x8000`, so the ASL allows either order.

- Lane 0 first: it observes 5, matches, and writes 9. Lane 1 observes 9, fails, and writes nothing. The destination is `5, 9` and GM ends at 9.
- Lane 1 first: it observes 5 and writes 3. Lane 0 observes 3 and fails. The destination is `3, 5` and GM ends at 3.

Both outcomes record two atomic events, one with the write performed and one without.

<!-- PTO-READER-BLOCK: tile-model-memory-atomics-related role=related-owners-navigation -->
## Related owners

- [GM atom/red](gm-atom-red.md) and [GM atom/red execution](gm-atom-red-execution.md) own the other atomic operations.
- [Gather and scatter](gather-scatter.md) owns the non-atomic indexed transfers.
- [Memory atomicity](../../../arch/memory-model/atomicity.md) owns atomic events.
- [Memory ordering](../../../arch/memory-model/ordering.md) owns atomic ordering points.
- [MGATHER_CAS](../../memory-and-data-movement/irregular/MGATHER_CAS.md) is the instruction page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/atomics.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-ATOMICS","surface":"tile","classification":["model","memory","atomics"],"depends_on":["PTO-TILE-MODEL-MEMORY-GATHER-SCATTER","PTO-ARCH-MEMORY-MODEL-ATOMICITY","PTO-TILE-MODEL-LEGALITY-MEMORY-SCHEMA","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
func MGATHER_CAS(destination: TileIndex, base_address: Word,
                 indices: TileIndex,
                 expected: TileIndex, replacement: TileIndex,
                 pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let expected_payload = _Tiles[[expected]].payload;
    let replacement_payload = _Tiles[[replacement]].payload;
    assert IndexedTLSUNumericDescriptorLegal(destination);
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUExecutionMaskContentsDefined(expected);
    assert IndexedTLSUExecutionMaskContentsDefined(replacement);
    assert destination_tile.valid_rows == index_tile.valid_rows;
    assert destination_tile.valid_columns == index_tile.valid_columns;
    assert IndexedTLSUMemoryIndexDataTypeLegal(index_tile.data_type);
    assert IndexedTLSUTransferDataTypeLegal(destination_tile.data_type);
    let index_payload = index_tile.payload;
    var original_addresses: TilePayload;
    var translated_addresses: TilePayload;
    var write_translated_addresses: TilePayload;
    var expected_values: TilePayload;
    var replacement_values: TilePayload;
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    var result = destination_tile;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   destination_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let destination_element = TileStorageIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let expected_element = TileStorageIndex(_Tiles[[expected]],
                row as integer {0..65535}, column as integer {0..65535});
            let replacement_element = TileStorageIndex(_Tiles[[replacement]],
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_payload[[index_element]], index_tile.data_type);
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
    end;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var inactive = FALSE;
            if row < destination_tile.valid_rows &&
               column < destination_tile.valid_columns then
                inactive = !BundleExecutionMaskActiveAt(
                    destination_tile.layout,
                    row as integer {0..65535},
                    column as integer {0..65535});
            end;
            let initial_value = if inactive then
                BundleExecutionMaskDestinationValue(
                    destination_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN})
            else TilePadValueForDataType(
                pad_value, destination_tile.data_type);
            result = TileInfoWithLogicalElementAndDefined(
                result, element, initial_value, TRUE);
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
            result = TileInfoWithLogicalElementAndDefined(result,
                element as PackedTileElementIndex, old_value, TRUE);
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
    _Tiles[[destination]] = result;
    MarkTilePhysicalRegionDefined(destination);
end;

func MGATHER_CAS(destination: TileIndex, base_address: Word,
                 indices: TileIndex,
                 expected: TileIndex,
                 replacement: TileIndex)
begin
    MGATHER_CAS(destination, base_address, indices, expected, replacement,
        TilePad_Null);
end;
```
<!-- GENERATED-ASL-END: unit -->
