# ADR 0044: Public integer conversion result subset

> Historical-evidence note: verification paths named below record the evidence used when this ADR was accepted; deleted aggregate checks are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Status

Accepted executable subset; same-width signedness changes, profile support,
floating conversion, rounding, saturation, flags, and exceptional results
remain open.

## Context

The public PTO type system defines integer widening and narrowing independently
of any backend. Widening sign-extends a signed source and zero-extends an
unsigned source. Narrowing truncates the high source bits. The public type table
also fixes the signedness and width of `i8/u8/i16/u16/i32/u32/i64/u64`, and
identifies `pto.tcvt` as the tile conversion operation.

The existing ASL integer path normalized only to the destination type. That is
correct for truncation, but not for signed widening: an `S8` payload `0x80`
could become positive `128` in `S16` instead of negative `-128`.

## Decision

For `TCVT`, when both operands use one of the eight public integer types and
their widths differ:

1. Interpret the source payload at the source width.
2. On widening, sign-extend a signed source and zero-extend an unsigned source.
3. On narrowing, retain the low destination-width bits and discard all higher
   bits.
4. Canonicalize the destination payload to PTO's 64-bit model word using the
   destination signedness.

The rule defines 48 ordered unequal-width source/destination tuples: 24
widening and 24 narrowing. It defines results only after a target profile has
accepted the type pair. It does not make any pair supported by A2/A3 or A5.

Same-width conversions are excluded because the pinned public rule states only
widening and narrowing. Floating-point, float/integer, quantization, rounding,
saturation, exception, and flag behavior remain behind their existing numeric
profile hooks.

## Consequences

`TileConvertValue` now normalizes the source before the destination. Direct and
decoded `TCVT` therefore agree for signed widening, unsigned widening, and
narrowing corners without changing any floating path.

`S5-T2-A6` closes this 48-tuple portable result subset. It does not accept the
parent `PD-07` decision, complete the `tile-convert` domain, select any of the
99 broad variation-point routes, or change the M4 maturity floor.

The pinned independent executable model's vector integer-conversion subset uses
the same source-width-first widening/narrowing structure. It is corroboration
only: that vector surface is outside PTO, and its type-code values, predicate
behavior, and register packing are not PTO semantics.

## Evidence

- `spec/evidence/public-integer-conversion-contract.json`
- `scripts/generate-public-integer-conversion-contract`
- `asl/tile/conversion.asl`
- `tests/asl/tile-tests.asl`
- `spec/evidence/public-numeric-type-baseline.json`
- `spec/evidence/numeric-profile-decision-inputs.json`
- `spec/evidence/executable-model-comparison.json`
- `scripts/check-catalogs`
