// PTO-UNIT: {"id":"PTO-TILE-MODEL-CAPACITY-LOCAL","surface":"tile","classification":["model","capacity","local"],"depends_on":["PTO-ARCH-STATE-PE-EXECUTION-CONTEXT","PTO-TILE-MODEL-STATE-SHARED-REGISTERS"]}
readonly func TileCapacityLimitBytes() => integer {0..262144}
begin
    assert UInt(_SystemRegisters.tile_capacity) <=
        PTO_MODEL_MAX_TILE_CAPACITY_BYTES;
    return UInt(_SystemRegisters.tile_capacity) as integer {0..262144};
end;

readonly func TileCapacityInUseExcept(excluded: TileIndex) => integer
begin
    if _CurrentPEContextValid then
        var bank_total: integer = 0;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            bank_total = bank_total +
                TileCapacityInUseExceptForPE(excluded, pe);
        end;
        return bank_total;
    end;
    var total: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if index != excluded && _Tiles[[index]].allocated then
            total = total + TileCoreAllocationBytes(
                _TilePayloadLiveMasks[[index]],
                _Tiles[[index]].capacity_bytes);
        end;
    end;
    return total;
end;

readonly func TileCapacityInUseForPE(
    pe_identity: integer {0..3}) => integer
begin
    var total: integer = 0;
    let mask_bit = PTOPEMaskBitOfPEIdentity(pe_identity);
    if !_CurrentPEContextValid || pe_identity == _CurrentMemoryAgent then
        for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
            if _Tiles[[index]].allocated &&
               _TilePayloadLiveMasks[[index]][mask_bit] == '1' then
                total = total + _Tiles[[index]].capacity_bytes;
            end;
        end;
        return total;
    end;
    let core = _CurrentModelCore;
    if _PEContextBankValid[[core]][pe_identity] == '1' then
        for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
            if _PEExecutionContexts[[core]][[pe_identity]].tiles[[index]].allocated &&
               _PEExecutionContexts[[core]][[pe_identity]]
                   .tile_payload_live_masks[[index]][mask_bit] == '1' then
                total = total + _PEExecutionContexts[[core]][[pe_identity]]
                    .tiles[[index]].capacity_bytes;
            end;
        end;
    else
        for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
            if _DefaultPEExecutionContext.tiles[[index]].allocated &&
               _DefaultPEExecutionContext.tile_payload_live_masks[[index]]
                   [mask_bit] == '1' then
                total = total + _DefaultPEExecutionContext.tiles[[index]]
                    .capacity_bytes;
            end;
        end;
    end;
    return total;
end;

readonly func TileCapacityInUseExceptForPE(
    excluded: TileIndex, pe_identity: integer {0..3}) => integer
begin
    var total: integer = 0;
    let mask_bit = PTOPEMaskBitOfPEIdentity(pe_identity);
    if !_CurrentPEContextValid || pe_identity == _CurrentMemoryAgent then
        for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
            if index != excluded && _Tiles[[index]].allocated &&
               _TilePayloadLiveMasks[[index]][mask_bit] == '1' then
                total = total + _Tiles[[index]].capacity_bytes;
            end;
        end;
        return total;
    end;
    let core = _CurrentModelCore;
    if _PEContextBankValid[[core]][pe_identity] == '1' then
        for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
            if index != excluded &&
               _PEExecutionContexts[[core]][[pe_identity]].tiles[[index]].allocated &&
               _PEExecutionContexts[[core]][[pe_identity]]
                   .tile_payload_live_masks[[index]][mask_bit] == '1' then
                total = total + _PEExecutionContexts[[core]][[pe_identity]]
                    .tiles[[index]].capacity_bytes;
            end;
        end;
    else
        for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
            if index != excluded &&
               _DefaultPEExecutionContext.tiles[[index]].allocated &&
               _DefaultPEExecutionContext.tile_payload_live_masks[[index]]
                   [mask_bit] == '1' then
                total = total + _DefaultPEExecutionContext.tiles[[index]]
                    .capacity_bytes;
            end;
        end;
    end;
    return total;
end;

readonly func LocalTileAllocationFitsExcept(
    excluded: TileIndex, pe_mask: bits(4), per_pe_bytes: integer) => boolean
begin
    if _CurrentPEContextValid then
        let pe = _CurrentMemoryAgent;
        let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
        return pe_mask[mask_bit] == '0' ||
            TileCapacityInUseExceptForPE(excluded, pe) + per_pe_bytes <=
                TileCapacityLimitBytes();
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
        if pe_mask[mask_bit] == '1' &&
           TileCapacityInUseExceptForPE(excluded, pe) + per_pe_bytes >
               TileCapacityLimitBytes() then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func LocalTileAllocationFits(
    pe_mask: bits(4), per_pe_bytes: integer) => boolean
begin
    if _CurrentPEContextValid then
        let pe = _CurrentMemoryAgent;
        let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
        return pe_mask[mask_bit] == '0' ||
            TileCapacityInUseForPE(pe) + per_pe_bytes <=
                TileCapacityLimitBytes();
    end;
    for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
        let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
        if pe_mask[mask_bit] == '1' &&
           TileCapacityInUseForPE(pe) + per_pe_bytes >
               TileCapacityLimitBytes() then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func LocalTileAllocationGroupFits(
    additional0: integer, additional1: integer,
    additional2: integer, additional3: integer) => boolean
begin
    if _CurrentPEContextValid then
        case _CurrentMemoryAgent of
            when 0 => return TileCapacityInUseForPE(0) + additional0 <=
                TileCapacityLimitBytes();
            when 1 => return TileCapacityInUseForPE(1) + additional1 <=
                TileCapacityLimitBytes();
            when 2 => return TileCapacityInUseForPE(2) + additional2 <=
                TileCapacityLimitBytes();
            when 3 => return TileCapacityInUseForPE(3) + additional3 <=
                TileCapacityLimitBytes();
        end;
    end;
    return TileCapacityInUseForPE(0) + additional0 <=
               TileCapacityLimitBytes() &&
           TileCapacityInUseForPE(1) + additional1 <=
               TileCapacityLimitBytes() &&
           TileCapacityInUseForPE(2) + additional2 <=
               TileCapacityLimitBytes() &&
           TileCapacityInUseForPE(3) + additional3 <=
               TileCapacityLimitBytes();
end;

readonly func TileCapacityInUse() => integer
begin
    if _CurrentPEContextValid then
        var bank_total: integer = 0;
        for pe = 0 to PTO_MODEL_MEMORY_AGENTS - 1 do
            bank_total = bank_total + TileCapacityInUseForPE(pe);
        end;
        return bank_total;
    end;
    var total: integer = 0;
    for index = 0 to PTO_TILE_REGISTER_COUNT - 1 do
        if _Tiles[[index]].allocated then
            total = total + TileCoreAllocationBytes(
                _TilePayloadLiveMasks[[index]],
                _Tiles[[index]].capacity_bytes);
        end;
    end;
    return total;
end;
