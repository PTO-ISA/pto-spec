# PTO ASL maturity bring-up plan

## Purpose

This plan converts the formal-model maturity evaluation into ordered closure
stages. It is a delivery plan, not a claim that the listed behavior is already
architectural. Normative behavior continues to come from the ASL, catalogs,
accepted architecture decisions, and requirement records.

For a compact stage map and target register, see
[Maturity stage and target index](maturity-stage-targets.md).

The current repository has strong mechanical closure: the accepted catalogs
generate, ASLRef type-checks the model, and executable tests pass. The remaining
work is architectural closure: proving that every accepted operation has the
intended visible effect, fault behavior, ordering, and conformance evidence.

## Maturity model

Stages are cumulative. A stage closes only when all of its exit criteria pass;
work may be developed in parallel, but the repository does not claim the next
maturity level early.

| Level | Meaning | Release claim permitted |
| --- | --- | --- |
| M0 — mechanically closed | Catalogs, generators, type checking, and current executable tests are green. | Normative draft |
| M1 — execution-path closed | Every accepted form reaches its intended architectural effect or an explicit unsupported result. | Executable draft |
| M2 — state-and-fault closed | State invariants, reset, status, faults, and restart behavior are total and consistent. | Architecture bring-up |
| M3 — ordering closed | Production memory operations generate and obey the normative memory-order events. | Memory-model candidate |
| M4 — reference-semantics closed | Every instruction group is total under the named PTO v0 reference profile. | Reference-model candidate |
| M5 — conformance closed | Independent evidence validates intended PTO behavior and any named hardware/numeric profile. | Conformance candidate |
| M6 — architecturally complete | All prior gates, traceability, review, and publication requirements close together. | Architecturally complete candidate |

The mechanical starting point was **M0**. The current cumulative floor is
**M4**: Stages 0 through 4 are closed, while numeric and independent-model
conformance remain open in Stage 5. Passing `make ci` is necessary at
every level but does not by itself prove a maturity promotion.

`specification.toml` records the highest demonstrated maturity floor. The stage
status in this document records delivery progress toward the next release gate.
The machine-readable maturity ledger under `spec/evidence/` records every target
owner, affected requirement, evidence path, tracking issue or ADR, classified
gap, and acceptance evidence. A stage closes only through its stage-specific
evidence; a later implementation does not waive an earlier gate.

### How levels and stages differ

- A **maturity level** is the strongest cumulative claim the repository may
  publish.
- A **bring-up stage** is a work package that produces evidence for one or more
  maturity levels.
- A **target** is the smallest unit that receives an owner, requirements,
  implementation, tests, and a closure decision.

Stages may finish out of order when their prerequisites are already available,
but maturity remains cumulative. Closing the Stage 0 ownership and claim ledger
therefore promoted the already-demonstrated Stage 1 through Stage 3 packages
together, establishing the previous M3 floor; Stage 4 closure now establishes
the current M4 floor.

### Evaluation dimensions and closure rule

Every target is evaluated across the same seven dimensions. A target is closed
only when every applicable dimension has evidence; a generated decoder or a
green aggregate test cannot substitute for missing semantic evidence.

| Dimension | Closure question | Minimum evidence |
| --- | --- | --- |
| Inventory | Is every accepted form, selector, register, state field, and profile hook accounted for? | Stable machine-readable IDs and fail-closed counts |
| Decode and legality | Does each legal encoding select exactly one operation, and does each reserved encoding reject before effects? | Positive, overlap-priority, constraint, and reserved-code witnesses |
| Operand binding | Does every operation-bearing field reach the intended semantic parameter with the specified width and signedness? | Generated operand-to-handler assertions and boundary encodings |
| Architectural effect | Are all visible destination, status, TPC, queue, tile, register, and context changes defined? | Before/after state tests with source-preservation and alias cases |
| Fault and restart | Are precedence, trap routing, no-partial-effect behavior, and reissue rules total? | Injected-fault matrices and recovery traces |
| Ordering | Do memory operations emit the required events and obey the selected PTO ordering rules? | Production event extraction and allowed/forbidden litmus outcomes |
| Conformance and traceability | Can each PTO rule be traced to a requirement and independently checked without importing another ISA as authority? | Requirement links, pinned comparison evidence, differential results, and reviewed dispositions |

The status vocabulary is deliberately strict:

- **Open:** the closure package has not started.
- **In progress:** some dimensions have evidence, but at least one required
  dimension is missing or a PTO decision remains unresolved.
- **Blocked:** the exact missing architecture or profile decision is named and
  linked; implementation work alone cannot close it.
- **Closed:** the complete evidence package passes and no listed residual risk
  contradicts the target claim.

### Stage roadmap

| Stage | Primary result | Targets | Exit product | Current status |
| --- | --- | --- | --- | --- |
| 0 — baseline | One honest and consistent gap ledger | `S0-T1`–`S0-T3` | Reviewed coverage, status, and decision inventory | Closed |
| 1 — execution paths | Every accepted encoding reaches an operation-bearing effect | `S1-T1`–`S1-T5` | Decoded before/after effect matrix | Closed |
| 2 — state and faults | Every visible state field resets, transitions, traps, and recovers precisely | `S2-T1`–`S2-T6` | State-invariant and fault/restart matrix | Closed |
| 3 — ordering | Production memory operations populate the PTO-TSO domain | `S3-T1`–`S3-T2` | Event-extraction and litmus suite | Closed |
| 4 — instruction semantics | Every instruction family is total under `pto-v0` | `S4-T1`–`S4-T10` | Per-family legality/effect/fault closure reports | Closed |
| 5 — conformance | Numeric and target-dependent results have independent evidence | `S5-T1`–`S5-T3` | Versioned conformance and ISA-comparison reports | In progress |
| 6 — release | All claims and artifacts close together | `S6-T1`–`S6-T2` | Architecturally-complete release evidence | Open |

## Current closure snapshot

