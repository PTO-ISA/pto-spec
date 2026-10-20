// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS","surface":"block","classification":["model","operands","shared-bindings"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS","PTO-BLOCK-MODEL-STATE-SOURCE-LIFETIME","PTO-SCALAR-MODEL-TYPES-OPERANDS"]}
readonly func BundleSharedSubviewOffsetRawForPE(
    binding: BundleSharedBindingIndex, pe_identity: MemoryAgentId) => Word
begin
    let modifier = _BundleSharedBindings[[binding]].source0_subview;
    return ReadPEAbsoluteGPROperand(pe_identity, modifier.reg_src) +
        ZeroExtend{PTO_XLEN}(modifier.uimm11);
end;

readonly func BundleSharedSubviewOffsetCellsForPE(
    binding: BundleSharedBindingIndex, pe_identity: MemoryAgentId)
    => integer {0..2047}
begin
    let raw_offset = UInt(BundleSharedSubviewOffsetRawForPE(
        binding, pe_identity));
    assert raw_offset <= 2047;
    return raw_offset as integer {0..2047};
end;

func BindBundleSharedIO(shared_tile_id: SharedTileID,
                        size_code: integer {0..12},
                        pe_mask: bits(4))
begin
    if !BundleSharedMaskCanAppend(pe_mask) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid &&
           _BundleSharedBindings[[index]].shared_tile_id == shared_tile_id then
            SetFault(Fault_BundleControl, ReadTPC());
            return;
        end;
    end;
    for index = 0 to 3 do
        if !_BundleSharedBindings[[index]].valid then
            _BundleSharedBindings[[index]].valid = TRUE;
            _BundleSharedBindings[[index]].shared_tile_id = shared_tile_id;
            _BundleSharedBindings[[index]].size_code = size_code;
            _BundleSharedBindings[[index]].pe_mask = pe_mask;
            _BundleSharedBindings[[index]].source_reuse = TRUE;
            _BundleSharedBindings[[index]].source_lifetime_captured = FALSE;
            _BundleSharedBindings[[index]].source_lifetime_ordinal = 0;
            _BundleSharedBindings[[index]].consumed = FALSE;
            return;
        end;
    end;
    SetFault(Fault_BundleControl, ReadTPC());
end;

func BindBundleSharedIOWithReuse(
    shared_tile_id: SharedTileID, size_code: integer {0..12},
    pe_mask: bits(4), source_reuse: boolean)
begin
    BindBundleSharedIO(shared_tile_id, size_code, pe_mask);
    if _LastFault == Fault_None then
        let binding = BundleSharedBindingLastIndex();
        _BundleSharedBindings[[binding]].source_reuse = source_reuse;
    end;
end;

readonly func BundleSharedSourcePayloadsAvailable() => boolean
begin
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].size_code == 0 &&
           !BundleSharedBindingIsReusedDestination(binding) &&
           !SharedTilePayloadIntact(
               _BundleSharedBindings[[binding]].shared_tile_id) then
            return FALSE;
        end;
    end;
    return TRUE;
end;

func RequireBundleSharedSourcePayloads() => boolean
begin
    if BundleSharedSourcePayloadsAvailable() &&
       CaptureBundleSharedSourceLifetimes() then return TRUE; end;
    if BundleSharedSourcePayloadsAvailable() then return FALSE; end;
    SetFault(Fault_TileLegality, ReadTPC());
    return FALSE;
end;

func CaptureBundleSharedSourceLifetimes() => boolean
begin
    if !_CurrentPEContextValid then
        return TRUE;
    end;
    let participant = PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent);
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].size_code == 0 &&
           !BundleSharedBindingIsReusedDestination(binding) &&
           !_BundleSharedBindings[[binding]].source_reuse &&
           _BundleSharedBindings[[binding]].pe_mask[participant] == '1' then
            let shared_id = _BundleSharedBindings[[binding]].shared_tile_id;
            let shared = SharedTileRecord(shared_id);
            let ordinal = CaptureBundleSourceLifetime(TRUE,
                0, UInt(shared_id) as TileIndex, 0,
                shared.payload_generation,
                _BundleSharedBindings[[binding]].pe_mask,
                _BundleSharedBindings[[binding]].source_lifetime_ordinal);
            if ordinal == 0 then return FALSE; end;
            _BundleSharedBindings[[binding]].source_lifetime_captured = TRUE;
            _BundleSharedBindings[[binding]].source_lifetime_ordinal = ordinal;
        end;
    end;
    return TRUE;
end;

// Every Shared destination path passes this common pre-effect gate, including
// ordinary destinations and INIT/continuation B.ASSEMBLE destinations.
readonly func BundleSharedPublicationAvailable() => boolean
begin
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           (_BundleSharedBindings[[binding]].size_code != 0 ||
            BundleSharedBindingIsReusedDestination(binding)) then
            let participant = !_CurrentPEContextValid ||
                _BundleSharedBindings[[binding]].pe_mask[
                    PTOPEMaskBitOfPEIdentity(_CurrentMemoryAgent)] == '1';
            if participant && SharedSourceLifetimePinned(
                   _BundleSharedBindings[[binding]].shared_tile_id) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

