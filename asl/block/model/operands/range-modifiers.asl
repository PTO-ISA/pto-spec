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
    if !BundleRangeRoleLegal(2) then return FALSE; end;
    if init && size_code == 0 then return FALSE; end;
    if !init && size_code != 0 then return FALSE; end;
    if size_code != 0 && _BundleRangeGroup.kind == BundleRangeGroup_Local &&
       !LocalTileSizeCodeIsLegal(size_code) then return FALSE; end;
    if size_code != 0 && _BundleRangeGroup.kind == BundleRangeGroup_Shared &&
       !TileSizeCodeIsLegal(size_code) then return FALSE; end;
    return TRUE;
end;

func RecordBundleRangeAssemble(init: boolean,
                              last: boolean,
                              reg_src: Reg5Selector,
                              uimm11: bits(11),
                              size_code: integer {0..12},
                              offset: Word)
begin
    if _BundleRangeGroup.kind == BundleRangeGroup_Local then
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
