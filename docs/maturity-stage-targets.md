# PTO ASL maturity evaluation and bring-up targets

This is the manual review plan for PTO ASL maturity. It splits the evaluation
into cumulative stages, gives every stage a measurable target and exit gate,
and names the evidence that permits a promotion. Work may be prepared in
parallel, but no later stage can waive an earlier exit gate.

The authoritative detailed plan remains
[Maturity bring-up plan](maturity-bringup-plan.md). The authoritative state for
each target remains `../spec/evidence/maturity-closure.json`.

## How to review a maturity stage

Review one stage at a time and record the result against an immutable commit.

1. Confirm that the stage entry gate is closed in the machine-readable maturity
   ledger.
2. Review every target in the stage; a target passes only when its inventory,
   legality, architectural effect, fault behavior, ordering, and conformance
   dimensions are either evidenced or explicitly not applicable.
3. Reproduce the stage-specific evidence and the cumulative regression floor.
   Aggregate CI is supporting evidence, not a substitute for a missing target
   artifact.
4. Record **pass**, **fail**, or **defer**. A pass promotes the maturity floor
   only when every earlier stage also passes. A defer must name its owner,
   missing evidence, and tracking record.

The review unit is a target ID such as `S4-T3`, not a source file or a raw test
count. Test counts help detect drift; they do not establish architectural
closure by themselves.

## Current maturity floor

The repository currently reports a maturity floor of M4.

| Level | Meaning | Current repository claim |
| --- | --- | --- |
| M0 | mechanically closed | catalogs, generation, and ASLRef gates are green |
| M1 | execution-path closed | every accepted form reaches an intended visible effect or explicit unsupported result |
| M2 | state-and-fault closed | state, reset, trap, and recovery behavior are total |
| M3 | ordering closed | production memory operations emit the normative PTO ordering events |
| M4 | reference-semantics closed | every instruction family is total under `pto-v0` |
| M5 | conformance closed | independent evidence validates the named numeric and target profile(s) |
| M6 | architecturally complete | all prior gates, traceability, review, and publication requirements close together |

## Stage summary

Stages are cumulative. A later implementation does not waive an earlier stage
decision.

| Stage | Primary result | Exit product | Current status |
| --- | --- | --- | --- |
| 0 — baseline | One honest gap ledger | reviewed coverage, status, and decision inventory | Closed |
| 1 — execution paths | Every accepted encoding reaches an operation-bearing effect | decoded before/after effect matrix | Closed |
| 2 — state and faults | Every visible state field resets, transitions, traps, and recovers precisely | state-invariant and fault/restart matrix | Closed |
| 3 — ordering | Production memory operations populate the PTO-TSO domain | event-extraction and litmus suite | Closed |
| 4 — instruction semantics | Every instruction family is total under `pto-v0` | per-family legality/effect/fault closure reports | Closed |
| 5 — conformance | Numeric and target-dependent results have independent evidence | versioned conformance and ISA-comparison reports | In progress |
| 6 — release | All claims and artifacts close together | architecturally-complete release evidence | Open |

## Target scorecard

Targets, rather than files or test counts, are the unit of maturity closure.
The current score is 28 closed targets out of 31; the cumulative maturity floor
is M4 because every Stage 4 target is closed.

| Stage | Closed | Total | Next gate |
| --- | ---: | ---: | --- |
| 0 — baseline | 3 | 3 | Closed |
| 1 — execution paths | 5 | 5 | Closed |
| 2 — state and faults | 6 | 6 | Closed |
| 3 — ordering | 2 | 2 | Closed |
| 4 — instruction semantics | 10 | 10 | Closed |
| 5 — conformance | 2 | 3 | Supply independent numeric conformance. |
| 6 — release | 0 | 2 | Close cumulative traceability, validation, review, and publication gates. |
| **Total** | **28** | **31** | **M4 is the published floor.** |

## Active promotion work

Only three targets remain open. This table is the short operational plan; the
later sections define their complete evidence packages.

| Priority | Target | Accountable owner | Immediate target | Promotion blocker |
| ---: | --- | --- | --- | --- |
| 1 | `S5-T2` | PTO numeric conformance maintainers | Accept the profile rules, qualify independent oracles, execute complete vectors, and adjudicate every result across 18 domains, 28 hooks, and 104 operations. | Ten of 12 numeric decisions and all 18 domain result rules are not yet accepted; independent oracle, vector, result, and review evidence is incomplete. |
| 2 | `S6-T1` | PTO release maintainers | Close the 11 Stage-5-dependent requirements and 28 numeric hooks, then review the 925-unit traceability ledger at one immutable commit. | Depends on `S5-T2`; immutable-commit claim-hygiene review is absent. |
| 3 | `S6-T2` | PTO release maintainers | Freeze one signed candidate and reproduce all local, hosted, repository-control, and review gates against it. | Depends on `S5-T2` and `S6-T1`; candidate results and approvals are absent. |

