# Formal model coverage

Coverage grades describe executable architecture evidence, not only parser or
mnemonic presence. The accepted PTO surface is scalar, bundle/command, and
direct tile. PTO does not include vector instruction execution.

| Area | Accepted surface | Current ASL grade | Executable evidence | Remaining closure |
| --- | ---: | --- | --- | --- |
| Scalar and context state | 24 absolute GPRs, four-entry T/U queues, eight 32-bit P registers, a separate 64-bit MPAR/MSEQ execution mask, TPC, bundle descriptors, return, commit, trap, ACR, system, time, and memory-order state | Stage 2 state/fault, Stage 3 ordering, and Stage 4 instruction closure complete | nonzero-seed boundary reset; R0 and queues; hardwired P0 and independent P1/P7 boundaries; machine/non-machine execution-mask selection; extended bundle/predicate/mask trap preservation; all-bank register access/reset; per-trap routing/recovery; ACR, time, and bounded event-capture tests | target numeric and release conformance are tracked in Stages 5–6; full comparison-ISA vector divergence remains outside PTO 0.57.1 |
| Bundle state | TPC, BPC, active/body flags, bundle condition, exact start form/class/selector/DataType/Mode/BrType descriptor, arguments, dimensions, scalar IO, tile IO, B.IOT lifetime, B.DATR data attributes, and B.CATR control attributes | Stage 1 lifecycle and Stage 4 command-totality targets closed; 0.57.1 attribute contract defined | all-start descriptor witnesses; field sensitivity; sequential start/header/stop and next-start commit; direct tile launch; DATR applicability; CATR ordering; source lifetime; timing; reserved-value, missing-binding, type-mismatch, invalid-next-start, trap-preservation, rollback, and 99-form effect-or-rejection tests | target scheduling and named hardware numeric conformance remain Stage 5 work |
| Scalar forms | 474 | decoded effect closure 474/474; Stage 1 closed; Stage 4 AGU, ALU, AMO, BRU, FSU, and SYS closed | stable form-ID effect ledger and generated before/after witnesses for every AGU, ALU, AMO, BRU, FSU, and SYS form; 1,464 decoded AGU boundary/fault/restart plus 4,296 alias cases; 337 decoded ALU boundary plus 35 alias cases; 2,474 decoded AMO modifier, value, alias, fault/restart, reservation, and DMA cases; 284 decoded BRU totality plus 32 alias/fault cases; 2,270 decoded FSU type, raw-boundary, rounding, Reg5/alias, and sticky-flag cases plus 35 direct flag cases; 4,401 decoded SYS transfer, Reg5, fence, request, recovery, privilege, and maintenance cases | target numeric conformance remains Stage 5 |
| Bundle/command forms | 99 | Stage 4 command totality closed | generated exact-form priority witnesses, all-start descriptor assertions, exact 89-executed/10-rejected dispositions, full-width memory-command bounds, explicit metadata-only effects, transactional commit, and checked bundle-to-tile representability | target-specific behavior for profile-rejected frame, queue, context-memory, and cross-core-block commands requires a new profile contract |
| Scalar semantics | AGU, ALU, AMO, BRU, FSU, SYS | all six scalar families have Stage 4 reference-totality closure; Stage 3 ordering closed | AGU address, update, prefetch-model, pair, event, fault, restart, and Reg5 evidence; ALU fixed-width and Reg5 evidence; AMO width, modifier, value, Reg5 alias, fault/restart, reservation, and DMA evidence; BRU condition, target, predicate, bundle, and fault evidence; FSU exhaustive carrier/type/rounding/flag/Reg5 evidence; SYS all-address transfer, Reg5 alias, fence-mask, request, recovery, privilege, and maintenance evidence | target numeric conformance |
| System registers and traps | 72 register definitions, including 18 EBARG snapshot registers; 13 trap identities | Stage 2 register and trap targets closed | checked reset/read/write/side-effect/profile classes, generated all-bank reset and access witnesses, authoritative EBARG recovery, per-trap entry/routing/recovery tests, and coherent interrupt/pending/timer/EOI behavior | active translation or debug-trigger profiles require new trigger, precedence, and conformance contracts |
| Tile registers | 64 `TileInfo` records; 128-byte CELL and B.IOT size codes 3..9 | capacity, definedness, and explicit handoff invariants closed; Stage 2 tile-state target closed | hand mapping, 128-byte minimum, every B.IOT size code, maximum/aggregate capacity, packed sub-byte storage, no-effect rejection, per-element and reduction incomplete-source rejection, reconfiguration reset, layout, aliasing, push/full-slot, pop/empty-slot, source lifetime, double-free, and multi-slot tests | instruction-family numeric and memory-order refinements are tracked in Stages 3–5 |
| TEPL | 98 operations | Stage 4 raw-carrier reference totality closed; Stage 5 conformance open | all-98 decoded deterministic state transitions, all-30 reserved selectors, 25 carrier types, layout rejection, multi-destination alias rejection, preserved regions, invalid indices/offsets, duplicate scatter, stable merge, and histogram corners | target floating, quantized, rounding, saturation, and exceptional-value conformance |
| TMA | 9 operations | Stage 4 reference totality closed; Stage 3 ordering closed | all-nine decoded effects, packed four-bit accesses, duplicate-lane ordering, masks, CAS, production events, restart, and first/middle/last preflight faults | target numeric conformance remains a Stage 5 obligation where profile hooks apply |
| CUBE | 13 operations with implicit ACC | Stage 4 raw-carrier reference totality closed; 0.57.1 logical/physical ACC contract defined; Stage 5 conformance open | all-13 decoded results, all-25 type identities, mixed layouts/locations, aliases, ACC initialization/update/conversion/release, trap preservation, and composite preflight | named hardware accumulation, rounding, saturation, exceptional-value, and numeric conformance |
| Encodings and execution status | 474 scalar forms + 99 bundle/command forms + 120 direct tile operations | PTO ISA 0.57.1 Mode/Function ABI and M4 instruction reference semantics closed; S5-T3 independent comparison closed | generated decoders, operand/handler bindings, reserved-code rejection, no-legacy-decode witnesses, one-tick success/rejection matrix, stale-fault isolation, preserved trap record, scalar/command/tile legality witnesses, and a 693-row comparison matrix with 557 exact matches, 96 classified divergences (86 approved 0.57.1 ABI-break remaps and 10 intentional rejected-command differences), 39 non-comparable rows, and one intentional extension, with all clean-snapshot documentation and Sail gates | Stage 5 numeric conformance and Stage 6 immutable-candidate evidence remain open |
| Named hardware numeric profile | `pto-hardware-numeric-0.57.1-ieee-v1` | contract and boundary-vector schema defined; implementation conformance open | checked profile identity, low-precision formats, packed lanes, NaN/zero/invalid-result/RHB rules, matrix operand and physical ACC classes, and MX scale shape/order | independent oracle results, downstream byte/effect parity, and accepted target review under `S5-T2` |
| PTO-TSO concurrency | 16-event/four-agent verification bound | production-connected candidate graph; Stage 3 closed | standalone litmus construction, axiomatic checks, scalar/tile/DMA/fence extraction, atomic ordering, reservation boundaries, conditional writes, and mixed-size fail-closed tests | byte-level mixed-size coherence is an explicit future extension |

