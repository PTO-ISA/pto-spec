# ADR 0048: Numeric format value classification

## Status

Accepted as the `PD-02-SC2` and `PD-05-SC1` format-classification checkpoint.
This decision does not complete PD-02 or PD-05 and does not change the M4
maturity floor.

## Context

ADR 0040 separated the five numeric code namespaces and fixed all 25
`TileDataType` identities, carrier widths, and packed four-bit order. The named
hardware numeric contract already records the bit layout of every type, but the
ASL model had no shared executable definition of zero, subnormal, normal,
infinity, quiet NaN, signaling NaN, or invalid internal encodings for tile
values. The active `pto-v0` profile consequently retained a raw-carrier helper
that deliberately treated every tile value as non-NaN.

That gap blocked later decisions from stating special-value, subnormal,
conversion, reduction, ordering, and matrix rules without repeating or
implicitly guessing format facts.

## Decision

### One typed classification vocabulary

`NumericValueClass` contains exactly these mutually exclusive classes:

- invalid encoding;
- positive and negative zero;
- positive and negative subnormal;
- positive and negative normal;
- positive and negative infinity;
- quiet NaN; and
- signaling NaN.

`TileNumericValueClass(data_type, value)` returns one class for every
`TileDataType` and every ASL `Word` carrier. Bits above the logical element
width are verification-carrier padding and do not participate in the value.

### Internally constrained encodings

Four formats have constraints inside their architectural carrier:

| Type | Required bits |
| --- | --- |
| TF32 | bits 12:0 are zero |
| HF32 | bits 11:0 are zero |
| E3M2 | bits 7:6 are zero |
| E2M3 | bits 7:6 are zero |

`TileNumericEncodingValid` reports these constraints. A violating value is
classified as `NumericValue_InvalidEncoding`. This checkpoint classifies the
bit pattern; it does not yet decide which operation/type/profile tuples may
consume it or which architecture-visible rejection or canonicalization rule a
future profile applies.

### Special-value capabilities

The following table fixes format capabilities independently of instruction
behavior:

| Types | NaN | signaling NaN | infinity | subnormal | signed zero |
| --- | --- | --- | --- | --- | --- |
| FP64, FP32, TF32, HF32, FP16, BF16 | yes | yes | yes | yes | yes |
| HiF8 | yes | no | yes | yes | no |
| E4M3 | yes | no | no | yes | yes |
| E5M2 | yes | yes | yes | yes | yes |
| E3M2, E2M3 | no | no | no | yes | yes |
| E2M1X2, E1M2X2, HiF4X2 | no | no | no | no | yes |
| E8M0 | yes | no | no | no | no zero encoding |
| signed and unsigned integer types | no | no | no | no | no negative zero |

For packed four-bit types, classification applies to one logical low-nibble
value. TMA packing and sibling preservation remain governed by ADR 0033.

### Canonical NaNs

`TileNumericCanonicalNaN` returns whether a type has a NaN and, when it does,
the exact canonical encoding:

| Type | Canonical NaN |
| --- | --- |
| FP64 | `0x7FF8000000000000` |
| FP32, TF32, HF32 | `0x7FC00000` |
| FP16 | `0x7E00` |
| BF16 | `0x7FC0` |
| HiF8 | `0x80` |
| E4M3 | `0x7F` |
| E5M2 | `0x7E` |
| E8M0 | `0xFF` |

Finite-only and integer types return `available = FALSE`; the accompanying
zero carrier has no numeric meaning and must not be used as a NaN substitute.

### Shared scalar classification

Scalar FP32 and FP64 NaN, signaling-NaN, zero, and canonical-NaN helpers use
the same format classifier. This removes a duplicate definition while
preserving the accepted scalar FSU behavior.

### Profile boundary

This decision does not bind the accepted value classes into the active
`pto-v0` tile arithmetic hooks. `pto-v0` remains the deterministic raw-carrier
reference profile. In particular, `TileProfileValueIsNaN` still returns false
there. A named numeric profile must explicitly use the accepted classifier and
supply complete operation/type result, flag, and rejection rules before it may
claim hardware or IEEE conformance.

## Independent comparison

An independently reviewed executable ISA model was checked at its recorded
clean snapshot. Its FP32 and FP64 classifiers agree on:

- exponent/fraction NaN detection;
- quiet-versus-signaling NaN discrimination;
- positive and negative zero equivalence;
- canonical quiet-NaN encodings; and
- min/max signed-zero and one-NaN selection foundations.

The comparison model has no authoritative PTO low-precision type binding and
does not cover HiF8, E4M3, E5M2, E3M2, E2M3, the packed four-bit types, or
E8M0. Those definitions come from the PTO-owned hardware profile and are not
inferred from the comparison.

## Rejected alternatives

- **Keep classification in each operation hook.** Rejected because duplicate
  bit tests can disagree across compare, conversion, reduction, sort, and
  matrix families.
- **Make `pto-v0` IEEE-aware implicitly.** Rejected because that would change
  the active reference profile without closing its result and flag contracts.
- **Treat all exponent-all-ones formats alike.** Rejected because E4M3 has no
  infinity, E8M0 has one NaN code and no zero, and finite-only types have no
  NaN or infinity.
- **Treat nonzero carrier padding as invalid.** Rejected because bits above the
  logical element width are ASL verification storage, not architectural bits.
- **Accept internally noncanonical TF32, HF32, E3M2, or E2M3 payloads as normal
  values.** Rejected because it erases explicit format constraints and makes
  later legality decisions unreviewable.

## Verification obligations

Executable assertions cover:

- quiet and signaling NaNs for every signaling-capable format;
- both infinities where defined;
- positive and negative zero where defined;
- minimum positive and negative subnormals;
- finite-only and packed four-bit values;
- every internal invalid-encoding constraint;
- E8M0's NaN and absence of zero; and
- canonical-NaN availability and exact bits.

The repository checker binds the ASL classifier, this decision, the hardware
profile, the generated format ledger, and the direct assertions together.

## Remaining boundaries

PD-02 still requires the complete operation/type/profile legality matrix,
target support, and independent result vectors. ADR 0050 now owns the bounded
PD-05-SC2 hardware special-value checkpoint for produced canonical NaNs,
comparison NaN/signed-zero results, and MIN/MAX NaN/signed-zero results. PD-05
still requires infinity arithmetic, broader NaN creation, conversions,
reductions, quantization, matrix results, and complete flag/status behavior.
ADR 0049 owns subnormal execution and tininess rules for the named hardware
profile. PD-06 owns scalar exception flags. No variation route or complete
numeric domain is closed by classification alone.

## Affected sources

- `asl/types.asl`
- `asl/numeric/formats.asl`
- `asl/scalar/floating.asl`
- `tests/asl/profile-tests.asl`
- `spec/hardware-conformance-profile.json`
- `spec/evidence/numeric-format-namespace-contract.json`
- `scripts/generate-numeric-format-namespace-contract`
