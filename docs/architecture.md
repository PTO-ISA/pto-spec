# Architecture design checklist

## Purpose

Use this document to define the PTO formal model before adding semantics. Replace the questions below with reviewed
architecture decisions and links to the corresponding public PTO ISA requirements.

## Normative source hierarchy

Before implementation, approve and record the precedence between the public PTO ISA manual, public API declarations,
assembly syntax, and this executable ASL model. ASLRef defines how ASL1 programs are parsed, typed, and executed; it
does not supply PTO architectural requirements.

Every modeled PTO behavior needs a stable requirement ID and public source link in `docs/traceability.md`. Conflicts
between sources are architecture decisions and must not be resolved implicitly in code.

## Model boundary

Decide which architecture-visible concepts the model will describe:

- architecture-visible tile shape, valid region, element type, and location intent;
- instruction legality shared by all conforming targets;
- deterministic result values and architecture-visible state transitions;
- explicit ordering or fault behavior when the ISA defines it;
- named target profiles where portable behavior genuinely differs.

Record what the model will deliberately exclude:

- physical buffer addresses or allocation algorithms;
- pipeline selection, event IDs, or backend intrinsic sequences;
- implementation latency, throughput, or cost-model estimates;
- C++ template dispatch and host-side launch mechanics;
- behavior that is only an accident of CPU-SIM or one NPU generation.

## Decisions required before implementation

- What is the smallest architecture-visible state required by PTO?
- Which tile bounds are normative, configurable, or verification-only?
- How are invalid regions represented and observed?
- Which legality failures are assertions, diagnostics, traps, or unspecified behavior?
- Which arithmetic rules are shared across integer and floating-point element types?
- What ordering state is visible for memory, events, and asynchronous communication?
- Which A2/A3 or A5 differences belong in named profiles rather than the portable model?

## Suggested implementation order

1. Type domains and named architectural constants.
2. Architecture-visible state and accessors.
3. Shared legality predicates and semantic helpers.
4. One representative instruction with executable tests.
5. Additional instruction families, memory ordering, events, and target profiles.
