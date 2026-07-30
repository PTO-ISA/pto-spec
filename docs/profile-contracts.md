# Architecture profile contracts

PTO retains named ASL `impdef` interfaces so an implementation profile is an
auditable layer rather than hidden backend behavior. The normative repository
selects one complete executable implementation, `pto-v0`, in
`asl/profiles/pto-v0.asl`. Every registered interface has exactly one matching
`implementation func` and a direct witness in `tests/asl/profile-tests.asl`.
The machine-readable authority for that executable reference-test layer is
`spec/profile-hooks.json`. The separate hardware numeric contract is
`spec/hardware-conformance-profile.json`.

The interface declaration, active implementation, and conformance tests travel
together. Removing, renaming, or adding a hook must update all three in one
reviewable change. An alternative implementation is conforming only if it names
the replaced hooks, satisfies every recorded obligation, preserves non-profile
architecture behavior, and supplies raw input/output and state-effect tests.

## Profile identities

PTO ISA 0.57.1 defines a hardware-conformance numeric contract using IEEE-754
behavior, canonical quiet NaN, and IEEE signed zero. Rounding, saturation, and
canonicalization are selected by B.DATR and per-operation legality. The
checked-in `pto-v0` implementation is a separately identified deterministic
reference-test profile. Its raw-carrier results are executable formal evidence
but are not hardware-conformance results.

The hardware profile identity is
`pto-hardware-numeric-0.57.1-ieee-v1`. A hardware, emulator, compiler/runtime
pair, or performance model may claim that identity only when it matches the
release content hash, passes every generated numeric boundary vector, and
provides independent operation-level legality, exception, byte, and effect
evidence. This repository currently publishes the contract and vectors; it
does not claim that the raw-carrier ASL implementation passes them.

## Hardware numeric contract

The machine-readable profile freezes all 25 accepted DataType codes and the six
reserved codes. It records storage width, logical packed-lane count, format
identity, integer extrema, and every available canonical NaN. E4M3, E5M2,
E3M2, E2M3, E2M1, and E8M0 use their exact OCP encodings. HiF8 uses the exact
variable-width Dot/Exponent/Mantissa prefix encoding, including its single zero,
NaN, infinities, and denormal exponent extension. `E1M2X2` and `HiF4X2` remain
distinct DataType identities even though both use the public 16-value E1M2 lane
table. Formats without a NaN or infinity encoding are not assigned one by PTO.

For every X2 DataType, Tile dimensions count logical lanes. Logical even lane
`2*i` occupies byte `i` bits 3:0 and logical odd lane `2*i+1` occupies bits 7:4.
An unused high nibble in an odd logical extent is reserved and zero on
publication. Subnormal values are supported by each format that defines them;
flush-to-zero behavior is non-conforming for those formats.

B.DATR has the following hardware-profile meaning:

- `CMode=0..5` selects EQ, NE, LT, GT, LE, or GE; 6 and 7 are reserved.
- `RMode=0` uses the operation default, which is RNE for numeric conversion.
  Codes 1 through 7 select RNE, RTZ, RDN, RUP, RNA, RTO, and RHB exactly as
  defined by the machine-readable profile.
- With `Sat=0`, integer arithmetic wraps, floating overflow produces infinity,
  and invalid float-to-integer conversion produces the exact destination
  indefinite value: the signed minimum or unsigned maximum, independently per
  packed lane. With `Sat=1`, integer and conversion results clamp, NaN-to-integer
  produces zero, and floating overflow clamps to maximum finite.
- `Canonicalize=1` canonicalizes NaN inputs before the operation.
  `Canonicalize=0` preserves source classification and payload while reading,
  but any NaN result is still canonical. Neither setting erases signed zero.

Floating comparisons are unordered on NaN: EQ and ordered relations are false,
NE is true, and a signaling NaN reports invalid. Positive and negative zero
compare equal. Minimum and maximum return the numeric input when exactly one
input is NaN, canonical qNaN when both are NaN, `-0` for minimum, and `+0` for
maximum.

Reductions process increasing logical row-major indices without reassociation
and round to the declared accumulator type after each step. ARGMIN/ARGMAX ties
select the lowest original index. Empty reductions are illegal before effects.
Sum/product propagate canonical qNaN; min/max ignore NaN when any numeric input
exists and return canonical qNaN for an all-NaN input.

TSORT processes exactly 32 elements, returns each value with its U32 original
index, remains stable for equal values and signed zeros, and places stable NaNs
after all numeric values for either direction.

Matrix dot products advance in increasing logical K order. Ordinary matrix
forms accept every assigned numeric DataType except E8M0; left, right, command
header, and bias use the same logical type. FP64 uses physical FP64 ACC; other
floating types use FP32 ACC; signed and unsigned integers use S64 and U64 ACC.

