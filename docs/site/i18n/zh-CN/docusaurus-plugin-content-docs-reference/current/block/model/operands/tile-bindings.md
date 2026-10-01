<!-- GENERATED FROM: asl/block/model/operands/tile-bindings.asl -->
# Tile Bindings

**Normative ASL source:** `asl/block/model/operands/tile-bindings.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-tile-bindings-purpose role=purpose-scope -->
## 用途与范围

本单元拥有指令束的 Local Tile 绑定。Tile 绑定是一条 `B.IOT` 头部命令留下的记录。它指名至多两个源 Tile、一个可选的带大小码的目标 hand、一个 PE 掩码和一个 `last` 标志。本单元追加绑定、解析相对源选择子、把 assemble 延续转换为目标，并在操作成功后发布新目标。

<!-- PTO-READER-BLOCK: block-model-operands-tile-bindings-concepts role=concepts-state -->
## 概念与可见状态

`_BundleTileBindings` 有 `PTO_BUNDLE_TILE_BINDING_COUNT`（16）个条目。`BundleTileBinding` 的重要字段有：

- `source0`、`source1`，以及 `source0_valid`、`source1_valid` 和 `source0_relative`、`source1_relative` 标志；
- `destination_valid`、`destination`、`destination_hand` 和 `destination_size`；
- `destination_allocated_by_bundle` 和 `destination_reused_by_generation`；
- `parent_ref_valid`、`parent_ref_relative` 和 `parent_ref`，由 assemble 延续使用；
- `pe_mask`、`last` 和三个范围修饰符。

相对选择子按一个 hand（T、U、M 或 N）的相对队列中的位置指名 Tile。距离 0 是该 hand 中最新发布的目标；汇编把它写作 `#1`，因此 `T#1` 是距离 0，`T#2` 是距离 1。

<!-- PTO-READER-BLOCK: block-model-operands-tile-bindings-rules role=rules-interactions -->
## 规则与交互

如果已存在带 `last` 的条目，`AddBundleTileBinding` 以 `Fault_BundleControl` 故障。它通过 `SetBundleTileBinding` 填充第一个空闲条目；16 个条目都已占用时引发 `Fault_TileLegality`。`SetBundleTileBinding` 以 `Fault_TileLegality` 拒绝 hand 索引大于 3 或大小码不在 1..10 内的目标，保存各字段，并清除相对、父引用和分配标志。随后 `B.IOT` 处理程序调用 `MarkBundleTileBindingSourcesRelative`，因此每个编码的源都是相对选择子。

`ResolveBundleRelativeTileSources` 在第 2 阶段准备时运行。它的第一个循环检查每个相对源是否可用，否则引发 `Fault_TileLegality`。第二个循环把每个选择子替换为绝对寄存器索引，并对相对的 `parent_ref` 做同样处理。

设计要点：在改写任何源选择子之前，先检查每个相对源的可用性，因此缺失的源引发故障时，每个绑定仍保持其编码形式。相对的 `parent_ref` 在第二个循环中才检查，因此缺失的父 Tile 可能在之前的源已被改写之后才引发故障。

设计要点：`B.IOT` 保存编码的相对选择子而不解析它。`ResolveBundleRelativeTileSources` 在操作的第 2 阶段准备期间解析它，因此被解析的 Tile 是相对队列在那一刻所指名的那个。

`BindBundleLocalGenerationDestination` 把一个已验证的延续转换为目标。它安装该代次的工作目标、hand 和父级大小码，并设置 `destination_reused_by_generation`。它从不分配。如果延续绑定没有源，它会被折叠到前一个有效绑定中，由该绑定接收父引用和 `last`，而载体条目被置为无效。

`FinalizeBundleTileAttempt` 只在操作已执行之后运行。对于指令束分配且不带 assemble 修饰符的每个目标，它调用 `PublishRelativeTileDestination`，使该 Tile 成为其 hand 中最新的条目（距离 0）。

<!-- PTO-READER-BLOCK: block-model-operands-tile-bindings-boundaries role=boundaries -->
## 架构边界

目标分配不在这里完成；由目标解析器在 schema 检查之后完成。当已看到 LAST、CUBE 描述符（如有）已最终确定、该 PE 参与、且该 PE 的每个所需 CELL 都已覆盖并就绪时，`BundleLocalGenerationPEPublicationEligible` 对该 PE 为 TRUE。

<!-- PTO-READER-BLOCK: block-model-operands-tile-bindings-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

带 `B.IOT T#1, T#2, mask=PE_MASK, <last>, ->T<2KB>` 的 `TADD` 产生一个绑定，其中含 hand T 中的两个相对源和一个大小为 5 的目标。在第 2 阶段，这两个源解析为当前位于距离 0 和 1 的 Tile。加法成功后，新目标被发布为 `T#1`，原来的 `T#1` 变为 `T#2`。

<!-- PTO-READER-BLOCK: block-model-operands-tile-bindings-related role=related-owners-navigation -->
## 相关所有者

- [命令](../dispatch/commands.md)包含 `B.IOT` 处理程序。
- [Tile 描述符](../../../tile/model/state/descriptors.md)拥有相对队列。
- [Local 代次](local-generation.md)打开代次并调用延续绑定函数。
- [B.IOT](../../operands/B.IOT.md) 是命令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/tile-bindings.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS","surface":"block","classification":["model","operands","tile-bindings"],"depends_on":["PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS","PTO-BLOCK-MODEL-STATE-CONTROL-STATE","PTO-TILE-MODEL-STATE-DESCRIPTORS","PTO-BLOCK-MODEL-OPERANDS-LOCAL-GENERATION-CUBE"]}
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
       (BundleLocalGenerationCubeLayout(
            _LocalGenerations[[slot]].parent_descriptor.layout) &&
        !_LocalGenerations[[slot]].descriptor_finalized) ||
       _LocalGenerations[[slot]].participant_mask[
           PTOPEMaskBitOfPEIdentity(pe)] == '0' then return FALSE; end;
    let required = if _LocalGenerations[[slot]].descriptor_finalized &&
        BundleLocalGenerationCubeLayout(
            _LocalGenerations[[slot]].parent_descriptor.layout) then
        _LocalGenerations[[slot]].parent_descriptor.cube_cell_count
        else _LocalGenerations[[slot]].parent_cell_count;
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