## Stage evaluation contract

Reviewers evaluate one row at a time. `Entry gate` says what must already be
true, `Measurable target` defines the work package, and `Exit gate` is the
minimum evidence required to close the row. A green aggregate CI run is
necessary, but it cannot substitute for a missing stage-specific artifact.

| Stage | Entry gate | Measurable target | Exit gate | Status |
| --- | --- | --- | --- | --- |
| 0 — baseline (`S0-T1`–`S0-T3`) | Repository catalogs and tests are discoverable. | Account for every accepted identity and classify every known gap; make all published maturity surfaces agree. | Deterministic catalogs plus one checked ownership ledger with no unowned gap or conflicting claim. | Closed |
| 1 — execution paths (`S1-T1`–`S1-T5`) | Stage 0 closed. | Bind all 474 scalar forms, 99 bundle/command forms, and 109 direct-tile selectors to one visible effect or pre-effect rejection. | Generated decode/effect matrices are total, unique, executable, and reject reserved encodings before effects. | Closed |
| 2 — state and faults (`S2-T1`–`S2-T6`) | Stage 1 effect paths stable. | Cover all architectural state, 72 system registers, P0–P7, tile state, 16 ACR banks, and 13 traps. | Reset, transition, preservation, trap, recovery, restart, capacity, and definedness matrices are complete. | Closed |
| 3 — ordering (`S3-T1`–`S3-T2`) | Stage 2 fault/restart rules stable. | Connect every production memory effect to PTO-TSO and close atomic, reservation, gather-CAS, prefetch, and mixed-size corners. | Event extraction and allowed/forbidden litmus evidence agree with the normative ordering model. | Closed |
| 4 — reference semantics (`S4-T1`–`S4-T10`) | Stages 0–3 closed. | Make AGU, ALU, AMO, BRU, FSU, SYS, bundle, TEPL, TLSU, and CUBE total under `pto-v0`. | Every family has checked legality, operand, value/effect, alias, boundary, fault, restart, and pre-effect-rejection evidence. | Closed |
| 5 — conformance (`S5-T1`–`S5-T3`) | M4 regression floor remains green. | Independently validate all 18 numeric domains, 28 hooks, and 104 operations, while retaining the closed 682-row executable-model comparison: 554 exact encoding matches, 90 classified divergences, and 38 non-comparable rows. | All 12 numeric decisions and 18 domain rules are accepted; six oracles, complete vectors/results, zero unclassified mismatches, and two reviews are recorded. | In progress: `S5-T2` open |
| 6 — release (`S6-T1`–`S6-T2`) | Stage 5 closed. | Close cumulative traceability and reproduce every release gate at one signed immutable candidate. | Eleven dependent requirements and 28 hooks close; all 925 trace units, ten gates, ten controls, hosted validation, and both approvals name the same commit. | Open |

## Remaining bring-up sequence

The remaining work is ordered by promotion dependency. Work may run in
parallel, but a later row cannot waive an earlier promotion gate.

| Order | Target | Concrete bring-up result | Acceptance gate | Promotion unlocked |
| ---: | --- | --- | --- | --- |
| 1 | M4 regression floor | Preserve the closed 474 scalar, 99 bundle/command, 109 direct-tile, 72 system-register, and 13-trap inventories while later evidence is added. | Catalog/repository checks, deterministic generation, ASLRef shards, and all Stage 0–4 target evidence remain green. | Safe Stage 5 development |
| 2 | `S5-T2` | Name the PTO target numeric profile and an independent, versioned oracle; cover normal, boundary, exceptional, rounding, saturation, and accumulation cases for every applicable numeric-contract row. | Differential report has no unclassified mismatch and does not treat the `pto-v0` raw-carrier model as hardware arithmetic. | Numeric conformance half of M5 |
| 3 | `S5-T3` | Closed: the complete stable-ID comparison is regenerated from a clean content-addressed executable-model snapshot; all 682 dispositions remain classified with 554 exact encoding matches, 90 divergences, and 38 non-comparable rows. | Parser, executable backend, generated-status, coverage, architecture-contract, and documentation gates all pass. The separate per-row oracle ledger preserves independent executable parity at 0/38. | Independent-disposition half of M5; executable parity remains explicit evidence work |
| 4 | `S6-T1` | Generated inventory and links closed: 925 exact units cover requirements, accepted forms and operations, registers, traps, profile hooks, and 75 state roots/235 leaves. Promotion remains open. | S5-T2 closes the 11 dependent requirements and 28 hooks; then one immutable-commit claim-hygiene review fills every review identity and disposition. | Release review may start |
| 5 | `S6-T2` | Gate contract/topology closed: ten release gates, ten external controls, two reviews, and the pinned 52-shard hosted path are exact. Candidate evidence remains open. | After S5-T2/S6-T1, freeze one signed commit; pass every local/hosted gate; snapshot GitHub controls; record both approvals. | M6 architecturally-complete candidate |

