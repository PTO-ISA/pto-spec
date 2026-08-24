---
name: pto-asl
description: Use when working in pto-spec on ASL1 architecture state or instruction semantics, mnemonic ASL/docs/test closure, ASLRef validation, normative traceability, or formal-spec repository governance.
---

# PTO ASL

Build an executable PTO architecture contract without mixing portable semantics with backend implementation details.

## Read the contract

Before editing, read:

- `AGENTS.md`
- the owning source below `asl/{arch,block,scalar,tile}/`
- `spec/evidence/adr-index.json` for the decision history affecting that owner
- its exact mirror below `docs/{arch,block,scalar,tile}/`
- its independently runnable points below `tests/asl/{arch,block,scalar,tile}/`
- `GOVERNANCE.md`
- `CONTRIBUTING.md`
- `docs/status/decisions/` and `docs/status/open/` when the change has linked status metadata
- commit-scoped evidence registered by `spec/release-inputs.json`, beginning
  with `spec/evidence/release-traceability-readiness.json`

Current semantics: owning ASL/NDF -> generated mirror -> AVS -> commit-scoped evidence.
Decision history: ADR index -> affected ASL/NDF.

For ASLRef setup, versioning, or language behavior, read [references/aslref.md](references/aslref.md). For any normative
model change or review, also read [references/formal-quality.md](references/formal-quality.md).
For mnemonic ASL authoring or readability refactors, also read
[references/arm-style.md](references/arm-style.md).
For source-to-normative migration or reconciliation, also read
[references/source-map.md](references/source-map.md).

## Classify the task

- **Repository maintenance**: improve tooling, governance, or non-normative docs without adding semantics.
- **Language/tooling maintenance**: update the audited ASLRef pin or validation workflow; verify the upstream delta first.
- **Normative modeling**: add or change architectural types, state, legality, instruction results, ordering, or faults.
- **Migration/reconciliation**: inventory source material, normalize it into PTO-owned contracts, and record independent
  evidence and conflicts without publishing restricted source identity or material.
- **Review**: test traceability, totality, determinism, type safety, state effects, profile boundaries, and evidence.

Never turn a repository-maintenance request into a normative modeling change.

## Model workflow

1. Identify the public PTO requirement and assign or cite stable requirement IDs.
2. State the architecture boundary, including what remains implementation-defined, constrained-unpredictable, or
   explicitly out of scope.
3. Inventory exact accepted forms, fields, constraints, registers, traps, selectors, reserved values, and rejected
   aliases before writing migrated semantics.
4. Record source conflicts and PTO normalization decisions explicitly.
5. Add the smallest named types and state needed by the requirement.
6. Express legality independently from operation semantics when possible.
7. Use pure functions for value semantics and thin procedures for architecture-visible state updates.
8. Add positive, boundary, negative-legality, aliasing, fault, ordering, and state-transition test points under the
   exact mirror in `tests/asl/{arch,block,scalar,tile}/`. Each point has one stable ID and is discovered automatically.
9. Regenerate ASL-derived catalogs, decoder witnesses, documentation, NDF traceability and coverage, and change
   classification together.
10. Run the repository validation gate and inspect the output before claiming completion.

For instruction-set changes, also keep the four ASL-owned surfaces synchronized:

1. the mnemonic ASL owner containing normative metadata, legality, and operation semantics;
2. its generated catalog and decoder witness;
3. the exact generated Markdown mirror with embedded ASL; and
4. independently runnable AVS test points covering the decoded state transition.

An accepted spelling without all four surfaces is a specification defect. Do not reduce semantic coverage to a mnemonic
count, function-name presence, or enum linkage, and do not hand-edit generated decoder output under `build/`.

When implementing a frozen mnemonic audit, an accepted ADR-family record is
the architecture decision input, not implementation evidence. Translate every
recorded implementation gap into the owning ASL operation, exact embedded
documentation, and independent tests. Continue until the active inventory is
`642/642 FORMAL-COMPLETE`; an audit count of `642/642` does not satisfy this
gate.

Do not invent missing semantics. Stop at a documented requirement gap and open or request an architecture decision.

## ASL rules