func FinalizeBundleSharedLastUseSources()
begin
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].size_code == 0 &&
           !BundleSharedBindingIsReusedDestination(binding) &&
           !_BundleSharedBindings[[binding]].source_reuse then
            if _BundleSharedBindings[[binding]].source_lifetime_captured then
                CompleteBundleSourceLifetime(
                    _BundleSharedBindings[[binding]].source_lifetime_ordinal);
            elsif !_CurrentPEContextValid then
                ConsumeSharedTilePayload(
                    _BundleSharedBindings[[binding]].shared_tile_id);
            end;
        end;
    end;
end;

readonly func BundleSharedMaskCanAppend(pe_mask: bits(4)) => boolean
begin
    if !BundleTileMaskCanAppend(pe_mask) then return FALSE; end;
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid &&
           _BundleSharedBindings[[index]].pe_mask != pe_mask then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func BundleSharedBindingPhysicalCount() => integer {0..4}
begin
    var count: integer {0..4} = 0;
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid then
            count = (count + 1) as integer {0..4};
        end;
    end;
    return count;
end;

// A Shared B.IOS SizeCode=0 binder is ordinary source material except when the
// same physical binder is immediately marked by a B.ASSEMBLE continuation.
readonly func BundleSharedBindingIsReusedDestination(
    ordinal: integer {0..3}) => boolean
begin
    return _BundleSharedBindings[[ordinal]].valid &&
           _BundleSharedBindings[[ordinal]].size_code == 0 &&
           _BundleSharedBindings[[ordinal]].destination_assemble.valid &&
           !_BundleSharedBindings[[ordinal]].destination_assemble.init;
end;

readonly func BundleSharedReusedDestinationCount() => integer {0..4}
begin
    var count: integer {0..4} = 0;
    for index = 0 to 3 do
        if BundleSharedBindingIsReusedDestination(index) then
            count = (count + 1) as integer {0..4};
        end;
    end;
    return count;
end;

readonly func BundleSharedReusedDestinationIsFinal() => boolean
begin
    var final_binding: integer {0..3} = 0;
    var found = FALSE;
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid then
            final_binding = index as integer {0..3};
            found = TRUE;
        end;
    end;
    if !found || BundleSharedReusedDestinationCount() != 1 then return FALSE; end;
    return BundleSharedBindingIsReusedDestination(final_binding);
end;

readonly func BundleSharedBindingCount() => integer {0..4}
begin
    var count: integer {0..4} = 0;
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid &&
           !BundleSharedBindingIsReusedDestination(index) then
            count = (count + 1) as integer {0..4};
        end;
    end;
    return count;
end;

readonly func BundleSharedPhysicalDestinationCount() => integer {0..4}
begin
    var count: integer {0..4} = 0;
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid &&
           _BundleSharedBindings[[index]].size_code != 0 then
            count = (count + 1) as integer {0..4};
        end;
    end;
    return count;
end;

readonly func BundleSharedBindingLastIndex() => integer {0..3}
begin
    var last: integer {0..3} = 0;
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid then
            last = index as integer {0..3};
        end;
    end;
    return last;
end;

readonly func BundleSharedBindingId(ordinal: integer {0..3}) => SharedTileID
begin
    assert _BundleSharedBindings[[ordinal]].valid &&
           !_BundleSharedBindings[[ordinal]].consumed;
    return _BundleSharedBindings[[ordinal]].shared_tile_id;
end;

readonly func BundleSharedBindingSize(ordinal: integer {0..3})
        => integer {0..12}
begin
    assert _BundleSharedBindings[[ordinal]].valid &&
           !_BundleSharedBindings[[ordinal]].consumed;
    return _BundleSharedBindings[[ordinal]].size_code;
end;

readonly func BundleSharedBindingMask(ordinal: integer {0..3}) => bits(4)
begin
    assert _BundleSharedBindings[[ordinal]].valid &&
           !_BundleSharedBindings[[ordinal]].consumed;
    return _BundleSharedBindings[[ordinal]].pe_mask;
end;

readonly func BundleSharedBindingIsDestination(
    ordinal: integer {0..3}) => boolean
begin
    return BundleSharedBindingSize(ordinal) != 0;
end;

func ConsumeBundleSharedBindings(count: integer {1..4})
begin
    assert BundleSharedBindingCount() == count ||
           BundleSharedBindingPhysicalCount() == count;
    var ordinary_consumed: integer {0..4} = 0;
    for index = 0 to 3 looplimit 4 do
        if _BundleSharedBindings[[index]].valid &&
           !_BundleSharedBindings[[index]].consumed &&
           !BundleSharedBindingIsReusedDestination(index) &&
           ordinary_consumed < count then
            _BundleSharedBindings[[index]].consumed = TRUE;
            ordinary_consumed = (ordinary_consumed + 1) as integer {0..4};
        end;
    end;
    assert ordinary_consumed == BundleSharedBindingCount();
end;

readonly func BundleSharedBindingsUnconsumed() => boolean
begin
    for index = 0 to 3 do
        if _BundleSharedBindings[[index]].valid &&
           !BundleSharedBindingIsReusedDestination(index) &&
           !_BundleSharedBindings[[index]].consumed then return TRUE; end;
    end;
    return FALSE;
end;

readonly func BundleTileMaskCanAppend(pe_mask: bits(4)) => boolean
begin
    if pe_mask == Zeros{4} then return FALSE; end;
    for index = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[index]].valid &&
           _BundleTileBindings[[index]].pe_mask != pe_mask then
            return FALSE;
        end;
    end;
    return TRUE;
end;
