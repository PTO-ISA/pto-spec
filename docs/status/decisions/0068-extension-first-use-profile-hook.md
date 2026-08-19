# ADR 0068: Extension first-use is a target-profile hook

- Status: accepted
- Scope: architecture profile boundary
- Requirement: PTO-ARCH-EXTENSION-FIRST-USE-PROFILE-001
- Issue: https://github.com/PTO-ISA/pto-spec/issues/100

## Context

Some targets allocate VECTOR or CUBE context lazily and need a precise trap
before the first instruction that would consume that context. PTO does not own
one portable enable-register layout, trap-number allocation, ACR route, or
software task-state policy. Encoding a particular target's values in the
portable model would turn an implementation profile into common PTO semantics.

## Decision

PTO defines two extension kinds and two target-profile hooks. The portable
default reports both kinds disabled. Its raise hook returns without changing
trap, bundle, queue, memory, or fault state.

An enabling target profile must define the covered instruction set, enable
state and ownership, source and manager ACRs, trap envelope and argument
mapping, and the ordering point. The trap must occur after decode and target
legality but before extension allocation or architectural effects. The saved
execution point must permit exact retry, and the target must guarantee forward
progress for its context-save path.

## Consequences

PTO implementations that do not select such a profile retain existing
behavior. Target profiles can bind a concrete first-use ABI without changing
PTO encodings or importing target register fields into the portable model. A
profile claim is incomplete without executable zero-effect, retry, and
independent-kind evidence.
