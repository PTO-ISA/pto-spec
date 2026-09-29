<!-- GENERATED FROM: asl/block/model/faults/rollback.asl -->
# Rollback

**Normative ASL source:** `asl/block/model/faults/rollback.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-FAULTS-ROLLBACK}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: block-model-faults-rollback-purpose role=purpose-scope -->
## Purpose and scope

This unit defines `RollBackBundleTileDestinations`. It releases the Local Tiles that a failing bundle allocated for its destinations and restores those bindings to their encoded hand.

The tile-execution path calls it whenever a step fails after destination allocation: failed writer validation, a failed GPR comparison carrier, or a failed or faulting operation body. Several specialized TLSU and CUBE handlers call it on their own failure paths.

<!-- PTO-READER-BLOCK: block-model-faults-rollback-concepts role=concepts-state -->
## Concepts and visible state

Each Tile binding (one `B.IOT` entry) records its destination in two forms. `destination_hand` is the encoded hand (`T`, `U`, `M`, or `N`, coded 0 to 3). `destination` is either that encoded value or, after allocation, the concrete Tile register index chosen from that hand.

Two flags describe where the concrete destination came from:

- `destination_allocated_by_bundle` is set when this bundle allocated a fresh Tile for the destination.
- `destination_reused_by_generation` is set when the destination is an existing parent Tile continued by a `B.ASSEMBLE` generation.

<!-- PTO-READER-BLOCK: block-model-faults-rollback-rules role=rules-interactions -->
## Rules and interactions

For each valid binding that was allocated by the bundle and not reused by a generation, rollback does three things:

1. Releases the allocated Tile with `ReleaseTile`.
2. Sets `destination` back to the encoded hand value.
3. Clears `destination_allocated_by_bundle`.

Then, if a fault is pending and the current ring holds a valid trap context, rollback copies the updated Tile bindings and range-group state into that saved context.

Design point: only bundle-allocated destinations are released. A generation-reused destination is a parent Tile that already existed before the bundle, so releasing it would destroy data the bundle did not create. Rollback leaves it in place, and generation abort handles its generation record separately.

Design point: restoring the encoded hand returns the binding to the state it had before allocation. When the bundle is retried from a saved context, destination resolution treats the binding as unallocated and chooses a Tile again.

Design point: the saved trap context is patched after the release. The ASL comment gives the reason: a memory fault saves the block before the caller releases the speculative destination, and Tile allocation state is not part of the portable trap context. Without the patch, a recovered bundle would believe it still owned a Tile that is now free.

<!-- PTO-READER-BLOCK: block-model-faults-rollback-boundaries role=boundaries -->
## Architectural boundaries

This unit releases only Local destination Tiles recorded in Tile bindings. Aborting Local and Shared generation records and discarding subview materializations are separate calls that the tile-execution path makes next to this one.

Rollback does not undo global-memory stores, scalar writes, or effects on source Tiles. Operations that can produce such effects define their own ordering and preflight rules.

<!-- PTO-READER-BLOCK: block-model-faults-rollback-example role=example-usage -->
## Non-normative reading example

This example illustrates the current ASL owner and does not replace the normative operation.

A bundle binds one destination on hand `T`, encoded as 0. Resolution allocates `T` register index 5 and marks the binding allocated. The operation body then raises `Fault_TileLegality`. Rollback releases index 5 and sets the binding destination back to 0. Because `SetFault` has already saved a trap context, that context now also shows the destination as 0 and unallocated.

<!-- PTO-READER-BLOCK: block-model-faults-rollback-related role=related-owners-navigation -->
## Related owners

- [Tile execution](../dispatch/tile-execution.md) orders validation, allocation, execution, and rollback.
- [Destination shape](../dispatch/destination-shape.md) performs the allocation that rollback undoes.
- [Tile bindings](../operands/tile-bindings.md) defines the binding fields.
- [Trap context](../../../arch/state/trap-context.md) owns the saved context that rollback patches.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/faults/rollback.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-FAULTS-ROLLBACK","surface":"block","classification":["model","faults","rollback"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE"]}
func RollBackBundleTileDestinations()
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_allocated_by_bundle &&
           !_BundleTileBindings[[binding]].destination_reused_by_generation then
            ReleaseTile(_BundleTileBindings[[binding]].destination);
            _BundleTileBindings[[binding]].destination =
                UInt(_BundleTileBindings[[binding]].destination_hand)
                    as TileIndex;
            _BundleTileBindings[[binding]].destination_allocated_by_bundle =
                FALSE;
        end;
    end;
    let ring = CurrentACR();
    if _LastFault != Fault_None && _TrapContexts[[ring]].valid then
        // Memory faults save the block before the caller can release a
        // speculative destination.  Recovery must observe the same rolled
        // back binding state as live execution, because Tile allocation state
        // itself is not part of the portable trap context.
        _TrapContexts[[ring]].bundle_tile_bindings = _BundleTileBindings;
        _TrapContexts[[ring]].bundle_range_group = _BundleRangeGroup;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
