// PTO-UNIT: {"id":"PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS","surface":"arch","classification":["data-types","numeric-formats"],"depends_on":["PTO-ARCH-DATA-TYPES-FORMAT-FP64","PTO-ARCH-DATA-TYPES-FORMAT-FP32","PTO-ARCH-DATA-TYPES-FORMAT-TF32","PTO-ARCH-DATA-TYPES-FORMAT-HF32","PTO-ARCH-DATA-TYPES-FORMAT-FP16","PTO-ARCH-DATA-TYPES-FORMAT-BF16","PTO-ARCH-DATA-TYPES-FORMAT-HIF8","PTO-ARCH-DATA-TYPES-FORMAT-E4M3","PTO-ARCH-DATA-TYPES-FORMAT-E5M2","PTO-ARCH-DATA-TYPES-FORMAT-E3M2","PTO-ARCH-DATA-TYPES-FORMAT-E2M3","PTO-ARCH-DATA-TYPES-FORMAT-E2M1X2","PTO-ARCH-DATA-TYPES-FORMAT-E1M2X2","PTO-ARCH-DATA-TYPES-FORMAT-E8M0","PTO-ARCH-DATA-TYPES-FORMAT-HIF4X2"]}

// NDF-BEGIN: PTO-NUMERIC-FINITE-DECOMPOSITION-001
// ndf: kind=executable level=L3 layer=architecture status=accepted
// Every valid finite floating or scale encoding MUST decompose without host
// floating-point arithmetic into available, sign, integer significand, and
// integer exponent such that its exact value is
// (-1)^sign * UInt(significand) * 2^exponent. Invalid internal encodings,
// infinities, NaNs, and integer Tile DataTypes MUST report unavailable.
// NDF-END: PTO-NUMERIC-FINITE-DECOMPOSITION-001

// DOC-BEGIN: operation
pure func TileNumericFormatDescriptor(data_type: TileDataType)
    => NumericFormatDescriptor
begin
    case data_type of
        when TileDataType_FP64 => return FP64NumericFormatDescriptor();
        when TileDataType_FP32 => return FP32NumericFormatDescriptor();
        when TileDataType_TF32 => return TF32NumericFormatDescriptor();
        when TileDataType_HF32 => return HF32NumericFormatDescriptor();
        when TileDataType_FP16 => return FP16NumericFormatDescriptor();
        when TileDataType_BF16 => return BF16NumericFormatDescriptor();
        when TileDataType_HiF8 => return HiF8NumericFormatDescriptor();
        when TileDataType_E4M3 => return E4M3NumericFormatDescriptor();
        when TileDataType_E5M2 => return E5M2NumericFormatDescriptor();
        when TileDataType_E3M2 => return E3M2NumericFormatDescriptor();
        when TileDataType_E2M3 => return E2M3NumericFormatDescriptor();
        when TileDataType_E2M1X2 => return E2M1X2NumericFormatDescriptor();
        when TileDataType_E1M2X2 => return E1M2X2NumericFormatDescriptor();
        when TileDataType_E8M0 => return E8M0NumericFormatDescriptor();
        when TileDataType_HiF4X2 => return HiF4X2NumericFormatDescriptor();
        otherwise => return UnavailableNumericFormatDescriptor();
    end;
end;

pure func TileNumericFiniteDecomposition(
    data_type: TileDataType,
    value: Word) => (boolean, boolean, Word, integer {-1074..1023})
begin
    case data_type of
        when TileDataType_FP64 => return FP64FiniteDecomposition(value);
        when TileDataType_FP32 => return FP32FiniteDecomposition(value[31:0]);
        when TileDataType_TF32 => return TF32FiniteDecomposition(value[31:0]);
        when TileDataType_HF32 => return HF32FiniteDecomposition(value[31:0]);
        when TileDataType_FP16 => return FP16FiniteDecomposition(value[15:0]);
        when TileDataType_BF16 => return BF16FiniteDecomposition(value[15:0]);
        when TileDataType_HiF8 => return HiF8FiniteDecomposition(value[7:0]);
        when TileDataType_E4M3 => return E4M3FiniteDecomposition(value[7:0]);
        when TileDataType_E5M2 => return E5M2FiniteDecomposition(value[7:0]);
        when TileDataType_E3M2 => return E3M2FiniteDecomposition(value[7:0]);
        when TileDataType_E2M3 => return E2M3FiniteDecomposition(value[7:0]);
        when TileDataType_E2M1X2 => return E2M1X2FiniteDecomposition(value);
        when TileDataType_E1M2X2 => return E1M2X2FiniteDecomposition(value);
        when TileDataType_E8M0 => return E8M0FiniteDecomposition(value[7:0]);
        when TileDataType_HiF4X2 => return HiF4X2FiniteDecomposition(value);
        otherwise => return (FALSE, FALSE, Zeros{PTO_XLEN}, 0);
    end;
end;
// DOC-END: operation