- Write ASL1 accepted by the repository-pinned ASLRef commit.
- Use Arm-style specification structure: decode binds small local names and
  legality; operation snapshots typed operands, computes named intermediate
  values, performs preflight, then commits architectural effects.
- Name public/shared helpers in descriptive PascalCase by architectural
  action (`ProbeDataAccess`, `AtomicReadModifyWrite`). Use concise lower-case
  locals for decoded indices and values (`address`, `old_value`, `result`).
- Keep one declaration, condition, call argument group, or state assignment
  visually reviewable. Wrap long signatures, boolean conditions, calls, and
  expressions with continuation indentation; do not compress an instruction
  operation into one line.
- Separate reusable value semantics into `pure func`, read-only architectural
  queries into `readonly func`, profile extension points into `impdef func`,
  and visible state transitions into ordinary `func` procedures.
- Keep instruction files thin but meaningful: their embedded operation region
  must identify the exact handler, width, operation, publication behavior,
  defaults, faults, and reserved space. Shared helpers may implement repeated
  mechanisms, but a mnemonic may not rely on an unexplained generic label.
- A `FORMAL-COMPLETE` operation region must contain a mnemonic-local semantic
  contract beyond `InstructionContractHandler_*`. A handler selector alone is
  decoder linkage, not readable operation semantics; expose the selected
  condition, transfer, bundle kind, tile operation, address rule, publication,
  or other behavior that distinguishes the mnemonic.
- Keep decode and operation regions page-shaped. Decode names fields and
  rejects reserved combinations; operation reads/snapshots inputs, derives
  named dimensions or addresses, preflights every possible fault, then commits
  visible effects. The generated page must embed these exact regions rather
  than paraphrasing them in a second semantic description.
- Prefer one architectural action per line. A complete instruction operation
  must not be a one-line forwarding wrapper whose meaning can only be learned
  by searching a generic dispatcher; retain a concise mnemonic-specific
  wrapper that names the selected operation, operand roles, defaults, fault
  boundary, and commit behavior.
- Use named constrained integers for architectural domains and `bits(N)` for fixed-width values.
- Prefix enumeration members with the type name.
- Make side effects visible and localized.
- Avoid unconstrained loops; provide justified limits where ASLRef requires them.
- Model fault or diagnostic behavior explicitly. Use `assert` only for a reviewed legality precondition that has no
  architecture-visible failure behavior.
- Keep target-specific behavior behind named profiles. Never encode A2/A3, A5, CPU-SIM, or cost-model behavior as
  portable PTO semantics by accident.
- Treat fixed verification bounds as model parameters, not normative architectural limits.
- Preserve the one-level PTO contract: direct tile operations may update tile, pipe, memory, or fault state, but may not
  introduce nested instruction bodies, body-local queues, replay bodies, or hidden command streams.
- Snapshot sources before destination writes whenever operand aliasing is legal.
- Keep floating, quantization, and target-dependent numeric behavior behind named profile hooks until the numeric profile
  defines raw encodings, rounding, exceptional values, and flags.
- Treat private or incompatibly licensed implementations as read-only comparison evidence. Record anonymized names,
  hashes, and dispositions; never copy or expose their identities, repository paths, prose, code, or diagrams.

## Mnemonic test shape

- Put executable evidence only under the exact mirror
  `tests/asl/{arch,block,scalar,tile}/.../<mnemonic>/`.
- Do not create a new test root or alternate taxonomy. One ASL owner may have
  multiple independent points, but every point remains inside its existing
  mirrored owner directory.
- Name each point `group-type-mnemonic-name-NNN.asl`, using the repository's
  short group/type vocabulary (`block|scalar|tile|arch`, then
  `decode|exec|bound|fault|state|noop|static`). Include the mnemonic, keep the
  purpose concise, and omit filler words such as `test`, `validate`, and
  `execution` from the name component. For example:
  `tile-bound-tmatmul-mx-scale-001.asl`.
- Give each file one stable test ID and one observable purpose. Split decode,
  legal execution, defaults, boundary/reserved rejection, state transition,
  no-effect, and precise-fault obligations when they are independent.
- Keep fixture setup local and short; reuse architecture test-library helpers
  only for setup mechanisms, never to compute the expected result.
