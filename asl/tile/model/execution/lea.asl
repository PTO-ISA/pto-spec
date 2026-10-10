// PTO-UNIT: {"id":"PTO-TILE-MODEL-EXECUTION-LEA","surface":"tile","classification":["model","execution","lea"],"depends_on":["PTO-TILE-MODEL-DEFINEDNESS-ELEMENTS","PTO-TILE-MODEL-EXECUTION-MASK-STATE","PTO-TILE-MODEL-LEGALITY-LEA-OPERANDS"]}

pure func TileLEAExtendedIndex(value: Word, data_type: TileDataType) => Word
begin
    case data_type of
        when TileDataType_S32 => return SignExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_U32 => return ZeroExtend{PTO_XLEN}(value[31:0]);
        when TileDataType_S64, TileDataType_U64 => return value;
        otherwise => unreachable;
    end;
end;

pure func TileLEAByteScale(element_bits: Word) => Word
begin
    assert TileLEAElementBitsLegal(element_bits);
    if element_bits == Zeros{PTO_XLEN} + 8 then
        return Zeros{PTO_XLEN} + 1;
    elsif element_bits == Zeros{PTO_XLEN} + 16 then
        return Zeros{PTO_XLEN} + 2;
    elsif element_bits == Zeros{PTO_XLEN} + 32 then
        return Zeros{PTO_XLEN} + 4;
    end;
    return Zeros{PTO_XLEN} + 8;
end;

pure func TileLEAByteOffset(
    value: Word, data_type: TileDataType, element_bits: Word) => Word
begin
    assert TileLEAIndexDataTypeLegal(data_type);
    assert TileLEAElementBitsLegal(element_bits);
    return MultiplyWord(
        TileLEAExtendedIndex(value, data_type),
        TileLEAByteScale(element_bits));
end;

func TLEA(destination: TileIndex, source: TileIndex, element_bits: Word)
begin
    assert TileOperandsLegal_TLEA(destination, source, element_bits);
    let source_tile = _Tiles[[source]];
    var result = _Tiles[[destination]];

    // Snapshot the complete source record before constructing the result.
    // This gives direct S64/U64 destination aliases read-old/write-new behavior.
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let destination_element = TileLogicalLinearIndex(
                result, row as integer {0..65535},
                column as integer {0..65535});
            var value = Zeros{PTO_XLEN};
            if BundleExecutionMaskActiveAt(
                   source_tile.layout, row as integer {0..65535},
                   column as integer {0..65535}) then
                let source_element = TileLogicalLinearIndex(
                    source_tile, row as integer {0..65535},
                    column as integer {0..65535});
                value = TileLEAByteOffset(
                    TileReadLogicalElement(source_tile, source_element),
                    source_tile.data_type, element_bits);
            else
                value = BundleExecutionMaskDestinationValue(
                    result.layout, row as integer {0..65535},
                    column as integer {0..65535}, Zeros{PTO_XLEN});
            end;
            result = TileInfoWithLogicalElement(
                result, destination_element, value);
        end;
    end;

    result = TileWithValidRegionDefined(result);
    result = TileWithPadding(result, CurrentBundlePadValue());
    _Tiles[[destination]] = result;
end;