| Stage | Status | Demonstrated evidence | Blocking evidence |
| --- | --- | --- | --- |
| Stage 0 | Closed | Catalog counts, deterministic generation, ASLRef gates, maturity vocabulary, and the fail-closed ownership/classification ledger are explicit and checker-enforced. | No Stage 0 target remains open; the ledger retains all Stage 4–6 gaps and promotion evidence. |
| Stage 1 | Closed | `S1-T1` and `S1-T2` close exact bundle-start descriptors, transactional commit, direct tile launch, timing, and rollback. `S1-T3` closes stable form-ID decoded before/after evidence for all 474 scalar forms across AGU, ALU, AMO, BRU, FSU, and SYS. `S1-T4` closes the shared scalar/command/tile execution-attempt status, one-tick, stale-fault isolation, trap-preservation, and legality no-effect contract. `S1-T5` closes selector-to-handler and operand binding for all 120 direct-tile operations. | No Stage 1 target remains open; deeper family totality remains in Stages 4–5. |
| Stage 2 | Closed | The 72-register behavior and all-bank reset contract (`S2-T1`), complete nonzero-seed architectural reset (`S2-T2`), all 13 trap dispositions and extended recovery envelopes (`S2-T3`), P0 producer/consumer and P1..P7 reserved-state contract (`S2-T4`), precise tile capacity/storage (`S2-T5`), element-level definedness, and explicit tile handoff (`S2-T6`) execute. | No Stage 2 target remains open; later instruction-family and ordering refinements remain in Stages 3–5. |
| Stage 3 | Closed | Production scalar, DMA, atomic, fence, tile, gather-CAS, and tile-prefetch paths emit the normative PTO-TSO stream; atomic, reservation, prefetch, and mixed-size corners have executable decisions. | No Stage 3 target remains open; byte-level mixed-size coherence is an explicit future extension, not an unclassified gap. |
| Stage 4 | Closed | All scalar, bundle, TEPL, TMA, and CUBE targets have checked selector/form inventories, legality, state/effect, alias, boundary, and pre-effect rejection evidence under `pto-v0`. | No Stage 4 target remains open; target numerical conformance remains in Stage 5. |
| Stage 5 | In progress | The checked numeric-contract matrix owns all 19 scalar and 89 direct-tile operations that cross 29 numeric hooks. ADR 0037 closes four numeric identities and five fail-closed selection rules; all 12 numeric decision dispositions and all 20 domain mappings have review proposals. The exhaustive 701-row executable-model matrix closes every stable-ID disposition, records all model limits, and archives a clean snapshot with all eight repository gates plus the pinned Sail parser/C-backend gate passing. | No numeric result decision or domain rule is accepted and no independent hardware/numeric oracle is closed. |
| Stage 6 | Open | The generated S6-T1 ledger closes exact traceability inventory/link coverage across 937 units. The generated S6-T2 ledger closes the ten-gate contract, hosted workflow policy, and exact 34-shard/98-call/86-subprogram topology. | S5-T2 leaves nine requirements and 29 hooks open; no immutable candidate, complete local/hosted results, protected-branch snapshot, or architecture/formal approvals exist. |

Update this table only from the exit evidence defined below. A stage may move to
closed only when all of its exit criteria are satisfied.

### Quantitative scorecard

The scorecard counts closed targets, not files or tests. It is the shortest
honest view of bring-up progress; the detailed target register remains the
authority for why a target is or is not closed.

| Stage | Closed targets | Total targets | Promotion blocker |
| --- | ---: | ---: | --- |
| 0 — baseline | 3 | 3 | None |
| 1 — execution paths | 5 | 5 | None |
| 2 — state and faults | 6 | 6 | None |
| 3 — ordering | 2 | 2 | None |
| 4 — instruction semantics | 10 | 10 | None |
| 5 — conformance | 2 | 3 | An independent numeric oracle and complete differential report |
| 6 — release | 0 | 2 | Cumulative closure and independent review |
| **Total** | **28** | **31** | Maturity is M4; Stage 5 numeric conformance blocks M5 |

## Bring-up target register

The following target IDs are the units of planning, review, and closure. Each
target must have one accountable owner, linked requirement or architecture-
decision records, implementation changes, and executable evidence before it can
be marked closed.

Status is evidence-based: **closed** means the listed evidence exists and passes;
**in progress** means some implementation or evidence exists but the closure
target is not met; **blocked** names the missing decision that prevents further
closure; **open** means no closure claim is made.

