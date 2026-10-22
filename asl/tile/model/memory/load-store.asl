// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-LOAD-STORE","surface":"tile","classification":["model","memory","load-store"],"depends_on":["PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION","PTO-ARCH-MEMORY-MODEL-GM-OBLIGATIONS","PTO-ARCH-STATE-CORE-SYNCHRONIZATION","PTO-BLOCK-MODEL-OPERANDS-PORTABLE-CARRIERS","PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-LEGALITY-EXECUTION-MASK-SOURCE-SCHEMA","PTO-TILE-MODEL-MEMORY-STRIDE"]}
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

func TileWithPhysicalRegionDefined(tile: TileInfo) => TileInfo
begin
    var result = tile;
    for row = 0 to tile.rows - 1 looplimit 65536 do
        for column = 0 to tile.columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, element,
                TileReadLogicalElement(tile, element));
        end;
    end;
    if TilePackedRowsHavePhysicalSlack(tile) then
        for row = 0 to tile.rows - 1 looplimit 65536 do
            result = TileInfoWithPackedRowSlack(result,
                row as integer {0..65535},
                TileReadLogicalElement(tile,
                    TilePackedRowSlackIndex(tile,
                        row as integer {0..65535})), TRUE);
        end;
    end;
    result.defined_valid_elements =
        (tile.valid_rows * tile.valid_columns) as integer {0..524288};
    result.contents_defined = TRUE;
    return result;
end;

func TLOADToValue(tile: TileInfo, base_address: Word,
                  row_stride_bytes: Word) => TileInfo
begin
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
            if RaiseDataAccessFault(probe, address) then return tile; end;
            if LoadTranslatedUnsigned(probe.translated_address,
                   TileMemoryElementBytes(tile.data_type)) !=
                   Zeros{PTO_XLEN} then
                packed_zero_fast = FALSE;
            end;
        end;
    end;
    if packed_zero_fast then
        return TileWithPackedZeroValidRegionDefined(tile);
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
                FlushMemoryReplay();
                return result;
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
    CompleteMemoryReplay();
    return result;
end;

func TLOAD(destination: TileIndex, base_address: Word,
           row_stride_bytes: Word)
begin
    _Tiles[[destination]] = TLOADToValue(
        _Tiles[[destination]], base_address, row_stride_bytes);
end;

readonly func TileStoreSourceGeneration(source: TileIndex) => Word
begin
    let slot = BundleLocalGenerationSlotForSource(source);
    if slot < 64 && _LocalGenerations[[slot]].generation_identity_valid then
        return _LocalGenerations[[slot]].generation_instance;
    end;
    return Zeros{PTO_XLEN};
end;

readonly func TileStoreHasActiveElements(tile: TileInfo,
                                        execution_mask:
                                            BundleExecutionMaskBinding)
                                        => boolean
begin
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(tile.layout,
                   row as integer {0..65535},
                   column as integer {0..65535}) then return TRUE; end;
        end;
    end;
    return FALSE;
end;

func TileStoreFootprintIsValidated(tile: TileInfo,
    base_address: Word, row_stride_bytes: Word,
    execution_mask: BundleExecutionMaskBinding) => boolean
begin
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if BundleExecutionMaskActiveAt(tile.layout,
                   row as integer {0..65535},
                   column as integer {0..65535}) then
                let address = TileMemoryStridedByteAddress(base_address,
                    row as integer {0..65535},
                    column as integer {0..65535}, row_stride_bytes,
                    tile.data_type);
                let probe = ProbeTileMemoryAccess(address,
                    tile.data_type, TRUE);
                if probe.fault != Fault_None then return FALSE; end;
            end;
        end;
    end;
    return TRUE;
end;

type TileStoreProgressResult of enumeration {
    TileStoreProgress_Faulted,
    TileStoreProgress_Pending,
    TileStoreProgress_Completed
};

func ExecuteTileStoreSnapshotProgress(tile: TileInfo, base_address: Word,
    row_stride_bytes: Word, request_pc: Word, memory_order: MemoryOrder,
    start_element: integer {0..32768},
    beat_budget: integer {0..32768},
    tracked: boolean, core: PTOModelCoreIdentity, pe: MemoryAgentId,
    obligation_slot: GMObligationIndex) => TileStoreProgressResult
