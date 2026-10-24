<!-- GENERATED FROM: asl/tile/model/memory/shared-movement-values.asl -->
# Shared Movement Values

**Normative ASL source:** `asl/tile/model/memory/shared-movement-values.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-VALUES}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/memory/shared-movement-values.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-VALUES","surface":"tile","classification":["model","memory","shared-movement-values"],"depends_on":["PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT-TYPES","PTO-TILE-MODEL-STATE-SHARED-REGISTERS","PTO-TILE-MODEL-STATE-TYPES","PTO-TILE-MODEL-LEGALITY-DTYPE-LAYOUT"]}
readonly func SharedTileElementRegion(tile: TileInfo,
                                  element: PackedTileElementIndex)
                                  => integer {0..3}
begin
    let bit_offset: integer = element * TileElementBits(tile.data_type);
    let byte_offset: integer = bit_offset DIVRM 8;
    assert byte_offset < tile.capacity_bytes;
    return ((byte_offset * 4) DIVRM tile.capacity_bytes)
        as integer {0..3};
end;

func TMOVSharedToLocalToValue(destination: TileOutputValueTarget,
                              shared_tile_id: SharedTileID,
                              shared_tile: TileInfo,
                              pe_mask: bits(4)) => TileInfo
begin
    var result = destination.value;
    if pe_mask == Zeros{4} then return result; end;
    assert result.capacity_bytes == shared_tile.capacity_bytes;
    assert result.rows == shared_tile.rows &&
           result.columns == shared_tile.columns &&
           result.valid_rows == shared_tile.valid_rows &&
           result.valid_columns == shared_tile.valid_columns &&
           result.data_type == shared_tile.data_type &&
           result.layout == shared_tile.layout;
    for element = 0 to shared_tile.rows * shared_tile.columns - 1
        looplimit 524288 do
        result = TileInfoWithLogicalElement(result,
            element as PackedTileElementIndex,
            ReadSharedTileWord(shared_tile_id,
                element as PackedTileElementIndex));
    end;
    result.contents_defined = TRUE;
    return TileWithValidRegionDefined(result);
end;

func TMOVSharedToLocalPerPEToValue(
    destination: TileOutputValueTarget,
    per_pe_tiles: CorePETileInfos,
    pe_mask: bits(4)) => TileInfo
begin
    var result = destination.value;
    if pe_mask == Zeros{4} then return result; end;
    var first_pe : integer {0..3} = 0;
    var last_pe : integer {0..3} = 3;
    if _CurrentPEContextValid then
        first_pe = _CurrentMemoryAgent as integer {0..3};
        last_pe = first_pe;
    end;
    for pe = first_pe to last_pe do
        let agent = pe as MemoryAgentId;
        if pe_mask[PTOPEMaskBitOfPEIdentity(agent)] == '1' then
            let source_tile = per_pe_tiles[[agent]];
            assert source_tile.allocated && source_tile.contents_defined;
            assert result.capacity_bytes == source_tile.capacity_bytes;
            assert result.rows == source_tile.rows &&
                   result.columns == source_tile.columns &&
                   result.valid_rows == source_tile.valid_rows &&
                   result.valid_columns == source_tile.valid_columns &&
                   result.data_type == source_tile.data_type &&
                   result.layout == source_tile.layout;
            for element = 0 to source_tile.rows * source_tile.columns - 1
                looplimit 524288 do
                let value = TileReadLogicalElement(source_tile,
                    element as PackedTileElementIndex);
                result = TileInfoWithLogicalElement(result,
                    element as PackedTileElementIndex, value);
            end;
        end;
    end;
    result.contents_defined = pe_mask == '1111';
    if pe_mask == '1111' then
        result = TileWithValidRegionDefined(result);
    end;
    return result;
end;

func GMOVFromSourceTileToValue(
    destination: TileOutputValueTarget, source_tile: TileInfo) => TileInfo
begin
    var result = destination.value;
    result.payload = source_tile.payload;
    result.defined_elements = source_tile.defined_elements;
    result.packed_defined_elements =
        source_tile.packed_defined_elements;
    result.defined_valid_elements =
        source_tile.defined_valid_elements;
    result.contents_defined = source_tile.contents_defined;
    return result;
end;
```
<!-- GENERATED-ASL-END: unit -->
