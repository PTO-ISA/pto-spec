<!-- GENERATED FROM: asl/arch/features/minmax-profile.asl -->
# Minmax Profile

**Normative ASL source:** `asl/arch/features/minmax-profile.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-MINMAX-PROFILE}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/minmax-profile.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-MINMAX-PROFILE","surface":"arch","classification":["features","minmax-profile"],"depends_on":["PTO-ARCH-FEATURES-MX-FORMATS"]}
// Convert an assigned binary floating carrier into a monotonically increasing
// unsigned key. NaNs and signed-zero ties are resolved before this helper is
// called. The returned availability bit keeps unsupported formats explicit.
pure func HardwareNumericFloatingOrderKey(
    data_type: TileDataType,
    value: Word) => (boolean, Word)
begin
    if !TileNumericEncodingValid(data_type, value) then
        return (FALSE, Zeros{PTO_XLEN});
    end;

    case data_type of
        when TileDataType_FP64 =>
            if value[63] == '1' then
                return (TRUE, NOT(value));
            else
                return (TRUE,
                    value XOR (Zeros{PTO_XLEN} + 0x8000000000000000));
            end;
        when TileDataType_FP32, TileDataType_TF32, TileDataType_HF32 =>
            let raw = value[31:0];
            let key =
                if raw[31] == '1' then NOT(raw)
                else raw XOR (Zeros{32} + 0x80000000);
            return (TRUE, ZeroExtend{PTO_XLEN}(key));
        when TileDataType_FP16, TileDataType_BF16 =>
            let raw = value[15:0];
            let key =
                if raw[15] == '1' then NOT(raw)
                else raw XOR (Zeros{16} + 0x8000);
            return (TRUE, ZeroExtend{PTO_XLEN}(key));
        when TileDataType_E4M3, TileDataType_E5M2 =>
            let raw = value[7:0];
            let key =
                if raw[7] == '1' then NOT(raw)
                else raw XOR (Zeros{8} + 0x80);
            return (TRUE, ZeroExtend{PTO_XLEN}(key));
        otherwise =>
            return (FALSE, Zeros{PTO_XLEN});
    end;
end;

// Return availability, selected raw carrier, and invalid-condition status.
// Special NaN and zero rules have priority over ordinary numeric ordering.
pure func HardwareNumericFloatingMinMax(
    maximum: boolean,
    data_type: TileDataType,
    left: Word,
    right: Word) => (boolean, Word, boolean)
begin
    let (special, special_result, invalid) =
        HardwareNumericMinMaxSpecial(maximum, data_type, left, right);
    if special then
        return (TRUE, special_result, invalid);
    end;

    let (left_available, left_key) =
        HardwareNumericFloatingOrderKey(data_type, left);
    let (right_available, right_key) =
        HardwareNumericFloatingOrderKey(data_type, right);
    if !left_available || !right_available then
        return (FALSE, Zeros{PTO_XLEN}, FALSE);
    end;

    if maximum then
        if UInt(left_key) >= UInt(right_key) then
            return (TRUE, left, FALSE);
        else
            return (TRUE, right, FALSE);
        end;
    elsif UInt(left_key) <= UInt(right_key) then
        return (TRUE, left, FALSE);
    else
        return (TRUE, right, FALSE);
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
