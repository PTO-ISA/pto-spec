#!/usr/bin/env python3
"""Verify GM floating-add AVS bits with an independent exact Fraction oracle."""

from fractions import Fraction
from pathlib import Path
import random
import re


ROOT = Path(__file__).resolve().parents[2]
FORMATS = {"FP16": (5, 10), "BF16": (8, 7), "FP32": (8, 23), "FP64": (11, 52)}
TESTS = ROOT / "tests/asl/tile/model/memory/gm-atom-red"
PATTERN = re.compile(
    r"let value_\d+ = GMFloatingAddPTX\(TileDataType_(FP16|BF16|FP32|FP64),"
    r"\s*Zeros\{PTO_XLEN\}\s*\+\s*0x([0-9a-fA-F]+),"
    r"\s*Zeros\{PTO_XLEN\}\s*\+\s*0x([0-9a-fA-F]+)\);"
    r"\s*assert value_\d+ == Zeros\{PTO_XLEN\}\s*\+\s*0x([0-9a-fA-F]+);",
    re.MULTILINE,
)


def power_of_two(exponent: int) -> Fraction:
    return Fraction(2**exponent) if exponent >= 0 else Fraction(1, 2 ** -exponent)


def round_even(value: Fraction) -> int:
    quotient, remainder = divmod(value.numerator, value.denominator)
    return quotient + int(2 * remainder > value.denominator or
                          (2 * remainder == value.denominator and quotient % 2 == 1))


def add_bits(left: int, right: int, exponent_bits: int, fraction_bits: int) -> int:
    width = 1 + exponent_bits + fraction_bits
    sign_bit = 1 << (width - 1)
    exponent_mask = (1 << exponent_bits) - 1
    fraction_mask = (1 << fraction_bits) - 1
    bias = (1 << (exponent_bits - 1)) - 1
    minimum_exponent = 1 - bias
    maximum_exponent = bias
    left &= (1 << width) - 1
    right &= (1 << width) - 1

    def decode(raw: int):
        exponent = (raw >> fraction_bits) & exponent_mask
        fraction = raw & fraction_mask
        negative = bool(raw & sign_bit)
        if exponent == exponent_mask:
            return ("nan" if fraction else "infinity", negative, None)
        significand = fraction if exponent == 0 else (1 << fraction_bits) + fraction
        power = (minimum_exponent if exponent == 0 else exponent - bias) - fraction_bits
        value = significand * power_of_two(power)
        return "finite", negative, -value if negative else value

    left_kind, left_negative, left_value = decode(left)
    right_kind, right_negative, right_value = decode(right)
    canonical_nan = (exponent_mask << fraction_bits) | (1 << (fraction_bits - 1))
    if left_kind == "nan" or right_kind == "nan":
        return canonical_nan
    if left_kind == "infinity" or right_kind == "infinity":
        if (left_kind == right_kind == "infinity" and
                left_negative != right_negative):
            return canonical_nan
        negative = left_negative if left_kind == "infinity" else right_negative
        return (sign_bit if negative else 0) | (exponent_mask << fraction_bits)

    result = left_value + right_value
    if result == 0:
        negative_zero_sum = (left_value == 0 and right_value == 0 and
                             left_negative and right_negative)
        return sign_bit if negative_zero_sum else 0
    negative = result < 0
    magnitude = abs(result)
    exact_exponent = magnitude.numerator.bit_length() - magnitude.denominator.bit_length()
    if magnitude < power_of_two(exact_exponent):
        exact_exponent -= 1
    if exact_exponent < minimum_exponent:
        rounded = round_even(magnitude / power_of_two(minimum_exponent - fraction_bits))
        return (sign_bit if negative else 0) | rounded

    significand = round_even(magnitude / power_of_two(exact_exponent - fraction_bits))
    if significand == 1 << (fraction_bits + 1):
        significand >>= 1
        exact_exponent += 1
    if exact_exponent > maximum_exponent:
        return (sign_bit if negative else 0) | (exponent_mask << fraction_bits)
    encoded = ((exact_exponent + bias) << fraction_bits) + (significand - (1 << fraction_bits))
    return (sign_bit if negative else 0) | encoded


def vectors(dtype: str, rng: random.Random):
    exponent_bits, fraction_bits = FORMATS[dtype]
    width = 1 + exponent_bits + fraction_bits
    exponent_mask = (1 << exponent_bits) - 1
    bias = (1 << (exponent_bits - 1)) - 1
    sign = 1 << (width - 1)
    one = bias << fraction_bits
    infinity = exponent_mask << fraction_bits
    largest_finite = infinity - 1
    half_ulp = (bias - fraction_bits - 1) << fraction_bits
    pairs = [
        (one + 2 * (1 << fraction_bits) + (3 << (fraction_bits - 2)), one),
        ((bias + 3) << fraction_bits, (bias + 1) << fraction_bits),
        (one, half_ulp), (one + 1, half_ulp), (1, 1),
        (1 << fraction_bits, sign | ((1 << fraction_bits) - 1)),
        ((1 << fraction_bits) - 1, 1), (0, sign), (sign, sign),
        (one, sign | one), (infinity, one), (infinity, sign | infinity),
        (largest_finite, largest_finite), (sign | largest_finite, sign | largest_finite),
        (infinity | 1, one), (infinity | (1 << (fraction_bits - 1)) | 3, one),
        (largest_finite, 1), (sign | 1, sign | 1),
        (sign | (1 << fraction_bits), (1 << fraction_bits) - 1),
    ]
    pairs.extend((rng.getrandbits(width), rng.getrandbits(width)) for _ in range(32))
    return [(left, right, add_bits(left, right, exponent_bits, fraction_bits))
            for left, right in pairs]


def main() -> None:
    checked = 0
    rng = random.Random(397)
    for dtype in FORMATS:
        path = TESTS / f"tile-exec-gm-add-{dtype.lower()}-001.asl"
        matches = [(kind, int(left, 16), int(right, 16), int(result, 16))
                   for kind, left, right, result in PATTERN.findall(path.read_text())]
        expected = [(dtype, *vector) for vector in vectors(dtype, rng)]
        if matches != expected:
            raise SystemExit(f"{path}: oracle mismatch or missing vector ({len(matches)} cases)")
        checked += len(matches)
    print(f"PASS: {checked} independent exact Fraction vectors across 4 GM floating types")


if __name__ == "__main__":
    main()