| Target | Stage | Status | Measurable closure target | Required evidence |
| --- | --- | --- | --- | --- |
| `S0-T1` | 0 | Closed | Freeze and regenerate the 474 scalar, 107 bundle/command, and 120 direct-tile accepted-form inventories. | Deterministic generation diff, catalog checks, positive and reserved-code witnesses |
| `S0-T2` | 0 | Closed | Classify every known gap as a specification defect, architecture decision, profile decision, ASLRef limitation, evidence gap, or release-governance obligation. | `spec/evidence/maturity-closure.json` links every open item to an owner, requirements, issue/ADR, and acceptance evidence; `scripts/check-catalogs` fails closed on drift |
| `S0-T3` | 0 | Closed | Make README, coverage, profile metadata, requirement status, and maturity claims describe the same demonstrated floor. | Checker-enforced M4 status and target reconciliation across all maturity surfaces |
| `S1-T1` | 1 | Closed | Bind all 71 bundle-start forms to an operation-bearing descriptor or an explicit pre-state unsupported result; no decoded selector or modifier is discarded. | ADR 0022; generated exact-form descriptor witnesses; DataType, selector, Mode, and BrType sensitivity; reserved selector/type/family no-install tests |
| `S1-T2` | 1 | Closed | Give bundle start, header append, and stop one tested lifecycle and connect a legal descriptor to exactly one tile operation. | ADR 0022; start/B.IOT/BSTOP and next-BSTART traces; single time increment; missing binding, type mismatch, invalid-next-start, trap preservation, and tile no-partial-effect tests |
| `S1-T3` | 1 | Closed (474/474) | Give all accepted scalar forms a tested TPC, status, operand, and architectural-effect path. Fifty-one stable form-ID classes and generated witnesses cover all 183 AGU, 107 ALU, 66 BRU, 53 AMO, 30 FSU, and 35 SYS forms. | Fail-closed class, address-kind, update-mode, generated-witness, and full-suite gates |
| `S1-T4` | 1 | Closed | Use one execution-status and fault contract across scalar, bundle, and tile dispatch. | ADR 0023; fresh-attempt latch reset without trap-bank clearing; exact one-tick assertions; unified/scalar/command/tile success and rejection; unknown/constraint/legality preservation; stale-fault and visible-trap survival tests |
| `S1-T5` | 1 | Closed | Bind all 120 accepted direct-tile selectors to the intended semantic handler and ordered operands, with reserved selectors rejected before effects. | Catalog-to-ASL handler checks, ordered operand assertions, generated exact-selector execution witnesses, reserved-selector rejection, and the shared execution-attempt contract |
| `S2-T1` | 2 | Closed | Resolve the visible system-register inventory: model the 70 source-reconciled baseline registers, including 18 `EBARG` registers, plus PTO `THREAD_ID` and `TILE_CAPACITY`, or document each deliberate exclusion in an accepted ADR. | ADR 0017, machine-readable behavior classes, generated reference, all-bank access/reset witnesses, and source-reconciliation record |
| `S2-T2` | 2 | Closed | Define reset for all 16 ACR banks and every visible core, thread, predicate, bundle, tile, reservation, memory-event, fault, trap, and saved-context field. | ADR 0010 plus nonzero-seed reset tests for lowest/highest register, bank, predicate, binding, tile, and context boundaries |
| `S2-T3` | 2 | Closed | Define all 13 trap producer envelopes or explicit PTO v0 no-trigger dispositions, causes, target-ACR routing, saved context, recovery, and restart behavior. | ADR 0018, machine-readable trap dispositions, per-trap routing/cause tests, and fault-injection recovery tests |
| `S2-T4` | 2 | Closed | Define architectural use or reserved behavior for predicates `P0`–`P7`; no visible predicate remains accidental state. | ADR 0019 plus body-entry producer, P0-only consumer, P1..P7 reserved-state, trap preservation, and reset tests |
| `S2-T5` | 2 | Closed | Enforce nonzero per-tile and aggregate capacity against `TILE_CAPACITY`, including shape/storage bounds and sub-byte formats. | ADR 0013 plus zero/minimum/maximum/exact-fit/overflow/reconfiguration/allocation-sequence tests |
| `S2-T6` | 2 | Closed | Define element contents, valid-region definedness, generic layout rejection, explicit handoff management, source lifetime, ordering, and alias rules. | ADRs 0014–0015 plus undefined/partial-write/reduction/layout/alias and decoded push/pop/full/empty/capacity/multi-slot tests |
| `S3-T1` | 3 | Closed | Emit normative PTO-TSO events from every production scalar and tile load, store, atomic, and fence path. | ADR 0020 plus event-kind/address/size/agent/order/program-order assertions for scalar singles/pairs, LR/SC, RMW/CAS, DMA, fences, and every TMA access class |
| `S3-T2` | 3 | Closed | Close acquire/release, reservation granule, failed-SC probe, gather-CAS, and mixed-size decisions. | ADR 0020 plus allowed/forbidden litmus, 64-byte boundary/cross-width/no-probe tests, conditional-atomic witnesses, tile-prefetch distinction, and overlap-boundary rejection |
| `S4-T1` | 4 | Closed | Close AGU address classes, scaling, pair accesses, update modes, preflight, writeback, prefetch, and restart. | ADRs 0024 and 0029; 1,464 decoded boundary/fault/restart cases, 4,296 decoded alias cases, 360 retained Stage 1 cases, and a reviewed independent executable-model comparison |
| `S4-T2` | 4 | Closed | Close ALU widths, arithmetic corners, shifts, bitfields, rearrangement, and source/destination aliases. | 337 raw decoded boundary cases cover all 107 ALU forms; 35 decoded alias cases cover GPR overlap, discard codes, all T/U sources, queue pushes, and ordered pair destinations; ADRs 0025–0026 and an independent executable ISA/model comparison record the reviewed contracts |
| `S4-T3` | 4 | Closed | Close AMO values, widths, conditional writes, translated location identity, and reservation-visible effects. | ADR 0030; `scalar-amo-totality.json`; 2,474 unique decoded Stage 4 attempts plus 66 retained Stage 1 attempts; readonly probe hooks; reviewed independent comparison disposition; closed Stage 3 ordering evidence |
| `S4-T4` | 4 | Closed | Close BRU conditions, targets, fallthrough, links, returns, alignment, and bundle interaction. | ADRs 0021 and 0027; 284 decoded totality cases over all 66 forms; 32 decoded Reg5 alias, predicate-domain, bundle-preservation, ignored-`SrcZero`, and fault obligations; publication-safe independent comparison disposition |
| `S4-T5` | 4 | Closed | Close FSU carrier widths, operand legality, comparisons, conversions, sticky flags, and explicit numeric-profile boundaries. | ADR 0028; 2,270 decoded totality cases, including every source/destination type and Reg5 topology; 35 direct sticky-flag cases; numerical conformance remains owned by Stage 5 |
| `S4-T6` | 4 | Closed | Close SYS register access, fence, maintenance, request, ACRE, ACRC, and context-control instruction effects. | ADR 0031; `scalar-sys-totality.json`; 4,401 unique Stage 4 attempts plus 35 retained Stage 1 effects; closed 72-register and 13-trap contracts |
| `S4-T7` | 4 | Closed | Replace every bundle-command placeholder, truncated operand, fixed-zero surrogate, and unused binding with a defined effect or explicit rejection. | ADR 0032; generated 107-form consumed-field/effect matrix; exact 95 executed/12 rejected dispositions; checked 63/1/5 bundle-to-tile representability; decoded retirement and rollback tests |
| `S4-T8` | 4 | Closed | Close TEPL legality, valid-region effects, layouts, aliases, exceptional values, and management behavior. | ADR 0035; exact 98/926 accepted/reserved selector partition; deterministic decoded state matrix; 19 raw-carrier types; alias, preserved-region, invalid-index, sort/merge, histogram, and management evidence; numeric conformance remains S5-T2 |
| `S4-T9` | 4 | Closed | Close TMA precise accesses, masks, restart, atomicity, ordering, fault precedence, and sub-byte transfer disposition. | ADR 0033; all-nine decoded-selector matrix; packed nibble, duplicate-index, masked, CAS, event, and first/middle/last fault-preflight evidence |
| `S4-T10` | 4 | Closed | Close CUBE type/shape combinations, accumulation, rounding, saturation, aliases, and composite preflight. | ADR 0034; all-13 decoded selector matrix; all-19 raw-carrier types; mixed layout/location, alias, and composite no-partial-effect matrices; numeric conformance remains S5-T2 |
| `S5-T1` | 5 | Closed | Inventory every operation whose result depends on numeric behavior beyond the raw-carrier reference profile. | Checked `spec/evidence/numeric-contracts.json`: 19 scalar forms, 89 direct-tile operations, 29 hooks, an owner per row, and explicit `S5-T2` conformance obligations |
| `S5-T2` | 5 | Open | Validate PTO numeric behavior against a named independent oracle without importing third-party semantics as PTO authority. | Generated readiness ledger partitions all 20 domains, 29 hooks, and 108 operations exactly once; ADR 0037 and the identity catalog close the identity/selection framework; the decision-input ledger exposes 12 unresolved questions from 24 pinned public sources; the proposal ledger maps every question and domain while leaving result rules open; closure requires accepted profile decisions, populated profile/oracle/vector/result/review evidence, and a complete differential report |
| `S5-T3` | 5 | Closed | Cross-check every shared scalar mnemonic and architectural pattern against a pinned independent executable ISA model, then resolve each difference as a PTO rule, profile difference, defect, or intentional non-equivalence. | The 701-row publication-safe disposition matrix is complete; the clean content-addressed snapshot passes all eight repository gates and the pinned Sail parser/C-backend gate |
| `S6-T1` | 6 | Open | Prove requirements-to-model-to-test traceability with no unsupported completeness claim. Exact inventory and link sub-stages are closed over 937 units; cumulative closure and review remain open. | Generated release-traceability readiness ledger; closed S5-T2-dependent requirement statuses; immutable-commit evidence-hygiene review |
| `S6-T2` | 6 | Open | Pass clean regeneration, ASLRef, repository, publication, protected-branch, and independent architecture/formal review gates. Gate-contract and topology sub-stages are closed; candidate execution and approval remain open. | Generated release-gate readiness ledger; clean `make ci`; `git diff --check`; hosted `validate`; GitHub control snapshot; recorded approvals at one signed commit |

