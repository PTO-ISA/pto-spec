// PTO-TEST: {"id":"PTO-AVS-ARCH-MINMAX-ORDER-KEYS-EXEC-001","source":"asl/arch/features/minmax-profile.asl","requirements":[],"kind":"execution","summary":"floating order keys cover positive and negative carriers at every supported width","pass_condition":"64-, 32-, 16-, and 8-bit positive and negative order-key assertions hold","related_sources":["asl/arch/features/mx-formats.asl"]}
func main() => integer
begin
    let (fp64_positive_available, fp64_positive_key) =
        HardwareNumericFloatingOrderKey(TileDataType_FP64,
            Zeros{PTO_XLEN} + 0x3ff0000000000000);
    let (fp64_negative_available, fp64_negative_key) =
        HardwareNumericFloatingOrderKey(TileDataType_FP64,
            Zeros{PTO_XLEN} + 0xbff0000000000000);
    assert fp64_positive_available && fp64_negative_available;
    assert fp64_positive_key == Zeros{PTO_XLEN} + 0xbff0000000000000;
    assert fp64_negative_key == Zeros{PTO_XLEN} + 0x400fffffffffffff;
    assert UInt(fp64_negative_key) < UInt(fp64_positive_key);

    let (fp32_positive_available, fp32_positive_key) =
        HardwareNumericFloatingOrderKey(TileDataType_FP32,
            Zeros{PTO_XLEN} + 0x3f800000);
    let (fp32_negative_available, fp32_negative_key) =
        HardwareNumericFloatingOrderKey(TileDataType_FP32,
            Zeros{PTO_XLEN} + 0xbf800000);
    assert fp32_positive_available && fp32_negative_available;
    assert fp32_positive_key == Zeros{PTO_XLEN} + 0xbf800000;
    assert fp32_negative_key == Zeros{PTO_XLEN} + 0x407fffff;

    let (fp16_positive_available, fp16_positive_key) =
        HardwareNumericFloatingOrderKey(TileDataType_FP16,
            Zeros{PTO_XLEN} + 0x3c00);
    let (fp16_negative_available, fp16_negative_key) =
        HardwareNumericFloatingOrderKey(TileDataType_FP16,
            Zeros{PTO_XLEN} + 0xbc00);
    assert fp16_positive_available && fp16_negative_available;
    assert fp16_positive_key == Zeros{PTO_XLEN} + 0xbc00;
    assert fp16_negative_key == Zeros{PTO_XLEN} + 0x43ff;

    let (e4m3_positive_available, e4m3_positive_key) =
        HardwareNumericFloatingOrderKey(TileDataType_E4M3,
            Zeros{PTO_XLEN} + 0x38);
    let (e4m3_negative_available, e4m3_negative_key) =
        HardwareNumericFloatingOrderKey(TileDataType_E4M3,
            Zeros{PTO_XLEN} + 0xb8);
    assert e4m3_positive_available && e4m3_negative_available;
    assert e4m3_positive_key == Zeros{PTO_XLEN} + 0xb8;
    assert e4m3_negative_key == Zeros{PTO_XLEN} + 0x47;
    return 0;
end;
