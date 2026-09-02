// PTO-UNIT: {"id":"PTO-TILE-MODEL-MEMORY-ADDRESSING","surface":"tile","classification":["model","memory","addressing"],"depends_on":["PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT"]}
// NDF-BEGIN: PTO-INDEXED-TLSU-STRIDE-001
// ndf: kind=executable level=L3 layer=tile status=accepted
// Indexed TLSU MUST interpret IndexTile elements as signed or unsigned logical
// linear element indices. B.IOR RegSrc1 MUST supply a row stride in elements
// no smaller than ValidCol. Address generation MUST split each index by
// ValidCol, apply the stride to its row, add its column, and scale by the
// transfer element size before probing memory.
// NDF-END: PTO-INDEXED-TLSU-STRIDE-001
pure func TileMemoryElementBytes(data_type: TileDataType) => integer {1,2,4,8}
begin
    // PTO-v0 TLSU exposes four-bit elements through byte-sized containing
    // accesses. Tile capacity remains packed in TileInfo.
    if TileDataTypeIsFourBit(data_type) then return 1;
    else return TileElementBytes(data_type);
    end;
end;

readonly func TileMemoryElementAddress(base_address: Word,
                                       element: ModelTileElementIndex,
                                       data_type: TileDataType) => Word
begin
    if TileDataTypeIsFourBit(data_type) then
        let offset = (element DIVRM 2) as integer {0..262144};
        return base_address + NaturalToWord(offset);
    else
        let element_bytes = TileElementBytes(data_type);
        let offset = (element * element_bytes) as integer {0..262144};
        return base_address + NaturalToWord(offset);
    end;
end;

readonly func TileMemoryIndexedAddress(base_address: Word,
                                       index_value: Word,
                                       data_type: TileDataType) => Word
begin
    if TileDataTypeIsFourBit(data_type) then
        return base_address + ZeroExtend{PTO_XLEN}(index_value[63:1]);
    else
        let element_bytes = TileElementBytes(data_type);
        let byte_width = NaturalToWord(element_bytes as integer {0..262144});
        return base_address + MultiplyWord(index_value, byte_width);
    end;
end;

readonly func TileMemoryElementHighNibble(element: ModelTileElementIndex,
                                          data_type: TileDataType) => boolean
begin
    return TileDataTypeIsFourBit(data_type) && element MOD 2 == 1;
end;

readonly func TileMemoryIndexedHighNibble(index_value: Word,
                                          data_type: TileDataType) => boolean
begin
    return TileDataTypeIsFourBit(data_type) && index_value[0] == '1';
end;

pure func TileIndexLinearElementIndex(index_value: Word,
                                      index_data_type: TileDataType)
                                      => integer
begin
    assert TileDataTypeIsInteger(index_data_type);
    case index_data_type of
        when TileDataType_S4X2 =>
            return SInt(index_value[3:0]);
        when TileDataType_S8 =>
            return SInt(index_value[7:0]);
        when TileDataType_S16 =>
            return SInt(index_value[15:0]);
        when TileDataType_S32 =>
            return SInt(index_value[31:0]);
        when TileDataType_S64 => return SInt(index_value);
        when TileDataType_U4X2 =>
            return UInt(index_value[3:0]);
        when TileDataType_U8 =>
            return UInt(index_value[7:0]);
        when TileDataType_U16 =>
            return UInt(index_value[15:0]);
        when TileDataType_U32 =>
            return UInt(index_value[31:0]);
        when TileDataType_U64 => return UInt(index_value);
        otherwise => unreachable;
    end;
end;

pure func TileIndexByteDisplacement(index_value: Word,
                                    index_data_type: TileDataType) => Word
begin
    assert TileDataTypeIsInteger(index_data_type);
    case index_data_type of
        when TileDataType_S4X2 =>
            return SignExtend{PTO_XLEN}(index_value[3:0]);
        when TileDataType_S8 =>
            return SignExtend{PTO_XLEN}(index_value[7:0]);
        when TileDataType_S16 =>
            return SignExtend{PTO_XLEN}(index_value[15:0]);
        when TileDataType_S32 =>
            return SignExtend{PTO_XLEN}(index_value[31:0]);
        when TileDataType_S64 => return index_value;
        when TileDataType_U4X2 =>
            return ZeroExtend{PTO_XLEN}(index_value[3:0]);
        when TileDataType_U8 =>
            return ZeroExtend{PTO_XLEN}(index_value[7:0]);
        when TileDataType_U16 =>
            return ZeroExtend{PTO_XLEN}(index_value[15:0]);
        when TileDataType_U32 =>
            return ZeroExtend{PTO_XLEN}(index_value[31:0]);
        when TileDataType_U64 => return index_value;
        otherwise => unreachable;
    end;
end;

pure func TileMemoryByteDisplacementAddress(
    base_address: Word, index_value: Word,
    index_data_type: TileDataType) => Word
begin
    return base_address +
        TileIndexByteDisplacement(index_value, index_data_type);
end;

pure func TileIndexedTLSURow(index: integer,
                             logical_columns: integer {1..65535}) => integer
begin
    if index >= 0 then return index DIVRM logical_columns; end;
    return -((((-index) + logical_columns) - 1) DIVRM logical_columns);
end;

pure func TileMemoryIndexedStridedAddress(
    base_address: Word, index_value: Word,
    index_data_type: TileDataType,
    logical_columns: integer {0..65535},
    row_stride_elements: Word,
    transfer_data_type: TileDataType) => Word
begin
    assert logical_columns > 0;
    assert UInt(row_stride_elements) >= logical_columns;
    let valid_columns = logical_columns as integer {1..65535};
    let index = TileIndexLinearElementIndex(
        index_value, index_data_type);
    let row = TileIndexedTLSURow(index, valid_columns);
    let column = index - row * valid_columns;
    assert 0 <= column && column < valid_columns;
    let element_offset = row * UInt(row_stride_elements) + column;
    let byte_offset = element_offset *
        TileMemoryElementBytes(transfer_data_type);
    return base_address + (Zeros{PTO_XLEN} + byte_offset);
end;