### Delivery order and dependencies

1. Close `S0-T1` through `S0-T3` before raising any maturity claim.
2. Close Stage 1 before relying on generated dispatch as semantic evidence.
3. Close Stage 2 state and fault contracts before Stage 3 ordering or Stage 4
   instruction results can be called precise.
4. Develop Stages 3 and 4 in parallel only where the state/fault dependencies
   are already closed; memory operations require both stages.
5. Stage 5 may inventory numeric operations early, but conformance closes only
   after the corresponding Stage 4 operation is total.
6. Stage 6 is a release gate and cannot waive an earlier open target.

### Open decision register

These decisions block target closure. Comparison models are evidence for the
question, not authority for the PTO answer. Close a row only by accepting a PTO
ADR or profile contract and adding the named executable witnesses.

The complete gap inventory is machine-readable in
`spec/evidence/maturity-closure.json`. It classifies specification defects,
architecture decisions, profile decisions, evidence gaps, ASLRef limitations,
and release-governance obligations separately. This table lists only unresolved
cross-family normative decisions.

| Decision | Blocks | Classification | Required PTO decision | Closure witness |
| --- | --- | --- | --- | --- |
| `MD-08` | `S5-T2` | Profile decision | Resolve all 12 questions in the numeric profile decision register, including formats, rounding, FTZ, special values, flags, conversions, accuracy, reductions, quantization, matrix arithmetic, and bounded implementation-defined behavior. | Accepted decisions populate every domain rule in `numeric-profile-decision-inputs.json`; named target profiles and independent-oracle vectors then populate every readiness-lane evidence slot |

Resolved decisions: ADR 0017 closes the former `MD-01` translation-register
classification by making it explicit storage-only behavior in `pto-v0`. ADR
0018 closes former `MD-02` through `MD-04` with complete entry envelopes and
explicit no-trigger dispositions for unsupported PTO v0 sources. ADR 0019
closes former `MD-06` with an active P0 contract and reserved P1..P7 behavior.
ADR 0020 closes former `MD-07` with production event extraction and owned
atomic, reservation, prefetch, gather-CAS, and mixed-size dispositions.
ADR 0022 closes former `MD-05` with an exact bundle descriptor, decoded-field
sensitivity, transactional installation, and reserved-combination rollback.
ADR 0028 removes `S4-T5` from `MD-08`: scalar raw-carrier reference semantics
are total, while target numerical conformance remains an `S5-T2` obligation.
ADRs 0034–0035 apply the same boundary to CUBE and TEPL: their portable
legality and raw-carrier effects are closed in Stage 4, while named-target
numeric conformance remains owned solely by `S5-T2`.
ADR 0037 closes the identity and fail-closed selection framework portion of
`MD-08`; complete format, operation/type, result, and bounded-variation rules
remain open across all 12 questions and 20 numeric domains.

## Stage 0 — establish an honest closure baseline

**Target:** make the repository's maturity claims match demonstrated behavior.

Deliverables:

- Record every gap in this plan or a linked formal-model issue with an owner,
  affected requirement IDs, and acceptance evidence.
