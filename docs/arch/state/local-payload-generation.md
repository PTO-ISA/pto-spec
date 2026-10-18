<!-- GENERATED FROM: asl/arch/state/local-payload-generation.asl -->
# Local Payload Generation

**Normative ASL source:** `asl/arch/state/local-payload-generation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-STATE-LOCAL-PAYLOAD-GENERATION}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-local-payload-generation-purpose role=purpose-scope -->
## Purpose and scope

This unit provides two cross-PE helpers for Local Tile payload generations. One reads the generation currently stored for a PE and Tile index; the other consumes one PE's liveness bit only when the requested generation still names the allocated payload.

The generation check exists because a physical Local Tile slot can be reused. A delayed completion must not consume a newer payload merely because it has the same Tile index.

<!-- PTO-READER-BLOCK: arch-local-payload-generation-concepts role=concepts-state -->
## Generation and liveness state

Each PE-private Tile slot has a payload generation in `_TilePayloadGenerations` and a liveness mask in `_TilePayloadLiveMasks`. The selected PE uses the active working set. Another PE is read through `_PEExecutionContexts` when its bank entry is valid, or through `_DefaultPEExecutionContext` before that entry has been saved.

`PTOPEMaskBitOfPEIdentity` chooses the bit cleared by consumption. Generation is the identity guard; the liveness bit records whether that PE's reference to the matching payload remains live.

<!-- PTO-READER-BLOCK: arch-local-payload-generation-rules role=rules-interactions -->
## Read and consume rules

`LocalTilePayloadGeneration` returns the selected PE's live value directly. For a different PE it returns the banked value when present and otherwise the default-context value.

`ConsumeLocalTilePayloadGeneration` clears one liveness bit only if the Tile is allocated and its current generation equals the captured generation. It applies the same test to the active working set or the target PE's saved context. A non-current PE without a valid saved context is left unchanged.

<!-- PTO-READER-BLOCK: arch-local-payload-generation-boundaries role=boundaries -->
## Boundaries

These helpers do not allocate, release, or replace a Tile, and they do not increment a generation. They also do not switch the current PE. Allocation and source-lifetime owners decide when a generation is created, pinned, or eligible for replacement.

A generation mismatch is a no-op rather than a fault. That behavior prevents stale completion from damaging current state; it does not declare the stale request otherwise legal.

<!-- PTO-READER-BLOCK: arch-local-payload-generation-example role=example-usage -->
## Reading example

Assume PE2 captured Local Tile 5 at generation 11. If Tile 5 is still allocated at generation 11 when the cohort completes, `ConsumeLocalTilePayloadGeneration(PE2, 5, 11)` clears PE2's liveness bit. If the slot has already been reused at generation 12, the same call changes nothing, so the new payload remains live.

<!-- PTO-READER-BLOCK: arch-local-payload-generation-related role=related-owners-navigation -->
## Related owners

- [PE execution context](pe-execution-context.md) owns the active and banked Local Tile fields read here.
- [Source lifetime](../../block/model/state/source-lifetime.md) captures immutable generations and invokes consumption after all declared participants complete.
- [Local registers](../../tile/model/state/local-registers.md) owns Local Tile allocation and payload state.
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
