<!-- GENERATED FROM: asl/tile/model/execution/generation.asl -->
# Generation

**Normative ASL source:** `asl/tile/model/execution/generation.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-EXECUTION-GENERATION}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/execution/generation.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-GENERATION","surface":"tile","classification":["model","execution","generation"],"depends_on":["PTO-TILE-MODEL-EXECUTION-EXPANSION","PTO-TILE-MODEL-LEGALITY-LAYOUT-REARRANGEMENT"]}
// PTO-REQ-TEPL-GENERATE-001: generated sequences, masks, and padding.

pure func TileTCIDataTypeSupported(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_S32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U16;
end;

pure func TileTTRIDataTypeSupported(data_type: TileDataType) => boolean
begin
    return data_type == TileDataType_FP32 ||
           data_type == TileDataType_FP16 ||
           data_type == TileDataType_S32 ||
           data_type == TileDataType_S16 ||
           data_type == TileDataType_U32 ||
           data_type == TileDataType_U16;
end;

pure func TileTTRIOneEncoding(data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_FP32 =>
            return Zeros{PTO_XLEN} + 0x3f800000;
        when TileDataType_FP16 =>
            return Zeros{PTO_XLEN} + 0x3c00;
        when TileDataType_BF16 =>
            return Zeros{PTO_XLEN} + 0x3f80;
        otherwise =>
            return Zeros{PTO_XLEN} + 1;
    end;
end;

func TCI(destination: TileIndex, start: Word, descending: boolean)
begin
    var result = _Tiles[[destination]];
    assert result.allocated;
    assert result.valid_rows == 1;
    assert TileTCIDataTypeSupported(result.data_type);
    let normalized_start = TileRawElementValue(
        start,
        result.data_type);
    for column = 0 to result.valid_columns - 1 looplimit 65536 do
        let element = TileLogicalLinearIndex(
            result,
            0,
            column as integer {0..65535});
        let offset = NaturalToWord(column as integer {0..65535});
        let value = if descending then
            normalized_start - offset
        else
            normalized_start + offset;
        result = TileInfoWithLogicalElement(result, element,
            TileRawElementValue(
            value,
            result.data_type));
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    result.location = TileLocation_Any;
    _Tiles[[destination]] = result;
end;

func TTRI(destination: TileIndex, upper: boolean,
          diagonal: integer {-65535..65535})
begin
    var result = _Tiles[[destination]];
    assert result.allocated;
    assert result.valid_rows >= 1;
    assert result.valid_columns >= 1;
    assert TileTTRIDataTypeSupported(result.data_type);
    let one = TileTTRIOneEncoding(result.data_type);
    for row = 0 to result.valid_rows - 1 looplimit 65536 do
        for column = 0 to result.valid_columns - 1 looplimit 65536 do
            let boundary: integer = row + diagonal;
            let selected = if upper then
                column >= boundary
            else
                column <= boundary;
            let element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, element,
                if selected then
                one
            else
                Zeros{PTO_XLEN});
        end;
    end;
    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, TilePad_Null);
    result.location = TileLocation_Any;
    _Tiles[[destination]] = result;
end;

func TFILLPAD(destination: TileIndex, source: TileIndex, padding: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert TileOperandsLegal_TFILLPAD(destination, source, padding);
    let typed_padding = TileRawElementValue(
        padding,
        destination_tile.data_type);
    var result = destination_tile;
    for row = 0 to destination_tile.rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.columns - 1 looplimit 65536 do
            var value = typed_padding;
            if row < source_tile.valid_rows && column < source_tile.valid_columns then
                let source_element = TileLogicalLinearIndex(source_tile,
                    row as integer {0..65535}, column as integer {0..65535});
                value = TileReadLogicalElement(source_tile, source_element);
            end;
            let destination_element = TileLogicalLinearIndex(
                result,
                row as integer {0..65535},
                column as integer {0..65535});
            result = TileInfoWithLogicalElement(result, destination_element,
                value);
        end;
    end;
    result.defined_valid_elements =
        (result.valid_rows * result.valid_columns)
            as integer {0..524288};
    result.contents_defined = TRUE;
    _Tiles[[destination]] = result;
end;
```
<!-- GENERATED-ASL-END: unit -->