- Run each new point alone through `scripts/run-asl-test --id`, observe the
  intended RED before production edits, then run the mnemonic family with the
  bounded `-j` parallel runner after GREEN.
- Build a focused family page directly from exact current IDs with
  `scripts/print-asl-test-matrix --ids-file`; this path discovers only the
  selected points and lazily generates only their required validation inputs.
  Do not select a newly added point from a stale cached
  `build/asl-test-matrix.json`, and do not invoke full release discovery merely
  to filter a focused family.
- Keep generated exhaustive coverage at one case per result file. Delete
  obsolete generated results, reject unexpected extras in generator check
  mode, and never restore a `SHARD_SIZE` or multi-case grouping abstraction.
- Reset only the architectural fixture state required by an exhaustive point.
  Do not call a full profile reset inside a large loop when a small local reset
  preserves the same observable behavior.
- Do not lengthen a test to amortize ASLRef startup. Improve assembly/cache and
  parallel scheduling in the runner while preserving independent points.

## Repository quality gate

For every pull request:

```bash
make pr-check
make repo-check
git diff --check
```

The pull-request lane is intentionally lightweight and does not claim release
readiness. Exact-commit full validation is:

```bash
python3 scripts/manual_semantic_audit.py
make setup
make release-verify RELEASE_COMMIT="$(git rev-parse HEAD)"
make release-prepare
```

For parallel executable tests, run `make setup` first. Its `scripts/prepare-aslref` step serially fetches, checks out,
and builds the repository-pinned ASLRef executable once. Each shard must then invoke the prepared executable through
the read-only `scripts/aslref` launcher. The launcher must never fetch, check out, or build: an absent, wrong-origin, or
wrong-commit cache fails closed and tells the caller to run `make setup`. Do not keep `dune exec` alive around each
ASLRef process: Dune retains the workspace lock for the process lifetime and silently serializes otherwise independent
shards.

Keep runtime results independent: assemble only the test-library sources needed
by each point, keep one case per result file, schedule known heavy totality
points first, and use a bounded job count. Coverage checks must inspect each
actual `main()` body, prove every canonical call appears exactly once, reject
orphan or empty result files, and prove every declared `Test*` or `Validate*`
subprogram remains reachable. A call-looking line in dead helper code is not
execution evidence.

Before committing, confirm:

- ASLRef strict type-checking succeeds.
- Toolchain canaries pass for accepted, rejected, and failing ASL inputs.
- Every independent test ID is discoverable through `scripts/print-asl-test-matrix` and executable through
  `scripts/run-asl-test --id`; focused families use `--ids-file` and must not
  fall back to full release discovery.
- Every normative claim has a source and requirement ID.
- Every accepted scalar form and tile operation has an executable decoder witness.
- Every scalar semantic primitive and tile handler group has direct executable feature evidence.
- Every form claimed executable has a checked decoded operand-to-effect binding;
  catalog or enum linkage alone is not execution.
- Every declared implementation profile has an exact machine-readable portable default, override obligations,
  requirement owner, ASL call site, and executable feature evidence.
- Independent-evidence gaps and conflicts remain visible rather than being converted into unsupported agreement.
- Independent comparison gates are executed against the recorded clean, pinned snapshot; evidence archives a stable
  publication-safe command identity, exit code, result, output hashes, and a sanitized diagnostic excerpt. Keep any
  restricted source/version recipe behind constructed local generator inputs. Never hardcode a gate result. Missing
  commands, timeouts, or nonzero exits fail closed and keep the associated maturity target open.
- Ephemeral `build/` outputs are not committed. Checked-in ASL-derived docs,
  catalogs, canonical AVS points, and release evidence must be regenerated and
  committed together when their owner changes.
- No backend mechanism leaked into the portable model.
- Governance, security, and contribution policies remain consistent.
- No validation check or canary was weakened to make a change pass.
- `scripts/check-publication-hygiene` passes before publication.

## Review output

Lead with correctness findings. Cite exact files and lines. Separate:

- specification defects;
- tool or ASLRef limitations;
- missing architecture decisions;
- non-normative repository-maintenance observations.

Do not approve a normative change based only on successful parsing or execution; require traceability and semantic
coverage evidence.
