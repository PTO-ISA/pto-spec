<!-- GENERATED FROM: asl/block/model/operands/range-modifiers.asl -->
# Range Modifiers

**Normative ASL source:** `asl/block/model/operands/range-modifiers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-RANGE-MODIFIERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-range-modifiers-purpose role=purpose-scope -->
## 用途与范围

本单元拥有范围修饰符组。范围修饰符是一条 `B.SUBVIEW` 或 `B.ASSEMBLE` 头部命令，用于细化紧挨在它之前的绑定命令。`B.SUBVIEW` 选择源的一个范围。`B.ASSEMBLE` 把一个目标或一个父引用标记为多指令束构建中的一个写者。

ASL 注释说明了范围：该组是语法层面的头部状态。它不分配目标，也不查询任何操作 schema。

<!-- PTO-READER-BLOCK: block-model-operands-range-modifiers-concepts role=concepts-state -->
## 概念与可见状态

`_BundleRangeGroup` 是一个 `BundleRangeGroupState` 记录：

- `open` 和 `zero_mode`；
- `kind`，取值为 `BundleRangeGroup_None`、`BundleRangeGroup_Local` 或 `BundleRangeGroup_Shared`；
- `tile_binding` 或 `shared_binding`，即打开该组的绑定命令的索引；
- `source0_allowed`、`source1_allowed`、`destination_allowed`，取自绑定命令的编码操作数；
- `source0_seen`、`source1_seen`、`destination_seen`。

`OpenBundleRangeTileGroup` 在 `B.IOT` 之后调用，`OpenBundleRangeSharedGroup` 在 `B.IOS` 之后调用。Shared 组从不允许源 1。PE 掩码为 `0000` 的绑定命令打开一个 `zero_mode` 为 TRUE、种类为 `None` 的组。

<!-- PTO-READER-BLOCK: block-model-operands-range-modifiers-rules role=rules-interactions -->
## 规则与交互

命令分派程序对每条不是范围修饰符的头部命令调用 `CloseBundleRangeGroup`。因此修饰符只附加到紧挨在它之前的绑定命令上。

角色必须按源 0、源 1、目标的顺序出现，每个至多一次。`BundleRangeRoleLegal` 拒绝出现在源 1 或目标之后的源 0，以及出现在目标之后的源 1。

`B.SUBVIEW` 首先以 `Fault_IllegalInstruction` 拒绝非法的寄存器选择子或 1..12 之外的大小码。随后 `BundleRangeSubviewLegal` 要求组已打开且角色合法。在 Local 组中大小码必须为 1..10，在 Shared 组中为 1..12。当非零模式的 Local 组遇到大小码 11 或 12 时，失败引发 `Fault_TileLegality`，其他情况引发 `Fault_BundleControl`。

带 INIT 的 `B.ASSEMBLE` 需要一个允许且未使用的目标角色。不带 INIT 时它是一个延续：绑定命令必须没有目标，修饰符占用最后一个源槽位。`RecordBundleRangeAssemble` 把该 Local 源（如存在源 1 则为源 1，否则为源 0）移入 `parent_ref` 并清除该源。延续指名的是被扩展的代次，而不是一个新操作数。

当组不是零模式时，处理程序读取 `GPR[RegSrc] + uimm11` 作为偏移，并把修饰符记录到绑定命令中。

设计要点：在零模式组中，每个修饰符都通过放置检查，但不改变任何内容，也不读取 GPR。没有参与 PE 的绑定命令因此让其后的修饰符在语法上保持合法，同时不产生效果。

设计要点：`BundleSharedDestinationAssemblyPolicyLegal` 要求参与 PE 多于一个的 Shared 目标带有 `B.ASSEMBLE`。Tile 执行在描述符准备之前检查它，并引发 `Fault_TileLegality`。因此，如契约 `PTO-B-ASSEMBLE-SHARED-STANDALONE-001` 所述，不带 `B.ASSEMBLE` 的多 PE Shared 目标会在描述符、载荷、内存或发布效果之前被拒绝。

<!-- PTO-READER-BLOCK: block-model-operands-range-modifiers-boundaries role=boundaries -->
## 架构边界

本单元只记录修饰符。在指令束关闭之后，subview 描述符由 subview 描述符单元推导，代次由 Local 和 Shared 代次单元打开和检查。

<!-- PTO-READER-BLOCK: block-model-operands-range-modifiers-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

```asm
B.IOT T#1, T#2, mask=PE_MASK, <last>, ->T<4KB>
B.SUBVIEW 1, x5, 0, 3
B.SUBVIEW 0, x6, 0, 3
```

该绑定命令允许源 0、源 1 和一个目标。第一条 `B.SUBVIEW` 记录源 1。第二条以 `Fault_BundleControl` 故障，因为源 0 不能出现在源 1 之后。交换这两条命令则是合法的。在绑定命令和修饰符之间放一条 `B.DIM` 会关闭该组，修饰符随后会故障。

<!-- PTO-READER-BLOCK: block-model-operands-range-modifiers-related role=related-owners-navigation -->
## 相关所有者

- [命令](../dispatch/commands.md)打开和关闭组，并包含修饰符处理程序。
- [Subview 描述符](subview-descriptor.md)推导所选范围。
- [Local 代次](local-generation.md)和 [Shared 代次](shared-generation.md)使用 assemble 记录。
- [B.SUBVIEW](../../operands/B.SUBVIEW.md) 和 [B.ASSEMBLE](../../operands/B.ASSEMBLE.md) 是命令页面。
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
