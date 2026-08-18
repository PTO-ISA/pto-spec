# Exact Numeric Format Definitions Design

## Outcome

Make every floating and scale `TileDataType` format structurally explicit and
executable in ASL. Each format receives one production ASL file, one normative
documentation page, and one executable test file with the same basename.

The model represents every finite floating value exactly as:

```text
(-1)^negative * significand * 2^exponent
```

`significand` is an unsigned integer. The representation uses no host floating
point and introduces no rounding.

## Requirements and authority

This change implements the existing PTO-owned requirements:

- `PTO-REQ-PROFILE-001`
- `PTO-REQ-SCALAR-FP-001`
- `PTO-REQ-HARDWARE-NUMERIC-001`
- `PTO-REQ-CLOSURE-001`

The accepted architecture decisions and
`spec/hardware-conformance-profile.json` remain authoritative. Repository
artifacts must not name, link, index, or disclose any non-public migration
input, local path, or external source identity.

## Architecture boundary

The change defines raw format structure and exact finite-value decomposition.
It does not define arithmetic operations, conversions, rounding, exception
flags, matrix accumulation, scale multiplication order, or operation/type
support. Those behaviors remain owned by the existing numeric profile and
variation-point contracts.

The active `pto-v0` profile remains a deterministic raw-carrier profile. Adding
format decoders does not make it an IEEE or target-conformance implementation.

## Source layout

Common dispatch and cross-format helpers remain in:

```text
asl/numeric/formats.asl
docs/numeric/formats/index.md
tests/asl/numeric/formats/common.asl
```

Each format uses the same basename across production ASL, documentation, and
tests:

| Format identity | Production ASL | Documentation | Executable test |
| --- | --- | --- | --- |
| FP64 | `asl/numeric/formats/fp64.asl` | `docs/numeric/formats/fp64.md` | `tests/asl/numeric/formats/fp64.asl` |
| FP32 | `asl/numeric/formats/fp32.asl` | `docs/numeric/formats/fp32.md` | `tests/asl/numeric/formats/fp32.asl` |
| TF32 | `asl/numeric/formats/tf32.asl` | `docs/numeric/formats/tf32.md` | `tests/asl/numeric/formats/tf32.asl` |
| HF32 | `asl/numeric/formats/hf32.asl` | `docs/numeric/formats/hf32.md` | `tests/asl/numeric/formats/hf32.asl` |
| FP16 | `asl/numeric/formats/fp16.asl` | `docs/numeric/formats/fp16.md` | `tests/asl/numeric/formats/fp16.asl` |
| BF16 | `asl/numeric/formats/bf16.asl` | `docs/numeric/formats/bf16.md` | `tests/asl/numeric/formats/bf16.asl` |
| HiF8 | `asl/numeric/formats/hif8.asl` | `docs/numeric/formats/hif8.md` | `tests/asl/numeric/formats/hif8.asl` |
| E4M3 | `asl/numeric/formats/e4m3.asl` | `docs/numeric/formats/e4m3.md` | `tests/asl/numeric/formats/e4m3.asl` |
| E5M2 | `asl/numeric/formats/e5m2.asl` | `docs/numeric/formats/e5m2.md` | `tests/asl/numeric/formats/e5m2.asl` |
| E3M2 | `asl/numeric/formats/e3m2.asl` | `docs/numeric/formats/e3m2.md` | `tests/asl/numeric/formats/e3m2.asl` |
| E2M3 | `asl/numeric/formats/e2m3.asl` | `docs/numeric/formats/e2m3.md` | `tests/asl/numeric/formats/e2m3.asl` |
| E2M1X2 | `asl/numeric/formats/e2m1x2.asl` | `docs/numeric/formats/e2m1x2.md` | `tests/asl/numeric/formats/e2m1x2.asl` |
| E1M2X2 | `asl/numeric/formats/e1m2x2.asl` | `docs/numeric/formats/e1m2x2.md` | `tests/asl/numeric/formats/e1m2x2.asl` |
| E8M0 | `asl/numeric/formats/e8m0.asl` | `docs/numeric/formats/e8m0.md` | `tests/asl/numeric/formats/e8m0.asl` |
| HiF4X2 | `asl/numeric/formats/hif4x2.asl` | `docs/numeric/formats/hif4x2.md` | `tests/asl/numeric/formats/hif4x2.asl` |

