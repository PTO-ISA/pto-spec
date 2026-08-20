<!-- GENERATED FROM: asl/block/model/faults/rollback.asl -->
# Rollback

**Normative ASL source:** `asl/block/model/faults/rollback.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-BLOCK-MODEL-FAULTS-ROLLBACK}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/block/model/faults/rollback.asl -->
```asl
// PTO-UNIT: {"id":"PTO-BLOCK-MODEL-FAULTS-ROLLBACK","surface":"block","classification":["model","faults","rollback"],"depends_on":["PTO-BLOCK-MODEL-DISPATCH-DESTINATION-SHAPE"]}
func RollBackBundleTileDestinations()
begin
    for binding = 0 to PTO_BUNDLE_TILE_BINDING_COUNT - 1 do
        if _BundleTileBindings[[binding]].valid &&
           _BundleTileBindings[[binding]].destination_allocated_by_bundle then
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
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
