<!-- GENERATED FROM: asl/tile/model/memory/load-store.asl -->
# Load Store

**Normative ASL source:** `asl/tile/model/memory/load-store.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-LOAD-STORE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-load-store-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the element-level GM access helpers and the Local `TLOAD` and `TSTORE` bodies.

- `ProbeTileMemoryAccess` checks one element access before it happens.
- `LoadTileMemoryElement` and `DecodeTileMemoryElementRaw` read and decode one element.
- `StoreTileMemoryElement` writes one element.
- `TLOAD` copies a strided GM region into a Local Tile; `TSTORE` copies a Local Tile to GM.

<!-- PTO-READER-BLOCK: tile-model-memory-load-store-concepts role=concepts-state -->
## Concepts and visible state

A probe (`DataAccessProbe`) returns a fault code and a translated address. `ProbeTileMemoryAccess` probes `TileMemoryElementBytes(data_type)` bytes with the same value as the alignment, so every element access must be naturally aligned. Four-bit types probe one byte.

A replay record is the fault-precision state from the architecture memory model. `TLOAD` and `TSTORE` open it with `BeginMemoryReplay`, mark each completed access with `CommitMemoryReplayEffect`, and close it with `CompleteMemoryReplay` on success or `FlushMemoryReplay` on a fault.

Every recorded load and store event carries `CurrentBundleMemoryOrder()`, which is derived from the bundle acquire and release attributes.

<!-- PTO-READER-BLOCK: tile-model-memory-load-store-rules role=rules-interactions -->
## Rules and interactions

Decoding: for a four-bit type, `DecodeTileMemoryElementRaw` returns the selected nibble zero-extended, for S4X2 too. For other types it sign-extends signed integer types (S8, S16, S32, S64) and leaves the raw bits unchanged otherwise.

Storing: for a type that is not four-bit, the value is truncated to the element width and written. For a four-bit type, the helper reads the containing byte, replaces one nibble, and writes the byte back.

Design point: the four-bit store is a read-modify-write of the byte. The sibling nibble keeps its old memory value, so two adjacent columns can be written by different stores without destroying each other.

`TLOAD` walks the valid region row by row. An inactive coordinate under an ExecutionMask receives the mask's zero or merge value and makes no access. An active coordinate is probed, loaded, recorded as a load event, and written into the result. After the walk the valid region is marked defined. CUBE layouts then receive the bundle `PadValue` in their physical tail.

`TSTORE` requires an allocated source whose contents are defined; under an ExecutionMask it checks only the elementwise source definedness. It stores active valid coordinates in row-major order.

Design point: both bodies stop at the first failing probe. Accesses completed before the fault are not undone: GM writes from `TSTORE` stay visible. The `TLOAD` body writes its partial result to the destination, but bundle dispatch then releases a destination that the bundle allocated. `FlushMemoryReplay` discards only event records after the last committed effect. The fault-precision contract says a retry re-executes the whole logical request, so a restart does not continue from an internal element cursor.

`TLOAD` has a fast path for four-bit Tiles that are not CUBE, have no defined valid elements yet, and have no ExecutionMask, no event capture, zero stride, a full valid region, and full packed capacity. It still probes every column of row 0 through the normal probe path and uses the shortcut only if all those bytes are zero.

<!-- PTO-READER-BLOCK: tile-model-memory-load-store-boundaries role=boundaries -->
## Architectural boundaries

Bundle dispatch allocates the `TLOAD` destination and resolves base, stride, `PE_MASK`, and dimensions before these bodies run. Schema, descriptor, and definedness failures are rejected there, before any access.

These bodies do not order `TSTORE` beats relative to each other beyond the program order of this loop, and they do not resolve overlap between PEs. Ordering belongs to the architecture memory model.

Shared `TLOAD` and `TSTORE` forms are defined in the shared-movement unit.

<!-- PTO-READER-BLOCK: tile-model-memory-load-store-example role=example-usage -->
## Non-normative reading example

`TSTORE` of a U4X2 Tile writes element `(0, 1)` with value `0x5`. The address is the row base plus 1 / 2 = 0, and column 1 is odd, so the high nibble is selected.

- The byte at that address currently holds `0xA7`.
- The helper keeps the low nibble `0x7` and replaces the high nibble with `0x5`.
- It stores `0x57`, and records a one-byte store event with value `0x57`.

For an S16 `TLOAD` at an address ending in `0x...1`, the two-byte alignment probe fails with `Fault_DataAlignment` before any byte is read for that element.

<!-- PTO-READER-BLOCK: tile-model-memory-load-store-related role=related-owners-navigation -->
## Related owners

- [Stride](stride.md) computes the strided byte addresses used here.
- [Restart](restart.md) points to the restart and precise-fault owners.
- [Fault precision](../../../arch/memory-model/fault-precision.md) owns the replay record.
- [Memory ordering](../../../arch/memory-model/ordering.md) owns the order of recorded events.
- [Scalar AGU memory](../../../scalar/model/agu/memory.md) owns `ProbeDataAccess` and the byte load and store primitives.
- [Shared movement](shared-movement.md) owns the Shared forms.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/load-store.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-LOAD-STORE","surface":"tile","classification":["model","memory","load-store"],"depends_on":["PTO-TILE-MODEL-MEMORY-STRIDE","PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA"]}
pure func DecodeTileMemoryElementRaw(raw: Word,
                                     data_type: TileDataType,
                                     high_nibble: boolean) => Word
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    if TileDataTypeIsFourBit(data_type) then
        if high_nibble then
            return ZeroExtend{PTO_XLEN}(raw[7:4]);
        else
            return ZeroExtend{PTO_XLEN}(raw[3:0]);
        end;
    else
        return NormalizeLoadedValue(raw, element_bytes,
            TileDataTypeIsSigned(data_type));
    end;
end;

readonly func LoadTileMemoryElement(translated_address: Word,
                                    data_type: TileDataType,
                                    high_nibble: boolean) => Word
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    let raw = LoadTranslatedUnsigned(translated_address, element_bytes);
    return DecodeTileMemoryElementRaw(raw, data_type, high_nibble);
end;

func StoreTileMemoryElement(original_address: Word,
                            translated_address: Word,
                            data_type: TileDataType,
                            high_nibble: boolean,
                            value: Word) => Word
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    if TileDataTypeIsFourBit(data_type) then
        let old_byte = LoadTranslatedUnsigned(translated_address, 1);
        var stored_byte: Byte = old_byte[7:0];
        if high_nibble then stored_byte[7:4] = value[3:0];
        else stored_byte[3:0] = value[3:0];
        end;
        let stored_value = ZeroExtend{PTO_XLEN}(stored_byte);
        StoreTranslated(original_address, translated_address, 1, stored_value);
        return stored_value;
    else
        let stored_value = NormalizeMemoryAccessValue(value, element_bytes);
        StoreTranslated(original_address, translated_address, element_bytes,
            stored_value);
        return stored_value;
    end;
end;

func ProbeTileMemoryAccess(address: Word, data_type: TileDataType,
                           write: boolean) => DataAccessProbe
begin
    let element_bytes = TileMemoryElementBytes(data_type);
    return ProbeDataAccess(address, element_bytes, element_bytes, write);
end;

func TLOAD(destination: TileIndex, base_address: Word,
           row_stride_bytes: Word)
begin
    let tile = _Tiles[[destination]];
    assert tile.allocated;
    if TileLayoutIsCube(tile.layout) then
        assert TileCubeDescriptorLegal(tile);
    end;
    // Complete packed carriers make the maximum U4 shape representable, but
    // an interpreter-sized translated-address array is still only a carrier
    // cache.  The fast case is limited to ordinary reset-backed zero-stride
    // packed loads and retains the normal translated probe/fault path.
    var packed_zero_fast = PackedTileDataTypeIsFourBit(tile.data_type) &&
        !_BundleExecutionMask.valid &&
        !TileLayoutIsCube(tile.layout) &&
        !_MemoryEventCaptureEnabled &&
        tile.defined_valid_elements == 0 &&
        row_stride_bytes == Zeros{PTO_XLEN} &&
        tile.valid_rows == tile.rows &&
        tile.valid_columns == tile.columns &&
        tile.rows * tile.columns ==
            PackedTileLogicalCapacity(tile.capacity_bytes, tile.data_type);
    if packed_zero_fast then
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let address = TileMemoryStridedByteAddress(base_address,
                0, column as integer {0..65535}, row_stride_bytes,
                tile.data_type);
            let probe = ProbeTileMemoryAccess(address, tile.data_type, FALSE);
            if RaiseDataAccessFault(probe, address) then return; end;
            if LoadTranslatedUnsigned(probe.translated_address,
                   TileMemoryElementBytes(tile.data_type)) !=
                   Zeros{PTO_XLEN} then
                packed_zero_fast = FALSE;
            end;
        end;
    end;
    if packed_zero_fast then
        _Tiles[[destination]] = TileWithPackedZeroValidRegionDefined(tile);
        return;
    end;
    var result = tile;
    BeginMemoryReplay(ReadBPC());
    // First-fault-only execution retains effects completed before the first
    // failing access. The destination is not marked complete until success.
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            if !BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let inactive_value = BundleExecutionMaskDestinationValue(
                    tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
                result = TileInfoWithLogicalElementAndDefined(
                    result, element, inactive_value, TRUE);
            else
            let address = TileMemoryStridedByteAddress(base_address,
                row as integer {0..65535}, column as integer {0..65535},
                row_stride_bytes, tile.data_type);
            let probe = ProbeTileMemoryAccess(address, tile.data_type, FALSE);
            if RaiseDataAccessFault(probe, address) then
                _Tiles[[destination]] = result;
                FlushMemoryReplay();
                return;
            end;
            let translated = probe.translated_address;
            let high_nibble = TileMemoryStridedByteHighNibble(
                column as integer {0..65535}, tile.data_type);
            let raw = LoadTranslatedUnsigned(translated,
                TileMemoryElementBytes(tile.data_type));
            RecordLoadEvent(translated,
                TileMemoryElementBytes(tile.data_type), raw,
                CurrentBundleMemoryOrder());
            CommitMemoryReplayEffect();
            result = TileInfoWithLogicalElement(result, element,
                DecodeTileMemoryElementRaw(raw, tile.data_type, high_nibble));
            result.defined_valid_elements =
                (result.defined_valid_elements + 1) as integer {0..524288};
            end;
        end;
    end;
    result = TileWithValidRegionDefined(result);
    if TileLayoutIsCube(result.layout) then
        result = TileWithPadding(result, CurrentBundlePadValue());
    end;
    _Tiles[[destination]] = result;
    CompleteMemoryReplay();
end;

func TSTORE(base_address: Word, row_stride_bytes: Word, source: TileIndex)
begin
    let tile = _Tiles[[source]];
    var source_contents_defined = tile.contents_defined;
    if _BundleExecutionMask.valid then
        source_contents_defined =
            TileElementwiseSourceContentsDefined(source);
    end;
    assert tile.allocated && source_contents_defined;
    if TileLayoutIsCube(tile.layout) then
        assert TileCubeDescriptorLegal(tile);
    end;
    BeginMemoryReplay(ReadBPC());
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryStridedByteAddress(base_address,
                row as integer {0..65535}, column as integer {0..65535},
                row_stride_bytes, tile.data_type);
            let probe = ProbeTileMemoryAccess(address, tile.data_type, TRUE);
            if RaiseDataAccessFault(probe, address) then
                FlushMemoryReplay();
                return;
            end;
            let translated = probe.translated_address;
            let stored_value = StoreTileMemoryElement(
                address, translated, tile.data_type,
                TileMemoryStridedByteHighNibble(
                    column as integer {0..65535}, tile.data_type),
                TileReadLogicalElement(tile, element));
            RecordStoreEvent(translated,
                TileMemoryElementBytes(tile.data_type), stored_value,
                CurrentBundleMemoryOrder());
            CommitMemoryReplayEffect();
            end;
        end;
    end;
    CompleteMemoryReplay();
end;
```
<!-- GENERATED-ASL-END: unit -->