- Reconcile `docs/coverage.md` and `specification.toml` with the distinction
  between generated reachability, reference-profile behavior, and validated
  architecture semantics.
- Classify each unresolved point as a specification defect, architecture
  decision, profile decision, ASLRef limitation, or evidence gap.
- Preserve the current catalog baseline: 474 scalar forms, 107 bundle/command
  forms, 120 direct tile operations, 72 system registers, and 13 trap numbers.

Exit criteria:

- No area is marked complete solely because its mnemonic, decoder case, or
  handler name exists.
- Every later-stage target has a traceable issue or accepted architecture
  decision.
- `make repo-check` and `git diff --check` pass.

## Stage 1 — close decoded execution paths

**Target:** make accepted encoded forms observably distinct where the ISA says
they are distinct.

### Bundle and tile launch

- Define an architectural bundle descriptor containing the operation-bearing
  fields needed by `BSTART`, including tile opcode, function, data type, mode,
  branch type, targets, and transfer behavior.
- Bind all 71 bundle-start forms to that descriptor.
- Connect bundle start and bundle-body execution to exactly one recognized tile
  semantic operation, or return an explicit unsupported/rejected result without
  partial state changes.
- Prove that unknown and reserved combinations raise the specified fault before
  changing bundle or tile state.

`S1-T1` and `S1-T2` are closed by ADR 0022 and executable evidence. Generated
witnesses now select each intended command row through the real mask-priority
decoder, then assert every descriptor field for all supported starts. The
unsupported FIXP family and generic CUBE holes reject before installation.
Multi-command traces prove sequential header traversal, BSTOP and next-BSTART
commit, one direct tile effect, one time increment per decoded command, and
destination preservation on failure.

### Scalar and global dispatch

- Define the sequential TPC rule for ordinary scalar instructions and the
  fall-through rule for control-flow instructions.
- Use one documented execution-status contract across scalar, bundle, and tile
  dispatch for success, rejection, and architectural fault.
- Replace unreachable or misclassified status/fault branches, including scalar
  register-legality failures currently reported as tile-legality faults.

`S1-T4` is closed by ADR 0023. Every public decoded boundary now begins one
fresh attempt, resets only the transient fault result, advances time once, and
uses the same executed-versus-rejected meaning. The internal no-time tile path
is reserved for bundle composition. Cross-dispatch tests prove success,
unknown encoding, constrained command, tile-legality, stale-fault isolation,
trap-record preservation, and no destination mutation.

`S1-T3` now has a stable form-ID effect ledger under
`spec/evidence/scalar-effect-closure.json`, following the same fail-closed
inventory discipline used by independent executable ISA models. Seven closed
classes contain all 107 ALU forms: scalar binary, arithmetic, pair-result,
bitfield, materialization, select, and control effects. Six additional classes
contain all 66 BRU forms: comparison, commit, branch, jump, PC-relative value,
and return-address effects. Generated decoded
witnesses calculate expected results independently, bind every encoded operand
to its visible effect, and check destination and source state, TPC increment,
status, fault result, and one time tick. The audit corrected the handler
identity of `MADDW`, `HL.LUI`, `C.MOVI`, `C.MOVR`, and `C.SETRET`; select
witnesses cover both predicate outcomes, and divide tests cover zero divisors
and signed-overflow behavior at both widths. No remaining form is promoted
merely from mnemonic or handler presence.

BRU witnesses execute every comparison, commit condition, and conditional
branch in both directions, including signed/unsigned and logical forms. They
also cover the compressed T-queue result, decoded `B.Z`/`B.NZ` precedence of P0
over an opposing commit argument inside bundle bodies, relative and register
targets, sequential TPC behavior, matching R10/bundle return state, and precise
odd-target register-jump fault recovery.

Seven additional effect classes close all 53 AMO forms: load-reserved,
store-conditional, swap, compare-and-swap, load-return RMW, store-only RMW, and
DMA. Generated witnesses independently calculate width-specific old and new
values, execute both conditional outcomes, and check reservation, memory,
destination, event, TPC, fault, and time state. This decoded-effect promotion
uses the already closed Stage 3 ordering and reservation contracts as
supporting evidence; it does not treat a mnemonic or shared handler as proof of
an architectural effect.

Ten additional effect classes close the Stage 1 decoded path for all 30 FSU
forms while preserving the numeric boundary. The witnesses prove PTO-v0
raw-carrier results, width normalization, comparison outcomes, NaN and
signed-zero selection rules, sticky NV/DZ flags, rejected source/destination
types, TPC, status, and time. They do not promote the raw carrier to a complete
floating-point profile; exhaustive raw corners are closed by `S4-T5`, and
correctly rounded/profile conformance remains Stage 5. The audit also aligned rounding
codes 1 and 2 with `FCVTM` (toward negative infinity) and `FCVTP` (toward
positive infinity), and documented that reserved active modes 5–7 select
nearest in PTO v0.

Thirteen additional classes close the Stage 1 decoded path for all 35 SYS
forms: system-register read/write/swap, cache and TLB maintenance, execution
requests, breakpoints, data and instruction fences, ASSERT, ACRC, ACRE, and
commit-target state. Generated witnesses bind each form to its current PTO
register, epoch, request, reservation, event, trap, or recovery effect and
exercise representative success and rejection paths. This promotion records
`SETC.TGT` as a source-value transfer and PTO-v0 cache operands as accepted
epoch-only hints. Stage 4 SYS closure now fixes cache/TLB scope and privilege,
nonblocking scheduling handoffs, ACRE type-0/type-1 equivalence, ACRC's
instruction-local boundary, and the explicit storage-only translation/debug
profile disposition in ADR 0031.

The final eight classes close all 183 AGU forms and complete `S1-T3`. Every
form has an independently calculated effective address and visible
load/store/pair/writeback/prefetch effect, plus event, source, TPC, status,
fault, no-partial-effect, and time evidence. The matrix freezes 98 immediate,
59 register, 22 PC-relative, and four compressed forms together with 117
non-writeback, 33 pre-index, and 33 post-index forms. PC-relative witnesses set
TPC bit 1 to prove the aligned base from ADR 0024; all six register
`HL.SH/SW/SD.UPR/UPO` witnesses use a nonzero offset that proves their unscaled
PTO disposition.

