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
