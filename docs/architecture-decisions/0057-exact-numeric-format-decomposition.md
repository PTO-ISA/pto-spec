# ADR 0057: Exact numeric format decomposition

## Status

Accepted as the `PD-02-SC3` exact-format checkpoint. Arithmetic conformance,
operation/type/profile legality, and implementation parity remain open under
`S5-T2`.

## Context

ADR 0040 separates numeric encoding namespaces, and ADR 0048 defines the
bit-exact value classes and canonical NaNs. The ASL model could classify raw
values but did not expose one typed description of each floating format or an
exact finite-value decoder. Reviewers therefore had to reconstruct field
widths, biases, constrained bits, packed lanes, and finite values from several
artifacts.

## Decision

### Carrier and logical value structure

`NumericFormatDescriptor` distinguishes carrier width, logical lane width,
lanes per carrier, sign/exponent/fraction fields, exponent bias, required zero
padding, and special-value capabilities.

TF32 and HF32 remain 32-bit carriers with 13 and 12 required low zero bits.
E3M2 and E2M3 are six-bit values in zero-extended eight-bit carriers. E2M1X2,
E1M2X2, and HiF4X2 contain two logical four-bit lanes per byte; ADR 0033
continues to own byte packing and sibling preservation.

### Exact finite decomposition

For every valid finite floating or scale encoding,
`TileNumericFiniteDecomposition` returns:

```text
available, negative, significand, exponent
```

When available, the exact value is:

```text
(-1)^negative * UInt(significand) * 2^exponent
```

The decoder uses only integers and bitvectors. It performs no rounding and
depends on no host floating-point behavior. Invalid internal encodings,
infinities, NaNs, and integer data types return unavailable.

### Dynamic and scale formats

HiF8 has an explicit six-way dot-field decoder. Its normal exponent uses the
accepted sign-magnitude construction, and its denormal domain decomposes to a
unit significand with exponent `mantissa - 23`.

E8M0 values `0x00..0xFE` decompose to unit significand and exponent
`raw - 127`; `0xFF` is quiet NaN. The shared scale block contains 32 logical K
elements. The format decoder does not apply E8M0 to a base value.

### File and evidence isolation

Each format has one ASL file, one reference page, and one executable test file
with the same basename. The common dispatcher remains
`asl/numeric/formats.asl`, and the numeric-format test shard calls every
format-specific test exactly once.

## Boundaries

This decision does not define arithmetic, conversion, rounding, saturation,
flags, NaN propagation by an instruction, matrix accumulation, or
operation/type/profile support. It does not change `pto-v0` raw-carrier
semantics or claim hardware conformance.

## Verification obligations

Executable evidence covers descriptor fields, zero, subnormal and normal
boundaries, infinity and NaN classes, required-zero violations, exact finite
tuples, all packed four-bit lane encodings, every HiF8 dot class, and E8M0
boundaries and block size.

## Affected sources

- `asl/types.asl`
- `asl/numeric/formats.asl`
- `asl/numeric/formats/`
- `tests/asl/numeric/formats/`
- `tests/asl/shards/numeric-formats.asl`
- `docs/numeric/formats/`
- `spec/evidence/numeric-format-namespace-contract.json`
