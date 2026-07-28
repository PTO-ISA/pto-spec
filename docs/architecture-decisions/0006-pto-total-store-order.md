# ADR-0006: PTO total store order candidate model

- Status: Accepted
- Date: 2026-07-28
- Requirement: PTO-REQ-MEMORY-TSO-001

## Context

Acquire and release counters can show that an instruction touched an ordering
path, but they cannot distinguish a permitted concurrent outcome from a
forbidden one. PTO needs an executable relation over candidate memory events
that covers scalar and tile accesses without introducing a second instruction
execution level.

PTO needs a public, reviewable relation shape that is owned by this repository.
External event taxonomies and instruction semantics are not PTO authority.

## Decision

PTO defines the multi-copy-atomic `PTO-TSO` model in `asl/concurrency.asl`.
Candidate executions contain explicit initial writes, loads, stores, atomics,
and masked data fences from multiple agents. Program order is derived per
agent, reads-from is explicit, and coherence is a total rank per exact
address-and-size location.

A candidate is allowed when both `po-loc | rf | fr | co` and
`ppo | rfe | fr | co` are acyclic. PTO `ppo` preserves read-to-memory and
memory-to-write order while normally relaxing store-to-load. Atomics are full
ordering points. Acquire, release, acquire-release, and applicable `FENCE.D`
masks can add preserved order but cannot weaken TSO.

The executable checker is bounded to 16 events and four agents. These are
verification bounds. Mixed-size and partially overlapping candidate accesses
fail closed pending a byte-level coherence rule.

## Consequences

- Allowed and forbidden concurrency outcomes have executable witnesses.
- Scalar and tile accesses share one ordering relation without hidden replay
  state.
- Epoch counters are removed because they are not concurrency evidence.
- A future mixed-size extension must define byte-level coherence and add
  litmus evidence before those candidates can become valid.
- Every retained rule is stated as a PTO-owned ASL predicate and test.
