# ADR 0049: Hardware numeric subnormal policy

## Status

Accepted for the named `pto-hardware-numeric-0.57.1-ieee-v1` profile. This
decision completes PD-04 for every otherwise-supported operation/type tuple.
It does not change the active `pto-v0` raw-carrier profile and does not close
any operation/type support tuple.

## Context

ADR 0048 made the subnormal encodings of eleven PTO numeric types executable,
but it deliberately left input handling, result underflow, tininess, and mode
selection open. The hardware profile already required support for every
subnormal encoding defined by those formats, prohibited flush-to-zero and
denormals-are-zero behavior, and selected after-rounding tininess detection.
Leaving PD-04 open despite that profile text would permit an implementation to
invent hidden mode state or silently apply a backend-specific shortcut.

An independently reviewed executable ISA model corroborates the raw FP32 and
FP64 classification boundary. It does not provide executable arithmetic
subnormal behavior, an FTZ/DAZ contract, or PTO low-precision formats, so it is
not used as the numeric oracle for this decision.

## Decision

### Input and result rules

For every otherwise-supported operation/type tuple in the named hardware
profile:

- a source format that defines subnormal encodings preserves the exact source
  value; there is no denormals-are-zero input transform;
- a destination format that defines subnormal encodings uses gradual
  underflow; there is no flush-to-zero result transform; and
- tininess is detected after rounding.

Input preservation and result gradual underflow are distinct typed ASL rules.
A tuple can consume a format with subnormals, produce one, or do both. This
decision applies only to the side that exists for that tuple. A format without
subnormal encodings reports the rule as not applicable.

This policy does not make an unsupported operation/type tuple legal. Profile
support and numeric result semantics remain separate obligations under ADR
0037.

### Selection and configuration

The policy is fixed by the profile identifier. PTO 0.57.1 exposes:

- no architectural FTZ or DAZ mode bit;
- no reset, save, restore, or trap-context state for subnormal modes; and
- no operation-local subnormal override.

A conformance configuration that requests FTZ, DAZ, or an operation-local
override is not this profile and must reject before architectural effects. An
implementation must not infer the request from backend state.

### Exact format boundaries

The ASL exposes exact raw encodings for the minimum positive subnormal,
maximum positive subnormal, and minimum positive normal:

| Type | Minimum subnormal | Maximum subnormal | Minimum normal |
| --- | ---: | ---: | ---: |
| FP64 | `0x0000000000000001` | `0x000FFFFFFFFFFFFF` | `0x0010000000000000` |
| FP32 | `0x00000001` | `0x007FFFFF` | `0x00800000` |
| TF32 | `0x00002000` | `0x007FE000` | `0x00800000` |
| HF32 | `0x00001000` | `0x007FF000` | `0x00800000` |
| FP16 | `0x0001` | `0x03FF` | `0x0400` |
| BF16 | `0x0001` | `0x007F` | `0x0080` |
| HiF8 | `0x01` | `0x07` | `0x08` |
| E4M3 | `0x01` | `0x07` | `0x08` |
| E5M2 | `0x01` | `0x03` | `0x04` |
| E3M2 | `0x01` | `0x03` | `0x04` |
| E2M3 | `0x01` | `0x07` | `0x08` |

TF32 and HF32 boundaries retain their required low zero bits. E3M2 and E2M3
boundaries retain their required carrier-high zero bits. Applying the format's
sign bit to either subnormal endpoint produces the corresponding negative
subnormal.

### Domain applicability

The generated subnormal contract enumerates every PD-04 domain, operation key,
profile hook, and each operation's eleven conditional format rows from the
numeric decision-input and contract ledgers. Its 95 compressed operation rows
therefore represent 1,045 operation/type obligations instead of relying on
mnemonic families or backend behavior. Operation-specific special values,
exception flags, range results, approximation error, reduction ties,
quantization equations, and matrix precision remain owned by PD-05 through
PD-12. ADR 0050 separately owns the bounded PD-05-SC2 checkpoint for produced
canonical NaNs, comparison NaN/signed-zero results, and MIN/MAX NaN/signed-zero
results; it does not relax this subnormal policy or create operation/type
support.

## Rejected alternatives

- **Add hidden FTZ/DAZ state.** Rejected because no PTO 0.57.1 architectural
  selector, reset rule, lifetime, or trap-context field owns such state.
- **Make backend state select the rule.** Rejected because target variation
  must cross a named profile or visible architectural selector.
- **Default to FTZ for performance.** Rejected because it contradicts the
  named hardware profile and changes both source and result values.
- **Apply the rule to `pto-v0`.** Rejected because `pto-v0` remains the
  architecture's deterministic raw-carrier reference profile.
- **Use the independent model as an arithmetic oracle.** Rejected because its
  corroborating FP32/FP64 classification coverage does not define arithmetic
  underflow, FTZ/DAZ, or PTO low-precision behavior.

## Consequences

PD-04 is complete for the named hardware profile. The accepted numeric
decision count increases to two of twelve. This decision does not complete a
numeric domain because every affected domain still has other open decision
dimensions, and it does not select a generic implementation-defined variation
route. PD-12 must still make every remaining target variation discoverable and
bounded.

## Verification obligations

Executable assertions cover:

- exact positive and negative minimum/maximum subnormal encodings;
- the minimum normal boundary for every subnormal-capable type;
- preserved-input and gradual-underflow rule selection;
- formats for which the rule is not applicable;
- rejection of FTZ, DAZ, and operation-local overrides; and
- the existing invalid internal TF32, HF32, E3M2, and E2M3 encodings.

The generated evidence binds these assertions, the hardware profile, all
affected domains and operations, the accepted decision record, and the
publication-safe independent-comparison boundary.

These assertions are Stage 5 profile-decision evidence. Arithmetic input/output
and underflow-transition vectors remain required by `S5-T2-C`; accepting PD-04
does not claim that any implementation has passed them. ADR 0050's
special-value checkpoint likewise remains profile-decision evidence rather
than an implementation-conformance result.

## Evidence

- `asl/types.asl`
- `asl/numeric/formats.asl`
- `spec/hardware-conformance-profile.json`
- `spec/evidence/numeric-subnormal-contract.json`
- `scripts/generate-numeric-subnormal-contract`
- `tests/asl/profile-tests.asl`
- `spec/evidence/numeric-profile-decision-inputs.json`
- `spec/evidence/numeric-contracts.json`
- `spec/evidence/numeric-format-namespace-contract.json`
- `spec/evidence/executable-model-comparison.json`
