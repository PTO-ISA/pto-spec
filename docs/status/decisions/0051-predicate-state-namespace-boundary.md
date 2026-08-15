# ADR 0051: Predicate state namespace boundary (superseded)

- Status: superseded by PRD-039 in
  [ADR 0062](0062-mnemonic-review-decisions.md#prd-039-machine-parallel-and-machine-sequential-block-starts-are-extension-reserved)
- Decision date: 2026-08-01

## Current boundary

PTO exposes P0 through P7 as eight independent 32-bit predicate registers.
P0 is hardwired to all ones; P1 through P7 reset to zero and are independently
trap-preserved. No accepted instruction produces or consumes this register
file.

Machine-parallel and machine-sequential block encodings are extension-reserved
and have no PTO execution semantics. Their former execution-mask model is not
architectural PTO state. Any future predicate namespace or instruction mapping
requires an explicit encoding, state, reset, trap, producer, consumer, and
executable-test contract.

This file records the superseded decision only. The current executable
contract is defined by the ASL programming-model and scalar BRU units.
