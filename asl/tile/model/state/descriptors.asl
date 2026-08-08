// PTO-UNIT: {"id":"PTO-TILE-MODEL-STATE-DESCRIPTORS","surface":"tile","classification":["model","state","descriptors"],"depends_on":["PTO-TILE-MODEL-CAPACITY-SHARED"]}
pure func TileHandOf(index: TileIndex) => TileHand
begin
    if index < 16 then return TileHand_T;
    elsif index < 32 then return TileHand_U;
    elsif index < 48 then return TileHand_M;
    else return TileHand_N;
    end;
end;

pure func TileIndexWithinHand(index: TileIndex) => integer {1..16}
begin
    return ((index MOD 16) + 1) as integer {1..16};
end;

readonly func TileCapacityIsLegal(capacity_bytes: integer {0..262144}) => boolean
begin
    return capacity_bytes >= PTO_TILE_CELL_BYTES &&
           capacity_bytes MOD PTO_TILE_CELL_BYTES == 0 &&
           capacity_bytes <= PTO_TILE_MAX_ALLOCATION_BYTES &&
           capacity_bytes <= TileCapacityLimitBytes();
end;

pure func TileSizeCodeIsLegal(size_code: integer {0..15}) => boolean
begin
    return 1 <= size_code && size_code <= 7;
end;

pure func TileSizeCodeBytes(size_code: integer {1..7})
    => integer {128,256,512,1024,2048,4096,8192}
begin
    case size_code of
        when 1 => return 128;
        when 2 => return 256;
        when 3 => return 512;
        when 4 => return 1024;
        when 5 => return 2048;
        when 6 => return 4096;
        when 7 => return 8192;
    end;
end;

pure func TileElementBits(data_type: TileDataType) => integer {4,8,16,32,64}
begin
    case data_type of
        when TileDataType_E2M1X2, TileDataType_E1M2X2,
             TileDataType_HiF4X2, TileDataType_S4X2,
             TileDataType_U4X2 => return 4;
        when TileDataType_S8, TileDataType_U8, TileDataType_HiF8,
             TileDataType_E4M3, TileDataType_E5M2, TileDataType_E3M2,
             TileDataType_E2M3, TileDataType_E8M0 => return 8;
        when TileDataType_S16, TileDataType_U16, TileDataType_FP16,
             TileDataType_BF16 => return 16;
        when TileDataType_S32, TileDataType_U32,
             TileDataType_FP32, TileDataType_TF32,
             TileDataType_HF32 => return 32;
        when TileDataType_S64, TileDataType_U64,
             TileDataType_FP64 => return 64;
    end;
end;

