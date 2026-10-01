<!-- GENERATED FROM: asl/block/model/operands/shared-bindings.asl -->
# Shared Bindings

**Normative ASL source:** `asl/block/model/operands/shared-bindings.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-shared-bindings-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the Shared bindings of a bundle. A Shared binding is the record left by one `B.IOS` header command. It names one Shared Tile, which is a Tile object that several PEs can read, together with a size code and a PE mask.

The unit appends bindings, counts them in several ways, marks them consumed, and checks that masks agree. It does not allocate or read a Shared Tile.

<!-- PTO-READER-BLOCK: block-model-operands-shared-bindings-concepts role=concepts-state -->
## Concepts and visible state

`_BundleSharedBindings` has four entries. Each holds `valid`, `shared_tile_id`, `size_code` (0 to 12), `pe_mask`, `consumed`, and two range modifiers: `source0_subview` and `destination_assemble`.

The size code sets the role. A nonzero size code makes the binding a destination of that capacity. Size code 0 makes it a source. A size-code-0 binding whose `destination_assemble` modifier is valid and is not an INIT phase is a reused destination: it names the Shared Tile that an open `B.ASSEMBLE` generation keeps building.

There are three counts. `BundleSharedBindingPhysicalCount` counts every valid entry. `BundleSharedBindingCount` excludes reused destinations. `BundleSharedPhysicalDestinationCount` counts entries with a nonzero size code.

<!-- PTO-READER-BLOCK: block-model-operands-shared-bindings-rules role=rules-interactions -->
## Rules and interactions

`BindBundleSharedIO(id, size, mask)` checks, in order:

1. `BundleSharedMaskCanAppend(mask)`: the mask is nonzero, equals the mask of every existing Tile binding, and equals the mask of every existing Shared binding. Otherwise it raises `Fault_TileLegality`.
2. No valid entry already names the same Shared Tile ID. Otherwise it raises `Fault_BundleControl`.
3. A free entry exists. It fills the first free entry and clears `consumed`. With four entries full, it raises `Fault_BundleControl`.

Design point: `BindBundleSharedIO` requires a new Shared binding's mask to equal the mask of every Tile and Shared binding already recorded, so a mismatched `B.IOS` is rejected at the header command. `BundleTileMaskCanAppend` compares a new Tile binding only with earlier Tile bindings, so a `B.IOT` that follows a `B.IOS` with a different mask is not rejected here; operation checks such as the Shared TLSU mask checks compare those masks later.

Design point: one Shared Tile ID may appear only once per bundle. `BindBundleSharedIO` rejects a repeated ID with `Fault_BundleControl` before it fills an entry, so every valid entry names a distinct Shared Tile.

`BundleSharedBindingId`, `BundleSharedBindingSize`, and `BundleSharedBindingMask` assert that the entry is valid and not consumed. `ConsumeBundleSharedBindings(count)` marks the first `count` ordinary entries consumed, skipping reused destinations. `BundleSharedBindingsUnconsumed` reports whether any ordinary entry is still unconsumed, and tile execution uses it.

<!-- PTO-READER-BLOCK: block-model-operands-shared-bindings-boundaries role=boundaries -->
## Architectural boundaries

The `B.IOS` handler runs three checks before this unit. It raises `Fault_IllegalInstruction` for a size code above 12. A zero PE mode (mask `0000`) is a strict no-op: inside a bundle header it records that zero participation was seen and opens a zero-mode range group, and in every case it advances `TPC`. Otherwise it raises `Fault_BundleControl` when no bundle is in its header phase.

`BundleSharedReusedDestinationIsFinal` is TRUE when exactly one reused destination exists and it is the last valid entry. Descriptor legality uses it. `BundleTileMaskCanAppend` also lives here and is shared with `B.IOT`.

<!-- PTO-READER-BLOCK: block-model-operands-shared-bindings-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A bundle binds Shared Tile 2 as a source (size 0, mask `1111`) and then Shared Tile 5 as a 4 KB destination (size 6, mask `1111`). Both calls succeed, so the physical count and the ordinary count are 2 and the destination count is 1. A third `B.IOS` for Shared Tile 2 raises `Fault_BundleControl`. A third `B.IOS` for Shared Tile 7 with mask `1000` raises `Fault_TileLegality`.

<!-- PTO-READER-BLOCK: block-model-operands-shared-bindings-related role=related-owners-navigation -->
## Related owners

- [Commands](../dispatch/commands.md) holds the `B.IOS` handler.
- [Range modifiers](range-modifiers.md) attaches subview and assemble modifiers to these entries.
- [Shared generation](shared-generation.md) uses reused destinations.
- [B.IOS](../../operands/B.IOS.md) is the command page.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/shared-bindings.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS","surface":"block","classification":["model","operands","shared-bindings"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS"]}
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
            _BundleSharedBindings[[index]].consumed = FALSE;
            return;
        end;
    end;
    SetFault(Fault_BundleControl, ReadTPC());
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
```
<!-- GENERATED-ASL-END: unit -->
