<!-- GENERATED FROM: asl/block/model/operands/range-modifiers.asl -->
# Range Modifiers

**Normative ASL source:** `asl/block/model/operands/range-modifiers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-range-modifiers-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the range-modifier group. A range modifier is a `B.SUBVIEW` or `B.ASSEMBLE` header command that refines the binder command just before it. `B.SUBVIEW` selects a range of a source. `B.ASSEMBLE` marks a destination, or a parent reference, as one writer of a multi-bundle build.

The ASL comment states the scope: the group is syntactic header state. It allocates no destination and consults no operation schema.

<!-- PTO-READER-BLOCK: block-model-operands-range-modifiers-concepts role=concepts-state -->
## Concepts and visible state

`_BundleRangeGroup` is one `BundleRangeGroupState` record:

- `open` and `zero_mode`;
- `kind`, which is `BundleRangeGroup_None`, `BundleRangeGroup_Local`, or `BundleRangeGroup_Shared`;
- `tile_binding` or `shared_binding`, the index of the binder that opened the group;
- `source0_allowed`, `source1_allowed`, `destination_allowed`, taken from the binder's encoded operands;
- `source0_seen`, `source1_seen`, `destination_seen`.

`OpenBundleRangeTileGroup` is called after a `B.IOT` and `OpenBundleRangeSharedGroup` after a `B.IOS`. A Shared group never allows source 1. A binder with PE mask `0000` opens a group with `zero_mode` TRUE and kind `None`.

<!-- PTO-READER-BLOCK: block-model-operands-range-modifiers-rules role=rules-interactions -->
## Rules and interactions

The command dispatcher calls `CloseBundleRangeGroup` for every header command that is not a range modifier. A modifier therefore attaches only to the binder immediately before it.

Roles must appear in the order source 0, source 1, destination, each at most once. `BundleRangeRoleLegal` rejects source 0 after source 1 or the destination, and source 1 after the destination.

`B.SUBVIEW` first rejects an illegal register selector or a size code outside 1..12 with `Fault_IllegalInstruction`. `BundleRangeSubviewLegal` then requires an open group and a legal role. The size code must be 1..10 in a Local group and 1..12 in a Shared group. A failure raises `Fault_TileLegality` when a Local non-zero-mode group sees size code 11 or 12, and `Fault_BundleControl` otherwise.

`B.ASSEMBLE` with INIT needs an allowed, unused destination role. Without INIT it is a continuation: the binder must have no destination, and the modifier takes the last source slot. `RecordBundleRangeAssemble` moves that Local source, source 1 if present and otherwise source 0, into `parent_ref` and clears the source. A continuation names the generation being extended, not a new operand.

When the group is not zero-mode, the handler reads `GPR[RegSrc] + uimm11` as the offset and records the modifier in the binder.

Design point: in a zero-mode group each modifier passes the placement check and changes nothing, and no GPR is read. A binder with no participating PEs keeps its following modifiers syntactically legal while producing no effect.

Design point: `BundleSharedDestinationAssemblyPolicyLegal` requires a Shared destination with more than one participating PE to carry `B.ASSEMBLE`. Tile execution checks it before descriptor preparation and raises `Fault_TileLegality`. A multi-PE Shared destination without `B.ASSEMBLE` is therefore rejected before descriptor, payload, memory, or publication effects, as the contract `PTO-B-ASSEMBLE-SHARED-STANDALONE-001` states.

<!-- PTO-READER-BLOCK: block-model-operands-range-modifiers-boundaries role=boundaries -->
## Architectural boundaries

This unit records modifiers. Subview descriptors are derived by the subview-descriptor unit, and generations are opened and checked by the Local and Shared generation units, after the bundle closes.

<!-- PTO-READER-BLOCK: block-model-operands-range-modifiers-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

```asm
B.IOT T#1, T#2, mask=PE_MASK, <last>, ->T<4KB>
B.SUBVIEW 1, x5, 0, 3
B.SUBVIEW 0, x6, 0, 3
```

The binder allows source 0, source 1, and a destination. The first `B.SUBVIEW` records source 1. The second faults with `Fault_BundleControl`, because source 0 may not follow source 1. Reversing the two commands would be legal. Placing a `B.DIM` between the binder and a modifier would close the group, and the modifier would then fault.

<!-- PTO-READER-BLOCK: block-model-operands-range-modifiers-related role=related-owners-navigation -->
## Related owners

- [Commands](../dispatch/commands.md) opens and closes groups and holds the modifier handlers.
- [Subview descriptor](subview-descriptor.md) derives the selected ranges.
- [Local generation](local-generation.md) and [Shared generation](shared-generation.md) use the assemble records.
- [B.SUBVIEW](../../operands/B.SUBVIEW.md) and [B.ASSEMBLE](../../operands/B.ASSEMBLE.md) are the command pages.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/range-modifiers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS","surface":"block","classification":["model","operands","range-modifiers"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS","PTO-BLOCK-MODEL-STATE-CONTROL-STATE"]}

// The group is syntactic header state. A binder opens it and the first
// non-modifier closes it; no destination is allocated and no operation schema
// is consulted here.
func OpenBundleRangeTileGroup(zero_mode: boolean,
                              source0_allowed: boolean,
                              source1_allowed: boolean,
                              destination_allowed: boolean)
begin
    _BundleRangeGroup.open = TRUE;
    _BundleRangeGroup.zero_mode = zero_mode;
    _BundleRangeGroup.kind = if zero_mode then BundleRangeGroup_None
        else BundleRangeGroup_Local;
    _BundleRangeGroup.tile_binding = BundleTileBindingLastIndex();
    _BundleRangeGroup.shared_binding = 0;
    _BundleRangeGroup.source0_allowed = source0_allowed;
    _BundleRangeGroup.source1_allowed = source1_allowed;
    _BundleRangeGroup.destination_allowed = destination_allowed;
    _BundleRangeGroup.source0_seen = FALSE;
    _BundleRangeGroup.source1_seen = FALSE;
    _BundleRangeGroup.destination_seen = FALSE;
end;

func OpenBundleRangeSharedGroup(zero_mode: boolean,
                                source0_allowed: boolean,
                                destination_allowed: boolean)
begin
    _BundleRangeGroup.open = TRUE;
    _BundleRangeGroup.zero_mode = zero_mode;
    _BundleRangeGroup.kind = if zero_mode then BundleRangeGroup_None
        else BundleRangeGroup_Shared;
    _BundleRangeGroup.tile_binding = 0;
    _BundleRangeGroup.shared_binding = BundleSharedBindingLastIndex();
    _BundleRangeGroup.source0_allowed = source0_allowed;
    _BundleRangeGroup.source1_allowed = FALSE;
    _BundleRangeGroup.destination_allowed = destination_allowed;
    _BundleRangeGroup.source0_seen = FALSE;
    _BundleRangeGroup.source1_seen = FALSE;
    _BundleRangeGroup.destination_seen = FALSE;
end;

func CloseBundleRangeGroup()
begin
    _BundleRangeGroup.open = FALSE;
    _BundleRangeGroup.zero_mode = FALSE;
    _BundleRangeGroup.kind = BundleRangeGroup_None;
    _BundleRangeGroup.tile_binding = 0;
    _BundleRangeGroup.shared_binding = 0;
    _BundleRangeGroup.source0_allowed = FALSE;
    _BundleRangeGroup.source1_allowed = FALSE;
    _BundleRangeGroup.destination_allowed = FALSE;
    _BundleRangeGroup.source0_seen = FALSE;
    _BundleRangeGroup.source1_seen = FALSE;
    _BundleRangeGroup.destination_seen = FALSE;
end;

readonly func BundleRangeRoleLegal(role: integer {0..2}) => boolean
begin
    if !_BundleRangeGroup.open then return FALSE; end;
    if role == 0 then
        return _BundleRangeGroup.source0_allowed &&
               !_BundleRangeGroup.source0_seen &&
               !_BundleRangeGroup.source1_seen &&
               !_BundleRangeGroup.destination_seen;
    elsif role == 1 then
        return _BundleRangeGroup.source1_allowed &&
               !_BundleRangeGroup.source1_seen &&
               !_BundleRangeGroup.destination_seen;
    else
        return _BundleRangeGroup.destination_allowed &&
               !_BundleRangeGroup.destination_seen;
    end;
end;

func MarkBundleRangeRole(role: integer {0..2})
begin
    if role == 0 then
        _BundleRangeGroup.source0_seen = TRUE;
    elsif role == 1 then
        _BundleRangeGroup.source1_seen = TRUE;
    else
        _BundleRangeGroup.destination_seen = TRUE;
    end;
end;

pure func BundleRangeSubviewRawLegal(size_code: integer {0..15}) => boolean
begin
    return 1 <= size_code && size_code <= 12;
end;

readonly func BundleRangeSubviewLegal(source_select: boolean,
                                      size_code: integer {0..15}) => boolean
begin
    if !_BundleRangeGroup.open || _BundleRangeGroup.zero_mode then
        return _BundleRangeGroup.open;
    end;
    let role = if source_select then 1 else 0;
    if !BundleRangeRoleLegal(role as integer {0..2}) then return FALSE; end;
    if _BundleRangeGroup.kind == BundleRangeGroup_Local then
        return LocalTileSizeCodeIsLegal(size_code);
    end;
    return TileSizeCodeIsLegal(size_code);
end;

func RecordBundleRangeSubview(source_select: boolean,
                              reg_src: Reg5Selector,
                              uimm11: bits(11),
                              size_code: integer {1..12},
                              offset: Word)
begin
    if source_select then
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .source1_subview.valid = TRUE;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .source1_subview.reg_src = reg_src;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .source1_subview.uimm11 = uimm11;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .source1_subview.size_code = size_code;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .source1_subview.offset = offset;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .source1_subview.init = FALSE;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .source1_subview.last = FALSE;
        MarkBundleRangeRole(1);
    else
        if _BundleRangeGroup.kind == BundleRangeGroup_Local then
            _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
                .source0_subview.valid = TRUE;
            _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
                .source0_subview.reg_src = reg_src;
            _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
                .source0_subview.uimm11 = uimm11;
            _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
                .source0_subview.size_code = size_code;
            _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
                .source0_subview.offset = offset;
            _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
                .source0_subview.init = FALSE;
            _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
                .source0_subview.last = FALSE;
        else
            _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
                .source0_subview.valid = TRUE;
            _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
                .source0_subview.reg_src = reg_src;
            _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
                .source0_subview.uimm11 = uimm11;
            _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
                .source0_subview.size_code = size_code;
            _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
                .source0_subview.offset = offset;
            _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
                .source0_subview.init = FALSE;
            _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
                .source0_subview.last = FALSE;
        end;
        MarkBundleRangeRole(0);
    end;
end;

readonly func BundleRangeAssembleLegal(init: boolean,
                                       size_code: integer {0..15}) => boolean
begin
    if !_BundleRangeGroup.open || _BundleRangeGroup.zero_mode then
        return _BundleRangeGroup.open;
    end;
    if init then
        if !_BundleRangeGroup.destination_allowed ||
           !BundleRangeRoleLegal(2) then return FALSE; end;
        if _BundleRangeGroup.kind == BundleRangeGroup_Local then
            return LocalTileSizeCodeIsLegal(size_code);
        end;
        return TileSizeCodeIsLegal(size_code);
    end;
    // A continuation ParentRef occupies the final source-form binder slot;
    // it is not a destination and therefore has no destination SizeCode.
    if _BundleRangeGroup.destination_allowed ||
       _BundleRangeGroup.destination_seen then return FALSE; end;
    if _BundleRangeGroup.kind == BundleRangeGroup_Local then
        return LocalTileSizeCodeIsLegal(size_code) &&
               ((_BundleRangeGroup.source1_allowed &&
                 !_BundleRangeGroup.source1_seen) ||
                (_BundleRangeGroup.source0_allowed &&
                 !_BundleRangeGroup.source1_allowed &&
                 !_BundleRangeGroup.source0_seen));
    end;
    return TileSizeCodeIsLegal(size_code) &&
           _BundleRangeGroup.source0_allowed &&
           !_BundleRangeGroup.source0_seen;
end;

func RecordBundleRangeAssemble(init: boolean,
                              last: boolean,
                              reg_src: Reg5Selector,
                              uimm11: bits(11),
                              size_code: integer {0..15},
                              offset: Word)
begin
    if _BundleRangeGroup.kind == BundleRangeGroup_Local then
        if !init && !_BundleRangeGroup.destination_allowed then
            let binding = _BundleRangeGroup.tile_binding;
            if _BundleTileBindings[[binding]].source1_valid then
                _BundleTileBindings[[binding]].parent_ref_valid = TRUE;
                _BundleTileBindings[[binding]].parent_ref_relative =
                    _BundleTileBindings[[binding]].source1_relative;
                _BundleTileBindings[[binding]].parent_ref =
                    _BundleTileBindings[[binding]].source1;
                _BundleTileBindings[[binding]].source1_valid = FALSE;
                _BundleTileBindings[[binding]].source1_relative = FALSE;
            elsif _BundleTileBindings[[binding]].source0_valid then
                _BundleTileBindings[[binding]].parent_ref_valid = TRUE;
                _BundleTileBindings[[binding]].parent_ref_relative =
                    _BundleTileBindings[[binding]].source0_relative;
                _BundleTileBindings[[binding]].parent_ref =
                    _BundleTileBindings[[binding]].source0;
                _BundleTileBindings[[binding]].source0_valid = FALSE;
                _BundleTileBindings[[binding]].source0_relative = FALSE;
            else
                SetFault(Fault_BundleControl, ReadTPC());
                return;
            end;
        end;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .destination_assemble.valid = TRUE;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .destination_assemble.reg_src = reg_src;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .destination_assemble.uimm11 = uimm11;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .destination_assemble.size_code = size_code;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .destination_assemble.offset = offset;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .destination_assemble.init = init;
        _BundleTileBindings[[_BundleRangeGroup.tile_binding]]
            .destination_assemble.last = last;
    else
        _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
            .destination_assemble.valid = TRUE;
        _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
            .destination_assemble.reg_src = reg_src;
        _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
            .destination_assemble.uimm11 = uimm11;
        _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
            .destination_assemble.size_code = size_code;
        _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
            .destination_assemble.offset = offset;
        _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
            .destination_assemble.init = init;
        _BundleSharedBindings[[_BundleRangeGroup.shared_binding]]
            .destination_assemble.last = last;
    end;
    MarkBundleRangeRole(2);
end;

// NDF-BEGIN: PTO-B-ASSEMBLE-SHARED-STANDALONE-001
// ndf: kind=contract level=L1 layer=block status=accepted
// A Shared destination with more than one participating PE MUST carry one
// B.ASSEMBLE modifier.  A multi-PE standalone B.IOS destination MUST raise
// Fault_TileLegality before descriptor, payload, memory, or publication
// effects.  A single-PE standalone destination retains the ordinary B.IOS
// behavior.
// NDF-END: PTO-B-ASSEMBLE-SHARED-STANDALONE-001
readonly func BundleSharedDestinationAssemblyPolicyLegal() => boolean
begin
    for binding = 0 to 3 do
        if _BundleSharedBindings[[binding]].valid &&
           _BundleSharedBindings[[binding]].size_code != 0 &&
           PEMaskPopulation(_BundleSharedBindings[[binding]].pe_mask) > 1 &&
           !_BundleSharedBindings[[binding]].destination_assemble.valid then
            return FALSE;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
