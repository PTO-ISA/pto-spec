# HiF4X2

HiF4X2 is a distinct PTO data-type identity containing two finite four-bit
S1/E1/M2 lanes per byte. Its lane encodings equal E1M2X2, but identity and
operation applicability remain separate architectural properties.

## Lane encoding

`S` is lane bit 3, `E` is lane bit 2, and `M` is lane bits 1:0.

| Raw lane | Value |
| ---: | ---: |
| `0x0` | 0 |
| `0x1` | 0.25 |
| `0x2` | 0.5 |
| `0x3` | 0.75 |
| `0x4` | 1 |
| `0x5` | 1.25 |
| `0x6` | 1.5 |
| `0x7` | 1.75 |
| `0x8` | -0 |
| `0x9` | -0.25 |
| `0xA` | -0.5 |
| `0xB` | -0.75 |
| `0xC` | -1 |
| `0xD` | -1.25 |
| `0xE` | -1.5 |
| `0xF` | -1.75 |

The low-index lane occupies byte bits 3:0 and the high-index lane occupies
bits 7:4. Stores preserve the unselected sibling lane.

The normative packing and sibling-preservation rules are in
[ADR 0033](../../architecture-decisions/0033-tlsu-four-bit-memory-packing.md).

## Exact finite value

Every nonzero finite value uses `exponent=-2`; its significand is `M` for
`E=0` and `4+M` for `E=1`. HiF4X2 has signed zero and has no infinity, quiet
NaN, or signaling NaN.

## Scope

Scale application and operation support remain profile contracts.
Requirements: `PTO-REQ-PROFILE-001`, `PTO-REQ-SCALAR-FP-001`,
`PTO-REQ-HARDWARE-NUMERIC-001`, and `PTO-REQ-CLOSURE-001`.