The current M4 claim means the mechanical, execution-path, state/fault,
ordering, and reference instruction-semantics stages close cumulatively. It
does not mean the raw-carrier reference profile conforms to target numeric
hardware or that the named 0.57.1 hardware contract has implementation
conformance. It also does not mean release review is complete. The staged exit criteria
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
- all 99 bundle/command form masks and matches, priority-selected exact-form
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
- The named 0.57.1 hardware numeric contract is normative, but no implementation
  conformance claim exists until `S5-T2` evidence closes.
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
direct-tile numeric-dependent operations to 30 hooks and an explicit profile
owner. Target conformance is graded separately: eight non-numeric contracts are
closed and the 29 numeric raw-carrier hooks remain assigned to `S5-T2`. Green
validation does not turn PTO v0 into an IEEE or hardware profile. The generated
`spec/evidence/numeric-conformance-readiness.json` ledger makes the remaining
six-lane partition and its absent profile/oracle/vector/result/review evidence
fail closed before expensive runtime validation begins. The generated
`numeric-profile-decision-inputs.json` ledger further covers all 20 domains
with 12 explicit open profile questions and 24 content-addressed public
evidence sources. The generated
`numeric-profile-decision-proposals.json` ledger adds four versioned profile
identities, proposed dispositions for all 12 questions, and an exact mapping
for all 20 domains. ADR 0037 and
`spec/catalog/numeric-profile-identities.json` now close the four identity and
five selection-framework records. Every question and domain result-rule
acceptance field remains null. The generated
`scalar-numeric-flag-contract.json` ledger and ADR 0038 close the scalar flag
state/lifecycle and assign all 30 FSU forms to one producer owner; exact flag
conditions remain open for 19 profile-owned forms. PD-06, S5-T2-A, and numeric
conformance therefore remain open.
The generated `numeric-rounding-selector-contract.json` ledger and ADR 0039
close PD-03 selector discovery and namespace ownership across eight active
scalar codes, five fixed overrides, eight bundle codes, four external selector
classes, 18 domains, 102 operations, and 25 hooks. All domain rounding and
saturation-order rules remain open, so this checkpoint does not increment the
accepted-decision count or change the M4 floor.
The generated `numeric-format-namespace-contract.json` ledger and ADR 0040
close the structural namespace portion of PD-02. Five code spaces remain
distinct; all 25 raw-carrier identities, every mapped/reserved code, and all four
packed 4-bit low/high nibble cases are executable invariants. Eight residuals
retain the bit-exact floating-format, exceptional-value, operation/type/profile
legality, target-availability, and conformance-vector work at that checkpoint.
ADR 0043 and the generated `public-numeric-type-baseline.json` ledger close
all 16 published public type identities, 11 exact catalog bindings, and public
availability for 11 A2/A3 and 16 A5 types. Seven bit-exact format, catalog-role,
legality, and vector residuals remain. No result or domain rule is accepted, so
PD-02, S5-T2, and the M4 floor remain unchanged.
ADR 0044 and the generated `public-integer-conversion-contract.json` ledger
close `S5-T2-A6` for 48 unequal-width public integer `TCVT` tuples. Three
portable result rules cover signed widening, unsigned widening, and narrowing;
executable boundary witnesses confirm source-width interpretation. Profile
support, same-width conversions, floating conversions, overflow/saturation,
rounding, flags, and target vectors remain open. The accepted bounded subset
does not increment the 0/12 complete-decision or 0/20 domain-rule counts, so
PD-07, S5-T2, and the M4 floor remain unchanged.
The generated `numeric-profile-applicability-closure.json` ledger and ADR 0041
close one negative PD-01 slice: A2/A3 does not support the six MX CUBE
selectors for any of the 25 `TileDataType` identities, and every one of the
150 operation/type tuples rejects before effects. No result rule is selected,
so PD-01, `cube-matrix`, S5-T2, and the M4 floor remain unchanged.
The generated `numeric-variation-point-ownership.json` ledger and ADR 0042
close PD-12 discovery and current-owner assignment for 99 stable
domain/dimension rows. The rows reach all 108 numeric operations and 30 hooks,
including the two library-only helpers. All selected routes, result rules, and
acceptance records remain null, so PD-12, S5-T2, and M4 remain unchanged.

Release traceability is independently fail-closed. The generated
`spec/evidence/release-traceability-readiness.json` ledger assigns requirement,
model, executable witness, and bounded status links to 935 exact units. It
covers all 474 scalar forms, 99 command forms, 120 direct tile operations, 72
system registers, 13 traps, 38 profile hooks, 46 requirements, and 73 top-level
ASL state roots expanded to 238 leaf fields. State rows distinguish direct
architectural state, bounded storage and ordering abstractions,
architectural-effect abstractions, and verification-only instrumentation. The
inventory and link package is closed; 11 S5-T2-dependent requirements, 30
numeric hooks, and the later immutable-commit review keep S6-T1 open.

The generated `spec/evidence/release-gate-readiness.json` ledger closes the
S6-T2 contract inventory independently of candidate execution. It defines ten
clone-verifiable release gates, proves the pinned least-privilege hosted
workflow and exact 34-shard/105-call/96-subprogram topology, and enumerates ten
external repository controls plus the PTO architecture and formal-model review
perspectives. All candidate commit, runtime result, hosted-run, control-snapshot,
and approval fields remain null. S5-T2 and S6-T1 therefore block candidate
freeze, and S6-T2 remains open without misrepresenting the current draft-branch
validation as M6 evidence.
