<!-- GENERATED FROM: asl/tile/model/state/local-registers.asl -->
# Local Registers

**Normative ASL source:** `asl/tile/model/state/local-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-STATE-LOCAL-REGISTERS}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/state/local-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","surface":"tile","classification":["model","state","local-registers"],"depends_on":["PTO-TILE-MODEL-STATE-TYPES"]}
// PTO-STATE: {"id":"PTO-STATE-TILE-LOCAL","classification":["tile","local"],"scope":"core","owner":"PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","members":["_Tiles","_TileAllocationMasks"],"depends_on":[]}
// PTO-STATE: {"id":"PTO-STATE-TILE-SHARED","classification":["tile","shared"],"scope":"core","owner":"PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","members":["_SharedTiles"],"depends_on":[]}

// NDF-BEGIN: PTO-REQ-TILE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Local Tile registers and their allocation masks MUST be the state defined by
// [[PTO-STATE-TILE-LOCAL]].
// NDF-END: PTO-REQ-TILE-001

// NDF-BEGIN: PTO-REQ-SHARED-TILE-001
// ndf: kind=contract level=L1 layer=tile status=accepted
// Shared Tile registers MUST be the core-private state defined by
// [[PTO-STATE-TILE-SHARED]].
// NDF-END: PTO-REQ-SHARED-TILE-001

var _Tiles : array [[PTO_TILE_REGISTER_COUNT]] of TileInfo;
var _TileAllocationMasks : array [[PTO_TILE_REGISTER_COUNT]] of bits(4);
var _SharedTiles : SharedTileSnapshot;
```
<!-- GENERATED-ASL-END: unit -->
