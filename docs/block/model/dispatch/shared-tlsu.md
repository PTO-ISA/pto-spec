<!-- GENERATED FROM: asl/block/model/dispatch/shared-tlsu.asl -->
# Shared TLSU

**Normative ASL source:** `asl/block/model/dispatch/shared-tlsu.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/dispatch/shared-tlsu.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-DISPATCH-SHARED-TLSU","surface":"block","classification":["model","dispatch","shared-tlsu"],"depends_on":["PTO-BLOCK-MODEL-FAULTS-ROLLBACK","PTO-BLOCK-MODEL-OPERANDS-SHARED-GENERATION","PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS"]}
readonly func BundleSharedTLSUSelected() => boolean
begin
    if !_BundleOperation.valid ||
       _BundleOperation.operation_class != BundleOperation_TileMemory ||
       !_BundleOperation.selector_valid then return FALSE; end;
    let function = UInt(_BundleOperation.selector[4:0]);
    return BundleSharedBindingCount() > 0;
end;

readonly func BundleSharedStoreValidColumns(shared_tile_id: SharedTileID)
    => integer {0..65535}
begin
    if _BundleDimensionPresent[[0]] then
        if UInt(_BundleDimensions[[0]]) <= 65535 then
            return UInt(_BundleDimensions[[0]]) as integer {0..65535};
        end;
        return 0;
    end;
    let shared = SharedTileRecord(shared_tile_id);
    if shared.descriptor_valid then return shared.tile.valid_columns; end;
    return 1;
end;

readonly func BundleSharedStoreValidRows(shared_tile_id: SharedTileID)
    => integer {0..65535}
begin
    if _BundleDimensionPresent[[1]] then
        if UInt(_BundleDimensions[[1]]) <= 65535 then
            return UInt(_BundleDimensions[[1]]) as integer {0..65535};
        end;
        return 0;
    end;
    let shared = SharedTileRecord(shared_tile_id);
    if shared.descriptor_valid then return shared.tile.valid_rows; end;
    return 1;
end;

readonly func BundleSharedStoreColumns(shared_tile_id: SharedTileID,
                                        valid_columns: integer {0..65535})
    => integer {0..65535}
begin
    if _BundleDimensionPresent[[2]] then
        if UInt(_BundleDimensions[[2]]) <= 65535 then
            return UInt(_BundleDimensions[[2]]) as integer {0..65535};
        end;
        return 0;
    end;
    let shared = SharedTileRecord(shared_tile_id);
    if shared.descriptor_valid then return shared.tile.columns; end;
    return valid_columns;
end;

readonly func BundleSharedTMOVLocalSchemaLegal() => boolean
begin
    if BundleSharedBindingCount() != 1 ||
       BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let shared_size = BundleSharedBindingSize(0);
    let shared_mask = BundleSharedBindingMask(0);
    if !binding.valid || binding.destination_valid ||
       !binding.source0_valid || binding.source1_valid || !binding.last ||
       binding.destination_size != 0 ||
       !TileSizeCodeIsLegal(shared_size) ||
       binding.pe_mask != shared_mask then return FALSE; end;
    if shared_mask == Zeros{4} then return TRUE; end;
    if !TileSourceContentsDefined(binding.source0) ||
       _Tiles[[binding.source0]].capacity_bytes !=
           TileSizeCodeBytes(shared_size as integer {1..12}) then
        return FALSE;
    end;
    var candidate = _Tiles[[binding.source0]];
    candidate.location = TileLocation_Any;
    return SharedTileUpdateCompatible(
        BundleSharedBindingId(0), candidate, shared_mask);
end;

readonly func BundleSharedTMOVDestinationSchemaLegal(
    shared_tile_id: SharedTileID, function: integer {0..31}) => boolean
begin
    if BundleSharedBindingCount() != 1 ||
       BundleTileBindingCount() != 1 then return FALSE; end;
    let binding = _BundleTileBindings[[0]];
    let shared_mask = BundleSharedBindingMask(0);
    if !binding.valid || !binding.destination_valid ||
       binding.source0_valid || binding.source1_valid || !binding.last ||
       !LocalTileSizeCodeIsLegal(binding.destination_size) ||
       BundleSharedBindingIsDestination(0) ||
       binding.pe_mask != shared_mask then return FALSE; end;
    if shared_mask == Zeros{4} then return TRUE; end;
    let capacity_bytes = TileSizeCodeBytes(
        binding.destination_size as integer {1..12});
    let valid_rows = BundleDestinationValidRows(FALSE, 0);
    let valid_columns = BundleDestinationValidColumns(FALSE, 0);
    let columns = BundleDestinationPhysicalColumns(FALSE, 0);
    if valid_rows < 1 || valid_columns < 1 || columns < 1 ||
       valid_columns > columns then return FALSE; end;
    let data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    let layout = CurrentBundleTileLayout();
    if _BundleSharedBindings[[0]].source0_subview.valid then
        if !BundleSharedSubviewLegal(0) then return FALSE; end;
        let view = MaterializeBundleSharedSubview(0);
        if view.capacity_bytes != capacity_bytes ||
           view.valid_rows != valid_rows ||
           view.valid_columns != valid_columns ||
           view.columns != columns || view.data_type != data_type ||
           view.layout != layout then
            return FALSE;
        end;
        return function == 2;
    end;
    if !SharedTileReadSchemaLegalAtCapacity(shared_tile_id, valid_rows,
           valid_columns, columns, data_type, layout, capacity_bytes) then
        return FALSE;
    end;
    return function == 2;
end;

func ExecuteBundleSharedTLSUOperation() => boolean
begin
    let function = UInt(_BundleOperation.selector[4:0]);
    if BundleSharedBindingCount() != 1 then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    let shared_tile_id = BundleSharedBindingId(0);
    let shared_size = BundleSharedBindingSize(0);
    let shared_mask = BundleSharedBindingMask(0);
    if shared_mask == Zeros{4} then return TRUE; end;
    let decoded = DecodeTileOperation(TileDecode_TLSU,
        BundleOperationDecodeCode(_BundleOperation));
    if decoded == PTO_TILE_OPERATION_COUNT then
        SetFault(Fault_IllegalInstruction, ReadTPC());
        return FALSE;
    end;
    let operation = decoded as integer {0..PTO_TILE_OPERATION_COUNT-1};
    let transfer_data_type = TileDataTypeFromEncoding(
        CurrentBundleTileOperationDataTypeCode() as TileDataTypeEncoding);
    if (function == 0 || function == 1) &&
       !TileRegularTLSUDataTypeSupported(transfer_data_type) then
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if !BundleOperationScalarBindingSchemaLegal(operation) then
        SetFault(Fault_BundleControl, ReadTPC());
        return FALSE;
    end;
    if !SelectedBundleTileDataAttributesLegal(operation) then
        return FALSE;
    end;
    if function == 0 then
        if !BundleSharedBindingIsDestination(0) ||
           !TileSizeCodeIsLegal(shared_size) ||
           BundleTileBindingCount() != 0 then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        let valid_columns = UInt(_BundleDimensions[[0]]);
        let valid_rows = UInt(_BundleDimensions[[1]]);
        let columns = UInt(_BundleDimensions[[2]]);
        if valid_columns < 1 || valid_columns > 65535 ||
           valid_rows < 1 || valid_rows > 65535 ||
           columns < 1 || columns > 65535 || valid_columns > columns then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        var load_base_addresses: CorePEWords;
        var load_row_stride_bytes: CorePEWords;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            load_base_addresses[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source0)
                else Zeros{PTO_XLEN};
            load_row_stride_bytes[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source1)
                else TileDenseRowStrideBytes(
                    columns as integer {0..65535}, transfer_data_type);
        end;
        let assembling =
            _BundleSharedBindings[[0]].destination_assemble.valid;
        var prior_shared = SharedTileRecord(shared_tile_id);
        if assembling then
            prior_shared = BeginBundleSharedGenerationProbe(shared_tile_id);
        end;
        TLOADShared(shared_tile_id, load_base_addresses, load_row_stride_bytes,
            shared_size as integer {1..12}, valid_rows as integer {1..65535},
            columns as integer {1..65535},
            valid_rows as integer {1..65535},
            valid_columns as integer {1..65535},
            transfer_data_type,
            CurrentBundleTileLayout(), shared_mask);
        if assembling then
            let candidate = SharedTileRecord(shared_tile_id);
            RestoreBundleSharedGenerationProbe(shared_tile_id, prior_shared);
            if _LastFault == Fault_None &&
               !CommitBundleSharedGenerationCandidate(0, candidate) then
                SetFault(Fault_TileLegality, ReadTPC());
            end;
        end;
    elsif function == 1 then
        if !SharedStorePEMaskLegal(function, shared_mask) ||
           BundleSharedBindingIsDestination(0) ||
           BundleTileBindingCount() != 0 then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        // Shared source readiness is a parent-level hardware gate. Pending or
        // incomplete generations wait with no payload read or GM effect.
        if !SharedTilePublished(shared_tile_id) then
            ConsumeBundleSharedBindings(1);
            FinalizeBundleTileAttempt(TileExecution_Executed);
            return TRUE;
        end;
        let store_valid_columns = BundleSharedStoreValidColumns(shared_tile_id);
        let store_valid_rows = BundleSharedStoreValidRows(shared_tile_id);
        let store_columns = BundleSharedStoreColumns(
            shared_tile_id, store_valid_columns);
        let store_data_type = transfer_data_type;
        let store_layout = CurrentBundleTileLayout();
        let has_subview =
            _BundleSharedBindings[[0]].source0_subview.valid;
        if has_subview && !BundleSharedSubviewLegal(0) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        if !has_subview && (store_valid_columns < 1 || store_valid_rows < 1 ||
           store_columns < 1 || store_valid_columns > store_columns ||
           !SharedTileReadSchemaLegal(shared_tile_id, store_valid_rows,
               store_valid_columns, store_columns, store_data_type,
               store_layout)) then
            SetFault(Fault_TileLegality, ReadTPC());
            return FALSE;
        end;
        var store_base_addresses: CorePEWords;
        var store_row_stride_bytes: CorePEWords;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            let agent = pe as MemoryAgentId;
            store_base_addresses[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source0)
                else Zeros{PTO_XLEN};
            store_row_stride_bytes[[agent]] =
                if _BundleScalarBindings[[0]].valid then
                    ReadPEAbsoluteGPROperand(agent,
                        _BundleScalarBindings[[0]].source1)
                else TileDenseRowStrideBytes(
                    store_columns as integer {0..65535}, store_data_type);
        end;
        if has_subview then
            var per_pe_store_tiles: CorePETileInfos;
            for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                let agent = pe as MemoryAgentId;
                per_pe_store_tiles[[agent]] =
                    MaterializeBundleSharedSubviewForPE(0, agent);
            end;
            TSTORESharedPerPE(store_base_addresses, store_row_stride_bytes,
                per_pe_store_tiles, shared_mask);
        else
            let store_tile = MaterializeSharedTileForReadSchema(
                shared_tile_id, store_valid_rows, store_valid_columns,
                store_columns, store_data_type, store_layout);
            TSTOREShared(store_base_addresses, store_row_stride_bytes,
                shared_tile_id, store_tile, shared_mask);
        end;
    elsif function == 2 then
        let shared_is_destination = BundleSharedBindingIsDestination(0);
        if shared_is_destination then
            if !BundleSharedTMOVLocalSchemaLegal() then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            let binding = _BundleTileBindings[[0]];
            let assembling =
                _BundleSharedBindings[[0]].destination_assemble.valid;
            var prior_shared = SharedTileRecord(shared_tile_id);
            if assembling then
                prior_shared = BeginBundleSharedGenerationProbe(shared_tile_id);
            end;
            TMOVLocalToShared(shared_tile_id, binding.source0,
                shared_size as integer {1..12}, shared_mask, !assembling);
            if assembling then
                let candidate = SharedTileRecord(shared_tile_id);
                RestoreBundleSharedGenerationProbe(shared_tile_id, prior_shared);
                if _LastFault == Fault_None &&
                   !CommitBundleSharedGenerationCandidate(0, candidate) then
                    SetFault(Fault_TileLegality, ReadTPC());
                end;
            end;
        else
            // The same parent-level readiness gate applies before any Local
            // destination allocation or Shared payload materialization.
            if !SharedTilePublished(shared_tile_id) then
                ConsumeBundleSharedBindings(1);
                FinalizeBundleTileAttempt(TileExecution_Executed);
                return TRUE;
            end;
            if !BundleSharedTMOVDestinationSchemaLegal(shared_tile_id, function) ||
               !SelectedBundleTileMasksLegal() then
                if _LastFault == Fault_None then
                    SetFault(Fault_TileLegality, ReadTPC());
                end;
                return FALSE;
            end;
            let binding = _BundleTileBindings[[0]];
            let capacity_bytes = TileSizeCodeBytes(
                binding.destination_size as integer {1..12});
            let valid_rows = BundleDestinationValidRows(FALSE, 0);
            let valid_columns = BundleDestinationValidColumns(FALSE, 0);
            let columns = BundleDestinationPhysicalColumns(FALSE, 0);
            let data_type = TileDataTypeFromEncoding(
                CurrentBundleTileOperationDataTypeCode()
                    as TileDataTypeEncoding);
            let has_subview =
                _BundleSharedBindings[[0]].source0_subview.valid;
            let shared_tile = if has_subview then
                MaterializeBundleSharedSubview(0)
            else MaterializeSharedTileForReadSchemaAtCapacity(
                shared_tile_id, valid_rows, valid_columns, columns, data_type,
                CurrentBundleTileLayout(), capacity_bytes);
            if !ResolveBundleTileDestinations() then return FALSE; end;
            let destination = _BundleTileBindings[[0]].destination;
            if _Tiles[[destination]].rows != shared_tile.rows ||
               _Tiles[[destination]].columns != shared_tile.columns ||
               _Tiles[[destination]].valid_rows != shared_tile.valid_rows ||
               _Tiles[[destination]].valid_columns != shared_tile.valid_columns ||
               _Tiles[[destination]].data_type != shared_tile.data_type ||
               _Tiles[[destination]].layout != shared_tile.layout then
                RollBackBundleTileDestinations();
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            if has_subview then
                var per_pe_shared_tiles: CorePETileInfos;
                for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
                    let agent = pe as MemoryAgentId;
                    per_pe_shared_tiles[[agent]] =
                        MaterializeBundleSharedSubviewForPE(0, agent);
                end;
                TMOVSharedToLocalPerPE(destination, per_pe_shared_tiles,
                    shared_mask);
            else
                TMOVSharedToLocal(destination, shared_tile_id, shared_tile,
                    shared_mask);
            end;
        end;
    else
        SetFault(Fault_TileLegality, ReadTPC());
        return FALSE;
    end;
    if _LastFault != Fault_None then
        RollBackBundleTileDestinations();
        return FALSE;
    end;
    ConsumeBundleSharedBindings(1);
    FinalizeBundleTileAttempt(TileExecution_Executed);
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
