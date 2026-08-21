# Numeric formats

PTO represents every finite floating or scale value exactly as:

```text
(-1)^negative * UInt(significand) * 2^exponent
```

`TileNumericFormatDescriptor` reports the carrier, logical lane, field,
padding, bias, and special-value properties. `TileNumericFiniteDecomposition`
returns the exact tuple `(available, negative, significand, exponent)`.
Non-finite values, invalid internal encodings, and integer `TileDataType`
identities return `available = FALSE`.

## Format reference

| Identity | Reference | Carrier | Logical lane |
| --- | --- | ---: | ---: |
| FP64 | [FP64](fp64.md) | 64 | 64 |
| FP32 | [FP32](fp32.md) | 32 | 32 |
| TF32 | [TF32](tf32.md) | 32 | 32 |
| HF32 | [HF32](hf32.md) | 32 | 32 |
| FP16 | [FP16](fp16.md) | 16 | 16 |
| BF16 | [BF16](bf16.md) | 16 | 16 |
| HiF8 | [HiF8](hif8.md) | 8 | 8 |
| E4M3 | [E4M3](e4m3.md) | 8 | 8 |
| E5M2 | [E5M2](e5m2.md) | 8 | 8 |
| E3M2 | [E3M2](e3m2.md) | 8 | 6 |
| E2M3 | [E2M3](e2m3.md) | 8 | 6 |
| E2M1X2 | [E2M1X2](e2m1x2.md) | 8 | 4 |
| E1M2X2 | [E1M2X2](e1m2x2.md) | 8 | 4 |
| E8M0 | [E8M0](e8m0.md) | 8 | 8 |
| HiF4X2 | [HiF4X2](hif4x2.md) | 8 | 4 |

Carrier and lane widths are distinct. TF32 and HF32 retain constrained zero
bits inside a 32-bit carrier. E3M2 and E2M3 use six value bits in a
zero-extended byte. The packed four-bit identities contain two logical lanes
per byte.

These definitions do not select instruction arithmetic, rounding, flags,
scale application, or operation/type/profile support.
