// PTO-REQ-TEPL-001: direct, read-before-write TEPL semantics.

impdef func TileSquareRoot(value: Word) => Word
begin
    // A numeric profile replaces this stable raw-encoding default.
    return value;
end;

impdef func TileLogarithm(value: Word) => Word
begin
    return value;
end;

impdef func TileReciprocal(value: Word) => Word
begin
    assert !IsZero(value);
    return DivideWordUnsigned(Ones{PTO_XLEN}, value);
end;

impdef func TileExponential(value: Word) => Word
begin
    return value;
end;

pure func TileBinaryValue(op: TileBinaryOperation, left: Word, right: Word) => Word
begin
    case op of
        when TileBinary_ADD => return left + right;
        when TileBinary_SUB => return left - right;
        when TileBinary_MUL => return MultiplyWord(left, right);
        when TileBinary_MAX =>
            if SInt(left) > SInt(right) then return left; else return right; end;
        when TileBinary_MIN =>
            if SInt(left) < SInt(right) then return left; else return right; end;
        when TileBinary_AND => return left AND right;
        when TileBinary_OR  => return left OR right;
        when TileBinary_XOR => return left XOR right;
        when TileBinary_SHL => return LSL(left, UInt(right[5:0]));
        when TileBinary_SHR => return LSR(left, UInt(right[5:0]));
        when TileBinary_DIV => return DivideWordUnsigned(left, right);
        when TileBinary_REM => return left - MultiplyWord(DivideWordUnsigned(left, right), right);
    end;
end;

impdef func TileProfileBinary(op: TileBinaryOperation, data_type: TileDataType,
                              left: Word, right: Word) => Word
begin
    return TileBinaryValue(op, left, right);
end;

func ExecuteTileBinary(op: TileBinaryOperation, destination: TileIndex,
                       source_left: TileIndex, source_right: TileIndex)
begin
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    assert left_tile.allocated && right_tile.allocated;
    assert TileShapesMatch(left_tile, right_tile);
    assert TileShapesMatch(_Tiles[[destination]], left_tile);
    assert left_tile.data_type == right_tile.data_type;
    assert _Tiles[[destination]].data_type == left_tile.data_type;

    // Snapshot both sources before the first destination write. This defines
    // source/destination aliasing as read-before-write.
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to left_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(left_tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[destination]].payload[[element]] =
                TileProfileBinary(op, left_tile.data_type,
                    left_payload[[element]], right_payload[[element]]);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func TileUnaryValue(op: TileUnaryOperation, value: Word) => Word
begin
    case op of
        when TileUnary_ABS =>
            if SInt(value) < 0 then return Zeros{PTO_XLEN} - value; else return value; end;
        when TileUnary_NOT => return NOT value;
        when TileUnary_NEG => return Zeros{PTO_XLEN} - value;
        when TileUnary_RELU =>
            if SInt(value) < 0 then return Zeros{PTO_XLEN}; else return value; end;
        when TileUnary_SQRT => return TileSquareRoot(value);
        when TileUnary_LOG => return TileLogarithm(value);
        when TileUnary_RECIP => return TileReciprocal(value);
        when TileUnary_EXP => return TileExponential(value);
        when TileUnary_RSQRT => return TileReciprocal(TileSquareRoot(value));
    end;
end;

impdef func TileProfileUnary(op: TileUnaryOperation, data_type: TileDataType,
                             value: Word) => Word
begin
    return TileUnaryValue(op, value);
end;

impdef func TileProfileAxpy(destination_value: Word, source_value: Word,
                            scalar: Word, data_type: TileDataType) => Word
begin
    return destination_value + MultiplyWord(scalar, source_value);
end;

func ExecuteTileAxpy(destination: TileIndex, source: TileIndex, scalar: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let source_tile = _Tiles[[source]];
    assert TileShapesMatch(destination_tile, source_tile);
    assert destination_tile.data_type == source_tile.data_type;
    let destination_payload = destination_tile.payload;
    let source_payload = source_tile.payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[destination]].payload[[element]] =
                TileProfileAxpy(destination_payload[[element]],
                    source_payload[[element]], scalar, source_tile.data_type);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func ExecuteTileFillScalar(destination: TileIndex, scalar: Word)
begin
    let destination_tile = _Tiles[[destination]];
    assert destination_tile.allocated;
    for row = 0 to destination_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to destination_tile.valid_columns - 1 looplimit 65536 do
            WriteTileElement(destination, row as integer {0..65535},
                column as integer {0..65535}, scalar);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func ExecuteTileUnary(op: TileUnaryOperation, destination: TileIndex, source: TileIndex)
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated;
    assert TileShapesMatch(_Tiles[[destination]], source_tile);
    assert _Tiles[[destination]].data_type == source_tile.data_type;
    let source_payload = source_tile.payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[destination]].payload[[element]] =
                TileProfileUnary(op, source_tile.data_type,
                    source_payload[[element]]);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

impdef func TileProfilePReLU(value: Word, negative_slope: Word,
                             data_type: TileDataType) => Word
begin
    if SInt(value) < 0 then
        return MultiplyWord(value, negative_slope);
    else
        return value;
    end;
