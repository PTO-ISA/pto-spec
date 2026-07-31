# ADR 0046: Separate the kernel execution mask and warp predicates

- Status: accepted
- Decision date: 2026-07-31
- Requirements: PTO-REQ-PREDICATE-001,
  PTO-REQ-SCALAR-CONTROL-001, PTO-REQ-STATE-001,
  PTO-REQ-FAULT-001

## Context

Two independent architectures use predicate terminology:

- The independently audited comparison ISA defines `p`, one 64-bit group-local
  execution mask for MPAR and MSEQ kernel bodies. Kernel-body `B.Z` and `B.NZ`
  consume `p`.
- The PTO warp architecture requires eight 32-bit per-warp predicate
  registers P0 through P7. P0 is the hardwired always-active predicate.

The previous PTO model combined those domains by representing P0 through P7 as
eight 64-bit registers, writing P0 on every bundle-body entry, and using P0 for
bundle-body branches. That contract matched neither architecture. It also made
ordinary, floating, system, tile, and frame-template bundles enter a kernel
execution-mask domain that belongs only to MPAR and MSEQ.

PTO ISA 0.57.1 has no accepted vector instruction or operand encoding that
selects P0 through P7. Its accepted encodings also have no unassigned predicate
selector field. Correcting state separation must therefore leave the binary
ABI unchanged and must not invent a vector surface.

## Decision

### Warp predicate registers

- P0 through P7 are eight independent 32-bit architectural registers.
- P0 reads as all ones and ignores every write. This invariant also holds
  after reset, trap entry, and recovery.
- P1 through P7 reset to zero and are preserved independently by trap save and
  recovery.
- PTO ISA 0.57.1 has no instruction consumer or producer for P0 through P7.
  Their storage cannot affect branch, tile, memory, or numeric semantics.
- A future instruction that uses these registers must define a versioned
  selector, producer/consumer effects, encoding allocation, aliases, and
  executable evidence. Existing reserved bits cannot be reinterpreted
  implicitly.

### Kernel execution mask

- The comparison-compatible kernel execution mask is a separate 64-bit
  architectural value named `_ExecutionMask` in the ASL model.
- Reset clears the stored value. Outside an active MPAR or MSEQ body it is
  inaccessible to accepted PTO instructions.
- Entering an MPAR or MSEQ body initializes the mask to all ones. Entering any
  other bundle kind does not modify it.
- In an active MPAR or MSEQ body, `B.Z` and `B.NZ` consume the execution mask.
  Everywhere else they consume the bundle commit argument established by
  `SETC.*`.
- Trap save and successful recovery preserve the mask together with the bundle
  kind and body-active state. Leaving a machine body makes the stored value
  inaccessible; the next machine-body entry reinitializes it.

The all-active entry rule is the complete portable PTO ISA 0.57.1 rule. The
comparison ISA also specifies vector comparison as an execution-mask producer,
and its staged formal model experiments with B.DIM/B.CATR-dependent tail
initialization. PTO
0.57.1 exposes neither the vector producer nor a complete group-index and lane
configuration contract, so it does not claim those semantics. Adding them is a
future versioned kernel-execution decision, not an implementation-defined
refinement of this release.

## Consequences

The change fixes an architectural category error without changing instruction
encodings. State width, reset, trap preservation, branch-domain selection, and
all nine bundle-kind boundaries are executable. Stage 2 predicate-state closure
therefore covers the eight warp predicates and the currently exposed kernel
execution-mask lifecycle, but does not claim full comparison-ISA vector
divergence closure.

The independent formal-model comparison remains evidence rather than PTO
authority. Its missing `V.CMP.* ->p` write path and incomplete trap preservation
are recorded as comparison-model gaps and are not imported into PTO.

## Verification

`TestScalarState`, `TestPredicateStateContract`, and `TestConcreteProfile`
cover P0 hardwiring, P1/P7 width boundaries, reset, machine/non-machine bundle
selection, branch source selection, trap save/recovery, and the absence of a
P-register instruction consumer. Generated BRU totality evidence exercises
both execution-mask branch outcomes and the non-machine commit-argument path.
