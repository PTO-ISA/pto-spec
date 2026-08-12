// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-LOCAL-REGISTERS","surface":"tile","classification":["model","state","local-registers"],"depends_on":["PTO-TILE-MODEL-STATE-TYPES"]}
// PTO-REQ-TILE-001: 64 flat tile registers and TileInfo legality.

var _Tiles : array [[PTO_TILE_REGISTER_COUNT]] of TileInfo;
var _TileAllocationMasks : array [[PTO_TILE_REGISTER_COUNT]] of bits(4);

// Complete-bundle group destinations retain the derived valid-M for each
// fixed PE identity so decoded evidence can observe inactive zero-row PEs.
// This is derived descriptor state, not a new encoded role or persistent
// MShard metadata.
type TilePerPEValidRows of record {
    pe0: integer {0..65535},
    pe1: integer {0..65535},
    pe2: integer {0..65535},
    pe3: integer {0..65535}
};

var _TilePerPEValidRows : array [[PTO_TILE_REGISTER_COUNT]]
    of TilePerPEValidRows;

readonly func TilePEValidRows(index: TileIndex, pe: integer {0..3})
                                    => integer {0..65535}
begin
    case pe of
        when 0 => return _TilePerPEValidRows[[index]].pe0;
        when 1 => return _TilePerPEValidRows[[index]].pe1;
        when 2 => return _TilePerPEValidRows[[index]].pe2;
        when 3 => return _TilePerPEValidRows[[index]].pe3;
    end;
end;

func SetTilePEValidRows(index: TileIndex, pe: integer {0..3},
                        rows: integer {0..65535})
begin
    case pe of
        when 0 => _TilePerPEValidRows[[index]].pe0 = rows;
        when 1 => _TilePerPEValidRows[[index]].pe1 = rows;
        when 2 => _TilePerPEValidRows[[index]].pe2 = rows;
        when 3 => _TilePerPEValidRows[[index]].pe3 = rows;
    end;
end;
var _SharedTiles : SharedTileSnapshot;