### Direct tile dispatch

`S1-T5` closes the execution-path layer for all 120 accepted direct-tile
selectors. Catalog checks prove exact selector identity, handler reachability,
and ordered operand binding; generated witnesses execute every accepted
selector through the public dispatch boundary. Reserved selectors reject before
architectural effects. This target proves dispatch-path identity, not the
per-operation numeric and corner-case totality owned by `S4-T8` through
`S4-T10`.

### Evidence

- Add decoded effect tests that check operands and before/after state, not only
  decode status.
- Cover every semantically distinct equivalence class across all 474 scalar
  forms, 107 command forms, and 120 tile selectors.
- Keep positive witnesses for every accepted form and negative witnesses for
  every reserved or constrained encoding.

Exit criteria:

- Every accepted catalog row has all five closure layers: catalog identity,
  decode witness, reachable semantic primitive, decoded operand-to-effect
  binding, and executable feature evidence.
- No operation-bearing field is decoded and then silently ignored.
- PC and execution status have one tested architectural contract.

## Stage 2 — close architectural state, capacity, and faults

**Target:** make every visible state transition legal, resettable, and precise.

### Tile state

- Enforce per-tile capacity and the sum of active tile capacities against the
  read-only `TILE_CAPACITY` system register.
- Reject zero capacity and descriptors whose shape, valid region, or element
  storage exceeds their allocation.
- Keep tile contents undefined after allocation or reconfiguration until an
  architectural write defines the affected elements.
- Define whether a write marks the whole valid region or only written elements
  as defined; reductions and histogram operations must not expose unwritten
  data.
- Specify distinct `TPUSH` and `TPOP` source/destination effects, source
  lifetime, queue ordering, and capacity checks.
- Keep implementation-defined layouts configurable, while generic row/column
  indexing rejects them.
- State the architectural storage rule for sub-byte element formats instead of
  relying on the ASL payload representation.

### System, trap, and reset state

- Give each of the 72 visible system registers explicit read, write, access,
  reset, and side-effect behavior; use generic backing storage only where the
  architecture explicitly defines storage-only behavior.
- Reset every ACR/context bank and extended register address, not only the
  ring-zero subset.
- Define observable behavior for translation, interrupt, timer, debug,
  maintenance, and control requests.
- Define failed recovery/entry behavior and preserve the first architectural
  fault without partial effects.
- Make scalar, bundle, and tile runtime faults report consistent status, TPC,
  trap bank, and restart state.

Exit criteria:

- Tile allocation and management tests cover zero, minimum, maximum, aggregate
  capacity, reconfiguration, aliasing, undefined reads, and implementation-
  defined layouts.
- Every visible register and trap bank has reset and access witnesses.
- All multi-effect fault tests prove no partial architectural effect and full
  reissue restartability where required.

## Stage 3 — connect PTO-TSO to instruction execution

**Target:** make the executable memory model describe production instruction
effects, not a test-only event graph.

Deliverables:

- Emit load, store, atomic, and data-fence events from scalar and tile memory
  semantics through the same architectural event interface used by the
  PTO-TSO model.
- Apply `aq` and `rl` bits to atomic ordering and prove relaxed, acquire,
  release, and acquire-release cases.
- Define reservation size and overlap precisely; prove LR/SC success and
  failure for same-granule but different-size and different-address accesses.
- Decide whether a failed SC performs translation, permission, and alignment
  probes; model the chosen rule explicitly.
- Align scalar and tile prefetch fault behavior or document a deliberate
  architectural difference.
- Define gather-CAS atomicity and ordering in the shared event domain.
- Either add byte-level mixed-size coherence or continue to reject mixed-size
  and partially overlapping candidates explicitly.

Exit criteria:

- Production execution tests observe the expected event kind, address, size,
  agent, order, and program-order position for every memory instruction class.
- Litmus tests include allowed and forbidden outcomes for fences, acquire/
  release, atomics, scalar/tile interaction, and the selected mixed-size rule.
- No normative event-construction function is reachable only from tests.

## Stage 4 — close instruction-group reference semantics

**Target:** make every accepted operation total under `pto-v0`, with explicit
legality, effects, aliases, boundaries, and profile limits.

| Target | Group | Current focus | Closure target |
| --- | --- | --- | --- |
| `S4-T1` | AGU | Address generation, scaling, pairs, preflight, and writeback | Closed: ADRs 0024 and 0029 plus `scalar-agu-totality.json` bind all 183 forms to exact boundary, fault, restart, prefetch-model, and Reg5 alias evidence. |
| `S4-T2` | ALU | Fixed-width arithmetic, division, multiply, bitfields, rearrangement, and Reg5 aliases | Closed: ADRs 0025–0026 and `scalar-alu-totality.json` bind all 107 accepted forms to 337 decoded boundary cases and 35 decoded alias cases. |
| `S4-T3` | AMO | LR/SC, RMW, width, order, translation, and reservation state | Closed: ADR 0030 and `scalar-amo-totality.json` bind all 53 accepted forms to 2,474 unique Stage 4 attempts plus 66 retained Stage 1 attempts, with explicit PTO-v0 profile limits and reviewed independent comparison dispositions. |
| `S4-T4` | BRU | Conditions, targets, calls, returns, and bundle interaction | Closed: ADRs 0021 and 0027 plus `scalar-bru-totality.json` bind all 66 accepted forms to 284 decoded totality cases and 32 decoded alias, predicate, bundle-preservation, and fault obligations. |
| `S4-T5` | FSU | Scalar floating and conversion operations | Closed: ADR 0028 and `scalar-fsu-totality.json` bind all 30 forms to 2,270 decoded carrier/type/rounding/Reg5 cases plus 35 direct flag-helper cases; target arithmetic remains profile-scoped for Stage 5. |
| `S4-T6` | SYS | Registers, fences, maintenance, requests, traps, and context control | Closed: ADR 0031 and `scalar-sys-totality.json` bind all 35 forms to 4,401 unique Stage 4 cases plus 35 retained Stage 1 effects. |
| `S4-T7` | Bundle commands | Arguments, dimensions, attributes, IO, hints, launch, save/recover, frames, queues, copies, and transfers | Closed: ADR 0032 and `bundle-command-totality.json` give all 107 forms an exact consumed-field and executed-or-rejected disposition, with transactional rollback evidence. |
| `S4-T8` | TEPL | Elementwise, reduction, generation, conversion, rearrangement, sort, histogram, and management | Closed: ADR 0035 and `tepl-totality.json` cover all accepted and reserved selectors, carrier/layout rules, aliases, preserved regions, indices, sort/merge, histogram, and management effects. |
| `S4-T9` | TMA | Load/store/move/prefetch/gather/scatter/masked/CAS | Closed: ADR 0033 and `tma-totality.json` cover all nine selectors, packed sub-byte transfer, duplicate lanes, masks, events, atomicity, restart, and first/middle/last preflight faults. |
| `S4-T10` | CUBE | Matrix, bias, accumulate, MX, ACCCVT, and matrix/vector forms | Closed: ADR 0034 and `cube-totality.json` cover all 13 selectors, 19 raw carriers, layouts, aliases, and composite preflight; target numeric results remain `S5-T2`. |

