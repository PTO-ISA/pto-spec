# Formal model coverage

Coverage grades describe executable architecture evidence, not only parser or
mnemonic presence. The accepted PTO surface is scalar, bundle/command, and
direct tile. PTO does not include vector instruction execution.

| Area | Accepted surface | Current ASL grade | Executable evidence | Remaining closure |
| --- | ---: | --- | --- | --- |
| Scalar and context state | 24 absolute GPRs, four-entry T/U queues, P0..P7, TPC, bundle descriptors, return, commit, trap, ACR, system, time, and memory-order state | Stage 2 state/fault, Stage 3 ordering, and Stage 4 instruction closure complete | nonzero-seed boundary reset; R0 and queues; P0 body-entry/consumer; P1..P7 reserved-state; extended bundle/predicate trap preservation; all-bank register access/reset; per-trap routing/recovery; ACR, time, and bounded event-capture tests | target numeric and release conformance are tracked in Stages 5–6 |
| Bundle state | TPC, BPC, active/body flags, bundle condition, exact start form/class/selector/DataType/Mode/BrType descriptor, arguments, dimensions, scalar IO, tile IO, control attributes, and data attributes | Stage 1 lifecycle and Stage 4 command-totality targets closed | all-start descriptor witnesses; field sensitivity; sequential start/header/stop and next-start commit; direct tile launch; timing; reserved-value, missing-binding, type-mismatch, invalid-next-start, trap-preservation, rollback, and 107-form effect-or-rejection tests | target-specific scheduling and descriptor-consumption refinements require a new profile contract |
| Scalar forms | 474 | decoded effect closure 474/474; Stage 1 closed; Stage 4 AGU, ALU, AMO, BRU, FSU, and SYS closed | stable form-ID effect ledger and generated before/after witnesses for every AGU, ALU, AMO, BRU, FSU, and SYS form; 1,464 decoded AGU boundary/fault/restart plus 4,296 alias cases; 337 decoded ALU boundary plus 35 alias cases; 2,474 decoded AMO modifier, value, alias, fault/restart, reservation, and DMA cases; 284 decoded BRU totality plus 32 alias/fault cases; 2,270 decoded FSU type, raw-boundary, rounding, Reg5/alias, and sticky-flag cases plus 35 direct flag cases; 4,401 decoded SYS transfer, Reg5, fence, request, recovery, privilege, and maintenance cases | target numeric conformance remains Stage 5 |
| Bundle/command forms | 107 | Stage 4 command totality closed | generated exact-form priority witnesses, all-start descriptor assertions, exact 95-executed/12-rejected dispositions, full-width memory-command bounds, explicit metadata-only effects, transactional commit, and checked bundle-to-tile representability | target-specific behavior for profile-rejected frame, queue, context-memory, and cross-block commands requires a new profile contract |
| Scalar semantics | AGU, ALU, AMO, BRU, FSU, SYS | all six scalar families have Stage 4 reference-totality closure; Stage 3 ordering closed | AGU address, update, prefetch-model, pair, event, fault, restart, and Reg5 evidence; ALU fixed-width and Reg5 evidence; AMO width, modifier, value, Reg5 alias, fault/restart, reservation, and DMA evidence; BRU condition, target, predicate, bundle, and fault evidence; FSU exhaustive carrier/type/rounding/flag/Reg5 evidence; SYS all-address transfer, Reg5 alias, fence-mask, request, recovery, privilege, and maintenance evidence | target numeric conformance |
| System registers and traps | 72 register definitions, including 18 EBARG snapshot registers; 13 trap identities | Stage 2 register and trap targets closed | checked reset/read/write/side-effect/profile classes, generated all-bank reset and access witnesses, authoritative EBARG recovery, per-trap entry/routing/recovery tests, and coherent interrupt/pending/timer/EOI behavior | active translation or debug-trigger profiles require new trigger, precedence, and conformance contracts |
| Tile registers | 64 `TileInfo` records | capacity, definedness, and explicit handoff invariants closed; Stage 2 tile-state target closed | hand mapping, zero/minimum/maximum/aggregate capacity, packed sub-byte storage, no-effect rejection, per-element and reduction incomplete-source rejection, reconfiguration reset, layout, aliasing, push/full-slot, pop/empty-slot, source lifetime, double-free, and multi-slot tests | instruction-family numeric and memory-order refinements are tracked in Stages 3–5 |
| TEPL | 98 operations | Stage 4 raw-carrier reference totality closed; Stage 5 conformance open | all-98 decoded deterministic state transitions, all-926 reserved selectors, 19 carrier types, layout rejection, multi-destination alias rejection, preserved regions, invalid indices/offsets, duplicate scatter, stable merge, and histogram corners | target floating, quantized, rounding, saturation, and exceptional-value conformance |
| TMA | 9 operations | Stage 4 reference totality closed; Stage 3 ordering closed | all-nine decoded effects, packed four-bit accesses, duplicate-lane ordering, masks, CAS, production events, restart, and first/middle/last preflight faults | target numeric conformance remains a Stage 5 obligation where profile hooks apply |
| CUBE | 13 operations | Stage 4 raw-carrier reference totality closed; Stage 5 conformance open | all-13 decoded results, all-19 type identities, mixed layouts/locations, aliases, ACCCVT, and composite preflight | target accumulation width, rounding, saturation, exceptional values, and numeric conformance |
| Encodings and execution status | 474 scalar forms + 107 bundle/command forms + 120 direct tile operations | M4 instruction reference semantics closed; S5-T3 independent comparison closed | generated decoders, operand/handler bindings, reserved-code rejection, one-tick success/rejection matrix, stale-fault isolation, preserved trap record, scalar/command/tile legality witnesses, a 701-row comparison matrix, and all clean-snapshot documentation and Sail gates | Stage 5 numeric conformance remains open |
| PTO-TSO concurrency | 16-event/four-agent verification bound | production-connected candidate graph; Stage 3 closed | standalone litmus construction, axiomatic checks, scalar/tile/DMA/fence extraction, atomic ordering, reservation boundaries, conditional writes, and mixed-size fail-closed tests | byte-level mixed-size coherence is an explicit future extension |

