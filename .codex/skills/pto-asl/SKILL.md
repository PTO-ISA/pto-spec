---
name: pto-asl
description: Author, review, validate, or govern PTO formal architecture specifications written in ASL1. Use for changes to pto-spec ASL types, architectural state, instruction semantics, legality rules, tests, ASLRef integration, normative traceability, or formal-spec repository quality.
---

# PTO ASL

Build an executable PTO architecture contract without mixing portable semantics with backend implementation details.

## Read the contract

Before editing, read:

- `AGENTS.md`
- `docs/architecture.md`
- `docs/modeling-conventions.md`
- `GOVERNANCE.md`
- `CONTRIBUTING.md`

For ASLRef setup, versioning, or language behavior, read [references/aslref.md](references/aslref.md). For any normative
model change or review, also read [references/formal-quality.md](references/formal-quality.md).

## Classify the task

- **Repository/template maintenance**: improve tooling, governance, docs, or placeholders without adding semantics.
- **Language/tooling maintenance**: update the audited ASLRef pin or validation workflow; verify the upstream delta first.
- **Normative modeling**: add or change architectural types, state, legality, instruction results, ordering, or faults.
- **Review**: test traceability, totality, determinism, type safety, state effects, profile boundaries, and evidence.

Never turn a template-maintenance request into a normative modeling change.

## Model workflow

1. Identify the public PTO requirement and assign or cite stable requirement IDs.
2. State the architecture boundary, including what remains implementation-defined, constrained-unpredictable, or
   explicitly out of scope.
3. Add the smallest named types and state needed by the requirement.
4. Express legality independently from operation semantics when possible.
5. Use pure functions for value semantics and thin procedures for architecture-visible state updates.
6. Add positive, boundary, negative-legality, and state-transition tests as applicable.
7. Update the traceability matrix and change classification in the pull request.
8. Run the repository validation gate and inspect the output before claiming completion.

Do not invent missing semantics. Stop at a documented requirement gap and open or request an architecture decision.

## ASL rules

- Write ASL1 accepted by the repository-pinned ASLRef commit.
- Use named constrained integers for architectural domains and `bits(N)` for fixed-width values.
- Prefix enumeration members with the type name.
- Make side effects visible and localized.
- Avoid unconstrained loops; provide justified limits where ASLRef requires them.
- Model fault or diagnostic behavior explicitly. Use `assert` only for a reviewed legality precondition that has no
  architecture-visible failure behavior.
- Keep target-specific behavior behind named profiles. Never encode A2/A3, A5, CPU-SIM, or cost-model behavior as
  portable PTO semantics by accident.
- Treat fixed verification bounds as model parameters, not normative architectural limits.

## Repository quality gate

For every change:

```bash
make ci
git diff --check
```

For template-only work, additionally prove no active ASL declarations were introduced:

```bash
rg '^[[:space:]]*(func|type|var|let|constant|config|implementation|impdef)[[:space:]]' asl
```

The command must return no matches unless the task explicitly authorizes semantics.

Before committing, confirm:

- ASLRef strict type-checking succeeds.
- Executable tests succeed when semantics exist.
- Every normative claim has a source and requirement ID.
- Generated files are not committed.
- No backend mechanism leaked into the portable model.
- Governance, security, and contribution policies remain consistent.

## Review output

Lead with correctness findings. Cite exact files and lines. Separate:

- specification defects;
- tool or ASLRef limitations;
- missing architecture decisions;
- non-normative repository-maintenance observations.

Do not approve a normative change based only on successful parsing or execution; require traceability and semantic
coverage evidence.