The M3-to-M4 promotion condition is met: all ten Stage 4 targets are closed
while Stages 0 through 3 remain green. M4 is therefore the published maturity
floor; M5 still requires both Stage 5 conformance targets to close.

### Stage 4 execution tranches

| Tranche | Targets | Immediate objective | Done when |
| --- | --- | --- | --- |
| A — scalar value/control | `S4-T2`, `S4-T4`, `S4-T5` | Close pure scalar result, control-flow, alias, and raw-carrier behavior before target-specific numeric conformance. | Every stable form ID has class-appropriate boundary and alias vectors; control-flow fault precedence is total; all profile-dependent numeric behavior remains explicitly hooked to Stage 5. |
| B — memory/system | `S4-T1`, `S4-T3`, `S4-T6`, `S4-T9` | Reuse the closed Stage 2 state/fault and Stage 3 event contracts to close address, atomic, system, and tile-memory semantics. | Every operation has value, event, fault, restart, and no-partial-effect evidence, including minimum/maximum address and overlap cases. |
| C — bundle/tile compute | `S4-T7`, `S4-T8`, `S4-T10` | Consume every retained descriptor field and close tile definedness, legality, aliases, and composite preflight. | No accepted command or selector relies on a placeholder, ignored binding, accidental fixed value, or unclassified numeric surrogate. |

Within Tranche A, `S4-T2`, `S4-T4`, and `S4-T5` are closed. Their decoded alias
matrices prove the PTO Reg5 namespace, including T/U source snapshots and
destination push/discard behavior. BRU closure additionally fixes signed
halfword target arithmetic, predicate-domain selection, the ignored
`JR.SrcZero` alias field, odd-target fault state, and bundle preservation. FSU
closure fixes deterministic raw-carrier and sticky-flag behavior while leaving
target numerical conformance in Stage 5. Independent executable ISA/model
comparisons corroborate shared rules but do not substitute for PTO-specific
queue, predicate, target-policy, bundle, or numeric-profile evidence.

Within Tranche B, all four targets are closed. The AGU package combines 360 retained
nominal/fault cases with 1,464 decoded boundary, prefetch-model, precedence,
pair-preflight, and restart cases plus 4,296 decoded Reg5 and pair-alias cases.
ADR 0029 fixes the PTO-owned rules, and the independent executable-model
comparison remains corroborating rather than normative. ADRs 0030–0031 and
0033 close the AMO, SYS, and TMA value, fault, restart, and event contracts.

Within Tranche C, all three targets are closed. ADR 0032 consumes or explicitly
rejects every bundle-command field, while ADRs 0034–0035 close CUBE and TEPL
portable legality, raw-carrier effects, aliases, and preflight. Named-target
numeric results remain an explicit Stage 5 obligation.

Exit criteria:

- Every legal operand tuple returns a result or performs a specified visible
  state transition; every illegal tuple has a specified rejection or fault.
- Alias, minimum/maximum, partial-region, overflow/saturation, exceptional-
  value, and no-partial-effect tests exist wherever applicable.
- Bundle arguments, dimensions, attributes, and IO bindings are either consumed
  by execution semantics or explicitly documented as unsupported.
- `docs/coverage.md` can justify `complete under PTO v0` per group without
  relying on generated all-form status-only tests.

## Stage 5 — close numeric and independent conformance

**Target:** separate deterministic executable placeholders from validated PTO
numeric behavior.

Deliverables:

- Retain the deterministic raw-carrier model only as the named `pto-v0`
  reference profile; do not describe it as IEEE-754 or hardware arithmetic.
- Inventory every scalar and tile operation that depends on floating-point,
  conversion, quantization, rounding, saturation, NaN, infinity, signed zero,
  denormal, or sticky-flag behavior.
- Define a PTO-owned numeric contract for each inventory row or mark it outside
  the portable profile behind a named hook.
- Add a separately named hardware/numeric conformance profile when the intended
  target behavior is available.
- Cross-check shared scalar mnemonics and architectural patterns against a
  pinned independent executable ISA model using stable PTO form IDs. Record
  exact comparable preconditions, matches, differences, and PTO-owned
  dispositions; the comparison model remains evidence and never becomes
  normative PTO authority or a published source identity.
- Add differential vectors for normal, boundary, exceptional, rounding, and
  saturation cases without importing third-party implementation text.

Exit criteria:

- Identity or arithmetic-surrogate hooks are not presented as target numeric
  behavior.
- Every numeric hook has direct tests and a documented profile owner.
- A conformance report records the independent oracle, version, tested domains,
  mismatches, and accepted PTO dispositions.
