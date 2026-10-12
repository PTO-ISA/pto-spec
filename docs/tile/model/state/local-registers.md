<!-- GENERATED FROM: asl/tile/model/state/local-registers.asl -->
# Local Registers

**Normative ASL source:** `asl/tile/model/state/local-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-LOCAL-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-state-local-registers-purpose role=purpose-scope -->
## Purpose and scope

This unit declares the architectural Tile state. It is short, but Tile operations read or write the variables it names.

It separates PE-local descriptor, payload-liveness and relative-generation state from the Core-wide Shared records. The accompanying source-lifetime model uses generation tokens to distinguish replacement at the same physical slot; those tokens are model bookkeeping, not software-visible registers.

- `PTO-STATE-TILE-LOCAL` owns descriptors, allocation masks, payload-live masks, generation tokens and relative order within each PE bank.
- `PTO-STATE-TILE-SHARED` owns `_SharedTiles` for the Core.

It also carries two accepted NDF requirements, `PTO-REQ-TILE-001` and `PTO-REQ-SHARED-TILE-001`.

<!-- PTO-READER-BLOCK: tile-model-state-local-registers-concepts role=concepts-state -->
## Concepts and visible state

| Variable | Shape | Meaning |
| --- | --- | --- |
| `_Tiles` | 64 `TileInfo` records | Descriptor, definedness, and payload of each Local Tile register |
| `_TileAllocationMasks` | 64 four-bit masks | The PEs that own each Local allocation |
| `_TilePayloadLiveMasks` | 64 four-bit masks | Payload backing that remains live in the PE bank |
| `_TilePayloadGenerations` | 64 integer tokens | Monotonic model identity for replacement at the same slot |
| `_TileRelativeOrder` | 4 hands of 16 register indices | Relative generation order per hand |
| `_TileRelativeValid` | 4 hands of 16 bits | Which relative entries are live |
| `_SharedTiles` | 64 `SharedTileInfo` records | Core-private Shared registers S0 to S63 |

The Local owner has PE scope; the Shared owner has Core scope. Local register indices are interpreted inside the selected PE bank. Payload liveness and generation identity are saved with that bank, so selecting another PE cannot resurrect a consumed source.

<!-- PTO-READER-BLOCK: tile-model-state-local-registers-rules role=rules-interactions -->
## Rules and interactions

`PTO-REQ-TILE-001` fixes relative naming. In each of the T, U, M, and N hands, `#1` is the newest published generation. When a new destination for that hand publishes, older live generations shift toward `#16`. Source generations must persist.

`PTO-REQ-SHARED-TILE-001` fixes that the Shared registers are exactly the core-private state named `PTO-STATE-TILE-SHARED`.

Design point: the relative order is architectural state, not a compiler convention. Because `_TileRelativeOrder` and `_TileRelativeValid` are members of `PTO-STATE-TILE-LOCAL`, the meaning of a relative selector such as `#2` changes only through an accepted ASL transition on that state.

Descriptor ownership and payload availability are distinct. `_TileAllocationMasks` retains descriptor ownership, while `_TilePayloadLiveMasks` drives payload capacity. `_TilePayloadGenerations` distinguishes a later allocation in the same slot. Relative lookup can therefore still identify a consumed generation without granting permission to read its payload.

<!-- PTO-READER-BLOCK: tile-model-state-local-registers-boundaries role=boundaries -->
## Architectural boundaries

This unit declares state only. The transitions that change it are owned elsewhere: allocation and release, relative publication, Shared publication, and the reset routine in the system-register owner.

`PTO_TILE_REGISTER_COUNT` and `PTO_SHARED_TILE_COUNT` are both 64. The payload inside each `TileInfo` is bounded by the model constant `PTO_MODEL_TILE_ELEMENTS`, which is a model bound rather than a requirement on implementations.

<!-- PTO-READER-BLOCK: tile-model-state-local-registers-example role=example-usage -->
## Non-normative reading example

To answer "which Local Tiles does PE1 currently own?", read the state in this order:

1. Select PE1’s actual bank and inspect each allocated `_Tiles` descriptor.
2. Check PE1’s bit in `_TileAllocationMasks` for descriptor ownership.
3. Check `_TilePayloadLiveMasks` separately for payload capacity; a retained identity alone contributes no live bytes.

To answer "what does `#2` in hand U mean?", read hand 1 distance 1 of `_TileRelativeOrder` and confirm the matching bit of `_TileRelativeValid`.

<!-- PTO-READER-BLOCK: tile-model-state-local-registers-related role=related-owners-navigation -->
## Related owners

- [Types](types.md) defines `TileInfo` and `SharedTileInfo`.
- [Descriptors](descriptors.md) implements relative resolution and publication.
- [Allocation](allocation.md) and [Shared registers](shared-registers.md) own the main transitions on this state.
- [Local capacity](../capacity/local.md) reads the allocation masks.
- [Tile registers](../../../arch/programming-model/tile-registers.md) gives the architecture-level view.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/state/local-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","surface":"tile","classification":["model","state","local-registers"],"depends_on":["PTO-TILE-MODEL-STATE-TYPES"]}
// PTO-STATE: {"id":"PTO-STATE-TILE-LOCAL","classification":["tile","local"],"scope":"pe","owner":"PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","members":["_Tiles","_TileAllocationMasks","_TilePayloadLiveMasks","_TilePayloadGenerations","_TileRelativeOrder","_TileRelativeValid"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-TILE-SHARED","classification":["tile","shared"],"scope":"core","owner":"PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","members":["_SharedTiles"],"depends_on":[]}

// NDF-BEGIN: PTO-REQ-TILE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Each Core has four independent PE-owned Local Tile register banks.
// Local descriptors, allocation masks, and independently consumable
// payload-live masks MUST be the state defined by
// [[PTO-STATE-TILE-LOCAL]]. Each T/U/M/N hand MUST resolve #1 as its newest
// published generation and shift older live generations toward #16 whenever
// a new destination for that hand publishes. Consuming payload capacity MUST
// NOT remove or compact the source generation identity.
// NDF-END: PTO-REQ-TILE-001

// NDF-BEGIN: PTO-REQ-SHARED-TILE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Shared Tile registers MUST be the core-private state defined by
// [[PTO-STATE-TILE-SHARED]].
// NDF-END: PTO-REQ-SHARED-TILE-001

var _Tiles : array [[PTO_TILE_REGISTER_COUNT]] of TileInfo;
var _TileAllocationMasks : array [[PTO_TILE_REGISTER_COUNT]] of bits(4);
var _TilePayloadLiveMasks : array [[PTO_TILE_REGISTER_COUNT]] of bits(4);
// Monotonic model identity for the payload installed in each physical Local
// slot. It prevents a delayed cross-PE completion from consuming a newer
// allocation that reused the same physical index.
var _TilePayloadGenerations : array [[PTO_TILE_REGISTER_COUNT]] of integer;
var _TileRelativeOrder : RelativeTileSnapshot;
var _TileRelativeValid : RelativeTileValiditySnapshot;
var _SharedTiles : SharedTileSnapshot;

func AdvanceCurrentLocalTilePayloadGeneration(index: TileIndex)
begin
    _TilePayloadGenerations[[index]] =
        _TilePayloadGenerations[[index]] + 1;
end;
```
<!-- GENERATED-ASL-END: unit -->