Promotion rules are exact: M5 requires all three Stage 5 targets to be closed;
M6 requires every Stage 0–5 target plus both Stage 6 targets to be closed or
explicitly excluded by an accepted PTO architecture decision.

## Stages 0–3 target register

These targets establish the evidence that Stage 4 work is allowed to reuse.
They remain listed even though they are closed because later work cannot weaken
their contracts.

| Target | Stage | Status | Closure target |
| --- | --- | --- | --- |
| `S0-T1` | Baseline | Closed | Freeze and deterministically regenerate every accepted scalar, bundle/command, and direct-tile inventory. |
| `S0-T2` | Baseline | Closed | Classify and own every known gap with requirements, evidence, and a tracking record. |
| `S0-T3` | Baseline | Closed | Reconcile README, coverage, profile metadata, requirements, and the published maturity floor. |
| `S1-T1` | Execution paths | Closed | Bind every bundle-start form to an operation-bearing descriptor or an explicit pre-state rejection. |
| `S1-T2` | Execution paths | Closed | Give bundle start, body, stop, and direct tile launch one transactional lifecycle. |
| `S1-T3` | Execution paths | Closed | Give all 474 scalar forms a decoded TPC, status, operand, and visible-effect path. |
| `S1-T4` | Execution paths | Closed | Use one attempt-status, fault, and exactly-one-tick contract across scalar, bundle, and tile dispatch. |
| `S1-T5` | Execution paths | Closed | Bind all 109 direct-tile selectors to ordered semantic handlers and reject reserved selectors before effects. |
| `S2-T1` | State and faults | Closed | Define access, reset, and behavior classes for all 72 visible system registers. |
| `S2-T2` | State and faults | Closed | Define complete nonzero-seed reset for every architectural state field and all 16 ACR banks. |
| `S2-T3` | State and faults | Closed | Define producer, routing, saved context, recovery, and restart envelopes for all 13 traps. |
| `S2-T4` | State and faults | Closed | Separate the 64-bit MPAR/MSEQ execution mask from eight 32-bit warp predicates; hardwire P0 and define reset, trap, and consumer boundaries; keep the public v0.6 `!pto.mask<G>` source layer outside PTO ISA 0.58.0 without inferring a physical mapping. |
| `S2-T5` | State and faults | Closed | Enforce per-tile and aggregate capacity through `TILE_CAPACITY`, including sub-byte storage. |
| `S2-T6` | State and faults | Closed | Define element-level tile validity, layout rejection, handoff, lifetime, ordering, and aliases. |
| `S3-T1` | Ordering | Closed | Emit normative PTO-TSO events from every production scalar and tile memory path. |
| `S3-T2` | Ordering | Closed | Close acquire/release, reservation, failed-SC, gather-CAS, and mixed-size ordering decisions. |

## Stage 4 tranches

Stage 4 is the closed reference-semantics tranche. Its sub-tranches remain
visible so independent family evidence can be audited without mixing scalar,
memory, bundle, tile, and compute decisions.

| Tranche | Targets | Immediate objective | Done when |
| --- | --- | --- | --- |
| A — scalar value/control | `S4-T2`, `S4-T4`, `S4-T5` | Close pure scalar result, control-flow, alias, and raw-carrier behavior before target-specific numeric conformance. | Every stable form ID has class-appropriate boundary and alias vectors; control-flow fault precedence is total; all profile-dependent numeric behavior remains explicitly hooked to Stage 5. |
| B — memory/system | `S4-T1`, `S4-T3`, `S4-T6`, `S4-T9` | Reuse the closed Stage 2 state/fault and Stage 3 event contracts to close address, atomic, system, and tile-memory semantics. | Every operation has value, event, fault, restart, and no-partial-effect evidence, including minimum/maximum address and overlap cases. |
| C — bundle/tile compute | `S4-T7`, `S4-T8`, `S4-T10` | Consume every retained descriptor field and close tile definedness, legality, aliases, and composite preflight. | No accepted command or selector relies on a placeholder, ignored binding, accidental fixed value, or unclassified numeric surrogate. |

