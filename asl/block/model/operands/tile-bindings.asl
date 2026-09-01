// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","surface":"block","classification":["model","operands","tile-bindings"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS","PTO-TILE-MODEL-STATE-DESCRIPTORS"]}
func SetBundleTileBinding(index: BundleTileBindingIndex,
                         destination_valid: boolean,
                         destination: TileIndex,
                         destination_size: integer {0..15},
                         pe_mask: bits(4),
                         source0_valid: boolean,
                         source1_valid: boolean,
                         source0: TileIndex,
                         source1: TileIndex,
                         last: boolean)
begin
    if destination_valid &&
       (destination > 3 || !LocalTileSizeCodeIsLegal(destination_size)) then
        SetFault(Fault_TileLegality, ReadTPC());
        return;
    end;
    _BundleTileBindings[[index]].valid = TRUE;
    _BundleTileBindings[[index]].destination_valid = destination_valid;
    _BundleTileBindings[[index]].destination = destination;
    _BundleTileBindings[[index]].destination_hand =
        Zeros{2} + (destination MOD 4);
    _BundleTileBindings[[index]].destination_allocated_by_bundle = FALSE;
    _BundleTileBindings[[index]].destination_reused_by_generation = FALSE;
    _BundleTileBindings[[index]].destination_size = destination_size;
    _BundleTileBindings[[index]].pe_mask = pe_mask;
    _BundleTileBindings[[index]].source0_valid = source0_valid;
    _BundleTileBindings[[index]].source1_valid = source1_valid;
    _BundleTileBindings[[index]].source0_relative = FALSE;
    _BundleTileBindings[[index]].source1_relative = FALSE;
    _BundleTileBindings[[index]].source0 = source0;
    _BundleTileBindings[[index]].source1 = source1;
    _BundleTileBindings[[index]].last = last;
end;

func MarkBundleTileBindingSourcesRelative(index: BundleTileBindingIndex)
begin
    _BundleTileBindings[[index]].source0_relative =
        _BundleTileBindings[[index]].source0_valid;
    _BundleTileBindings[[index]].source1_relative =
        _BundleTileBindings[[index]].source1_valid;
end;

readonly func BundlePendingRelativeGeneration(
    binding: BundleTileBindingIndex, selector: TileIndex) => boolean
begin
    let hand = RelativeTileHandIndex(selector);
    let mask = _BundleTileBindings[[binding]].pe_mask;
    let slot = (hand + UInt(mask) * 4) as integer {0..63};
    return _LocalGenerations[[slot]].closed &&
           !_LocalGenerations[[slot]].published &&
           _Tiles[[_LocalGenerations[[slot]].working_destination]].allocated;
end;

readonly func BundleRelativeTileSourceAvailable(
    binding: BundleTileBindingIndex, selector: TileIndex) => boolean
begin
    let distance = RelativeTileDistance(selector);
    if BundlePendingRelativeGeneration(binding, selector) then
        if distance == 0 then return TRUE; end;
        let shifted = ((RelativeTileHandIndex(selector) * 16 + distance) - 1)
            as TileIndex;
        return RelativeTileSourceAvailable(shifted);
    end;
    return RelativeTileSourceAvailable(selector);
end;

readonly func ResolveBundleRelativeTileSource(
    binding: BundleTileBindingIndex, selector: TileIndex) => TileIndex
begin
    assert BundleRelativeTileSourceAvailable(binding, selector);
    let distance = RelativeTileDistance(selector);
    if BundlePendingRelativeGeneration(binding, selector) then
        if distance == 0 then
            let hand = RelativeTileHandIndex(selector);
            let mask = _BundleTileBindings[[binding]].pe_mask;
            let slot = (hand + UInt(mask) * 4) as integer {0..63};
            return _LocalGenerations[[slot]].working_destination;
        end;
        let shifted = ((RelativeTileHandIndex(selector) * 16 + distance) - 1)
            as TileIndex;
        return ResolveRelativeTileSource(shifted);
    end;
    return ResolveRelativeTileSource(selector);
end;

