<!-- GENERATED FROM: asl/tile/model/execution/complex.asl -->
# Complex

**Normative ASL source:** `asl/tile/model/execution/complex.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-COMPLEX}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/complex.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-COMPLEX","surface":"tile","classification":["model","execution","complex"],"depends_on":["PTO-TILE-MODEL-EXECUTION-ELEMENTWISE","PTO-TILE-MODEL-EXECUTION-REARRANGEMENT","PTO-TILE-MODEL-LEGALITY-INDEXED-LAYOUT"]}
// PTO-REQ-TEPL-COMPLEX-001: partial, ordering, and histogram operations.

impdef func TileProfileOrderLeft(
    left: Word,
    right: Word,
    descending: boolean,
    data_type: TileDataType) => boolean
begin
    if descending then
        return SInt(left) >= SInt(right);
    end;
    return SInt(left) <= SInt(right);
end;

impdef func TileProfileValueIsNaN(
    value: Word,
    data_type: TileDataType) => boolean
begin
    return FALSE;
end;

pure func ExtractWordByte(value: Word, byte_index: integer {0..3}) => Byte
begin
    return value[(byte_index * 8) +: 8];
end;

func THISTOGRAM(destination: TileIndex, source: TileIndex, filter: TileIndex,
                selected_byte: integer {0..3})
begin
    var result = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    let filter_tile = _Tiles[[filter]];
    assert TileOperandsLegal_THISTOGRAM(
        destination,
        source,
        filter,
        selected_byte);
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        var counts: array [[256]] of Word;
        for bin = 0 to 255 do
            counts[[bin]] = Zeros{PTO_XLEN};
        end;
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let source_element = TileLogicalLinearIndex(
                source_tile,
                row as integer {0..65535},
                column as integer {0..65535});
            let value = TileReadLogicalElement(source_tile, source_element);
            var selected = TRUE;
            if source_tile.data_type == TileDataType_U16 &&
               selected_byte == 0 then
                let filter_element = TileLogicalLinearIndex(
                    filter_tile,
                    row as integer {0..65535},
                    0);
                selected = ExtractWordByte(value, 1) ==
                    TileReadLogicalElement(filter_tile, filter_element)[7:0];
            elsif source_tile.data_type == TileDataType_U32 then
                if selected_byte <= 2 then
                    selected = ExtractWordByte(value, 3) ==
                        TileReadLogicalElement(filter_tile,
                            TileLogicalLinearIndex(filter_tile, 0, 0))[7:0];
                end;
                if selected && selected_byte <= 1 then
                    selected = ExtractWordByte(value, 2) ==
                        TileReadLogicalElement(filter_tile,
                            TileLogicalLinearIndex(filter_tile, 1, 0))[7:0];
                end;
                if selected && selected_byte == 0 then
                    selected = ExtractWordByte(value, 1) ==
                        TileReadLogicalElement(filter_tile,
                            TileLogicalLinearIndex(filter_tile, 2, 0))[7:0];
                end;
            end;
            if selected then
                let bin = UInt(ExtractWordByte(value, selected_byte));
                counts[[bin]] = counts[[bin]] + 1;
            end;
        end;
        var cumulative: Word = Zeros{PTO_XLEN};
        for bin = 0 to 255 do
            cumulative = cumulative + counts[[bin]];
            let element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                bin as integer {0..65535});
            result = TileInfoWithLogicalElement(result, element, cumulative);
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    result.location = TileLocation_Any;
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->