begin
    BeginMemoryReplay(request_pc);
    var committed_beats : integer {0..32768} = 0;
    var next_element = start_element;
    var progress_budget_reached = FALSE;
    var logical_element : integer {0..32768} = 0;
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            if logical_element >= start_element &&
               !progress_budget_reached &&
               BundleExecutionMaskActiveAt(tile.layout,
                   row as integer {0..65535},
                   column as integer {0..65535}) then
                if beat_budget != 0 && committed_beats >= beat_budget then
                    progress_budget_reached = TRUE;
                else
                    let element = TileLogicalLinearIndex(tile,
                        row as integer {0..65535},
                        column as integer {0..65535});
                    let address = TileMemoryStridedByteAddress(base_address,
                        row as integer {0..65535},
                        column as integer {0..65535}, row_stride_bytes,
                        tile.data_type);
                    let probe = ProbeTileMemoryAccess(address,
                        tile.data_type, TRUE);
                    if RaiseDataAccessFault(probe, address) then
                        FlushMemoryReplay();
                        return TileStoreProgress_Faulted;
                    end;
                    let translated = probe.translated_address;
                    let stored_value = StoreTileMemoryElement(address,
                        translated, tile.data_type,
                        TileMemoryStridedByteHighNibble(
                            column as integer {0..65535}, tile.data_type),
                        TileReadLogicalElement(tile, element));
                    RecordStoreEvent(translated,
                        TileMemoryElementBytes(tile.data_type), stored_value,
                        memory_order);
                    CommitMemoryReplayEffect();
                    next_element = (logical_element + 1)
                        as integer {0..32768};
                    committed_beats = (committed_beats + 1)
                        as integer {0..32768};
                    if tracked then
                        _GMObligations[[core]][[pe]][[obligation_slot]]
                            .progress_element = next_element;
                        MarkGMObligationIrrevocable(core, pe,
                            obligation_slot);
                    end;
                    if beat_budget != 0 &&
                       committed_beats >= beat_budget then
                        progress_budget_reached = TRUE;
                    end;
                end;
            end;
            logical_element = (logical_element + 1)
                as integer {0..32768};
        end;
    end;
    CompleteMemoryReplay();
    return if progress_budget_reached && next_element < logical_element then
        TileStoreProgress_Pending else TileStoreProgress_Completed;
end;

func ExecuteTileStoreSnapshot(tile: TileInfo, base_address: Word,
    row_stride_bytes: Word, request_pc: Word, memory_order: MemoryOrder,
    tracked: boolean, core: PTOModelCoreIdentity, pe: MemoryAgentId,
    obligation_slot: GMObligationIndex) => boolean
begin
    let result = ExecuteTileStoreSnapshotProgress(tile, base_address,
        row_stride_bytes, request_pc, memory_order, 0, 0, tracked, core, pe,
        obligation_slot);
    return result == TileStoreProgress_Completed;
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
    let request_pc = ReadBPC();
    let order = CurrentBundleMemoryOrder();
    let tracked = _CurrentMemoryOrigin == MemoryEventOrigin_Kernel &&
        _KernelInvocationActiveByCore[[_CurrentModelCore]] &&
        _CurrentKernelInvocation != 0 &&
        TileStoreHasActiveElements(tile, _BundleExecutionMask);
    if !tracked then
        let completed = ExecuteTileStoreSnapshot(tile,
            base_address, row_stride_bytes,
            request_pc, order, FALSE, _CurrentModelCore,
            _CurrentMemoryAgent, 0 as GMObligationIndex);
        return;
    end;
    let core = _CurrentModelCore;
    let pe = _CurrentMemoryAgent;
    let slot = RegisterKernelGMObligation(GMRequest_Tile,
        _BundleStartEncodedInstruction, request_pc, _BundleOperation,
        _BundleArgument, _BundleTileBindings, _BundleScalarBindings,
        _BundleSharedBindings, _BundleDimensions, source,
        TileStoreSourceGeneration(source), tile, _BundleExecutionMask,
        base_address, row_stride_bytes, order, TRUE, FALSE, FALSE,
        FALSE, TRUE);
    if VerificationGMProgressIsDeferred() &&
       TileStoreFootprintIsValidated(tile, base_address, row_stride_bytes,
           _BundleExecutionMask) then
        ResolveGMObligationFaultRisk(core, pe, slot);
        MarkGMObligationCapturedTStoreProgress(core, pe, slot);
        return;
    end;
    let obligation = _GMObligations[[core]][[pe]][[slot]];
    IssueGMObligation(core, pe, slot);
    if ExecuteTileStoreSnapshot(tile, base_address, row_stride_bytes,
            request_pc, order, TRUE, core, pe, slot) then
        CompleteGMObligationForIdentity(core, pe, slot,
            obligation.invocation, obligation.identity);
    else
        FaultGMObligation(core, pe, slot);
    end;
end;
