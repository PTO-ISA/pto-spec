# ADR 0036: Formal source and evidence boundary

## Status

Accepted.

## Context

Architecture meaning must not be reconstructed from generated artifacts,
tool behavior, maturity ledgers, or documentation prose. Those artifacts can
detect drift, but they cannot fill an absent ASL rule.

## Decision

- The four-surface PTO ASL tree is the only authored architecture source.
- Every accepted instruction, rejected form, field domain, default, state
  effect, memory effect, ordering rule, fault, and reservation has one ASL
  owner.
- Catalogs, generated pages, navigation, AVS points, evidence ledgers, and
  release manifests are derived artifacts or checks.
- A derived artifact that disagrees with ASL is stale or defective and must
  fail closed. It never changes the architecture definition.
- An ASL gap remains incomplete or ambiguous until a PTO architecture decision
  resolves it and updates the owning ASL unit first.
- Formal review records contain only review method, outcome, and covered formal
  subjects. They contain no repository, path, page, branch, commit, or blob
  provenance.

## Consequences

PTO release closure proves that the projections agree with the authored ASL;
it does not promote any projection into a second source. Architecture review
therefore remains mnemonic-local, reproducible from this repository, and
independent of the availability or behavior of another implementation.
