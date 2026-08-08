# ADR 0042: Numeric variation-point ownership

> Historical-evidence note: verification paths named below record the evidence used when this ADR was accepted; deleted aggregate checks are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Status

Accepted structural checkpoint; numeric result rules and allowed-result sets
remain open.

## Context

`PD-12` requires every target-dependent or implementation-defined numeric
result to have a discoverable selector and a finite or mathematically testable
allowed-result contract. The closed numeric inventory already assigns 108
operations to 20 domains and 30 hooks, but it did not enumerate the individual
open dimensions within those domains. In PTO ISA 0.58.0 that inventory contains
104 operations, 18 domains, and 28 hooks. That made it possible to discuss a
profile or hook without proving ownership of every unresolved result choice.

The public PTO contract identifies target profiles and numeric variation but
does not supply complete allowed-result sets. The pinned independent executable
model corroborates encodings and namespace separation only: its PTO tile paths
do not execute numeric payload semantics, and similarly numbered data-type
fields belong to conflicting namespaces. Neither that model nor a backend may
therefore become the numeric owner by implication.

## Decision

The generated
`spec/evidence/numeric-variation-point-ownership.json` ledger is the
fail-closed discovery and ownership checkpoint for `PD-12`.

1. A variation point is one exact `(numeric domain, open dimension)` pair from
   `spec/evidence/numeric-contracts.json`. The current inventory contains 99
   points across all 20 domains.
2. Every point remains owned by the portable `pto-numeric-v1` architecture
   contract until an accepted PTO decision explicitly delegates that exact
   point to a named target profile or visible numeric selector, or marks the
   applicable operation/type/profile tuple unsupported.
3. The ledger maps every point to its complete operation and hook reachability.
   Separate operation and hook tables prove that all 108 operations and all 30
   hooks, including two library-only helpers, have one explicit owner boundary.
4. A target profile identity, selector namespace, backend behavior, or equal
   numeric code does not create a result rule. Delegation requires an accepted
   record, exact applicability, selector identity, and bounded allowed-result
   contract.
5. Unknown profiles, modes, formats, tuples, or missing delegated rules reject
   before architectural effects. The existing A2/A3 MX applicability decision
   remains the only accepted unsupported numeric slice: 150 tuples and zero
   result rules.

## Consequences

`S5-T2-A4` closes variation-point discovery and current-owner assignment. It
does not accept a numeric result, delegate a variation point, populate an
allowed-result set, or close `PD-12`. The generated ledger therefore records
99 portable-owner rows, zero accepted delegations, zero bounded result
contracts, and zero accepted domain result rules.

`PD-12` closes only after every non-portable row names its accepted profile or
visible selector, bounds its results, and has unknown-selection and
missing-rule rejection evidence. The other 11 numeric decisions, all 20 domain
rules, oracle qualification, vectors, differential execution, adjudication,
and independent approval remain open. The maturity floor remains M4.

The current ASL model has no generic named-target-profile selection boundary.
This checkpoint therefore proves evidence ownership only; it does not claim
executable rejection of an unknown profile. When that selection surface is
introduced, its unknown-profile and missing-rule paths require explicit
pre-effect tests before `PD-12` can close.

## Evidence

- `spec/evidence/numeric-variation-point-ownership.json`
- `scripts/generate-numeric-variation-point-ownership`
- `spec/evidence/numeric-contracts.json`
- `spec/evidence/numeric-profile-decision-inputs.json`
- `spec/catalog/numeric-profile-identities.json`
- `spec/evidence/numeric-rounding-selector-contract.json`
- `spec/evidence/numeric-format-namespace-contract.json`
- `spec/evidence/numeric-profile-applicability-closure.json`
- `spec/profile-hooks.json`
- `scripts/check-catalogs`
