<!-- GENERATED FROM: asl/tile/model/memory/gm-atom-red-execution.asl -->
# Gm Atom Red Execution

**Normative ASL source:** `asl/tile/model/memory/gm-atom-red-execution.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-execution-purpose role=purpose-scope -->
## Purpose and scope

This unit runs the GM atom/red family against memory.

- `GMRunAtomic` is the shared atom body. `GM_ATOM_CAS` and `GM_ATOM_VALUE` call it.
- `GM_RED_VALUE` runs a reduction with a value Tile and no destination.
- `GM_RED_POPC` adds 1 at each indexed address.
- `GMReductionResult` computes reduction results.
- `GMAtomicOperationFromFunction` and `GMReductionOperationFromFunction` map TLSU Function numbers to operations.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-execution-concepts role=concepts-state -->
## Concepts and visible state

The Function map is:

| Function | Operation |
| --- | --- |
| 8, 9, 10, 11, 12 | atom CAS, EXCH, MAX, MIN, ADD |
| 14, 15, 16, 17, 18 | atom INC, DEC, AND, OR, XOR |
| 19, 20, 21, 22, 23 | red MAX, MIN, ADD, INC, DEC |
| 24, 25, 26, 27 | red AND, OR, XOR, POPC |

Function 13 is `GMOV`, not part of this family. The atom map returns XOR for any Function it does not list, and the reduction map returns POPC; the block dispatcher only calls them for the listed values.

A lane is an active valid coordinate of the index Tile (or of the destination for atom forms, which has the same valid shape). Each lane produces exactly one atomic event.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-execution-rules role=rules-interactions -->
## Rules and interactions

Every body has the same three steps.

- Preflight: compute `base + displacement` for each active lane, probe for read, probe for write, and raise `Fault_DataPage` if the two translations differ. Snapshot the lane's value, expected, and replacement operands.
- Atom forms only: initialize the destination. Inactive valid coordinates get the ExecutionMask zero or merge value; every other physical element gets the pad value.
- Commit: process lanes in an order chosen by `ARBITRARY` choices. Each lane loads the old value, computes the new value, stores it if a write is performed, writes the old value into the atom destination, and records one atomic event.

Design point: all probes finish before the first event or local publication (NDF `PTO-ATOM-RED-ORDERING-001`). A fault leaves GM untouched and records no event. The consequence is that retrying a faulting atom or red request cannot apply an update twice.

Design point: duplicate effective addresses serialize in an implementation-defined order, and all of them take effect. Two red ADD lanes at the same address both add, so the final sum is independent of order for integer ADD.

Reduction forms always store the new value and record `write_performed` as TRUE. Atom CAS records FALSE when the comparison fails and does not store.

`GM_RED_POPC` always works on U32, has no value Tile and no destination, and adds exactly 1 per lane.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-execution-boundaries role=boundaries -->
## Architectural boundaries

These bodies assume operand legality has already passed; the block dispatcher calls the `TileOperandsLegal_GM_*` predicates first and faults with `Fault_TileLegality` otherwise. `PE_MASK=0000` exits at the start of the GM atom/red dispatcher, before its schema, descriptor, type, and memory checks.

Each lane is atomic by itself. The request as a whole is not one atomic transaction, and its events carry `CurrentBundleMemoryOrder()`. Ordering rules are owned by the architecture memory model.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-execution-example role=example-usage -->
## Non-normative reading example

`MSCATTER_POPC` (Function 27) with base `0x1000` and a 1 by 3 U64 index Tile holding `0, 4, 0`. GM holds U32 value 10 at `0x1000` and 20 at `0x1004`.

- Lane addresses are `0x1000`, `0x1004`, and `0x1000`; all are 4-byte aligned.
- Two lanes add 1 at `0x1000`, which ends at 12 in either order.
- One lane adds 1 at `0x1004`, which ends at 21.
- Three atomic events are recorded, each with `write_performed` TRUE.

<!-- PTO-READER-BLOCK: tile-model-memory-gm-atom-red-execution-related role=related-owners-navigation -->
## Related owners

- [GM atom/red](gm-atom-red.md) owns the operation/type matrix and result rules.
- [Atomics](atomics.md) owns the `MGATHER_CAS` body.
- [Restart](restart.md) explains the probe-all-first restart pattern.
- [Memory atomicity](../../../arch/memory-model/atomicity.md) and [ordering](../../../arch/memory-model/ordering.md) own event semantics.
- [MSCATTER_POPC](../../memory-and-data-movement/irregular/MSCATTER_POPC.md) is one instruction page in this family.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/gm-atom-red-execution.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION","surface":"tile","classification":["model","memory","gm-atom-red-execution"],"depends_on":["PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER","PTO-TILE-MODEL-EXECUTION-MASK-STATE"]}
func GMRunAtomic(destination: TileIndex, base_address: Word, indices: TileIndex,
                value: TileIndex, expected: TileIndex, replacement: TileIndex,
                data_type: TileDataType, operation: GMAtomicOperation,
                pad_value: TilePadValue)
begin
    let destination_tile = _Tiles[[destination]];
    let index_tile = _Tiles[[indices]];
    let value_tile = _Tiles[[value]];
    let expected_tile = _Tiles[[expected]];
    let replacement_tile = _Tiles[[replacement]];
    var translated_addresses: TilePayload;
    var write_translated_addresses: TilePayload;
    var original_addresses: TilePayload;
    var lane_order: ScatterLaneOrder;
    var values: TilePayload;
    var expecteds: TilePayload;
    var replacements: TilePayload;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUExecutionMaskContentsDefined(value);
    assert IndexedTLSUExecutionMaskContentsDefined(expected);
    assert IndexedTLSUExecutionMaskContentsDefined(replacement);
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   destination_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let element = TileStorageIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let index_element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[index_element]], index_tile.data_type,
                data_type);
            let read_probe = ProbeTileMemoryAccess(address, data_type, FALSE);
            if RaiseDataAccessFault(read_probe, address) then return; end;
            let write_probe = ProbeTileMemoryAccess(address, data_type, TRUE);
            if RaiseDataAccessFault(write_probe, address) then return; end;
            if read_probe.translated_address != write_probe.translated_address then
                SetFault(Fault_DataPage, address);
                return;
            end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = read_probe.translated_address;
            write_translated_addresses[[element]] = write_probe.translated_address;
            let value_element = TileStorageIndex(value_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let expected_element = TileStorageIndex(expected_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let replacement_element = TileStorageIndex(replacement_tile,
                row as integer {0..65535}, column as integer {0..65535});
            values[[element]] = value_tile.payload[[value_element]];
            expecteds[[element]] = expected_tile.payload[[expected_element]];
            replacements[[element]] = replacement_tile.payload[[replacement_element]];
            lane_order[[lane_count]] = NaturalToWord(element);
            lane_count = (lane_count + 1) as integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    var result = destination_tile.payload;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileStorageIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            var inactive = FALSE;
            if row < destination_tile.valid_rows &&
               column < destination_tile.valid_columns then
                inactive = !BundleExecutionMaskActiveAt(
                    destination_tile.layout,
                    row as integer {0..65535},
                    column as integer {0..65535});
            end;
            result[[element]] = if inactive then
                BundleExecutionMaskDestinationValue(
                    destination_tile.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN})
            else TilePadValueForDataType(pad_value, data_type);
        end;
    end;
    // Duplicate addresses are serialized in an implementation-defined order.
    for position = 0 to lane_count - 1 looplimit PTO_MODEL_TILE_ELEMENTS do
        var selected_position: integer {0..PTO_MODEL_TILE_ELEMENTS-1} =
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
        let element = UInt(lane_order[[position]]) as ModelTileElementIndex;
        let old_raw = LoadTranslatedUnsigned(translated_addresses[[element]],
            TileMemoryElementBytes(data_type));
        let old = DecodeTileMemoryElementRaw(old_raw, data_type, FALSE);
        let (new_value, write_performed) = GMAtomicResult(operation, data_type,
            old, values[[element]], expecteds[[element]], replacements[[element]]);
        if write_performed then
            - = StoreTileMemoryElement(original_addresses[[element]],
                write_translated_addresses[[element]], data_type, FALSE, new_value);
        end;
        result[[element]] = old;
        RecordAtomicEvent(write_translated_addresses[[element]],
            TileMemoryElementBytes(data_type), old_raw,
            NormalizeMemoryAccessValue(new_value, TileMemoryElementBytes(data_type)),
            CurrentBundleMemoryOrder(), write_performed);
    end;
    _Tiles[[destination]].payload = result;
    MarkTilePhysicalRegionDefined(destination);
end;

func GM_ATOM_CAS(operation: GMAtomicOperation, destination: TileIndex, base_address: Word, indices: TileIndex,
                 expected: TileIndex, replacement: TileIndex,
                 pad_value: TilePadValue)
begin
    GMRunAtomic(destination, base_address, indices, expected, expected,
        replacement, _Tiles[[destination]].data_type, operation, pad_value);
end;

func GM_ATOM_VALUE(operation: GMAtomicOperation, destination: TileIndex, base_address: Word, indices: TileIndex,
                   value: TileIndex, pad_value: TilePadValue)
begin
    GMRunAtomic(destination, base_address, indices, value, value, value,
        _Tiles[[destination]].data_type, operation, pad_value);
end;


readonly func GMReductionResult(operation: GMReductionOperation,
                            data_type: TileDataType, old: Word,
                            input: Word) => Word
begin
    case operation of
        when GMReduction_ADD =>
            if TileDataTypeIsFloating(data_type) then
                return GMFloatingAddPTX(data_type, old, input);
            end;
            return old + input;
        when GMReduction_INC => return GMIncValue(old, input);
        when GMReduction_DEC => return GMDecValue(old, input);
        when GMReduction_AND => return old AND input;
        when GMReduction_OR => return old OR input;
        when GMReduction_XOR => return old XOR input;
        when GMReduction_MAX =>
            if TileDataTypeIsSigned(data_type) then
                if SInt(old) > SInt(input) then return old; else return input; end;
            end;
            if UInt(old) > UInt(input) then return old; else return input; end;
        when GMReduction_MIN =>
            if TileDataTypeIsSigned(data_type) then
                if SInt(old) < SInt(input) then return old; else return input; end;
            end;
            if UInt(old) < UInt(input) then return old; else return input; end;
        otherwise => return old;
    end;
end;
func GM_RED_VALUE(operation: GMReductionOperation, base_address: Word,
                  indices: TileIndex, value: TileIndex, pad_value: TilePadValue)
begin
    let data_type = _Tiles[[value]].data_type;
    let value_tile = _Tiles[[value]];
    let index_tile = _Tiles[[indices]];
    var translated_addresses: TilePayload;
    var write_translated_addresses: TilePayload;
    var original_addresses: TilePayload;
    var lane_order: ScatterLaneOrder;
    var values: TilePayload;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    assert IndexedTLSUExecutionMaskContentsDefined(value);
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[element]], index_tile.data_type,
                data_type);
            let read_probe = ProbeTileMemoryAccess(address, data_type, FALSE);
            if RaiseDataAccessFault(read_probe, address) then return; end;
            let write_probe = ProbeTileMemoryAccess(address, data_type, TRUE);
            if RaiseDataAccessFault(write_probe, address) then return; end;
            if read_probe.translated_address != write_probe.translated_address then
                SetFault(Fault_DataPage, address);
                return;
            end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = read_probe.translated_address;
            write_translated_addresses[[element]] = write_probe.translated_address;
            let value_element = TileStorageIndex(value_tile,
                row as integer {0..65535}, column as integer {0..65535});
            values[[element]] = value_tile.payload[[value_element]];
            lane_order[[lane_count]] = NaturalToWord(element);
            lane_count = (lane_count + 1) as integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    for position = 0 to lane_count - 1 looplimit PTO_MODEL_TILE_ELEMENTS do
        var selected_position: integer {0..PTO_MODEL_TILE_ELEMENTS-1} =
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
        let element = UInt(lane_order[[position]]) as ModelTileElementIndex;
        let old_raw = LoadTranslatedUnsigned(translated_addresses[[element]],
            TileMemoryElementBytes(data_type));
        let old = DecodeTileMemoryElementRaw(old_raw, data_type, FALSE);
        let new_value = GMReductionResult(operation, data_type, old,
            values[[element]]);
        - = StoreTileMemoryElement(original_addresses[[element]],
            write_translated_addresses[[element]], data_type, FALSE, new_value);
        RecordAtomicEvent(write_translated_addresses[[element]],
            TileMemoryElementBytes(data_type), old_raw,
            NormalizeMemoryAccessValue(new_value, TileMemoryElementBytes(data_type)),
            CurrentBundleMemoryOrder(), TRUE);
    end;
end;

func GM_RED_POPC(operation: GMReductionOperation, base_address: Word, indices: TileIndex)
begin
    let data_type = TileDataType_U32;
    let index_tile = _Tiles[[indices]];
    var translated_addresses: TilePayload;
    var write_translated_addresses: TilePayload;
    var original_addresses: TilePayload;
    var lane_order: ScatterLaneOrder;
    var lane_count: integer {0..PTO_MODEL_TILE_ELEMENTS} = 0;
    assert IndexedTLSUExecutionMaskContentsDefined(indices);
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(
                   index_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
            let element = TileStorageIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[element]], index_tile.data_type,
                data_type);
            let read_probe = ProbeTileMemoryAccess(address, data_type, FALSE);
            if RaiseDataAccessFault(read_probe, address) then return; end;
            let write_probe = ProbeTileMemoryAccess(address, data_type, TRUE);
            if RaiseDataAccessFault(write_probe, address) then return; end;
            if read_probe.translated_address != write_probe.translated_address then
                SetFault(Fault_DataPage, address);
                return;
            end;
            original_addresses[[element]] = address;
            translated_addresses[[element]] = read_probe.translated_address;
            write_translated_addresses[[element]] = write_probe.translated_address;
            lane_order[[lane_count]] = NaturalToWord(element);
            lane_count = (lane_count + 1) as integer {0..PTO_MODEL_TILE_ELEMENTS};
            end;
        end;
    end;
    for position = 0 to lane_count - 1 looplimit PTO_MODEL_TILE_ELEMENTS do
        var selected_position: integer {0..PTO_MODEL_TILE_ELEMENTS-1} =
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
        let element = UInt(lane_order[[position]]) as ModelTileElementIndex;
        let old_raw = LoadTranslatedUnsigned(translated_addresses[[element]],
            TileMemoryElementBytes(data_type));
        let old = DecodeTileMemoryElementRaw(old_raw, data_type, FALSE);
        let new_value = old + Zeros{PTO_XLEN} + 1;
        - = StoreTileMemoryElement(original_addresses[[element]],
            write_translated_addresses[[element]], data_type, FALSE, new_value);
        RecordAtomicEvent(write_translated_addresses[[element]],
            TileMemoryElementBytes(data_type), old_raw,
            NormalizeMemoryAccessValue(new_value, TileMemoryElementBytes(data_type)),
            CurrentBundleMemoryOrder(), TRUE);
    end;
end;

pure func GMAtomicOperationFromFunction(function: integer {0..31})
    => GMAtomicOperation
begin
    case function of
        when 8 => return GMAtomic_CAS;
        when 9 => return GMAtomic_EXCH;
        when 10 => return GMAtomic_MAX;
        when 11 => return GMAtomic_MIN;
        when 12 => return GMAtomic_ADD;
        when 14 => return GMAtomic_INC;
        when 15 => return GMAtomic_DEC;
        when 16 => return GMAtomic_AND;
        when 17 => return GMAtomic_OR;
        otherwise => return GMAtomic_XOR;
    end;
end;

pure func GMReductionOperationFromFunction(function: integer {0..31})
    => GMReductionOperation
begin
    case function of
        when 19 => return GMReduction_MAX;
        when 20 => return GMReduction_MIN;
        when 21 => return GMReduction_ADD;
        when 22 => return GMReduction_INC;
        when 23 => return GMReduction_DEC;
        when 24 => return GMReduction_AND;
        when 25 => return GMReduction_OR;
        when 26 => return GMReduction_XOR;
        otherwise => return GMReduction_POPC;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
