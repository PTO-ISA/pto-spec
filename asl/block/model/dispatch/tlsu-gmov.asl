// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-TLSU-GMOV","surface":"block","classification":["model","dispatch","tlsu-gmov"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-TLSU-PREFETCH","PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT"]}

readonly func BundleGMOVSelected() => boolean
begin
    return _BundleOperation.valid &&
           _BundleOperation.operation_class == BundleOperation_TileMemory &&
           _BundleOperation.selector_valid &&
           UInt(_BundleOperation.selector[4:0]) == 13;
end;

readonly func BundleGMOVPESourceTile(source: TileIndex,
                                     pe: MemoryAgentId) => TileInfo
begin
    if _CurrentPEContextValid && pe == _CurrentMemoryAgent then
        return _Tiles[[source]];
    end;
    return _PEExecutionContexts[[_CurrentModelCore]][[pe]].tiles[[source]];
end;

readonly func BundleGMOVPESourceTileReady(tile: TileInfo) => boolean
begin
    if TileLayoutIsCube(tile.layout) then
        return TileCubeDescriptorLegal(tile) && tile.contents_defined;
    end;
    return TileInfoDescriptorLegal(tile);
end;

readonly func BundleGMOVSourceDescriptorsMatch(left: TileInfo,
                                                right: TileInfo) => boolean
begin
    return left.capacity_bytes == right.capacity_bytes &&
           left.rows == right.rows && left.columns == right.columns &&
           left.valid_rows == right.valid_rows &&
           left.valid_columns == right.valid_columns &&
           left.data_type == right.data_type &&
           left.layout == right.layout &&
           left.storage_kind == right.storage_kind &&
           left.cube_k_repeat == right.cube_k_repeat &&
           left.cube_n_repeat == right.cube_n_repeat &&
           left.cube_cell_count == right.cube_cell_count &&
           left.cube_storage_bytes == right.cube_storage_bytes;
end;

readonly func BundleGMOVCore4SourceReady(source: TileIndex) => boolean
begin
    // Standalone aggregate callers retain the established Core4 batch view.
    // Encoded PE streams instead resolve each destination's private peer_tid
    // against that peer's actual Local bank before any destination effect.
    if !_CurrentPEContextValid then
        return TileElementwiseSourceContentsDefined(source) &&
               _TileAllocationMasks[[source]] == '1111';
    end;
    if !_BundleScalarBindings[[0]].valid then return FALSE; end;
    var reference_valid = FALSE;
    var reference: TileInfo;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let destination_pe = pe as MemoryAgentId;
        let peer_word = ReadPEAbsoluteGPROperand(destination_pe,
            _BundleScalarBindings[[0]].source0);
        if UInt(peer_word) >= PTO_MODEL_MEMORY_AGENTS then return FALSE; end;
        let source_pe = UInt(peer_word) as MemoryAgentId;
        if source_pe != _CurrentMemoryAgent &&
           _PEContextBankValid[[_CurrentModelCore]][source_pe] != '1' then
            return FALSE;
        end;
        let source_tile = BundleGMOVPESourceTile(source, source_pe);
        if !BundleGMOVPESourceTileReady(source_tile) then return FALSE; end;
        if !reference_valid then
            reference = source_tile;
            reference_valid = TRUE;
        elsif !BundleGMOVSourceDescriptorsMatch(reference, source_tile) then
            return FALSE;
        end;
    end;
    return reference_valid;
end;

func ExecuteBundleGMOVOperation() => boolean
begin
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    if BundleSharedBindingCount() != 0 ||
       !BundleOperationBindingsComplete(operation) ||
       !BundleOperationGPRBindingValuesLegal(operation) ||
       !SelectedBundleTileMasksLegal() ||
       BundleTileBindingCount() != 1 then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let current_peer_word = if _CurrentPEContextValid &&
        _BundleScalarBindings[[0]].valid then
        ReadPEAbsoluteGPROperand(_CurrentMemoryAgent,
            _BundleScalarBindings[[0]].source0)
        else Zeros{PTO_XLEN};
    if UInt(current_peer_word) >= PTO_MODEL_MEMORY_AGENTS then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let current_source_tile = if _CurrentPEContextValid then
        BundleGMOVPESourceTile(binding.source0,
            UInt(current_peer_word) as MemoryAgentId)
        else _Tiles[[binding.source0]];
    if !binding.destination_valid || !binding.source0_valid ||
       binding.source1_valid || !binding.last ||
       !BundleGMOVCore4SourceReady(binding.source0) ||
       BundleTileDestinationSizeBytes(0) !=
           current_source_tile.capacity_bytes ||
       !TileCarrierOrPackedBaselineDataTypeSupported(
           TileDataTypeFromEncoding(
               CurrentBundleTileOperationDataTypeCode()
                   as TileDataTypeEncoding)) ||
       current_source_tile.data_type != TileDataTypeFromEncoding(
           CurrentBundleTileOperationDataTypeCode()
               as TileDataTypeEncoding) ||
       current_source_tile.layout != CurrentBundleTileLayout() then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    for dimension = 0 to PTO_BUNDLE_DIMENSION_COUNT - 1 do
        if UInt(_BundleDimensions[[dimension]]) != 1 then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    end;
    // Every PE participates in peer selection and readiness preflight even
    // when PE_MASK suppresses that PE's destination request/write.  Repeated
    // peer identifiers are legal; only the absolute 0..3 range is constrained.
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let agent = pe as MemoryAgentId;
        let peer_tid = if _BundleScalarBindings[[0]].valid then
            ReadPEAbsoluteGPROperand(agent,
                _BundleScalarBindings[[0]].source0)
            else Zeros{PTO_XLEN};
        if UInt(peer_tid) >= PTO_MODEL_MEMORY_AGENTS then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
    end;
    // GMOV has no dimensions that describe a new shape: the destination
    // carries the resolved peer source shape while B.DATR.Layout selects its
    // physical representation.
    if !ResolveBundleTileDestinationsWithShapeAndType(
           TRUE, current_source_tile.valid_rows,
           current_source_tile.valid_columns,
           current_source_tile.columns, TRUE,
           current_source_tile.data_type) then return FALSE; end;
    if !ValidateBundleLocalGenerationWriters() then
        RollBackBundleTileDestinations(); return FALSE;
    end;
    let destination = _BundleTileBindings[[0]].destination;
    let source = binding.source0;
    let selected_source = if _CurrentPEContextValid then
        current_source_tile else _Tiles[[source]];
    if !BundleGMOVPESourceTileReady(selected_source) ||
       !TileElementwiseDescriptorLegal(destination) ||
       _Tiles[[destination]].rows != selected_source.rows ||
       _Tiles[[destination]].columns != selected_source.columns ||
       _Tiles[[destination]].valid_rows != selected_source.valid_rows ||
       _Tiles[[destination]].valid_columns != selected_source.valid_columns ||
       _Tiles[[destination]].data_type != selected_source.data_type ||
       _Tiles[[destination]].layout != selected_source.layout ||
       !TileElementwiseLayoutSupported(selected_source.layout) ||
       !TileCarrierOrPackedBaselineDataTypeSupported(
           selected_source.data_type) then
        RollBackBundleTileDestinations();
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if _CurrentPEContextValid then
        GMOVFromSourceTile(destination, selected_source);
    else
        GMOV(destination, source, Zeros{PTO_XLEN});
    end;
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
