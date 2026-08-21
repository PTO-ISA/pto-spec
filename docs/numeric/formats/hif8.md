# HiF8

HiF8 is an 8-bit dynamic dot/exponent/mantissa format. Bit 7 is the value
sign. The prefix beginning at bit 6 determines the exponent and fraction
widths.

## Dynamic fields

| Prefix | Dot class | Exponent bits | Fraction bits |
| --- | --- | ---: | ---: |
| `0000` | Denormal | 0 | 3 |
| `0001` | D0 | 0 | 3 |
| `001` | D1 | 1 | 3 |
| `01` | D2 | 2 | 3 |
| `10` | D3 | 3 | 2 |
| `11` | D4 | 4 | 1 |

For D1 through D4, the exponent field uses sign-magnitude. Its most
significant bit is the exponent sign. Prepending an implicit magnitude one to
the remaining exponent bits yields magnitudes 1, 2..3, 4..7, and 8..15.

## Exact finite value

For a normal value with `m` fraction bits and decoded signed exponent `e`:

```text
significand = 2^m + fraction
exponent = e - m
value = (-1)^S * significand * 2^exponent
```

D0 uses `e=0`. For the Denormal prefix and mantissa 1..7:

```text
significand = 1
exponent = mantissa - 23
```

The positive subnormal exponent range is therefore -22 through -16.

## Special encodings

| Raw | Value class |
| --- | --- |
| `0x00` | Zero |
| `0x80` | Quiet NaN and canonical NaN |
| `0x6F` | Positive infinity |
| `0xEF` | Negative infinity |

HiF8 has one zero encoding and therefore no signed zero. It has no signaling
NaN encoding.

## Scope

This page defines encoding and exact finite values only. Arithmetic, rounding,
flags, and operation/type support remain profile contracts. Requirements:
`PTO-REQ-PROFILE-001`, `PTO-REQ-SCALAR-FP-001`,
`PTO-REQ-HARDWARE-NUMERIC-001`, and `PTO-REQ-CLOSURE-001`.