- The executable-ISA comparison matrix has no unclassified shared-mnemonic row;
  every divergence links to a PTO test, requirement, profile rule, or accepted
  ADR.

## Stage 6 — architectural-completeness release gate

**Target:** produce a reviewable `architecturally-complete` candidate without
hidden exceptions.

### S6-T1 traceability promotion stages

`spec/evidence/release-traceability-readiness.json` is the fail-closed S6-T1
promotion input. It covers 937 globally unique traceability units: 44
requirements, 474 scalar forms, 107 bundle/command forms, 120 direct tile
operations, 72 system registers, 13 traps, 37 profile hooks, and 70 top-level
ASL state roots. Composite roots expand to 199 leaf fields so nested bundle,
trap-context, memory-event, system-register, and `TileInfo` fields remain
visible to review.

| Sub-stage | Current state | Target | Exit evidence |
| --- | --- | --- | --- |
| `S6-T1-A` | Closed | Exact, duplicate-free release inventory | Every catalog identity, requirement, hook, and ASL state root appears exactly once. |
| `S6-T1-B` | Closed | Existing requirement, model, test, and bounded-status links | Every path exists; state roots distinguish architectural state and abstractions from verification-only instrumentation. |
| `S6-T1-C` | Blocked by S5-T2 | Cumulative Stage 0–5 closure | The nine S5-T2-dependent requirement rows and all 29 numeric hooks close with accepted conformance evidence. |
| `S6-T1-D` | Waiting on C | Immutable-commit claim-hygiene approval | Reviewer identity, reviewed commit, date, and disposition are populated. |
| `S6-T1-E` | Waiting on C–D | S6-T1 promotion | All release surfaces agree and no completeness status exceeds its evidence. |

The inventory and links are therefore ready, but S6-T1 is not closed. The
generated review fields remain null until a stable post-S5-T2 candidate exists.

### S6-T2 release-gate promotion stages

`spec/evidence/release-gate-readiness.json` separates the exact release
contract from future results. It defines ten local/candidate gates, proves the
hosted workflow uses full action pins and least-privilege contents access, and
proves 34 shards partition 98 canonical calls reaching 86 test subprograms.
It also inventories ten GitHub repository/branch controls and the two required
review perspectives.

| Sub-stage | Current state | Target | Exit evidence |
| --- | --- | --- | --- |
| `S6-T2-A` | Closed | Exact release-gate contract | Ten commands/evidence boundaries, ten external controls, and two review perspectives are generated and checked. |
| `S6-T2-B` | Closed | Hosted and parallel execution contract | Full action pins, least-privilege workflow, required `validate`, 360-minute bound, and exact 34/98/86 partition pass fail-closed checks. |
| `S6-T2-C` | Blocked by S5-T2 and S6-T1 | Freeze one signed candidate | All cumulative prerequisites close and one immutable commit/tree identity is recorded. |
| `S6-T2-D` | Waiting on C | Reproduce the candidate | Every local gate and hosted `validate` passes at the same candidate commit. |
| `S6-T2-E` | Waiting on C–D | Verify controls and reviews | Candidate-specific GitHub control snapshot plus accepted PTO architecture and formal-model dispositions. |
| `S6-T2-F` | Waiting on C–E | Promote M6 metadata | Evidence ledgers, requirements, coverage, status metadata, and release commit agree. |

The current draft-branch hosted run is feedback, not release evidence. All
candidate, result, snapshot, and approval fields remain null until S6-T2-C.

Required release evidence:

- All Stage 0–5 exit criteria are closed or explicitly excluded by an accepted
  architecture decision.
- `spec/requirements.json` links every normative claim to model and executable
  evidence with no unsupported completeness status.
- `docs/coverage.md`, `specification.toml`, profile metadata, generated
  instruction references, and evidence ledgers agree.
- PTO architecture and formal-model reviewers independently approve totality,
  determinism, state locality, aliasing, boundaries, ordering, portability,
  decode closure, semantic reachability, and evidence hygiene.
- The pinned ASLRef gate, deterministic regeneration, script checks,
  publication-hygiene checks, and hosted CI all pass.
- The canonical executable suite is partitioned exactly once across focused
  parallel shards; orphan, empty, duplicate, missing, dead-code-only, and
  unreachable test entry points fail closed before ASLRef execution.

Release commands:

```bash
make clean
make ci
git diff --check
```

Only after this gate may `specification.toml` move from `draft` to
`architecturally-complete`.

## Recommended execution sequence

The next work should follow this dependency order:

1. Preserve Stages 0–4 as regression gates; any semantic change must update and
   re-pass its target-specific closure matrix.
2. Close `S5-T2` by naming the target numeric profile and independent oracle,
   then populate the generated six-lane readiness ledger with normal, boundary,
   exceptional, rounding, saturation, reduction, and accumulation evidence.
3. Preserve the closed `S5-T3` content-addressed comparison and all archived
   independent gates whenever either specification changes.
4. Reconcile requirements, model, tests, coverage, and release metadata for
   `S6-T1`, then obtain the independent formal/architecture reviews and clean CI
   evidence required by `S6-T2`.

Do not use a later-stage implementation to mark an earlier target closed. Each
target needs its own evidence package and review decision.

## Progress reporting

Track each stage with this minimum record:

| Field | Required content |
| --- | --- |
| Target ID | One or more IDs from the bring-up target register |
| Owner | One accountable person or team responsible for closure |
| Scope | Instruction groups, state, requirements, and profile hooks affected |
| Decision | Accepted architecture rule or explicit unresolved question |
| Implementation | ASL and catalog paths changed |
| Evidence | Positive, boundary, negative, alias, fault, ordering, and differential tests as applicable |
| Result | Open, in progress, blocked by architecture decision, or closed |
| Residual risk | Known profile limits, ASLRef limits, and untested domains |

A stage result should link to the pull requests and requirement IDs that prove
closure. Passing CI is necessary at every stage; it is not a substitute for the
stage-specific exit criteria.