## Stage 4 target register

| Target | Group | Current status | Closure target |
| --- | --- | --- | --- |
| `S4-T1` | AGU | Closed | Address generation, scaling, all prefetch models, pair preflight, writeback, events, aliases, fault precedence, and full-reissue restart are exact and executable. |
| `S4-T2` | ALU | Closed | Close fixed-width arithmetic, division, multiply, bitfields, rearrangement, and Reg5 aliases. |
| `S4-T3` | AMO | Closed | All 53 forms have exact, unique modifier, value, Reg5 alias, fault/restart, reservation-interaction, and 64-byte DMA overlap/boundary evidence, with reviewed comparison limits and fail-closed counts. |
| `S4-T4` | BRU | Closed | Close conditions, targets, calls, returns, alignment, and bundle interaction. |
| `S4-T5` | FSU | Closed | Close raw-carrier reference effects and keep target arithmetic profile-scoped until Stage 5 supplies numeric conformance. |
| `S4-T6` | SYS | Closed | ADR 0031 and `scalar-sys-totality.json` close all 35 forms with 4,401 unique Stage 4 transfer, Reg5, fence, request, recovery, privilege, and maintenance cases plus 35 retained Stage 1 effects. |
| `S4-T7` | Bundle commands | Closed | All 99 forms have generated consumed-field and effect-or-rejection dispositions; bridge limitations are explicit and commit-fail-closed. |
| `S4-T8` | TEPL | Closed | ADRs 0035 and 0052 plus `tepl-totality.json` close all 87 accepted selectors, 41 reserved selectors, carrier/layout rules, aliases, regions, indices, sort/merge, histogram, and management effects. |
| `S4-T9` | TLSU | Closed | All ten selectors have decoded effects plus packed four-bit, duplicate-lane, event, restart, and first/middle/last preflight-fault evidence. |
| `S4-T10` | CUBE | Closed | All 12 accepted operations, 20 reserved selectors, 25 raw-carrier types, logical layouts/locations, explicit C/D aliases, and composite preflight are closed; hardware numeric conformance remains S5-T2. |

### Stage 4 SYS sub-areas

`S4-T6` closes the SYS surface as one authoritative target. Its six reviewed
sub-areas remain visible below so the decision and evidence boundaries can be
audited without introducing extra target IDs.

| Sub-area | Closed disposition | Evidence |
| --- | --- | --- |
| Cache/TLB maintenance | Synchronous epoch completion; opaque cache scope tokens; root-only TLB with canonical-VA48/ASID gates | ADR 0031 plus 475 decoded selector, boundary, and privilege cases |
| Wait/wake requests | Nonblocking PTO-v0 scheduling handoff with no additional visible sleep/wake state | ADR 0031 plus all 128 Reg5 request cases |
| ACRE transitions | Types 0/1 are aliases; invalid type precedes missing or malformed-context checks | ADR 0031 plus 22 decoded recovery cases |
| Register transfer coverage | All 837 concrete addresses through every applicable 5-, 12-, and 24-bit form; swap preflights before reads | 1,937 transfer plus 1,184 Reg5/alias cases |
| Profile-gated registers | Translation, XB, ACR-parameter, and debug families are explicitly `pto-v0-storage-only` | ADRs 0017 and 0031 |
| ACRC service request | All source-ring/type routing and failure precedence are closed; bundle placement belongs to `S4-T7` | ADRs 0012 and 0031 plus 256 decoded cases |

## Stage 5 target register

| Target | Current status | Closure target |
| --- | --- | --- |
| `S5-T1` | Closed | Inventory every operation whose result depends on numeric behavior beyond the raw-carrier reference profile. |
| `S5-T2` | Open | Validate PTO numeric behavior against a named independent oracle without importing third-party semantics as PTO authority. |
| `S5-T3` | Closed | The exhaustive 682-row disposition matrix is complete: 554 exact encoding matches, 90 explicit divergences, and 38 non-comparable rows. All eight clean-snapshot repository gates plus the pinned Sail parser/C-backend gate pass. Independent executable parity for the 38 rows is orthogonal and remains 0/38. |

### S5-T2 numeric-conformance bring-up plan

`S5-T2` is intentionally split into promotion-ordered sub-stages. The
sub-stages are execution checkpoints, not new maturity claims: `S5-T2` remains
open, and the repository remains at M4, until every sub-stage below closes.

