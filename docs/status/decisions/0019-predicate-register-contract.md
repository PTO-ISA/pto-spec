# ADR 0019: Define the PTO predicate-register contract

## Status

Superseded by PRD-039 in
[ADR 0062](0062-mnemonic-review-decisions.md#prd-039-machine-parallel-and-machine-sequential-block-starts-are-extension-reserved).

## Historical context

This decision identified that every visible predicate needs explicit reset,
preservation, producer, and consumer rules. The current PTO contract retains
only P0 through P7: P0 is hardwired all ones, P1 through P7 are independently
trap-preserved, and no accepted instruction consumes them. Machine-block
encodings and their former execution-mask model are outside PTO.
