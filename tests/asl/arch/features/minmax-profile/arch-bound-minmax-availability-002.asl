// PTO-TEST: {"id":"PTO-AVS-ARCH-MINMAX-AVAILABILITY-BOUND-002","source":"asl/arch/features/minmax-profile.asl","requirements":[],"kind":"boundary","summary":"invalid TF32 and unsupported integer carriers have no floating order key","pass_condition":"invalid and unsupported requests return unavailable with the zero placeholder","related_sources":["asl/arch/features/mx-formats.asl"]}
func main() => integer
begin
    let (invalid_tf32_available, invalid_tf32_key) =
        HardwareNumericFloatingOrderKey(TileDataType_TF32,
            Zeros{PTO_XLEN} + 0x3f800001);
    assert !invalid_tf32_available;
    assert invalid_tf32_key == Zeros{PTO_XLEN};

    let (integer_available, integer_key) =
        HardwareNumericFloatingOrderKey(TileDataType_S32,
            Zeros{PTO_XLEN} + 1);
    assert !integer_available;
    assert integer_key == Zeros{PTO_XLEN};
    return 0;
end;