| Sub-stage | Current state | Clear target | Required exit evidence |
| --- | --- | --- | --- |
| `S5-T2-A` — profile decision | Checkpoints A1, A4, A5, and A6 are closed; PD-03 and PD-04 are accepted; PD-05-SC2 has a bounded special-value checkpoint | Apply the four accepted identities and fail-closed selection rules. Preserve the 89-point ownership ledger. Use the A5 public baseline of 16 identities, 16 accepted catalog bindings, 11 A2/A3 types, and 16 A5 types without treating availability as legality or complete result semantics. Preserve A6's three conditional result rules over all 48 unequal-width public integer `TCVT` pairs without turning them into support claims. Preserve ADR 0047's 16 selected rounding routes, ADR 0049's eleven-format, 93-operation named-profile subnormal contract, and ADR 0050's three special-value rules over eight operations and 154 conditional operation/type rows without changing `pto-v0` or creating support. Resolve the remaining PD-02/PD-05–PD-12 residuals, ten complete decisions, all 18 complete domain rules, 19 profile-owned flag conditions, and 73 open variation routes/result bounds. | Accepted records populate all 12 decisions and 18 domain rules; every non-portable point has one visible route and bounded result contract; all format, legality, conversion, flag, rounding, and target-support residuals have reproducible evidence. |
| `S5-T2-B` — oracle qualification | Waiting on A | Select an independent, versioned oracle for each lane. The implementation under test and the `pto-v0` reference are not independent oracles. | Reproducible oracle identity, version/digest, invocation, supported domain list, known limitations, and a reviewer-approved rule for any target behavior that requires hardware capture rather than a software arithmetic library. |
| `S5-T2-C` — vector corpus | Waiting on A–B | Generate deterministic inputs for every operation and every open numeric dimension. | Normal, minimum/maximum, boundary, signed-zero, subnormal, infinity, NaN, tie, overflow, underflow, divide-by-zero, rounding, saturation, reduction-order, and accumulation cases as applicable; each vector links to one operation key, profile, oracle, and expected disposition. |
| `S5-T2-D` — differential execution | Waiting on B–C | Run the six numeric lanes independently and preserve raw oracle and PTO results. | All 18 contract domains, 28 hooks, and 104 operations are assigned exactly once; every vector produces a reproducible match, mismatch, unsupported, or implementation-defined record; no lane is missing or duplicated. |
| `S5-T2-E` — mismatch adjudication | Waiting on D | Resolve every differential result without silently changing PTO semantics to match an external implementation. | Zero unclassified results. Each mismatch is fixed as a PTO defect, accepted as a target-profile rule, rejected as an oracle limitation, or bounded by an architecture decision with regression evidence. |
| `S5-T2-F` — promotion | Waiting on A–E | Freeze the conformance package and promote Stage 5 only after independent review. | Clean-tree reproduction, immutable profile/oracle/vector/result identities, repository gates, numeric-architecture approval, formal-model approval, and an updated closure ledger with no remaining `S5-T2` gaps. |

The sub-stages may prepare independent artifacts concurrently, but promotion is
strictly ordered: profile scope controls oracle selection; profile and oracle
scope control vector expectations; results cannot be adjudicated before the
corresponding oracle and vector identities are frozen.

