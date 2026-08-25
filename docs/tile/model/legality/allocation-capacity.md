<!-- GENERATED FROM: asl/tile/model/legality/allocation-capacity.asl -->
# Allocation Capacity

**Normative ASL source:** `asl/tile/model/legality/allocation-capacity.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/allocation-capacity.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-ALLOCATION-CAPACITY","surface":"tile","classification":["model","legality","allocation-capacity"],"depends_on":["PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
readonly func TilePayloadNonzero(index: TileIndex) => boolean
begin
    if !TileSourceContentsDefined(index) then return FALSE; end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if IsZero(TileReadLogicalElement(tile, element)) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileBroadcastPayloadNonzero(axis: TileAxis, source: TileIndex,
                                           broadcast: TileIndex) => boolean
begin
    if !TileSourceContentsDefined(source) ||
       !TileSourceContentsDefined(broadcast) then
        return FALSE;
    end;
    let source_tile = _Tiles[[source]];
    let broadcast_tile = _Tiles[[broadcast]];
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let broadcast_row = if axis == TileAxis_Row then row else 0;
            let broadcast_column = if axis == TileAxis_Row then 0 else column;
            let element = TileLogicalLinearIndex(broadcast_tile,
                broadcast_row as integer {0..65535},
                broadcast_column as integer {0..65535});
            if IsZero(TileReadLogicalElement(broadcast_tile, element)) then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileIndexPayloadWithin(index: TileIndex, extent: integer) => boolean
begin
    if !TileSourceContentsDefined(index) then return FALSE; end;
    let tile = _Tiles[[index]];
    for row = 0 to tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(tile,
                row as integer {0..65535},
                column as integer {0..65535});
            if UInt(TileReadLogicalElement(tile, element)) >= extent then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TileByteOffsetPayloadWithin(offsets: TileIndex,
                                           source: TileIndex) => boolean
begin
    if !TileSourceContentsDefined(offsets) ||
       !TileSourceContentsDefined(source) then
        return FALSE;
    end;
    let offsets_tile = _Tiles[[offsets]];
    let element_bytes = TileElementBytes(_Tiles[[source]].data_type);
    let source_extent: integer =
        _Tiles[[source]].valid_rows * _Tiles[[source]].valid_columns;
    for row = 0 to offsets_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to offsets_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLogicalLinearIndex(offsets_tile,
                row as integer {0..65535}, column as integer {0..65535});
            let byte_offset = UInt(TileReadLogicalElement(
                offsets_tile, element));
            if byte_offset MOD element_bytes != 0 ||
               byte_offset DIV element_bytes >= source_extent then
                return FALSE;
            end;
        end;
    end;
    return TRUE;
end;

readonly func TilePartialCoverageLegal(destination: TileIndex,
                                        source_left: TileIndex,
                                        source_right: TileIndex) => boolean
begin
    if !TileDescriptorLegal(destination) ||
       !TileDescriptorLegal(source_left) ||
       !TileDescriptorLegal(source_right) then
        return FALSE;
    end;
    let destination_tile = _Tiles[[destination]];
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    if left_tile.valid_rows > destination_tile.valid_rows ||
       left_tile.valid_columns > destination_tile.valid_columns ||
       right_tile.valid_rows > destination_tile.valid_rows ||
       right_tile.valid_columns > destination_tile.valid_columns then
        return FALSE;
    end;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            let left_valid = row < left_tile.valid_rows &&
                             column < left_tile.valid_columns;
            let right_valid = row < right_tile.valid_rows &&
                              column < right_tile.valid_columns;
            if !left_valid && !right_valid then return FALSE; end;
        end;
    end;
    return TRUE;
end;
```
<!-- GENERATED-ASL-END: unit -->