The current M4 claim means the mechanical, execution-path, state/fault,
ordering, and reference instruction-semantics stages close cumulatively. It
does not mean the raw-carrier reference profile conforms to target numeric
hardware or that release review is complete. The staged exit criteria
and owned residual gaps are in `docs/maturity-bringup-plan.md` and
`spec/evidence/maturity-closure.json`.

## Decoder evidence

The scalar catalog contains 45 operand-field kinds, 1,867 encoded field pieces,
three form constraints, and no family-wide operand constraints. Build
generation emits strict ASL for:

- all 474 scalar form masks and matches, ordered by mask specificity;
- every scalar operand field, including split-field reconstruction;
- operand width, signedness, presence, and form-local legality;
- Reg5 mapping across absolute GPR and T/U queue selectors;
- exact linkage of every scalar form to one of 69 checked ASL semantic
  handlers;
- decoded execution for all 474 scalar forms, including legality, operand
  binding, Reg5 reads, address classes and update modes, atomic width/order/
  reservation effects, DMA, predicate/commit state, system-register addressing,
  maintenance, fences, requests, faults, floating carrier/type legality,
  ordered comparisons, NaN/signed-zero min/max, and sticky FP flags;
- all 107 bundle/command form masks and matches, priority-selected exact-form
  witnesses, operand extraction, constraints, command-state bindings, and
  handler dispatch;
- all 120 direct tile operation selectors, semantic handlers, typed operand
  presence, ordered handler arguments, and decoded execution cases; and
- positive witnesses for every accepted form, operand occurrence, bundle command,
  and tile selector; negative witnesses for each declared constraint and
  rejected selector range.

The repository checker independently rejects out-of-width masks, unmasked match
bits, overlapping field pieces, non-contiguous reconstructed values, dangling
constraints, ambiguous equal-priority encodings, and unreviewed overlaps. It
also requires accepted handlers to appear in executable ASL feature evidence and
requires generated instruction-reference freshness.

## Explicit limits and future extensions

- PTO has no vector instruction execution surface. Adding one would require new
  catalogs, state, semantics, tests, and profile evidence.
- PTO v0 closes numeric interfaces with deterministic raw-carrier behavior; it
  deliberately does not claim correctly rounded IEEE-754 arithmetic.
- PTO v0 uses identity translation and explicit ACR0..ACR15 permissions.
- Scalar pairs, DMA, and tile memory operations preflight every access and
  commit atomically at instruction granularity. Fault witnesses prove original
  address reporting, preservation, and restart by full reissue.
- Platform-specific interpretation of address-class hints remains a named
  refinement of the portable flat-address baseline.
- PTO-TSO is executable for exact address-and-size locations. Mixed-size and
  partially overlapping candidate accesses fail closed pending byte-level
  coherence rules and litmus evidence.

The profile implementation registry is closed for PTO v0: CI requires exact
equality among all registered hooks, ASL `impdef` declarations, active
implementations, and direct profile-test calls. The `S5-T1` inventory is also
closed: `spec/evidence/numeric-contracts.json` assigns all 19 scalar and 89
direct-tile numeric-dependent operations to 29 hooks and an explicit profile
owner. Target conformance is graded separately: eight non-numeric contracts are
closed and the 29 numeric raw-carrier hooks remain assigned to `S5-T2`. Green
validation does not turn PTO v0 into an IEEE or hardware profile. The generated
`spec/evidence/numeric-conformance-readiness.json` ledger makes the remaining
six-lane partition and its absent profile/oracle/vector/result/review evidence
fail closed before expensive runtime validation begins.