The [numeric profile decision register](numeric-profile-decision-register.md)
records the 12 S5-T2-A questions and the pinned public-contract and
implementation evidence that exposed them. Its generated domain matrix covers
all 18 numeric domains without selecting a result rule. The generated
`spec/evidence/numeric-profile-decision-proposals.json` package proposes every
disposition and mapping while importing the four identities accepted in
`spec/catalog/numeric-profile-identities.json`. `S5-T2-A1` is closed; all 12
question records are populated, PD-03 and PD-04 are accepted, and the remaining ten
complete decisions plus all 18 complete domain rules remain open.
The machine-derived closure snapshot is 2 accepted and 10 open decisions,
and the complete-decision and complete-domain-rule counts remain 2/12 and
0/18; 16 selected and 73 open variation routes remain.
ADR 0038 and `spec/evidence/scalar-numeric-flag-contract.json` additionally
close flag state/lifecycle and the 30/30 FSU producer-owner matrix. Eleven
architecture-owned conditions are exact; 19 profile-owned conditions keep
PD-06 open and do not increment the S5-T2-A2 decision count.
ADRs 0039 and 0047 and
`spec/evidence/numeric-rounding-selector-contract.json` close PD-03 across
eight scalar raw values, five fixed conversion overrides, eight bundle
`RMode` codes, seven public conversion values, four external selector classes,
18 domains, 102 operations, and 25 hooks. All 18 per-domain rounding and
saturation-order rules are accepted and 16/89 variation routes are selected.
ADR 0049 and `spec/evidence/numeric-subnormal-contract.json` close PD-04 for
the named hardware profile across eleven subnormal-capable formats, 16
domains, 95 operations, 23 hooks, and 1,045 conditional operation/type rows.
Input values are preserved, results use gradual underflow, tininess is detected
after rounding, and all FTZ/DAZ/override configurations reject before effects.
The decision count is therefore 2/12. The generic selected-route count remains
16/89 until PD-12 admits the hardware profile as a visible selection identity.
ADR 0040 and `spec/evidence/numeric-format-namespace-contract.json` close the
PD-02 structural checkpoint: five independent code spaces, all 25
`TileDataType` raw-carrier widths, complete mapped/reserved tables, and
low-nibble-first packing for the five packed four-bit types E2M1X2, E1M2X2,
HiF4X2, S4X2, and U4X2. Eight residuals keep exact floating formats,
exceptional values, operation/type/profile legality, target
availability, and vectors open. PD-02 likewise does not increment the
S5-T2-A2 decision count.
ADR 0048 closes the shared PD-02/PD-05 value-class checkpoint. The ASL model
classifies all 25 formats, rejects four internally constrained encodings, and
provides canonical NaNs for ten formats. This is not an operation result rule:
propagation, flags, legality, target behavior, and independent vectors remain
open; those PD-02/PD-05 residuals do not change the 2/12 decision count.
ADR 0050 adds the bounded PD-05-SC2 special-value checkpoint for the named
hardware profile. Three accepted rules fix produced canonical NaNs, tile
comparison NaN/signed-zero results, and scalar/tile MIN/MAX NaN/signed-zero
results across eight operations and 154 conditional operation/type rows. The
rules are conditional on separately accepted profile support, do not change
`pto-v0`, and do not close PD-05, a complete numeric domain, or another
generic variation route. Infinity arithmetic, broader NaN creation,
conversions, reductions, quantization, matrix results, and full flag/status
behavior remain open; the decision count stays 2/12, open decisions stay ten,
complete domains stay 0/18, and selected generic variation routes stay 16/89.
ADR 0041 and `spec/evidence/numeric-profile-applicability-closure.json` close
a bounded PD-01 checkpoint within `S5-T2-A3`: A2/A3 rejects
`TMATMUL_MX`, `TMATMUL_MX_BIAS`, `TMATMUL_MX_ACC`, `TGEMV_MX`,
`TGEMV_MX_BIAS`, and `TGEMV_MX_ACC` for every one of the 25 `TileDataType`
identities before effects. It records 150 unsupported tuples and zero result
rules, so the rest of PD-01 and `cube-matrix` remain open.
ADR 0042 and `spec/evidence/numeric-variation-point-ownership.json` close
`S5-T2-A4`, the PD-12 discovery and current-owner checkpoint. Its 89 stable
domain/dimension rows cover all 18 domains, 104 operations, and 28 hooks.
Sixteen rounding routes are selected; the remaining 73 routes and all generic
hardware-profile discovery remain open, so PD-12 and S5-T2 remain open.
ADR 0043 and `spec/evidence/public-numeric-type-baseline.json` close
`S5-T2-A5`, the PD-02 public identity and target-availability checkpoint. The
baseline enumerates all 16 published types, accepts 16 catalog bindings, and
fixes availability at 11 types for A2/A3 and 16 for A5. Nine catalog types
remain outside the public inventory, and four legality, vector, parity, and
review residuals remain; accepted complete-domain-rule counts remain zero.
ADR 0044 and `spec/evidence/public-integer-conversion-contract.json` close
`S5-T2-A6`, the first bounded PD-07 result checkpoint. Its 48 generated tuples
cover every ordered unequal-width pair among the eight public integer types.
Three portable rules define signed widening, unsigned widening, and narrowing
only after the selected profile accepts the tuple. Six residuals keep
same-width conversions, floating conversions, support legality,
overflow/saturation and exceptional results, rounding/flags, and independent
vectors open. PD-07, `tile-convert`, `S5-T2-A`, and M5 therefore remain open;
this bounded subset does not change the current 2/12 accepted-decision count
or the 0/18 complete-domain-rule count.

#### Parallel numeric lanes

These lanes partition the closed `S5-T1` inventory exactly once. Counts are
closure invariants: future inventory changes must update the numeric-contract
ledger and this plan together before conformance execution. The generated
`spec/evidence/numeric-conformance-readiness.json` ledger contains the complete
operation-key and hook assignment for each lane; CI regenerates it from
`numeric-contracts.json` and rejects missing, duplicate, or stale membership.

