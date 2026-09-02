<!-- GENERATED FROM: asl/tile/model/memory/gm-atom-red-execution.asl -->
# Gm Atom Red Execution

**Normative ASL source:** `asl/tile/model/memory/gm-atom-red-execution.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/gm-atom-red-execution.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-GM-ATOM-RED-EXECUTION","surface":"tile","classification":["model","memory","gm-atom-red-execution"],"depends_on":["PTO-TILE-MODEL-MEMORY-GM-ATOM-RED","PTO-TILE-MODEL-MEMORY-GATHER-SCATTER"]}
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
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let index_element = TileLinearIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[index_element]], index_tile.data_type);
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
            let value_element = TileLinearIndex(value_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let expected_element = TileLinearIndex(expected_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let replacement_element = TileLinearIndex(replacement_tile,
                row as integer {0..65535}, column as integer {0..65535});
            values[[element]] = value_tile.payload[[value_element]];
            expecteds[[element]] = expected_tile.payload[[expected_element]];
            replacements[[element]] = replacement_tile.payload[[replacement_element]];
            lane_order[[lane_count]] = NaturalToWord(element);
            lane_count = (lane_count + 1) as integer {0..PTO_MODEL_TILE_ELEMENTS};
        end;
    end;
    var result = destination_tile.payload;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            let element = TileLinearIndex(destination_tile,
                row as integer {0..65535}, column as integer {0..65535});
            result[[element]] = TilePadValueForDataType(pad_value, data_type);
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
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[element]], index_tile.data_type);
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
            let value_element = TileLinearIndex(value_tile,
                row as integer {0..65535}, column as integer {0..65535});
            values[[element]] = value_tile.payload[[value_element]];
            lane_order[[lane_count]] = NaturalToWord(element);
            lane_count = (lane_count + 1) as integer {0..PTO_MODEL_TILE_ELEMENTS};
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
    for row = 0 to index_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to index_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(index_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let address = TileMemoryByteDisplacementAddress(base_address,
                index_tile.payload[[element]], index_tile.data_type);
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
