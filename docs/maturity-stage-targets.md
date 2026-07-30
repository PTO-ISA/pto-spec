# PTO ASL maturity stage and target index

This document is the compact navigation layer for PTO ASL maturity bring-up.
It splits the evaluation into stages, gives each stage a clear closure target,
and points to the detailed evidence ledger and rationale.

The authoritative detailed plan remains
[Maturity bring-up plan](maturity-bringup-plan.md). The authoritative state for
each target remains `../spec/evidence/maturity-closure.json`.

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

## Remaining bring-up sequence

The remaining work is ordered by promotion dependency. Work may run in
parallel, but a later row cannot waive an earlier promotion gate.

| Order | Target | Concrete bring-up result | Acceptance gate | Promotion unlocked |
| ---: | --- | --- | --- | --- |
| 1 | M4 regression floor | Preserve the closed 474 scalar, 107 bundle/command, 120 direct-tile, 72 system-register, and 13-trap inventories while later evidence is added. | Catalog/repository checks, deterministic generation, ASLRef shards, and all Stage 0–4 target evidence remain green. | Safe Stage 5 development |
| 2 | `S5-T2` | Name the PTO target numeric profile and an independent, versioned oracle; cover normal, boundary, exceptional, rounding, saturation, and accumulation cases for every applicable numeric-contract row. | Differential report has no unclassified mismatch and does not treat the `pto-v0` raw-carrier model as hardware arithmetic. | Numeric conformance half of M5 |
| 3 | `S5-T3` | Closed: the complete stable-ID comparison is regenerated from a clean content-addressed executable-model snapshot, all 701 dispositions remain classified, and every required gate result is archived. | Parser, executable backend, generated-status, coverage, architecture-contract, and documentation gates all pass. | Independent-comparison half of M5 |
| 4 | `S6-T1` | Produce fail-closed requirement-to-model-to-test traceability for accepted forms, registers, traps, visible state, and profile hooks. | No surface lacks a requirement, normative implementation path, executable witness, or bounded status claim. | Release review may start |
| 5 | `S6-T2` | Reproduce the candidate from a clean tree and obtain independent PTO architecture and formal-model approvals. | Clean regeneration, ASLRef, repository, publication, hosted CI, `git diff --check`, and recorded approvals all pass. | M6 architecturally-complete candidate |

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
| `S1-T5` | Execution paths | Closed | Bind all 120 direct-tile selectors to ordered semantic handlers and reject reserved selectors before effects. |
| `S2-T1` | State and faults | Closed | Define access, reset, and behavior classes for all 72 visible system registers. |
| `S2-T2` | State and faults | Closed | Define complete nonzero-seed reset for every architectural state field and all 16 ACR banks. |
| `S2-T3` | State and faults | Closed | Define producer, routing, saved context, recovery, and restart envelopes for all 13 traps. |
| `S2-T4` | State and faults | Closed | Define active or reserved architectural behavior for predicates P0–P7. |
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
| `S4-T7` | Bundle commands | Closed | All 107 forms have generated consumed-field and effect-or-rejection dispositions; bridge limitations are explicit and commit-fail-closed. |
| `S4-T8` | TEPL | Closed | ADR 0035 and `tepl-totality.json` close all 98 accepted selectors, 926 reserved selectors, carrier/layout rules, aliases, regions, indices, sort/merge, histogram, and management effects. |
| `S4-T9` | TMA | Closed | All nine selectors have decoded effects plus packed four-bit, duplicate-lane, event, restart, and first/middle/last preflight-fault evidence. |
| `S4-T10` | CUBE | Closed | All 13 selectors, 19 raw-carrier types, logical layouts/locations, aliases, and composite preflight are closed; hardware numeric conformance remains S5-T2. |

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
| `S5-T3` | Closed | The exhaustive 701-row disposition matrix is complete and all eight clean-snapshot repository gates plus the pinned Sail parser/C-backend gate pass. |

### S5-T2 numeric-conformance bring-up plan

`S5-T2` is intentionally split into promotion-ordered sub-stages. The
sub-stages are execution checkpoints, not new maturity claims: `S5-T2` remains
open, and the repository remains at M4, until every sub-stage below closes.

