# Formal model coverage

Coverage grades describe executable architecture evidence, not only parser or
mnemonic presence. The accepted surface is complete under the concrete PTO v0
reference profile. The repository remains a normative draft because PTO v0 is
a reference profile and PTO-TSO is a bounded candidate model; those limits are
explicit rather than missing dispositions in the accepted surface.

| Area | Accepted surface | Current ASL grade | Executable evidence | Remaining closure |
| --- | ---: | --- | --- | --- |
| Scalar state | 24 GPRs, PC, return, commit, predicate, trap, privilege, system, time, and memory-order state | implemented under PTO v0 | reset, R0, predicate, privilege, time, trap envelope, and state tests | platform-specific exception routing outside PTO v0 |
| Scalar forms | 473 | complete decode, operand extraction, form/family constraints, Reg5 legality, handler linkage, and decoded execution | one positive decode, every operand-field witness, every family-constraint application, one semantic-handler witness per form, all-form canonical execution, family effects, overlap rejection, unavailable-bridge rejection, and removed-DMA rejection | none for current decoded dispatch |
| Scalar semantics | AGU, ALU, AMO, BRU, FSU, SYS | complete under PTO v0 | arithmetic, division, wide multiply, bitfields, control, memory, atomic, system, raw-carrier FP, profile, and privilege tests | alternate IEEE or hardware profiles only if separately specified |
| System registers | 52 definitions, 13 trap numbers | executable catalog with explicit privilege and reset | generated access witnesses plus read/write/trap/privilege/reset tests | none for PTO v0 |
| Tile registers | 64 | implemented | hand mapping, descriptor, capacity, and alias tests | none in the portable state model |
| TEPL | 97 operations | decoded execution with explicit legality under PTO v0 | elementwise, reduction, expansion, generation, conversion, rearrangement, complex, pipe, decoded-effect, profile, negative-data/descriptor/pipe, and no-partial-effect tests | none for accepted source dispositions |
| TMA | 6 operations | decoded execution with explicit legality, PTO v0 access policy, precise completion, and shared PTO-TSO events | decoded load plus load/store/move/prefetch/gather/scatter, profile, descriptor, first/middle/last fault, preservation, restart, and concurrency tests | mixed-size concurrency extension |
| CUBE | 8 operations | decoded execution with explicit legality under PTO v0 | decoded matrix multiply, matrix/vector base, bias, accumulate, MX, profile, and composite preflight tests | alternate hardware numeric profile only if desired |
| Encodings | 473 scalar forms + 111 tile operations | executable complete | generated ASL decoders, operand/handler bindings, reserved/removed-code assertions, and decoded family effects | none for accepted selector-to-handler identity |
| PTO-TSO concurrency | 16-event/four-agent verification bound | executable axiomatic candidate model | store buffering, fenced store buffering, message passing, IRIW, same-location forwarding/stale-read, and atomicity tests | byte-level mixed-size coherence |
| Public source reconciliation | 473 scalar forms + 111 tile operations | complete pinned disposition inventory | all scalar forms classified; 110 exact tile names; `TSORT` → `TSORT32`; all 14 raw non-agreements closed | none at the audited public pin |
| Independent tile cross-check | 111 operations | preserved raw disposition inventory | 97 agree, 1 conflict, 13 incomplete | no public closure remains; raw private observations are not rewritten |

`complete under PTO v0` means every accepted operation is connected to an ASL
semantic primitive and every registered implementation-defined interface has a
concrete override and direct conformance witness. PTO v0 is a deterministic
raw-carrier reference profile, not an IEEE-754 or hardware-performance claim.

## Decoder evidence

The scalar catalog contains 45 operand-field kinds, 1,865 encoded field pieces,
three form constraints, and two family constraints with 85 current
applications. Build generation emits strict ASL for:

- all 473 scalar form masks and matches, ordered by mask specificity;
- every scalar operand field, including split-field reconstruction;
- operand width, signedness, presence, form-local legality, and relational
  family-legality queries;
- one-level Reg5 mapping across GPR and direct T/U bridge selectors;
- exact linkage of every scalar form to one of 67 checked ASL semantic handlers;
- decoded execution for all 473 forms, including legality, operand binding,
  Reg5 reads, all scalar address classes and update modes, atomic width/order/
  reservation effects, predicate/commit state, system-register addressing,
  maintenance, fences, requests, faults, floating carrier/type legality,
  ordered comparisons, NaN/signed-zero min/max, and sticky FP flags;
- all 111 direct tile operation selectors, semantic handlers, typed operand
  presence, ordered handler arguments, and decoded execution cases; and
- positive witnesses for every accepted form, operand occurrence, family-rule
  application, and tile selector; negative witnesses for each form and family
  constraint; every catalog-reserved and review-only tile code; plus
  out-of-width representatives.

The repository checker independently rejects out-of-width masks, unmasked match
bits, overlapping field pieces, non-contiguous reconstructed values, dangling
constraints, ambiguous equal-priority encodings, and unreviewed overlaps.
It also requires every one of the 67 scalar semantic primitives and all 51 tile
handler groups to appear in executable ASL feature evidence, every scalar form
to have a checked-in decoded-operation binding, and the tile catalog to generate
the public decoded execution boundary. Handler-name presence in the normative
sources alone is insufficient.

## Explicit limits and future extensions

- The 13 incomplete private observations and the `TPREFETCH` private conflict
  remain raw provenance. ADR-0007 and the public reconciliation ledger close
  their architecture disposition without manufacturing private agreement.
- Backend availability is not evidence of portable semantics.
- PTO v0 closes the numeric interfaces with deterministic raw-carrier behavior;
  it deliberately does not claim correctly rounded IEEE-754 arithmetic. A
  future IEEE or hardware profile needs a distinct identity and evidence.
- `ExecuteScalarInstruction` runs every accepted scalar form through legality,
  operand binding, Reg5 access, and its architecture state transition.
- `ExecuteTileInstruction` runs every accepted tile selector through its
  catalog-declared operand binding, read-only per-operation legality preflight,
  and architecture state transition. Tile and Reg5 legality failures are
  explicit and effect-free.
- PTO v0 uses identity translation and explicit User, Supervisor, and Machine
  permissions. Tile memory accesses use the same scalar data-access hooks,
  including destination-free prefetch.
- Scalar pairs and tile memory operations preflight every access and commit
  atomically at instruction granularity. First/middle/last failure witnesses
  prove original-address reporting, preservation, and restart by full reissue.
- Platform-specific interpretation of the atomic FAR address-class hint remains
  a named refinement of the portable flat-address baseline.
- PTO-TSO is executable for exact address-and-size locations. Mixed-size and
  partially overlapping candidate accesses fail closed pending byte-level
  coherence rules and litmus evidence.

The raw independent observations remain machine-readable in
`spec/evidence/independent-tile-crosscheck.json`; their public closures are in
`spec/evidence/public-source-reconciliation.json`. The profile registry is
closed for PTO v0: CI requires exact equality among all 34 registered hooks, ASL
`impdef` declarations, active implementations, and direct conformance calls.
Green validation does not turn PTO v0 into an IEEE or hardware profile.
