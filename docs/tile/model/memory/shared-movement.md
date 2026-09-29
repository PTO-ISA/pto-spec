<!-- GENERATED FROM: asl/tile/model/memory/shared-movement.asl -->
# Shared Movement

**Normative ASL source:** `asl/tile/model/memory/shared-movement.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-purpose role=purpose-scope -->
## Purpose and scope

This unit owns data movement that involves Shared Tile registers or more than one PE, plus the Local copy helpers `TMOV` and `GMOV`.

- `TLOADShared` loads GM into a Shared Tile record, with per-PE base and stride.
- `TSTOREShared` and `TSTORESharedPerPE` store a Shared Tile to GM from each selected PE.
- `TMOVLocalToShared` copies a Local Tile into a Shared record.
- `TMOVSharedToLocal` and `TMOVSharedToLocalPerPE` copy Shared data into a Local Tile.
- `TMOV` copies one Local Tile to another; `GMOV` copies a peer snapshot into a Local Tile.

It also defines `ScatterLaneOrder` and `CorePETileInfos`, types used by the indexed and per-PE bodies.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-concepts role=concepts-state -->
## Concepts and visible state

A Core has four PEs. `PE_MASK` is four bits, and PE `p` is bit `3 - p` (`PTOPEMaskBitOfPEIdentity`), so `1000` is PE0.

A Shared Tile is split into four byte quarters. `SharedTileElementRegion` returns the quarter of an element: its byte offset times 4, divided by the capacity, rounded down. In a multi-PE load, quarter `q` is loaded by PE `q` using that PE's base and stride.

A single-issuer load has exactly one mask bit set. That PE loads every valid element.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-rules role=rules-interactions -->
## Rules and interactions

`PE_MASK=0000` returns immediately in every Shared helper, before any check.

`TLOADShared` builds a fresh descriptor and raises `Fault_TileLegality` if the shape does not fit the size code or is incompatible with the existing record. It then loads each selected valid element with byte-strided addressing and records a load event for the loading PE. It marks the contents complete only for a single issuer or mask `1111`, and installs the record with `AtomicUpdateSharedTile`.

Design point: `AtomicUpdateSharedTileWithPublication` changes a Shared record with one complete record assignment, which the ASL names the architectural commit point. `TLOADShared` builds its candidate in a local copy and installs it with one such update, so no half-assigned record is visible.

On a probe fault in its per-element load loop, `TLOADShared` installs the record it has built so far and returns; loads completed before the fault remain in that record.

`TSTOREShared` visits selected PEs in order 0 to 3 and stores the full valid region from each PE's own base and stride. The first fault stops the whole request; stores already done stay visible.

`TMOVLocalToShared` with `publish` set requires the prospective record to be fully initialized, and faults with `Fault_TileLegality` otherwise.

`TMOVSharedToLocal` requires an exact descriptor match and copies every physical element. Each participating consumer sees the same complete parent; the mask selects consumers, not quarters.

`TMOV` copies payload and definedness from source to destination. Under an ExecutionMask, inactive valid coordinates get the mask zero or merge value.

`GMOV` asserts `peer_tid < 4` and copies payload and definedness from a snapshot; it makes no Shared or GM access.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-boundaries role=boundaries -->
## Architectural boundaries

The Shared-TLSU block dispatcher resolves per-PE GPRs, subviews, and Shared readiness before calling these helpers, and it handles `B.ASSEMBLE` generation candidates around `TLOADShared`. The shared-registers unit owns the record fields, compatibility, and publication rules.

These helpers use stop-at-first-fault behavior. They do not probe the whole footprint first.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-example role=example-usage -->
## Non-normative reading example

A Shared FP32 Tile has capacity 4096 bytes. Element 700 has bit offset 700 x 32 = 22400, which is byte 2800.

- Its quarter is 2800 x 4 / 4096 = 2 (rounded down), so PE2 owns it.
- PE2 is mask bit 3 - 2 = 1, so the multi-PE mask `PE_MASK=0011` selects this element and `0101` does not.
- With `PE_MASK=1111`, PE2 loads it from PE2's base address plus row times PE2's stride, plus column times 4.

With `PE_MASK=0010` alone, the load is single-issuer, so PE2 loads all valid elements, including element 700.

<!-- PTO-READER-BLOCK: tile-model-memory-shared-movement-related role=related-owners-navigation -->
## Related owners

- [Shared registers](../state/shared-registers.md) owns the Shared record and its publication.
- [Stride](stride.md) owns the byte-strided addresses.
- [Load and store](load-store.md) owns the Local forms and the probe.
- [Shared TLSU dispatch](../../../block/model/dispatch/shared-tlsu.md) calls these helpers.
- [Global memory access](../../../arch/memory-model/global-memory-access.md) owns GM access rules.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/shared-movement.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT","surface":"tile","classification":["model","memory","shared-movement"],"depends_on":["PTO-TILE-MODEL-STATE-SHARED-REGISTERS","PTO-SCALAR-MODEL-AGU-MEMORY","PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA"]}
// PTO-REQ-TLSU-001, PTO-REQ-MEMORY-COMPLETION-001,
// PTO-REQ-MEMORY-RC-001: precise, restartable direct
// TLOAD/TSTORE/MGATHER/MSCATTER and destination-free TPREFETCH.

type ScatterLaneOrder of array [[PTO_MODEL_TILE_ELEMENTS]] of Word;
type CorePETileInfos of array [[PTO_MODEL_MEMORY_AGENTS]] of TileInfo;

readonly func SharedTileElementRegion(tile: TileInfo,
                                  element: PackedTileElementIndex)
                                  => integer {0..3}
begin
    let bit_offset: integer = element * TileElementBits(tile.data_type);
    let byte_offset: integer = bit_offset DIVRM 8;
    assert byte_offset < tile.capacity_bytes;
    return ((byte_offset * 4) DIVRM tile.capacity_bytes)
        as integer {0..3};
end;

func SharedTileFromLocal(source: TileIndex,
                         capacity_bytes: integer {128,256,512,1024,2048,4096,8192,
                                                  16384,32768,65536,131072,
                                                  262144})
                         => TileInfo
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated && source_tile.contents_defined;
    assert source_tile.capacity_bytes == capacity_bytes;
    var result = source_tile;
    return result;
end;

func TMOVLocalToShared(shared_tile_id: SharedTileID, source: TileIndex,
                       size_code: integer {1..12}, pe_mask: bits(4),
                       publish: boolean)
begin
    if pe_mask == Zeros{4} then return; end;
    let capacity_bytes = TileSizeCodeBytes(size_code);
    let shared_tile = SharedTileFromLocal(source, capacity_bytes);
    if publish && !SharedTileProspectiveFullyInitialized(
            shared_tile_id, shared_tile, pe_mask) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    let updated = AtomicUpdateSharedTileWithPublication(
        shared_tile_id, shared_tile, pe_mask, publish);
    if !updated then SetFault(Fault_TileLegality, ReadTPC()); end;
end;

func TMOVSharedToLocal(destination: TileIndex, shared_tile_id: SharedTileID,
                       shared_tile: TileInfo, pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    let destination_tile = _Tiles[[destination]];
    assert destination_tile.capacity_bytes == shared_tile.capacity_bytes;
    assert destination_tile.rows == shared_tile.rows &&
           destination_tile.columns == shared_tile.columns &&
           destination_tile.valid_rows == shared_tile.valid_rows &&
           destination_tile.valid_columns == shared_tile.valid_columns &&
           destination_tile.data_type == shared_tile.data_type &&
           destination_tile.layout == shared_tile.layout;
    // PE_MASK selects consumer PEs, not payload quarters. Every participating
    // consumer observes the same complete published parent when no B.SUBVIEW
    // narrows the source range.
    for element = 0 to shared_tile.rows * shared_tile.columns - 1
        looplimit 524288 do
        _Tiles[[destination]] = TileInfoWithLogicalElement(
            _Tiles[[destination]], element as PackedTileElementIndex,
            ReadSharedTileWord(shared_tile_id,
                element as PackedTileElementIndex));
    end;
    _Tiles[[destination]].contents_defined = TRUE;
    MarkTileValidRegionDefined(destination);
end;

func TLOADShared(shared_tile_id: SharedTileID, base_addresses: CorePEWords,
                 row_stride_bytes: CorePEWords,
                 size_code: integer {1..12},
                 rows: integer {1..65535}, columns: integer {1..65535},
                 valid_rows: integer {1..65535},
                 valid_columns: integer {1..65535},
                 data_type: TileDataType, layout: TileLayout,
                 pe_mask: bits(4))
begin
    let zero_packed_tile_elements = ZeroPackedTileDefinedElements();
    if pe_mask == Zeros{4} then return; end;
    let capacity_bytes = TileSizeCodeBytes(size_code);
    if rows < valid_rows || rows >
           DerivedTileRows(capacity_bytes, columns, data_type) ||
       !TileDescriptorShapeLegal(capacity_bytes, columns, valid_rows,
           valid_columns, data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    let derived_rows = DerivedTileRows(capacity_bytes, columns, data_type);
    if derived_rows * columns >
           TileLogicalElementCapacity(capacity_bytes, data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    var tile: TileInfo;
    tile.allocated = TRUE;
    tile.contents_defined = FALSE;
    tile.defined_elements = Zeros{PTO_MODEL_TILE_ELEMENTS};
    tile.defined_valid_elements = 0;
    tile.packed_defined_elements = zero_packed_tile_elements;
    tile.capacity_bytes = capacity_bytes;
    tile.rows = derived_rows;
    tile.columns = columns;
    tile.valid_rows = valid_rows;
    tile.valid_columns = valid_columns;
    tile.data_type = data_type;
    tile.predicate_basis_type = data_type;
    tile.layout = layout;
    tile.cube_k_repeat = 0;
    tile.cube_n_repeat = 0;
    tile.cube_cell_count = 0;
    tile.cube_storage_bytes = 0;
    if !SharedTileUpdateCompatible(shared_tile_id, tile, pe_mask) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    let single_issuer = PEMaskPopulation(pe_mask) == 1;
    var single_agent: MemoryAgentId = 0;
    if single_issuer then
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
                single_agent = agent;
            end;
        end;
    end;
    // The maximum packed witness uses zero byte stride and a fresh Shared
    // record. Check every participating issuer through the ordinary
    // translated probe before publishing the complete carrier state.
    var packed_zero_fast = PackedTileDataTypeIsFourBit(tile.data_type) &&
        !_MemoryEventCaptureEnabled &&
        !SharedTileRecord(shared_tile_id).descriptor_valid &&
        tile.valid_rows == tile.rows &&
        tile.valid_columns == tile.columns &&
        tile.rows * tile.columns ==
            PackedTileLogicalCapacity(tile.capacity_bytes, tile.data_type) &&
        tile.capacity_bytes == 262144;
    if packed_zero_fast then
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' &&
               (base_addresses[[agent]] != Zeros{PTO_XLEN} ||
                row_stride_bytes[[agent]] != Zeros{PTO_XLEN}) then
                packed_zero_fast = FALSE;
            end;
        end;
    end;
    if packed_zero_fast then
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
                for column = 0 to tile.valid_columns - 1 looplimit 65536 do
                    let address = TileMemoryStridedByteAddress(
                        base_addresses[[agent]], 0,
                        column as integer {0..65535},
                        row_stride_bytes[[agent]], tile.data_type);
                    let probe = ProbeTileMemoryAccess(address,
                        tile.data_type, FALSE);
                    if RaiseDataAccessFault(probe, address) then return; end;
                    if LoadTranslatedUnsigned(probe.translated_address,
                           TileMemoryElementBytes(tile.data_type)) !=
                           Zeros{PTO_XLEN} then
                        packed_zero_fast = FALSE;
                    end;
                end;
            end;
        end;
    end;
    if packed_zero_fast then
        let payload_mask = if single_issuer then '1111' else pe_mask;
        tile = TileWithPackedZeroSelectedMaxRegionDefined(tile, payload_mask);
        let updated = AtomicUpdateSharedTile(shared_tile_id, tile, pe_mask);
        assert updated;
        return;
    end;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535}, column as integer {0..65535});
            let region = SharedTileElementRegion(tile, element);
            let selected = single_issuer ||
                pe_mask[PTOPEMaskBitOfPEIdentity(region)] == '1';
            if selected then
                let agent = if single_issuer then single_agent
                    else region as MemoryAgentId;
                let high_nibble = TileMemoryStridedByteHighNibble(
                    column as integer {0..65535}, tile.data_type);
                let address = TileMemoryStridedByteAddress(
                    base_addresses[[agent]], row as integer {0..65535},
                    column as integer {0..65535},
                    row_stride_bytes[[agent]], tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    tile.data_type, FALSE);
                if RaiseDataAccessFault(probe, address) then
                    let updated = AtomicUpdateSharedTile(shared_tile_id,
                        tile, pe_mask);
                    assert updated;
                    return;
                end;
                let translated = probe.translated_address;
                let raw = LoadTranslatedUnsigned(translated,
                    TileMemoryElementBytes(tile.data_type));
                RecordLoadEventForAgent(agent, translated,
                    TileMemoryElementBytes(tile.data_type), raw,
                    CurrentBundleMemoryOrder());
                tile = TileInfoWithLogicalElement(tile, element,
                    LoadTileMemoryElement(translated, tile.data_type,
                        high_nibble));
                tile.defined_valid_elements =
                    (tile.defined_valid_elements + 1)
                        as integer {0..524288};
            end;
        end;
    end;
    if single_issuer || pe_mask == '1111' then
        tile.defined_valid_elements =
            (tile.valid_rows * tile.valid_columns) as integer {0..524288};
        tile.contents_defined = TRUE;
    end;
    let updated = AtomicUpdateSharedTile(shared_tile_id, tile, pe_mask);
    assert updated;
end;

func TSTOREShared(base_addresses: CorePEWords,
                  row_stride_bytes: CorePEWords,
                  shared_tile_id: SharedTileID,
                  tile: TileInfo,
                  pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    assert tile.allocated;
    // PE_MASK selects consumer PEs. The first fault stops the request and
    // stores completed before it remain visible.
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            for row = 0 to tile.valid_rows - 1 looplimit 65536 do
                for column = 0 to tile.valid_columns - 1 looplimit 65536 do
                    let element = TileLogicalLinearIndex(tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    let address = TileMemoryStridedByteAddress(
                        base_addresses[[agent]], row as integer {0..65535},
                        column as integer {0..65535},
                        row_stride_bytes[[agent]], tile.data_type);
                    let probe = ProbeTileMemoryAccess(address,
                        tile.data_type, TRUE);
                    if RaiseDataAccessFault(probe, address) then return; end;
                    let translated = probe.translated_address;
                    let stored_value = StoreTileMemoryElement(
                        address, translated, tile.data_type,
                        TileMemoryStridedByteHighNibble(
                            column as integer {0..65535}, tile.data_type),
                        TileReadLogicalElement(tile, element));
                    RecordStoreEventForAgent(agent, translated,
                        TileMemoryElementBytes(tile.data_type), stored_value,
                        CurrentBundleMemoryOrder());
                end;
            end;
        end;
    end;
end;


func TMOVSharedToLocalPerPE(destination: TileIndex,
                           per_pe_tiles: CorePETileInfos,
                           pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            let source_tile = per_pe_tiles[[agent]];
            let destination_tile = _Tiles[[destination]];
            assert source_tile.allocated && source_tile.contents_defined;
            assert destination_tile.capacity_bytes == source_tile.capacity_bytes;
            assert destination_tile.rows == source_tile.rows &&
                   destination_tile.columns == source_tile.columns &&
                   destination_tile.valid_rows == source_tile.valid_rows &&
                   destination_tile.valid_columns == source_tile.valid_columns &&
                   destination_tile.data_type == source_tile.data_type &&
                   destination_tile.layout == source_tile.layout;
            for element = 0 to source_tile.rows * source_tile.columns - 1
                looplimit 524288 do
                let value = TileReadLogicalElement(source_tile,
                    element as PackedTileElementIndex);
                _Tiles[[destination]] = TileInfoWithLogicalElement(
                    _Tiles[[destination]],
                    element as PackedTileElementIndex, value);
            end;
        end;
    end;
    _Tiles[[destination]].contents_defined = pe_mask == '1111';
    if pe_mask == '1111' then MarkTileValidRegionDefined(destination); end;
end;

func TSTORESharedPerPE(base_addresses: CorePEWords,
                       row_stride_bytes: CorePEWords,
                       per_pe_tiles: CorePETileInfos,
                       pe_mask: bits(4))
begin
    if pe_mask == Zeros{4} then return; end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            let tile = per_pe_tiles[[agent]];
            assert tile.allocated && tile.contents_defined;
            for row = 0 to tile.valid_rows - 1 looplimit 65536 do
                for column = 0 to tile.valid_columns - 1 looplimit 65536 do
                    let address = TileMemoryStridedByteAddress(
                        base_addresses[[agent]], row as integer {0..65535},
                        column as integer {0..65535},
                        row_stride_bytes[[agent]], tile.data_type);
                    let probe = ProbeTileMemoryAccess(address,
                        tile.data_type, TRUE);
                    if RaiseDataAccessFault(probe, address) then return; end;
                    let translated = probe.translated_address;
                    let stored_value = StoreTileMemoryElement(
                        address, translated, tile.data_type,
                        TileMemoryStridedByteHighNibble(
                            column as integer {0..65535}, tile.data_type),
                        TileReadLogicalElement(tile,
                            TileLogicalLinearIndex(tile,
                                row as integer {0..65535},
                                column as integer {0..65535})));
                    RecordStoreEventForAgent(agent, translated,
                        TileMemoryElementBytes(tile.data_type), stored_value,
                        CurrentBundleMemoryOrder());
                end;
            end;
        end;
    end;
end;

func TMOV(destination: TileIndex, source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated;
    assert TileShapesMatch(_Tiles[[destination]], source_tile);
    if _BundleExecutionMask.valid then
        assert TileElementwiseSourceContentsDefined(source);
    end;
    _Tiles[[destination]].payload = source_tile.payload;
    _Tiles[[destination]].defined_elements = source_tile.defined_elements;
    _Tiles[[destination]].packed_defined_elements =
        source_tile.packed_defined_elements;
    _Tiles[[destination]].defined_valid_elements =
        source_tile.defined_valid_elements;
    _Tiles[[destination]].contents_defined = source_tile.contents_defined;
    if _BundleExecutionMask.valid then
        var result = _Tiles[[destination]];
        for row = 0 to result.valid_rows - 1 looplimit 65536 do
            for column = 0 to result.valid_columns - 1 looplimit 65536 do
                if !BundleExecutionMaskActiveAt(
                       result.layout, row as integer {0..65535},
                       column as integer {0..65535}) then
                    let element = TileLogicalLinearIndex(result,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    result = TileInfoWithLogicalElementAndDefined(
                        result, element,
                        BundleExecutionMaskDestinationValue(
                            result.layout, row as integer {0..65535},
                            column as integer {0..65535}, Zeros{PTO_XLEN}),
                        TRUE);
                end;
            end;
        end;
        result = TileWithValidRegionDefined(result);
        _Tiles[[destination]] = result;
    end;
end;

// The direct-operation carrier binds source to the Core4 snapshot already
// resolved from the four PE-private peer_tid values.  The bundle dispatcher
// performs collective readiness and peer-range preflight before this read-old,
// write-new local copy.  No Shared register or global-memory event is involved.
func GMOV(destination: TileIndex, source: TileIndex, peer_tid: Word)
begin
    assert UInt(peer_tid) < 4;
    let source_tile = _Tiles[[source]];
    let source_payload = source_tile.payload;
    _Tiles[[destination]].payload = source_payload;
    _Tiles[[destination]].defined_elements = source_tile.defined_elements;
    _Tiles[[destination]].packed_defined_elements =
        source_tile.packed_defined_elements;
    _Tiles[[destination]].defined_valid_elements =
        source_tile.defined_valid_elements;
    _Tiles[[destination]].contents_defined = source_tile.contents_defined;
end;
```
<!-- GENERATED-ASL-END: unit -->
