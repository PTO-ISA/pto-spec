<!-- GENERATED FROM: asl/block/model/operands/shared-bindings.asl -->
# Shared Bindings

**Normative ASL source:** `asl/block/model/operands/shared-bindings.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-operands-shared-bindings-purpose role=purpose-scope -->
## 用途与范围

本单元拥有指令束的 Shared 绑定。Shared 绑定是一条 `B.IOS` 头部命令留下的记录。它指名一个 Shared Tile（一个可由多个 PE 读取的 Tile 对象），以及一个大小码和一个 PE 掩码。

本单元追加绑定、以几种方式计数、将其标记为已消费，并检查掩码是否一致。它不分配也不读取 Shared Tile。

<!-- PTO-READER-BLOCK: block-model-operands-shared-bindings-concepts role=concepts-state -->
## 概念与可见状态

`_BundleSharedBindings` 有四个条目。除源/目标角色、掩码和范围修饰符外，普通源还记录复用选择及捕获的生命周期实例。绑定属于 PE 私有状态；实例的参与者完成记录属于 Core，不能从 PE 异常快照恢复。

大小码决定角色。非零大小码使绑定成为具有该容量的目标。大小码 0 使它成为源。一个大小码为 0、其 `destination_assemble` 修饰符有效且不是 INIT 阶段的绑定是重用目标：它指名一个打开的 `B.ASSEMBLE` 代次正在继续构建的 Shared Tile。

共有三种计数。`BundleSharedBindingPhysicalCount` 计数每个有效条目。`BundleSharedBindingCount` 排除重用目标。`BundleSharedPhysicalDestinationCount` 计数大小码非零的条目。

<!-- PTO-READER-BLOCK: block-model-operands-shared-bindings-rules role=rules-interactions -->
## 规则与交互

`BindBundleSharedIO(id, size, mask)` 按顺序检查：

1. `BundleSharedMaskCanAppend(mask)`：掩码非零，等于每个现有 Tile 绑定的掩码，并等于每个现有 Shared 绑定的掩码。否则引发 `Fault_TileLegality`。
2. 没有有效条目已经指名相同的 Shared Tile ID。否则引发 `Fault_BundleControl`。
3. 存在空闲条目。它填充第一个空闲条目并清除 `consumed`。四个条目都已占用时，引发 `Fault_BundleControl`。

设计要点：`BindBundleSharedIO` 要求新 Shared 绑定的掩码等于每个已记录的 Tile 绑定和 Shared 绑定的掩码，因此掩码不一致的 `B.IOS` 会在头部命令处被拒绝。`BundleTileMaskCanAppend` 只把新 Tile 绑定与之前的 Tile 绑定比较，因此跟在掩码不同的 `B.IOS` 之后的 `B.IOT` 不会在这里被拒绝；Shared TLSU 掩码检查等操作检查会在之后比较这些掩码。

设计要点：一个 Shared Tile ID 在每个指令束中只能出现一次。`BindBundleSharedIO` 在填充条目之前以 `Fault_BundleControl` 拒绝重复的 ID，因此每个有效条目都指名不同的 Shared Tile。

`ConsumeBundleSharedBindings` 标记操作层面的绑定使用。该记账与源回收分离：`FinalizeBundleSharedLastUseSources` 向生命周期归属单元报告参与者成功完成。`.reuse` 以及被重分类为目标的继续绑定均不回收 Shared 源。

<!-- PTO-READER-BLOCK: block-model-operands-shared-bindings-boundaries role=boundaries -->
## 架构边界

`B.IOS` 处理程序在本单元之前执行三项检查。大小码大于 12 时，它引发 `Fault_IllegalInstruction`。零 PE 模式（掩码 `0000`）是严格的空操作：在指令束头部中，它记录曾出现零参与并打开一个零模式范围组，并且在任何情况下都推进 `TPC`。除此之外，当没有指令束处于头部阶段时，它引发 `Fault_BundleControl`。

当恰好存在一个重用目标且它是最后一个有效条目时，`BundleSharedReusedDestinationIsFinal` 为 TRUE。描述符合法性检查会使用它。`BundleTileMaskCanAppend` 也位于这里，并与 `B.IOT` 共用。

<!-- PTO-READER-BLOCK: block-model-operands-shared-bindings-example role=example-usage -->
## 非规范阅读示例

本示例只用于演示当前 ASL 所有者，不替代规范操作。

一个指令束把 Shared Tile 2 绑定为源（大小 0，掩码 `1111`），再把 Shared Tile 5 绑定为 4 KB 目标（大小 6，掩码 `1111`）。两次调用都成功，因此物理计数和普通计数为 2，目标计数为 1。第三条针对 Shared Tile 2 的 `B.IOS` 引发 `Fault_BundleControl`。第三条针对 Shared Tile 7、掩码为 `1000` 的 `B.IOS` 引发 `Fault_TileLegality`。

<!-- PTO-READER-BLOCK: block-model-operands-shared-bindings-related role=related-owners-navigation -->
## 相关所有者

- [命令](../dispatch/commands.md)包含 `B.IOS` 处理程序。
- [范围修饰符](range-modifiers.md)把 subview 和 assemble 修饰符附加到这些条目上。
- [Shared 代次](shared-generation.md)使用重用目标。
- [B.IOS](../../operands/B.IOS.md) 是命令页面。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/operands/shared-bindings.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS","surface":"block","classification":["model","operands","shared-bindings"],"depends_on":["PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS","PTO-BLOCK-MODEL-STATE-SOURCE-LIFETIME"]}
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
```
<!-- GENERATED-ASL-END: unit -->