| Lane | Contract domains | Operations | Hooks | Required numeric focus |
| --- | --- | ---: | ---: | --- |
| N1 — scalar arithmetic | `scalar-binary`, `scalar-unary`, `scalar-fused` | 11 | 4 | arithmetic and fused precision, elementary functions, rounding, flags, signed zero, subnormals, NaN, infinity, overflow, and underflow |
| N2 — scalar conversion | `scalar-fp-to-integer`, `scalar-fp-convert`, `scalar-integer-to-fp` | 8 | 4 | format mapping, signedness, all rounding directions, inexact results, out-of-range behavior, saturation or indefinite results, and exception flags |
| N3 — tile elementwise | `tile-binary`, `tile-unary`, `tile-axpy`, `tile-prelu`, `tile-compare`, `tile-expand` | 53 | 9 | carrier interpretation, transcendental helpers, comparison ordering, divide/domain errors, multiply-add precision, rounding, saturation, and exceptional values |
| N4 — tile conversion | `tile-convert`, `cube-convert`, `tile-quantize`, `tile-dequantize` | 4 | 3 | source/destination formats, scale and zero point, rounding, clamping, NaN payloads, overflow, and underflow |
| N5 — reductions and ordering | `tile-reduction`, `tile-partial`, `tile-order` | 20 | 5 | accumulation width and order, tie-breaking, stability, NaN placement, signed zero, partial-result precision, and ascending/descending behavior |
| N6 — matrix arithmetic | `cube-matrix` | 12 | 3 | product precision, accumulation width, bias and MX scaling, rounding, saturation, NaN, infinity, overflow, and underflow |
| **Total** | **18 domains** | **104** | **28** | **Complete `S5-T1` numeric inventory** |

#### S5-T2 promotion checklist

The numeric target closes only when all answers below are evidenced, not merely
documented as intentions.

- Which named profile is tested, and which rules are portable versus
  target-specific?
- Which independent oracle and immutable version validates each lane?
- Does every one of the 108 operation keys have applicable normal, boundary,
  exceptional, rounding, saturation, reduction, and accumulation vectors?
- Are unsupported and implementation-defined cases explicit and bounded?
- Are raw oracle inputs, outputs, tool logs, comparison results, and mismatch
  dispositions reproducible from a clean checkout?
- Did independent numeric-architecture and formal-model reviewers approve the
  profile boundary and every remaining divergence?
- Do all Stage 0–4 regression gates and the closed `S5-T3` comparison remain
  green after the numeric profile is added?

## Stage 6 target register

| Target | Current status | Closure target |
| --- | --- | --- |
| `S6-T1` | Open | Prove requirements-to-model-to-test traceability with no unsupported completeness claim. |
| `S6-T2` | Open | Gate contract and hosted/parallel topology are closed; immutable candidate execution, protected-branch evidence, and architecture/formal approvals remain open. |

### S6-T1 release-traceability bring-up plan

The generated `spec/evidence/release-traceability-readiness.json` ledger makes
the release inventory and its residual blockers reviewable before the expensive
release gate. S6-T1 stays open until all five sub-stages close.

| Sub-stage | Current state | Clear target | Required exit evidence |
| --- | --- | --- | --- |
| `S6-T1-A` — exact inventory | Closed | Enumerate every release-traceability unit exactly once. | 47 requirements, 474 scalar forms, 99 command forms, 109 tile operations, 72 system registers, 13 traps, 36 hooks, and 75 state roots are present with globally unique IDs. |
| `S6-T1-B` — links and boundaries | Closed | Attach PTO requirement, model, executable witness, and bounded status to every unit without turning instrumentation into ISA state. | All paths exist; 75 state roots expand to 235 leaf fields and classify architectural state, storage/ordering/effect abstractions, or verification-only state. |
| `S6-T1-C` — cumulative closure | Blocked by S5-T2 | Close every Stage 0–5 prerequisite and dependent requirement status. | S5-T2 closes; the 11 currently open requirement rows and 28 numeric hooks receive accepted conformance evidence. |
| `S6-T1-D` — claim-hygiene review | Waiting on C | Review one immutable candidate rather than a moving branch. | Reviewer identity, commit, date, and accepted disposition are all populated; no unsupported completeness claim remains. |
| `S6-T1-E` — promotion | Waiting on C–D | Close S6-T1 and unlock the cumulative release gate. | Generated ledger, maturity ledger, requirements, coverage, README, and review record agree on closure. |

### S6-T2 architecturally-complete gate plan

The generated `spec/evidence/release-gate-readiness.json` ledger prevents gate
configuration from being confused with a passing release candidate.

