<!-- GENERATED FROM: asl/block/model/operands/tile-bindings.asl -->
# Tile Bindings

**Normative ASL source:** `asl/block/model/operands/tile-bindings.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/tile-bindings.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","surface":"block","classification":["model","operands","tile-bindings"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-STATE-DESCRIPTORS"]}
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
    _BundleTileBindings[[index]].parent_ref_valid = FALSE;
    _BundleTileBindings[[index]].parent_ref_relative = FALSE;
    _BundleTileBindings[[index]].parent_ref = 0;
    _BundleTileBindings[[index]].last = last;
end;

func MarkBundleTileBindingSourcesRelative(index: BundleTileBindingIndex)
begin
    _BundleTileBindings[[index]].source0_relative =
        _BundleTileBindings[[index]].source0_valid;
    _BundleTileBindings[[index]].source1_relative =
        _BundleTileBindings[[index]].source1_valid;
end;

readonly func BundleLocalTileParentRefCount() => integer {0..16}
begin
    var count: integer {0..16} = 0;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].parent_ref_valid then
            count = (count + 1) as integer {0..16};
        end;
    end;
    return count;
end;

readonly func BundleLocalTileParentRefIsFinal() => boolean
begin
    var final_binding: integer {0..15} = 0;
    var found = FALSE;
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid then
            final_binding = binding as integer {0..15};
            found = TRUE;
        end;
    end;
    if !found || BundleLocalTileParentRefCount() != 1 then return FALSE; end;
    return _BundleTileBindings[[final_binding]].parent_ref_valid &&
           _BundleTileBindings[[final_binding]].last;
end;

// Convert one already validated continuation ParentRef into the semantic
// destination consumed by schemas and handlers. A parent-only final carrier
// is folded into the preceding ordinary binding so it does not add an operand
// group. The selected Tile already exists and is never allocated here.
func BindBundleLocalGenerationDestination(
    binding: BundleTileBindingIndex, generation_slot: integer {0..63},
    selected: TileIndex)
begin
    let destination = _LocalGenerations[[generation_slot]].working_destination;
    let assemble = _BundleTileBindings[[binding]].destination_assemble;
    var semantic_binding = binding;
    if !_BundleTileBindings[[binding]].source0_valid &&
       !_BundleTileBindings[[binding]].source1_valid then
        var prior_found = FALSE;
        for prior = 0 to binding - 1 do
            if _BundleTileBindings[[prior]].valid then
                semantic_binding = prior as BundleTileBindingIndex;
                prior_found = TRUE;
            end;
        end;
        if prior_found then
            assert !_BundleTileBindings[[semantic_binding]].destination_valid;
            assert !_BundleTileBindings[[semantic_binding]].parent_ref_valid;
            assert !_BundleTileBindings[[semantic_binding]].destination_assemble.valid;
            _BundleTileBindings[[semantic_binding]].parent_ref_valid = TRUE;
            _BundleTileBindings[[semantic_binding]].parent_ref_relative = FALSE;
            _BundleTileBindings[[semantic_binding]].parent_ref = selected;
            _BundleTileBindings[[semantic_binding]].destination_assemble = assemble;
            _BundleTileBindings[[semantic_binding]].last = TRUE;
            _BundleTileBindings[[binding]].valid = FALSE;
        end;
    end;
    _BundleTileBindings[[semantic_binding]].destination_valid = TRUE;
    _BundleTileBindings[[semantic_binding]].destination = destination;
    _BundleTileBindings[[semantic_binding]].destination_hand =
        Zeros{2} + _LocalGenerations[[generation_slot]].destination_hand;
    _BundleTileBindings[[semantic_binding]].destination_size =
        _LocalGenerations[[generation_slot]].parent_size_code;
    _BundleTileBindings[[semantic_binding]].destination_allocated_by_bundle = FALSE;
    _BundleTileBindings[[semantic_binding]].destination_reused_by_generation = TRUE;
end;

readonly func BundleLocalGenerationPEPublicationEligible(
    slot: integer {0..63}, pe: integer {0..3}) => boolean
begin
    if !_LocalGenerations[[slot]].last_seen ||
       !_LocalGenerations[[slot]].parent_descriptor.valid ||
       _LocalGenerations[[slot]].participant_mask[
           PTOPEMaskBitOfPEIdentity(pe)] == '0' then return FALSE; end;
    let required = _LocalGenerations[[slot]].parent_cell_count;
    if required == 0 || required > 2048 then return FALSE; end;
    for cell = 0 to 2047 do
        if cell < required &&
           (_LocalGenerations[[slot]].per_pe_covered_cells[[pe]][cell] == '0' ||
            _LocalGenerations[[slot]].per_pe_ready_cells[[pe]][cell] == '0') then
            return FALSE;
        end;
    end;
    return TRUE;
end;

readonly func BundlePendingRelativeGeneration(
    binding: BundleTileBindingIndex, selector: TileIndex) => boolean
begin
    // Local generations are inserted into the ordinary relative queue at
    // successful INIT allocation.  No private assemble namespace or fallback
    // is used; an explicitly selected open entry remains that exact entry.
    return FALSE;
end;

readonly func BundleRelativeTileSourceAvailable(
    binding: BundleTileBindingIndex, selector: TileIndex) => boolean
begin
    return RelativeTileSourceAvailable(selector);
end;

readonly func ResolveBundleRelativeTileSource(
    binding: BundleTileBindingIndex, selector: TileIndex) => TileIndex
begin
    assert BundleRelativeTileSourceAvailable(binding, selector);
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
            if _BundleTileBindings[[binding]].parent_ref_valid &&
               _BundleTileBindings[[binding]].parent_ref_relative then
                if !RelativeTileSourceAvailable(
                       _BundleTileBindings[[binding]].parent_ref) then
                    SetFault(Fault_TileLegality, ReadTPC());
                    return FALSE;
                end;
                _BundleTileBindings[[binding]].parent_ref =
                    ResolveRelativeTileSource(
                        _BundleTileBindings[[binding]].parent_ref);
                _BundleTileBindings[[binding]].parent_ref_relative = FALSE;
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
```
<!-- GENERATED-ASL-END: unit -->