The Makefile lists these files explicitly in dependency order. Generated build
output remains untracked.

## Common ASL contracts

### Format descriptor

Add one typed descriptor that separates numerical encoding from storage:

- format kind: fixed binary, HiF8 dynamic, E8M0 scale, or non-floating;
- carrier width;
- logical lane width;
- lanes per carrier;
- sign-field presence and position;
- minimum and maximum exponent-field widths;
- minimum and maximum fraction-field widths;
- fixed exponent bias availability and value;
- required low and high zero bits;
- zero, signed-zero, subnormal, infinity, quiet-NaN, and signaling-NaN
  capabilities.

For fixed formats, minimum and maximum field widths are equal. HiF8 records
the complete dynamic ranges and supplies a separate dot-field decoder. Integer
`TileDataType` identities return an unavailable floating descriptor rather than
an invented floating layout.

### Exact finite decomposition

Add a pure function with this semantic result:

```text
available, negative, significand, exponent
```

When `available` is true, the raw value is a valid finite encoding and equals:

```text
(-1)^negative * UInt(significand) * 2^exponent
```

When `available` is false, the remaining tuple fields have no numeric meaning.
The function returns false for invalid internal encodings, infinities, NaNs,
and non-floating integer types.

For a fixed `E`-bit exponent, `M`-bit fraction, and bias `B`:

- zero: `significand = 0`, `exponent = 0`;
- subnormal: `significand = fraction`, `exponent = 1 - B - M`;
- normal: `significand = 2^M + fraction`,
  `exponent = encoded_exponent - B - M`.

The exponent result type must include the FP64 minimum, `-1074`, and every
positive exponent needed by the accepted formats.

### Classification and canonical values

Existing classification, encoding-validity, subnormal-boundary, signed-zero,
and canonical-NaN APIs remain stable. Their format-specific logic moves into
the matching per-format file. `asl/numeric/formats.asl` dispatches across
`TileDataType` and retains cross-format hardware-profile helpers.

## Per-format rules

### Fixed binary formats

- FP64: S1/E11/M52, bias 1023.
- FP32: S1/E8/M23, bias 127.
- TF32: a 32-bit carrier with S1/E8/M10 and bits `[12:0]` required zero,
  bias 127.
- HF32: a 32-bit carrier with S1/E8/M11 and bits `[11:0]` required zero,
  bias 127.
- FP16: S1/E5/M10, bias 15.
- BF16: S1/E8/M7, bias 127.
- E4M3: S1/E4/M3, bias 7; no infinity; only exponent 15/fraction 7 is NaN.
- E5M2: S1/E5/M2, bias 15; IEEE-style infinity and quiet/signaling NaNs.
- E3M2: a 6-bit S1/E3/M2 value in an 8-bit zero-extended carrier; bits
  `[7:6]` are required zero; all encodings are finite.
- E2M3: a 6-bit S1/E2/M3 value in an 8-bit zero-extended carrier; bits
  `[7:6]` are required zero; all encodings are finite.

### Packed four-bit formats

E2M1X2, E1M2X2, and HiF4X2 have two logical four-bit lanes per byte. Exact
decomposition consumes one logical low-nibble lane. TLSU packing remains
low-index/low-nibble and odd-index/high-nibble with sibling preservation.

- E2M1X2: S1/E2/M1, finite only.
- E1M2X2: S1/E1/M2, finite only.
- HiF4X2: the same raw lane values as E1M2X2 but a distinct architectural
  identity.