MX forms use an FP32 command header, FP32 ACC, FP32 bias, and E8M0 scales. Their
accepted operand pairs are the four ordered E4M3/E5M2 combinations and the four
ordered E2M1X2/HiF4X2 combinations. K is partitioned into blocks of 32 logical
elements: ScaleA has shape `M x ceil(K/32)` and ScaleB has shape
`ceil(K/32) x N`. Each input is scaled by its K-block scale before the fused
multiply-add. A `.ACC` form computes old ACC plus this newly scaled dot product;
it never scales the old ACC. Bias is added after the complete dot product.
ACCCVT rounds once to the destination type and releases ACC only after complete
Tile publication.

`spec/evidence/pto-isa-0571-hardware-numeric-vectors.json` is generated from
this profile. It covers canonical NaNs, signed zero, every rounding mode,
saturation, unordered comparisons, reduction ties/NaNs, stable 32-element sort,
low-format encodings, packed lane order, integer indefinite results, and matrix
initialization/bias/accumulate/MX K-block boundaries.

## PTO v0 reference-test behavior

### Reset, access-control rings, and time

`ResetProfileState` clears the 24 absolute GPRs, the T/U queues, P0..P7, and
bounded memory; invalidates every `TileInfo`; clears defined extended
system-register storage; resets faults, reservations, concurrency candidates,
and maintenance epochs; sets VERSION to 1 and TILE_CAPACITY to 256 KiB; sets
time to zero; and enters ACR0. Tile payload backing that becomes unobservable
through invalid descriptors is not scrubbed.

ACR0..ACR15 are explicit architecture state. Base system registers are
accessible at every ring subject to their RO/WO/RW class. Context,
translation, interrupt, and debug register families whose low index is at
least `0xF00` require ACR0. A denied system
register access raises `Fault_IllegalInstruction` before the access.

The bounded reference memory is 4096 bytes. ACR0 and ACR1 can access the full
range; ACR2 through ACR15 can access bytes 0 through 3071. Translation is identity.
Permission and bounds failure use the existing data-page fault envelope.

TIME and CYCLE return the same 64-bit modulo counter. Reset sets it to zero and
each scalar or tile decoded execution attempt increments it once, including an
attempt that is later rejected or faults.

### Numeric carrier profile

PTO v0 is a deterministic executable reference profile, not an IEEE-754 claim.
Scalar and tile floating carriers use the documented raw payload widths. The
profile fixes modular word arithmetic, signed raw ordering, normalization,
tie-to-even integer rounding, division-by-zero results, and flag behavior so no
host floating library can change execution.

- The real-number exponential helper is an 18-term Taylor reference algorithm.
- Scalar raw ADD/SUB/MUL/DIV and fused variants use modular XLEN carrier
  arithmetic; zero DIV/reciprocal returns all ones and records DZ.
- Scalar conversion hooks preserve the source carrier before the normative
  destination-width normalization already defined in scalar ASL.
- Tile arithmetic, reduction, expansion, partial, conversion, matrix, and
  ordering hooks use the explicit raw-bitvector helpers in the normative model.
- Tile SQRT and LOG preserve the raw carrier, EXP increments it, and reciprocal
  uses unsigned all-ones division. Quantization and dequantization use the
  declared scale and zero-point word operations.

This profile makes the formal reference model total and reproducible. It must
not silently reinterpret `pto-v0` results as the 0.57.1 hardware profile.

## Registered domains

| Domain | Concrete boundary |
| --- | --- |
| Architecture reset | deterministic PTO v0 reset state |
| Access-control ring | ACR0..ACR15 memory and system-register policy |
| System time | one modulo-64-bit tick per decoded execution attempt |
| Scalar mathematical helpers | 18-term exponential and nearest-ties-even rounding |
| Scalar carrier arithmetic/conversion | deterministic raw word operations and flags |
| Atomic and data address | FAR-preserving, identity translation, explicit permissions |
| Tile floating and elementwise | deterministic raw carrier operations |
| Tile comparison, reduction, expansion, and partial | signed raw ordering and modular accumulation |
| Tile conversion | raw normalization, quantization, and dequantization |
| Tile matrix arithmetic | modular word-width multiply, bias, accumulate, and scale |

## Validation rule

The repository checker extracts every `impdef func` under `asl/`, every
`implementation func` from the active profile, and every direct call in the
profile conformance test. The three name sets must equal the current registry
exactly. CI also requires the active reference-test identity in
`specification.toml`, validates the distinct hardware profile and generated
numeric vectors through the release manifest, and executes the complete ASL
suite with the pinned ASLRef. Passing the ASL suite proves `pto-v0`; it does not
prove hardware numeric conformance.
