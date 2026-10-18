<!-- GENERATED FROM: asl/arch/state/local-payload-generation.asl -->
# Local Payload Generation

**Normative ASL source:** `asl/arch/state/local-payload-generation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-LOCAL-PAYLOAD-GENERATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-local-payload-generation-purpose role=purpose-scope -->
## 目的和范围

本单元提供两个跨 PE 的 Local Tile payload generation helper。一个读取某 PE 和 Tile index 当前存储的 generation；另一个仅在请求的 generation 仍指向已分配 payload 时，消费该 PE 的一个 liveness bit。

generation 检查之所以存在，是因为一个物理 Local Tile slot 可以被重用。延迟完成不能只因 Tile index 相同就消费更新的 payload。

<!-- PTO-READER-BLOCK: arch-local-payload-generation-concepts role=concepts-state -->
## Generation 和 liveness 状态

每个 PE-private Tile slot 在 `_TilePayloadGenerations` 中有一个 payload generation，在 `_TilePayloadLiveMasks` 中有一个 liveness mask。所选 PE 使用活跃工作集。其他 PE 在 bank entry 有效时通过 `_PEExecutionContexts` 读取，否则在该 entry 尚未保存时通过 `_DefaultPEExecutionContext` 读取。

`PTOPEMaskBitOfPEIdentity` 选择消费时清除的 bit。generation 是标识保护；liveness bit 记录该 PE 对匹配 payload 的引用是否仍然活跃。

<!-- PTO-READER-BLOCK: arch-local-payload-generation-rules role=rules-interactions -->
## 读取和消费规则

`LocalTilePayloadGeneration` 直接返回所选 PE 的活跃值。对其他 PE，它在存在时返回 banked value，否则返回 default-context value。

`ConsumeLocalTilePayloadGeneration` 仅在 Tile 已分配且当前 generation 等于捕获 generation 时清除一个 liveness bit。它对活跃工作集或目标 PE 的已保存 context 应用同一测试。没有有效已保存 context 的非当前 PE 保持不变。

<!-- PTO-READER-BLOCK: arch-local-payload-generation-boundaries role=boundaries -->
## 边界

这些 helper 不分配、释放或替换 Tile，也不递增 generation。它们也不切换当前 PE。allocation 和 source-lifetime owner 决定何时创建、固定 generation，或使其可被替换。

generation 不匹配时不执行任何操作，而不是产生 fault。该行为防止 stale completion 损坏当前状态；它并不声明 stale request 在其他方面合法。

<!-- PTO-READER-BLOCK: arch-local-payload-generation-example role=example-usage -->
## 阅读示例

假设 PE2 捕获 Local Tile 5 的 generation 11。若队列完成时 Tile 5 仍以 generation 11 分配，`ConsumeLocalTilePayloadGeneration(PE2, 5, 11)` 会清除 PE2 的 liveness bit。若该 slot 已以 generation 12 重用，同一调用不会改变任何状态，因此新 payload 仍保持 live。

<!-- PTO-READER-BLOCK: arch-local-payload-generation-related role=related-owners-navigation -->
## 相关所有者

- [PE execution context](pe-execution-context.md) 拥有此处读取的活跃和 banked Local Tile 字段。
- [Source lifetime](../../block/model/state/source-lifetime.md) 捕获 immutable generation，并在所有声明 participant 完成后调用消费。
- [Local registers](../../tile/model/state/local-registers.md) 拥有 Local Tile allocation 和 payload 状态。
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/state/local-payload-generation.asl -->
```asl
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
```
<!-- GENERATED-ASL-END: unit -->