| Sub-stage | Current state | Clear target | Required exit evidence |
| --- | --- | --- | --- |
| `S6-T2-A` — gate inventory | Closed | Freeze all candidate, hosted, external-control, and review obligations. | Ten gates, ten controls, and two review perspectives are unique, complete, and path-valid. |
| `S6-T2-B` — execution topology | Closed | Prove the hosted workflow and parallel suite are bounded and exact. | Full action pins, contents-read permission, required `validate` aggregator, cancel-in-progress, 360-minute timeout, and 52 shards covering 113 calls/107 subprograms. |
| `S6-T2-C` — candidate freeze | Blocked by S5-T2/S6-T1 | Name one signed immutable candidate. | Closed cumulative prerequisites, candidate commit/tree identity, clean-tree and signature evidence. |
| `S6-T2-D` — candidate reproduction | Waiting on C | Execute every gate without moving the candidate. | Ten local results and passing hosted `validate` all name the candidate commit. |
| `S6-T2-E` — controls and approvals | Waiting on C–D | Prove repository controls and both review perspectives. | Content-addressed GitHub API snapshot plus accepted architecture and formal-model dispositions. |
| `S6-T2-F` — promotion | Waiting on C–E | Publish an M6 candidate without hidden exceptions. | All release surfaces and promotion metadata agree at the accepted commit. |

## Closure rule

- A target closes only when its own evidence package passes.
- Later-stage implementation does not retroactively close an earlier target.
- `docs/maturity-bringup-plan.md` explains the rationale and sequencing.
- `spec/evidence/maturity-closure.json` is the machine-readable source of truth
  for target state, evidence, and gaps.
- `spec/evidence/numeric-conformance-readiness.json` is the generated S5-T2
  source of truth for sub-stage dependencies, exact parallel-lane membership,
  evidence slots, and promotion readiness.
- `spec/evidence/numeric-profile-decision-proposals.json` is the generated
  S5-T2-A review package for four accepted identities, 12 proposed
  dispositions, 20 domain mappings, and the still-null result-rule acceptance
  records.
- `spec/evidence/scalar-numeric-flag-contract.json` is the generated PD-06
  state/lifecycle and producer-owner matrix. It closes 30 ownership rows and 11
  architecture-owned conditions while retaining 19 profile-owned conditions.
- `spec/evidence/numeric-rounding-selector-contract.json` is the generated
  accepted PD-03 contract. It closes discovery, namespace separation, tie
  behavior, translations, defaults, all 18 rounding points, and saturation
  order while leaving unrelated numeric dimensions open.
- `spec/evidence/numeric-format-namespace-contract.json` is the generated
  PD-02 namespace/carrier inventory. It closes structural ownership while
  handing its eight residuals to later PD-02 checkpoints.
- `spec/evidence/public-numeric-type-baseline.json` is the generated PD-02
  public identity/availability baseline. It closes 16 public identities, 16
  catalog bindings, and the two target partitions while retaining nine
  non-public catalog types and four legality, vector, parity, and review
  residuals.
- `spec/evidence/public-integer-conversion-contract.json` is the generated
  PD-07 bounded-result package. It closes three portable rules across 48
  unequal-width public integer `TCVT` tuples while keeping profile support and
  six conversion residuals explicit.
- `spec/evidence/numeric-profile-applicability-closure.json` is the generated
  PD-01 A2/A3 MX negative-applicability package. It closes 150 unsupported
  tuples and leaves result semantics open.
- `spec/evidence/numeric-variation-point-ownership.json` is the generated
  PD-12 discovery and decision-owner package. It closes 99-row ownership
  coverage with 16 selected rounding routes while retaining 73 open routes and
  every complete domain result rule.
- `spec/evidence/release-traceability-readiness.json` is the generated S6-T1
  source of truth for exact release inventory, link coverage, state-boundary
  classification, cumulative blockers, and immutable-commit review readiness.
- `spec/evidence/release-gate-readiness.json` is the generated S6-T2 source of
  truth for gate configuration, hosted/parallel topology, external controls,
  candidate results, approvals, and promotion readiness.

## Stage decision record

Use this record for manual review. Store a completed record in the applicable
tracking issue or release evidence package; do not edit a target to `closed`
without the matching evidence and reviewer disposition.

```text
Stage / target:
Candidate commit:
Entry gate: pass | fail
Inventory and decode evidence: pass | fail | not applicable
Architectural state/effect evidence: pass | fail | not applicable
Fault/restart evidence: pass | fail | not applicable
Ordering evidence: pass | fail | not applicable
Conformance/traceability evidence: pass | fail | not applicable
Cumulative regression gate: pass | fail
Open gaps and tracking records:
Reviewer and perspective: architecture | formal model | conformance | release
Decision: pass | fail | defer
Decision date:
```
