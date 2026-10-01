<!-- GENERATED FROM: asl/arch/features/minmax.asl -->
# Minmax

**Normative ASL source:** `asl/arch/features/minmax.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-MINMAX}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-minmax-profile-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit holds two `pure` helpers of a named hardware numeric profile: `HardwareNumericFloatingOrderKey(data_type, value) => (boolean, Word)` maps one carrier to an unsigned ordering key, and `HardwareNumericFloatingMinMax(maximum, data_type, left, right) => (boolean, Word, boolean)` selects one of two carriers.

The owning file embeds no NDF clause; its normative content is the two function bodies and their comments.

The first element of each result is an availability bit. `FALSE` means this profile returns no key or no selection, and the returned `Word` is then the placeholder `Zeros{PTO_XLEN}`.

<!-- PTO-READER-BLOCK: arch-minmax-profile-concepts-state role=concepts-state -->
## The ordering key

Every key request first calls `TileNumericEncodingValid(data_type, value)`; a carrier that fails that check returns `(FALSE, Zeros{PTO_XLEN})` before any bit manipulation.

- `FP64`: the sign is bit `63`; a negative carrier returns `NOT(value)` over the whole `64`-bit `Word`, and a non-negative carrier returns `value XOR (Zeros{PTO_XLEN} + 0x8000000000000000)`.
- `FP32`, `TF32`, `HF32`: `raw` is `value[31:0]`; a negative carrier returns `NOT(raw)`, otherwise `raw XOR (Zeros{32} + 0x80000000)`, zero-extended to `PTO_XLEN`.
- `FP16`, `BF16`: `raw` is `value[15:0]`, inverted when negative and otherwise toggled with `0x8000`, then zero-extended to `PTO_XLEN`.
- `E4M3`, `E5M2`: `raw` is `value[7:0]`, inverted when negative and otherwise toggled with `0x80`, then zero-extended to `PTO_XLEN`.
- Every other `TileDataType` returns `(FALSE, Zeros{PTO_XLEN})`.

Design point: the transform rewrites sign-magnitude into biased order, inverting all bits of a negative carrier and setting the top bit of a non-negative one. An unsigned comparison of two keys therefore orders the underlying values, and the selection can test `>=` or `<=` instead of adding a separate equality case.

<!-- PTO-READER-BLOCK: arch-minmax-profile-rules-interactions role=rules-interactions -->
## Rules and interactions

`HardwareNumericFloatingMinMax` calls `HardwareNumericMinMaxSpecial` first and returns its result unchanged when that handler reports the pair handled.

Otherwise both keys are computed. If either is unavailable the helper returns `(FALSE, Zeros{PTO_XLEN}, FALSE)`, so the invalid-condition element is `FALSE` on that path even when the unavailability came from an encoding check.

With both keys available, `maximum` returns `left` when `UInt(left_key) >= UInt(right_key)` and otherwise `right`; the minimum branch uses `UInt(left_key) <= UInt(right_key)` with the same fallback, so equal keys select `left` for both operations.

Design point: the encoding check inside the key helper constrains four types only. `TileNumericEncodingValid` tests `TF32` with `value[12:0] == Zeros{13}`, `HF32` with `value[11:0] == Zeros{12}`, `E3M2` and `E2M3` with their own rules, and returns `TRUE` for every other type. An `FP32`, `FP16`, `BF16`, `E4M3`, or `E5M2` carrier can therefore never make a key unavailable through that check, while a `TF32` or `HF32` carrier whose low bits are not zero can.

<!-- PTO-READER-BLOCK: arch-minmax-profile-boundaries role=boundaries -->
## Architectural boundaries

Special cases are decided before any key exists. One NaN operand returns the other carrier and a signaling NaN sets the invalid element; two NaNs return the canonical NaN of the data type through `HardwareNumericCanonicalNaNResult`. Two zeros return `left` only for the `maximum` of two negative zeros, return the negative-zero operand for the minimum, and otherwise return `Zeros{PTO_XLEN}`.

A type outside the key arms, such as `E3M2`, still has a value class for the special handler, but an ordinary pair of such carriers has no ordering key and reports unavailable.

Design point: the availability bit is consumed by a model assertion at the tile owner. `TileFloatingMinMaxValue` in `asl/tile/model/execution/minmax.asl` asserts `available` before returning a selection and passes the invalid element to its caller, so an unsupported type or an illegal `TF32` carrier becomes an assertion at that call site instead of a silent zero result.

This unit defines no instruction, no fault, and no destination; it returns carriers and status elements only.

<!-- PTO-READER-BLOCK: arch-minmax-profile-example-usage role=example-usage -->
## Non-normative reading example

Take two positive `FP32` normals, `0x3f800000` and `0x40000000`. Both are non-negative, so the keys are `0xbf800000` and `0xc0000000` after the sign-bit toggle. For `maximum`, `UInt(0xbf800000) >= UInt(0xc0000000)` is false and the helper returns the right carrier `0x40000000`; for minimum the left comparison is true and it returns `0x3f800000`. The returned `Word` is the raw carrier, not the key.

Take a `TF32` carrier `0x3f800001`. Its bit `0` is `1`, so `value[12:0] == Zeros{13}` fails, the key helper returns unavailable, and the triple is `(FALSE, Zeros{PTO_XLEN}, FALSE)`: the invalid element is `FALSE` even though the carrier is an illegal `TF32` encoding.

Reaching the same pair through `TileFloatingMinMaxValue` arrives at `assert available` and fails the model assertion.

<!-- PTO-READER-BLOCK: arch-minmax-profile-related-owners role=related-owners-navigation -->
## Related owners

- [Hardware numeric format policy](mx-formats.md) owns `TileNumericEncodingValid` and the canonical NaN of each type.
- [Numeric classification](../data-types/numeric-classification.md) owns the value classes and `NumericValueClassIsZero`.
- [Tile min and max execution](../../tile/model/execution/minmax.md) is the caller that consumes the availability bit.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/minmax.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-MINMAX","surface":"arch","classification":["features","minmax"],"depends_on":["PTO-ARCH-FEATURES-MX-FORMATS"]}
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