end;

func TPRELU(destination: TileIndex, source: TileIndex, negative_slope: Word)
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated;
    assert TileShapesMatch(_Tiles[[destination]], source_tile);
    assert _Tiles[[destination]].data_type == source_tile.data_type;
    let source_payload = source_tile.payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[destination]].payload[[element]] =
                TileProfilePReLU(source_payload[[element]], negative_slope,
                    source_tile.data_type);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func ExecuteTileScalar(op: TileBinaryOperation, destination: TileIndex,
                       source: TileIndex, scalar: Word)
begin
    let source_tile = _Tiles[[source]];
    assert source_tile.allocated;
    assert TileShapesMatch(_Tiles[[destination]], source_tile);
    assert _Tiles[[destination]].data_type == source_tile.data_type;
    let source_payload = source_tile.payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[destination]].payload[[element]] =
                TileProfileBinary(op, source_tile.data_type,
                    source_payload[[element]], scalar);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

pure func TileCompareValue(comparison: TileComparison, left: Word, right: Word) => Word
begin
    var result: boolean;
    case comparison of
        when TileComparison_EQ => result = left == right;
        when TileComparison_NE => result = left != right;
        when TileComparison_LT => result = SInt(left) < SInt(right);
        when TileComparison_LE => result = SInt(left) <= SInt(right);
        when TileComparison_GT => result = SInt(left) > SInt(right);
        when TileComparison_GE => result = SInt(left) >= SInt(right);
    end;
    if result then return Zeros{PTO_XLEN} + 1; else return Zeros{PTO_XLEN}; end;
end;

impdef func TileProfileCompare(comparison: TileComparison,
                               data_type: TileDataType,
                               left: Word, right: Word) => Word
begin
    return TileCompareValue(comparison, left, right);
end;

func ExecuteTileCompare(destination: TileIndex, source_left: TileIndex,
                        source_right: TileIndex, comparison: TileComparison)
begin
    let left_tile = _Tiles[[source_left]];
    let right_tile = _Tiles[[source_right]];
    assert TileShapesMatch(left_tile, right_tile);
    assert left_tile.data_type == right_tile.data_type;
    assert _Tiles[[destination]].rows == left_tile.rows;
    assert _Tiles[[destination]].columns == left_tile.columns;
    let left_payload = left_tile.payload;
    let right_payload = right_tile.payload;
    for row = 0 to left_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to left_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(left_tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[destination]].payload[[element]] =
                TileProfileCompare(comparison, left_tile.data_type,
                    left_payload[[element]], right_payload[[element]]);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func ExecuteTileCompareScalar(destination: TileIndex, source: TileIndex,
                              scalar: Word, comparison: TileComparison)
begin
    let source_tile = _Tiles[[source]];
    assert _Tiles[[destination]].rows == source_tile.rows;
    assert _Tiles[[destination]].columns == source_tile.columns;
    let payload = source_tile.payload;
    for row = 0 to source_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to source_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(source_tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[destination]].payload[[element]] =
                TileProfileCompare(comparison, source_tile.data_type,
                    payload[[element]], scalar);
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func ExecuteTileSelect(destination: TileIndex, mask: TileIndex,
                       source_true: TileIndex, source_false: TileIndex)
begin
    let true_tile = _Tiles[[source_true]];
    let false_tile = _Tiles[[source_false]];
    assert TileShapesMatch(true_tile, false_tile);
    assert _Tiles[[mask]].rows == true_tile.rows;
    assert _Tiles[[mask]].columns == true_tile.columns;
    assert TileShapesMatch(_Tiles[[destination]], true_tile);
    let true_payload = true_tile.payload;
    let false_payload = false_tile.payload;
    let mask_payload = _Tiles[[mask]].payload;
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            if !IsZero(mask_payload[[element]]) then
                _Tiles[[destination]].payload[[element]] = true_payload[[element]];
            else
                _Tiles[[destination]].payload[[element]] = false_payload[[element]];
            end;
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;

func ExecuteTileSelectScalar(destination: TileIndex, mask: TileIndex,
                             source_true: TileIndex, scalar_false: Word)
begin
    let destination_tile = _Tiles[[destination]];
    let true_tile = _Tiles[[source_true]];
    let mask_tile = _Tiles[[mask]];
    assert destination_tile.valid_rows == true_tile.valid_rows;
    assert destination_tile.valid_columns == true_tile.valid_columns;
    assert mask_tile.valid_rows == true_tile.valid_rows;
    assert mask_tile.valid_columns == true_tile.valid_columns;
    let true_payload = true_tile.payload;
    let mask_payload = mask_tile.payload;
    for row = 0 to true_tile.valid_rows - 1 looplimit 65536 do
        for column = 0 to true_tile.valid_columns - 1 looplimit 65536 do
            let element = TileLinearIndex(true_tile,
                row as integer {0..65535}, column as integer {0..65535});
            _Tiles[[destination]].payload[[element]] = if !IsZero(mask_payload[[element]]) then
                true_payload[[element]] else scalar_false;
        end;
    end;
    MarkTileValidRegionDefined(destination);
end;