| Sub-stage | Current state | Clear target | Required exit evidence |
| --- | --- | --- | --- |
| `S5-T2-A` — profile decision | Open | Name and version each numeric target profile. Separate portable rules from A2/A3-, A5-, or other target-specific rules instead of treating the `pto-v0` raw-carrier reference as hardware arithmetic. | Accepted architecture decision defining formats, rounding modes, exceptional values, subnormals, flags, saturation, accumulation widths, and implementation-defined dimensions for every applicable numeric-contract domain. |
| `S5-T2-B` — oracle qualification | Waiting on A | Select an independent, versioned oracle for each lane. The implementation under test and the `pto-v0` reference are not independent oracles. | Reproducible oracle identity, version/digest, invocation, supported domain list, known limitations, and a reviewer-approved rule for any target behavior that requires hardware capture rather than a software arithmetic library. |
| `S5-T2-C` — vector corpus | Waiting on A–B | Generate deterministic inputs for every operation and every open numeric dimension. | Normal, minimum/maximum, boundary, signed-zero, subnormal, infinity, NaN, tie, overflow, underflow, divide-by-zero, rounding, saturation, reduction-order, and accumulation cases as applicable; each vector links to one operation key, profile, oracle, and expected disposition. |
| `S5-T2-D` — differential execution | Waiting on B–C | Run the six numeric lanes independently and preserve raw oracle and PTO results. | All 20 contract domains, 29 hooks, and 108 operations are assigned exactly once; every vector produces a reproducible match, mismatch, unsupported, or implementation-defined record; no lane is missing or duplicated. |
| `S5-T2-E` — mismatch adjudication | Waiting on D | Resolve every differential result without silently changing PTO semantics to match an external implementation. | Zero unclassified results. Each mismatch is fixed as a PTO defect, accepted as a target-profile rule, rejected as an oracle limitation, or bounded by an architecture decision with regression evidence. |
| `S5-T2-F` — promotion | Waiting on A–E | Freeze the conformance package and promote Stage 5 only after independent review. | Clean-tree reproduction, immutable profile/oracle/vector/result identities, repository gates, numeric-architecture approval, formal-model approval, and an updated closure ledger with no remaining `S5-T2` gaps. |

The sub-stages may prepare independent artifacts concurrently, but promotion is
strictly ordered: profile scope controls oracle selection; profile and oracle
scope control vector expectations; results cannot be adjudicated before the
corresponding oracle and vector identities are frozen.

#### Parallel numeric lanes

These lanes partition the closed `S5-T1` inventory exactly once. Counts are
closure invariants: future inventory changes must update the numeric-contract
ledger and this plan together before conformance execution.

| Lane | Contract domains | Operations | Hooks | Required numeric focus |
| --- | --- | ---: | ---: | --- |
| N1 — scalar arithmetic | `scalar-binary`, `scalar-unary`, `scalar-fused` | 11 | 4 | arithmetic and fused precision, elementary functions, rounding, flags, signed zero, subnormals, NaN, infinity, overflow, and underflow |
| N2 — scalar conversion | `scalar-fp-to-integer`, `scalar-fp-convert`, `scalar-integer-to-fp` | 8 | 4 | format mapping, signedness, all rounding directions, inexact results, out-of-range behavior, saturation or indefinite results, and exception flags |
| N3 — tile elementwise | `tile-binary`, `tile-unary`, `tile-axpy`, `tile-prelu`, `tile-compare`, `tile-expand` | 53 | 11 | carrier interpretation, transcendental helpers, comparison ordering, divide/domain errors, multiply-add precision, rounding, saturation, and exceptional values |
| N4 — tile conversion | `tile-convert`, `cube-convert`, `tile-quantize`, `tile-dequantize` | 4 | 3 | source/destination formats, scale and zero point, rounding, clamping, NaN payloads, overflow, and underflow |
| N5 — reductions and ordering | `tile-reduction`, `tile-partial`, `tile-order` | 20 | 4 | accumulation width and order, tie-breaking, stability, NaN placement, signed zero, partial-result precision, and ascending/descending behavior |
| N6 — matrix arithmetic | `cube-matrix` | 12 | 3 | product precision, accumulation width, bias and MX scaling, rounding, saturation, NaN, infinity, overflow, and underflow |
| **Total** | **20 domains** | **108** | **29** | **Complete `S5-T1` numeric inventory** |

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
| `S6-T2` | Open | Pass clean regeneration, ASLRef, repository, publication, and independent architecture/formal review gates. |

## Closure rule

- A target closes only when its own evidence package passes.
- Later-stage implementation does not retroactively close an earlier target.
- `docs/maturity-bringup-plan.md` explains the rationale and sequencing.
- `spec/evidence/maturity-closure.json` is the machine-readable source of truth
  for target state, evidence, and gaps.