func ResolveBundleRelativeTileSources() => boolean
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_relative &&
               !BundleRelativeTileSourceAvailable(
                   binding as BundleTileBindingIndex,
                   _BundleTileBindings[[binding]].source0) then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
            if _BundleTileBindings[[binding]].source1_relative &&
               !BundleRelativeTileSourceAvailable(
                   binding as BundleTileBindingIndex,
                   _BundleTileBindings[[binding]].source1) then
                SetFault(Fault_TileLegality, ReadTPC());
                return FALSE;
            end;
        end;
    end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            if _BundleTileBindings[[binding]].source0_relative then
                _BundleTileBindings[[binding]].source0 =
                    ResolveBundleRelativeTileSource(
                        binding as BundleTileBindingIndex,
                        _BundleTileBindings[[binding]].source0);
                _BundleTileBindings[[binding]].source0_relative = FALSE;
            end;
            if _BundleTileBindings[[binding]].source1_relative then
                _BundleTileBindings[[binding]].source1 =
                    ResolveBundleRelativeTileSource(
                        binding as BundleTileBindingIndex,
                        _BundleTileBindings[[binding]].source1);
                _BundleTileBindings[[binding]].source1_relative = FALSE;
            end;
        end;
    end;
    return TRUE;
end;

func AddBundleTileBinding(destination_valid: boolean,
                          destination: TileIndex,
                          destination_size: integer {0..15},
                          pe_mask: bits(4),
                          source0_valid: boolean,
                          source1_valid: boolean,
                          source0: TileIndex,
                          source1: TileIndex,
                          last: boolean)
begin
    if BundleTileBindingSequenceClosed() then
        SetFault(Fault_BundleControl, ReadTPC());
        return;
    end;
    var added = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if !added && !_BundleTileBindings[[binding]].valid then
            SetBundleTileBinding(binding as BundleTileBindingIndex,
                destination_valid, destination, destination_size, pe_mask,
                source0_valid, source1_valid, source0, source1, last);
            added = TRUE;
        end;
    end;
    if !added then SetFault(Fault_TileLegality, ReadTPC()); end;
end;

readonly func BundleTileBindingSequenceClosed() => boolean
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].last then
            return TRUE;
        end;
    end;
    return FALSE;
end;

readonly func BundleTileBindingLastIndex() => integer {0..15}
begin
    var last: integer {0..15} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            last = binding as integer {0..15};
        end;
    end;
    return last;
end;

readonly func BundleMatrixPrimaryDestinationHand()
    => (boolean, integer {0..3})
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid then
            return (TRUE,
                UInt(_BundleTileBindings[[binding]].destination_hand)
                    as integer {0..3});
        end;
    end;
    return (FALSE, 0);
end;

readonly func BundleTileDestinationSizeLegal(
    binding: BundleTileBindingIndex) => boolean
begin
    if !_BundleTileBindings[[binding]].destination_valid then return TRUE; end;
    return LocalTileSizeCodeIsLegal(
        _BundleTileBindings[[binding]].destination_size);
end;

readonly func BundleTileDestinationSizeBytes(
    binding: BundleTileBindingIndex)
    => integer {0,128,256,512,1024,2048,4096,8192,16384,32768,65536,
                131072,262144}
begin
    if !_BundleTileBindings[[binding]].destination_valid then return 0; end;
    assert BundleTileDestinationSizeLegal(binding);
    return TileSizeCodeBytes(
        _BundleTileBindings[[binding]].destination_size as integer {1..12})
        as integer {128,256,512,1024,2048,4096,8192,16384,32768,65536,
                    131072,262144};
end;

readonly func BundleTileIsDestination(tile: TileIndex) => boolean
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           _BundleTileBindings[[binding]].destination == tile then
            return TRUE;
        end;
    end;
    return FALSE;
end;

func FinalizeBundleTileAttempt(status: TileExecutionStatus)
begin
    if status != TileExecution_Executed then return; end;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_valid &&
           _BundleTileBindings[[binding]].destination_allocated_by_bundle &&
           !_BundleTileBindings[[binding]].destination_assemble.valid then
            PublishRelativeTileDestination(
                _BundleTileBindings[[binding]].destination);
        end;
    end;
end;
