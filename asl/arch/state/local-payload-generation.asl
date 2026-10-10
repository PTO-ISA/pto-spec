// PTO-UNIT: {"id":"PTO-ARCH-STATE-LOCAL-PAYLOAD-GENERATION","surface":"arch","classification":["state","local-payload-generation"],"depends_on":["PTO-ARCH-STATE-PE-EXECUTION-CONTEXT"]}

readonly func LocalTilePayloadGeneration(
    pe: MemoryAgentId, index: TileIndex) => integer
begin
    if pe == _CurrentMemoryAgent then
        return _TilePayloadGenerations[[index]];
    end;
    let core = _CurrentModelCore;
    if _PEContextBankValid[[core]][pe] == '1' then
        return _PEExecutionContexts[[core]][[pe]]
            .tile_payload_generations[[index]];
    end;
    return _DefaultPEExecutionContext.tile_payload_generations[[index]];
end;

func ConsumeLocalTilePayloadGeneration(
    pe: MemoryAgentId, index: TileIndex, generation: integer)
begin
    let mask_bit = PTOPEMaskBitOfPEIdentity(pe);
    if pe == _CurrentMemoryAgent then
        if _Tiles[[index]].allocated &&
           _TilePayloadGenerations[[index]] == generation then
            _TilePayloadLiveMasks[[index]][mask_bit] = '0';
        end;
        return;
    end;
    let core = _CurrentModelCore;
    if _PEContextBankValid[[core]][pe] == '1' &&
       _PEExecutionContexts[[core]][[pe]].tiles[[index]].allocated &&
       _PEExecutionContexts[[core]][[pe]]
           .tile_payload_generations[[index]] == generation then
        _PEExecutionContexts[[core]][[pe]]
            .tile_payload_live_masks[[index]][mask_bit] = '0';
    end;
end;