The ASL tests enumerate all 16 lane encodings for each identity.

### HiF8

HiF8 receives a typed dot-field decoder for the six layouts:

| Prefix | Exponent bits | Fraction bits | Meaning |
| --- | ---: | ---: | --- |
| `0000` | 0 | 3 | subnormal/special domain |
| `0001` | 0 | 3 | normal with exponent zero |
| `001` | 1 | 3 | exponent magnitude 1 |
| `01` | 2 | 3 | exponent magnitude 2 through 3 |
| `10` | 3 | 2 | exponent magnitude 4 through 7 |
| `11` | 4 | 1 | exponent magnitude 8 through 15 |

For normal encodings, the exponent field uses sign-magnitude: its most
significant bit is the exponent sign and an implicit leading one precedes the
stored magnitude bits. The exact significand is `2^M + fraction`, and the
decomposition exponent is the decoded signed exponent minus `M`.

For prefix `0000` and mantissa 1 through 7, the value is
`(-1)^S * 2^(mantissa-23)`, represented by significand 1. The four special raw
values retain their accepted zero, NaN, and positive/negative infinity
classification.

### E8M0 and Microscaling

E8M0 has no sign and no zero encoding. Raw values `0x00` through `0xFE`
decompose to significand 1 and exponent `raw - 127`; `0xFF` is NaN.

The format contract exposes the scale block size of 32 logical K elements.
The base low-precision format decoder does not multiply by E8M0. Scale lookup,
application, accumulation, and rounding remain operation/profile semantics.

## Documentation contract

Every per-format page contains the same reviewable sections:

1. architecture identity and carrier/lane widths;
2. exact bit layout and required-zero constraints;
3. zero, subnormal, normal, infinity, and NaN encodings;
4. exact decomposition rules;
5. canonical NaN and signed-zero behavior where applicable;
6. packing or scaling rules where applicable;
7. explicitly excluded operation/profile behavior;
8. requirement IDs and links only to PTO-owned repository artifacts.

The index links each page and explains the common exact-value representation.

## Executable evidence

Each same-named test file proves its production file independently:

- descriptor widths, field counts, bias, and capabilities;
- positive and negative zero where defined;
- minimum and maximum subnormal;
- minimum and maximum normal;
- positive and negative infinity where defined;
- every quiet/signaling NaN distinction where defined;
- invalid required-zero encodings;
- exact `negative`, `significand`, and `exponent` decomposition results.

Additional exhaustive obligations are:

- all 16 logical lane encodings for E2M1X2, E1M2X2, and HiF4X2;
- all six HiF8 dot layouts plus every special raw value and exponent boundary;
- E8M0 raw `0x00`, `0x01`, `0x7F`, `0x80`, `0xFE`, and `0xFF`;
- exact scale block size 32;
- rejection of nonzero TF32/HF32 discarded bits and FP6 carrier padding.

Tests are called from `tests/asl/main.asl` and assigned exactly once to a
numeric-format shard. Existing broad profile tests retain only cross-format
profile behavior.

## Traceability and generated evidence

The normative change updates together:

- `spec/requirements.json`;
- `docs/architecture.md`;
- `docs/normative-sources.md`;
- `docs/coverage.md`;
- a new accepted architecture decision for exact format decomposition;
- `scripts/generate-numeric-format-namespace-contract`;
- `spec/evidence/numeric-format-namespace-contract.json`;
- `Makefile` source, test-library, and shard inventories.

No instruction catalog or decoder changes are required because the accepted
type identities and instruction encodings do not change.

## Validation

Implementation follows test-first development. The focused format tests must
fail before the new production APIs exist, then pass after the minimal format
implementation is added.

Completion requires fresh evidence from:

```bash
make repo-check
git diff --check
```

The complete pinned ASLRef gate is run if available and reported separately.
No generated `build/` or `.cache/` files are committed.
