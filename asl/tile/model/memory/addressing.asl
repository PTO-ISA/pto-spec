// PTO-UNIT: {"classification":["model","memory","addressing"],"depends_on":["PTO-ARCH-MEMORY-MODEL-ORDERING","PTO-TILE-MODEL-MEMORY-SHARED-MOVEMENT"],"id":"PTO-TILE-MODEL-MEMORY-ADDRESSING","surface":"tile"}
// NDF-BEGIN: PTO-INDEXED-TLSU-STRIDE-001
// ndf: kind=executable level=L3 layer=tile status=accepted
// Indexed TLSU MUST interpret S32, U32, S64, and U64 IndexTile elements as
// byte displacements. Signed values MUST sign-extend and unsigned values MUST
// zero-extend before addition to BaseGPR. Indexed TLSU MUST NOT scale the
// displacement, decompose it by ValidCol, or consume an implicit row stride.
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

// RANGE-001 scheduling arithmetic is deliberately separate from the
// architectural effective-address helper above. Its integer endpoints do not
// wrap at PTO_XLEN and are never used as MemoryEvent addresses.
type TileIndexedTLSUByteInterval of record {
    valid: boolean,
    start_byte: integer,
    end_byte_exclusive: integer
};

type TileIndexedTLSURangeRelation of enumeration {
    TileIndexedTLSURange_Unknown,
    TileIndexedTLSURange_Overlap,
    TileIndexedTLSURange_Disjoint
};

pure func TileIndexedTLSUByteIntervalFromDescriptor(
    descriptor_present: boolean,
    base_address: Word,
    minimum_displacement: Word,
    maximum_displacement: Word,
    access_bytes: integer {1,2,4,8}) => TileIndexedTLSUByteInterval
begin
    let minimum = SInt(minimum_displacement);
    let maximum = SInt(maximum_displacement);
    let start_byte = UInt(base_address) + minimum;
    let end_byte_exclusive = UInt(base_address) + maximum + access_bytes;
    let address_space_end = UInt(Ones{PTO_XLEN}) + 1;
    let valid = descriptor_present && minimum <= maximum &&
        start_byte >= 0 && start_byte < end_byte_exclusive &&
        end_byte_exclusive <= address_space_end;
    return TileIndexedTLSUByteInterval {
        valid = valid,
        start_byte = start_byte,
        end_byte_exclusive = end_byte_exclusive
    };
end;

pure func TileIndexedTLSUByteIntervalRelation(
    left: TileIndexedTLSUByteInterval,
    right: TileIndexedTLSUByteInterval,
    addresses_comparable: boolean) => TileIndexedTLSURangeRelation
begin
    if !addresses_comparable || !left.valid || !right.valid then
        return TileIndexedTLSURange_Unknown;
    end;
    if left.end_byte_exclusive <= right.start_byte ||
       right.end_byte_exclusive <= left.start_byte then
        return TileIndexedTLSURange_Disjoint;
    end;
    return TileIndexedTLSURange_Overlap;
end;

pure func TileIndexedTLSUByteIntervalUnion(
    left: TileIndexedTLSUByteInterval,
    right: TileIndexedTLSUByteInterval) => TileIndexedTLSUByteInterval
begin
    if !left.valid || !right.valid then
        return TileIndexedTLSUByteInterval {
            valid = FALSE,
            start_byte = 0,
            end_byte_exclusive = 0
        };
    end;
    return TileIndexedTLSUByteInterval {
        valid = TRUE,
        start_byte = if left.start_byte < right.start_byte
            then left.start_byte else right.start_byte,
        end_byte_exclusive = if left.end_byte_exclusive >
                right.end_byte_exclusive
            then left.end_byte_exclusive else right.end_byte_exclusive
    };
end;
