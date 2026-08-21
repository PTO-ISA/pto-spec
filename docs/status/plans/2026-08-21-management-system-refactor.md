# PTO Specification Management System Refactor Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace PTO's remaining PRD/PD decision namespaces with one validated ADR system, derive implementation and release status from repository facts, restore a ten-minute P95 pull-request lane, add non-authoritative nightly full validation, and make the repository easier to navigate without changing ISA semantics.

**Architecture:** ADRs become the sole human-authored architecture-evolution records while ASL and NDF remain the sole current normative semantic source. Python standard-library tools parse JSON-form YAML frontmatter, validate the ADR graph, generate decision/open/readiness indexes, and feed existing release closure; pull-request, nightly, and release workflows remain distinct commit-scoped evidence lanes.

**Tech Stack:** ASL1, Python 3.11+ standard library, JSON Schema, Markdown, GNU Make, Bash, GitHub Actions, pinned Rust NDF submodule, pinned OCaml/ASLRef toolchain.

**Status:** approved implementation plan

## Global Constraints

- Baseline all migration comparisons against commit `1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f` until an explicit rebase updates both the design and this plan.
- Do not change PTO instruction semantics, encoding masks, matches, operand fields, profile results, state transitions, or the `0.58.2` release identity in management-only commits.
- Keep ASL and NDF as the only current normative semantic source.
- Use ADR identities for every active human-authored architecture decision.
- Remove active PRD, PDR, and PD identities through one hard migration; do not add a compatibility parser or parallel active schema.
- Preserve former identifiers only in ADR `legacy_ids` and one generated historical map.
- Use JSON object frontmatter between `---` delimiters. JSON is valid YAML 1.2 and keeps the pull-request lane dependency-free through `json.loads`.
- Keep accepted ADR decision text substantively immutable. Later semantic changes use a new ADR and explicit supersession.
- Keep pull-request validation structural; do not claim ASLRef or release closure from it.
- Keep required pull-request validation at or below ten minutes P95 over ten representative hosted samples spanning at least five workflow run IDs.
- Treat nightly full validation as a commit-scoped health signal, never release evidence.
- Keep release verification exact-head, clean, fail-closed, and complete.
- Add no third-party Python dependency.
- Add executable regression tests before replacing each old checker or record owner.
- Keep governance, toolchain, normative semantics, and mechanical projection changes in separate commits.
- Keep `@zhoubot` as the sole identity in `.github/CODEOWNERS`.
- Use `apply_patch` for hand-authored edits and deterministic generators for bulk projections.
- Run `git diff --check` before every commit.

---

## Planned file structure

### Decision model

- `spec/schemas/pto-adr.schema.json` — machine contract for ADR frontmatter.
- `scripts/adr_records.py` — parse, validate, index, and relate ADR records.
- `scripts/check-adrs` — fail-closed command for active ADR content and graph.
- `scripts/generate-adr-index` — generate human and machine decision/open indexes.
- `docs/status/decisions/0000-template.md` — contributor-facing ADR template.
- `docs/status/decisions/index.md` — generated ADR catalog.
- `docs/status/open/index.md` — generated open-decision and implementation view.
- `spec/evidence/adr-index.json` — generated exact decision graph and legacy map.
- `tests/scripts/test_adrs.py` — parser, schema, transition, graph, and migration tests.

### Derived readiness and release scope

- `scripts/architecture_readiness.py` — derive architecture-defined, modeled, executable, validated, and released states.
- `scripts/generate-architecture-readiness` — checked generator command.
- `spec/evidence/architecture-readiness.json` — generated commit-scoped readiness view.
- `spec/release-selection.json` — exact release-selection and target-ADR contract.
- `spec/schemas/pto-release-selection.schema.json` — release-selection schema.
- `tests/scripts/test_architecture_readiness.py` — state-derivation and blocker tests.
- `tests/scripts/test_release_selection.py` — exact selection and no-hidden-change tests.

### Validation workflows

- `.github/workflows/asl.yml` — parallel pull-request jobs plus stable aggregator.
- `.github/workflows/full-validation.yml` — reusable strict-model and AVS-page workflow.
- `.github/workflows/release.yml` — exact-head manual release wrapper and release evidence.
- `.github/workflows/nightly.yml` — scheduled latest-main health wrapper.
- `scripts/pr_timing.py` — record and summarize per-check timing.
- `scripts/full_validation_workflow.py` — validate shared/full, nightly, and release workflow contracts.
- `scripts/check-release-workflow` — delegate to the shared workflow validator.
- `tests/scripts/test_pr_timing.py` — timing record and percentile tests.
- `tests/scripts/test_release_workflow.py` — pull-request, nightly, shared, and release workflow tests.

### Professional repository surface

- `README.md` — concise hub and five-minute quick start.
- `CONTRIBUTING.md` — short contributor workflow.
- `GOVERNANCE.md` — authority, ADR, merge, nightly, and release policy.
- `CHANGELOG.md` — generated release-oriented architecture history.
- `docs/governance/adr-process.md` — ADR lifecycle and examples.
- `docs/governance/validation.md` — lane contracts and evidence meanings.
- `docs/development/getting-started.md` — reproducible setup and commands.
- `docs/development/repository-layout.md` — source and projection ownership.
- `docs/releases/index.md` — generated release navigation.
- `scripts/generate-changelog` — derive changelog/release notes from ADR and manifest data.
- `scripts/generate-review-summary` — merge-base semantic review summary.
- `tests/scripts/test_repository_docs.py` — hub ownership, navigation, and stale-route tests.

### Reproducible development environment

- `tests/scripts/test_development_environment.py` — missing, mutable, and mismatched pin tests.

---

### Task 1: Add the ADR parser, schema, and fixture tests

**Files:**
- Create: `spec/schemas/pto-adr.schema.json`
- Create: `scripts/adr_records.py`
- Create: `scripts/check-adrs`
- Create: `tests/scripts/test_adrs.py`
- Create: `docs/status/decisions/0000-template.md`
- Modify: `scripts/check-script-entrypoints`
- Modify: `tests/scripts/test_script_entrypoints.py`

**Interfaces:**
- Consumes: Markdown files below `docs/status/decisions/` whose first block is JSON-form YAML frontmatter.
- Produces: `AdrRecord`, `parse_adr(path: Path) -> AdrRecord`, `load_adrs(root: Path) -> tuple[AdrRecord, ...]`, `validate_adr_graph(records: Sequence[AdrRecord]) -> list[str]`, and command `scripts/check-adrs [--root PATH]`.

- [ ] **Step 1: Write parser failure tests**

Add fixture helpers and these exact cases to `tests/scripts/test_adrs.py`:

```python
from pathlib import Path
import tempfile
import unittest

from scripts.adr_records import parse_adr, validate_adr_graph


class AdrRecordTest(unittest.TestCase):
    def write_adr(self, root: Path, name: str, metadata: str, body: str) -> Path:
        path = root / name
        path.write_text(f"---\n{metadata}\n---\n{body}\n", encoding="utf-8")
        return path

    def test_missing_frontmatter_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = Path(directory) / "0075-example.md"
            path.write_text("# ADR 0075: Example\n", encoding="utf-8")
            with self.assertRaisesRegex(ValueError, "JSON frontmatter"):
                parse_adr(path)

    def test_unknown_status_is_rejected(self) -> None:
        with tempfile.TemporaryDirectory() as directory:
            path = self.write_adr(
                Path(directory),
                "0075-example.md",
                '{"id":"ADR-0075","title":"Example","status":"done"}',
                "# ADR 0075: Example",
            )
            with self.assertRaisesRegex(ValueError, "status"):
                parse_adr(path)
```

- [ ] **Step 2: Run the tests and prove the module is absent**

Run:

```bash
python3 -m unittest tests.scripts.test_adrs -v
```

Expected: FAIL with `ModuleNotFoundError: No module named 'scripts.adr_records'`.

- [ ] **Step 3: Define the JSON Schema**

Create `spec/schemas/pto-adr.schema.json` with `additionalProperties: false`, the four status values, 40-hex baseline validation, `ADR-[0-9]{4}` identities, unique arrays, nullable dates/issues, and conditional requirements:

```json
{
  "$schema": "https://json-schema.org/draft/2020-12/schema",
  "$id": "https://github.com/PTO-ISA/pto-spec/spec/schemas/pto-adr.schema.json",
  "title": "PTO Architecture Decision Record",
  "type": "object",
  "additionalProperties": false,
  "required": [
    "id", "title", "status", "authors", "approvers", "created",
    "accepted", "rejected", "superseded", "baseline", "target_releases", "affected_ndf",
    "affected_units", "resolves", "supersedes", "superseded_by",
    "implementation_issue", "release_impact", "legacy_ids"
  ],
  "properties": {
    "id": {"type": "string", "pattern": "^ADR-[0-9]{4}$"},
    "title": {"type": "string", "minLength": 1},
    "status": {"enum": ["draft", "accepted", "rejected", "superseded"]},
    "authors": {
      "type": "array", "minItems": 1, "uniqueItems": true,
      "items": {"type": "string", "minLength": 1}
    },
    "approvers": {
      "type": "array", "uniqueItems": true,
      "items": {"type": "string", "minLength": 1}
    },
    "created": {"type": "string", "format": "date"},
    "accepted": {"type": ["string", "null"], "format": "date"},
    "rejected": {"type": ["string", "null"], "format": "date"},
    "superseded": {"type": ["string", "null"], "format": "date"},
    "baseline": {"type": "string", "pattern": "^[0-9a-f]{40}$"},
    "target_releases": {
      "type": "array", "minItems": 1, "uniqueItems": true,
      "items": {"type": "string", "pattern": "^([0-9]+\\.[0-9]+\\.[0-9]+|unassigned)$"}
    },
    "affected_ndf": {
      "type": "array", "uniqueItems": true,
      "items": {"type": "string", "pattern": "^PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*$"}
    },
    "affected_units": {
      "type": "array", "uniqueItems": true,
      "items": {"type": "string", "pattern": "^PTO-[A-Z0-9]+(?:-[A-Z0-9]+)*$"}
    },
    "resolves": {
      "type": "array", "uniqueItems": true,
      "items": {"type": "string", "pattern": "^ADR-[0-9]{4}$"}
    },
    "supersedes": {
      "type": "array", "uniqueItems": true,
      "items": {"type": "string", "pattern": "^ADR-[0-9]{4}$"}
    },
    "superseded_by": {
      "type": "array", "uniqueItems": true,
      "items": {"type": "string", "pattern": "^ADR-[0-9]{4}$"}
    },
    "implementation_issue": {"type": ["string", "null"], "format": "uri"},
    "release_impact": {"enum": ["required", "not-required"]},
    "legacy_ids": {
      "type": "array", "uniqueItems": true,
      "items": {
        "type": "string",
        "pattern": "^(PRD-[0-9]{3}|PDR-[0-9]{3}|PD-[0-9]{2}(?:-[A-Z0-9]+)?)$"
      }
    }
  },
  "allOf": [
    {
      "if": {"properties": {"status": {"const": "accepted"}}},
      "then": {
        "properties": {
          "accepted": {"type": "string", "format": "date"},
          "approvers": {"minItems": 1},
          "affected_ndf": {"minItems": 1}
        }
      }
    },
    {
      "if": {"properties": {"status": {"const": "rejected"}}},
      "then": {"properties": {"rejected": {"type": "string", "format": "date"}}}
    },
    {
      "if": {"properties": {"status": {"const": "superseded"}}},
      "then": {
        "properties": {
          "superseded": {"type": "string", "format": "date"},
          "superseded_by": {"minItems": 1}
        }
      }
    }
  ]
}
```

- [ ] **Step 4: Implement the dependency-free parser**

Create `scripts/adr_records.py` with:

```python
@dataclass(frozen=True)
class AdrRecord:
    adr_id: str
    title: str
    status: str
    authors: tuple[str, ...]
    approvers: tuple[str, ...]
    created: str
    accepted: str | None
    rejected: str | None
    superseded: str | None
    baseline: str
    target_releases: tuple[str, ...]
    affected_ndf: tuple[str, ...]
    affected_units: tuple[str, ...]
    resolves: tuple[str, ...]
    supersedes: tuple[str, ...]
    superseded_by: tuple[str, ...]
    implementation_issue: str | None
    release_impact: str
    legacy_ids: tuple[str, ...]
    path: Path


def _frontmatter(text: str, path: Path) -> dict[str, object]:
    lines = text.splitlines()
    if len(lines) < 3 or lines[0] != "---":
        raise ValueError(f"{path}: missing JSON frontmatter")
    try:
        end = lines.index("---", 1)
    except ValueError as error:
        raise ValueError(f"{path}: unterminated JSON frontmatter") from error
    try:
        value = json.loads("\n".join(lines[1:end]))
    except json.JSONDecodeError as error:
        raise ValueError(f"{path}: invalid JSON frontmatter: {error}") from error
    if not isinstance(value, dict):
        raise ValueError(f"{path}: ADR frontmatter must be an object")
    return value
```

Implement explicit Python validation equivalent to the checked-in schema so runtime checks do not depend on a JSON Schema package.

- [ ] **Step 5: Add graph and status tests**

Cover duplicate IDs, filename/ID mismatch, accepted ADR without approvers or date, superseded ADR without `superseded_by`, unknown NDF/ADR references, cycles, duplicate legacy IDs, and reciprocal supersession.

- [ ] **Step 6: Add the checker command and template**

`scripts/check-adrs` loads every non-template Markdown file and prints the exact
record count only after schema and graph validation. The template contains a
complete draft JSON object and the body headings from the design.

- [ ] **Step 7: Register executable/module policy**

Update `scripts/check-script-entrypoints` and its tests so `adr_records.py` may be non-executable while `check-adrs` must be executable.

- [ ] **Step 8: Run focused verification**

Run:

```bash
python3 -m unittest tests.scripts.test_adrs tests.scripts.test_script_entrypoints -v
python3 -m json.tool spec/schemas/pto-adr.schema.json >/dev/null
git diff --check
```

Expected: all tests pass. Do not add `check-adrs` to `pr-check` yet because existing ADRs have not migrated.

- [ ] **Step 9: Commit**

```bash
git add spec/schemas/pto-adr.schema.json scripts/adr_records.py scripts/check-adrs \
  tests/scripts/test_adrs.py docs/status/decisions/0000-template.md \
  scripts/check-script-entrypoints tests/scripts/test_script_entrypoints.py
git commit -S -m "feat(governance): define the ADR record contract"
```

---

### Task 2: Migrate every existing ADR to the hard schema

**Files:**
- Modify: every file returned by `git ls-files 'docs/status/decisions/*.md'`, excluding `0000-template.md`
- Modify: `scripts/check-adrs`
- Modify: `Makefile`
- Modify: `scripts/check-pr`
- Modify: `.github/workflows/asl.yml`
- Modify: `scripts/release_workflow.py`
- Modify: `tests/scripts/test_adrs.py`
- Modify: `tests/scripts/test_check_pr.py`
- Modify: `tests/scripts/test_release_workflow.py`
- Modify: `scripts/instruction_docs.py`
- Modify: `tests/scripts/test_instruction_docs.py`

**Interfaces:**
- Consumes: parser and schema from Task 1.
- Produces: one enforced ADR schema for all 69 baseline decision files; `make check-adrs` and required PR enforcement.

- [ ] **Step 1: Add a repository failure test before migration**

Add:

```python
def test_every_repository_adr_uses_frontmatter(self) -> None:
    records = load_adrs(ROOT / "docs/status/decisions")
    self.assertEqual(len(records), 69)
    self.assertEqual(validate_adr_graph(records), [])
```

- [ ] **Step 2: Run the test and prove legacy headers fail**

Run:

```bash
python3 -m unittest tests.scripts.test_adrs.AdrRecordTest.test_every_repository_adr_uses_frontmatter -v
```

Expected: FAIL on the first ADR with `missing JSON frontmatter`.

- [ ] **Step 3: Add frontmatter to all baseline ADRs**

For each tracked ADR:

- derive `id` from the numeric filename;
- preserve the current title;
- normalize status to `accepted`, `superseded`, or `rejected` from the historical record;
- use the original author where recorded, otherwise the repository maintainer identity from the accepting commit;
- require at least one approver for accepted records;
- use the original decision date;
- use the full commit before the ADR first landed as `baseline`;
- enumerate actual NDF and unit impacts from current ASL ownership;
- convert supersession prose to reciprocal ADR IDs;
- put PRD/PD IDs in `legacy_ids` only when that ADR already accepted them;
- leave historical acceptance-time counts in prose but mark them as historical.

Use this concrete command first, then repeat it for each decision path returned
by the tracked-file inventory:

```bash
git log --follow --format='%H|%aI|%an|%ae' -- \
  docs/status/decisions/0001-pto-architecture-scope.md
```

Recover dates and baseline commits from Git; do not invent metadata.

- [ ] **Step 4: Normalize contradictory status prose**

Remove duplicate `## Status` sections and proposal-time conclusions that contradict accepted frontmatter. Preserve rationale, exclusions, acceptance criteria, and historical context.

In ADR 0069, replace the final proposal warning with:

```markdown
This decision became executable through the implementation linked in the ADR
frontmatter. Release closure remains commit-scoped and is not implied by the
accepted ADR status.
```

- [ ] **Step 5: Enable ADR checks in local and hosted PR lanes**

First add a failing `test_decision_template_is_excluded_from_navigation` fixture
to `tests/scripts/test_instruction_docs.py`. It must show that
`0000-template.md` is neither a generated navigation page nor a published
decision. Update `instruction_docs.py` to exclude exactly that filename from
status-page discovery; do not add a general prefix or draft-file exclusion.

Add `check-adrs` to `.PHONY`, define:

```make
check-adrs:
	./scripts/check-adrs
```

Make `pr-check` depend on `check-adrs`, add `./scripts/check-adrs` to `scripts/check-pr --list`, and add the command once to the hosted source-contract list.

- [ ] **Step 6: Update workflow contract tests**

Require `check-adrs` in the PR and exact-head release lightweight contract. Add a negative test that removes it and expects `validate_pr_workflow` to reject the workflow.

- [ ] **Step 7: Run verification**

Run:

```bash
./scripts/check-adrs
python3 -m unittest tests.scripts.test_adrs tests.scripts.test_check_pr \
  tests.scripts.test_release_workflow -v
make pr-check
git diff --check
```

Expected: 69 ADRs pass one schema and all PR checks pass.

- [ ] **Step 8: Commit**

```bash
git add docs/status/decisions spec/schemas/pto-adr.schema.json scripts/check-adrs \
  Makefile scripts/check-pr .github/workflows/asl.yml scripts/release_workflow.py \
  tests/scripts/test_adrs.py tests/scripts/test_check_pr.py \
  tests/scripts/test_release_workflow.py scripts/instruction_docs.py \
  tests/scripts/test_instruction_docs.py
git commit -S -m "refactor(governance): normalize every ADR record"
```

---

### Task 3: Replace the 183 mnemonic PRDs with ADR-owned decision groups

**Files:**
- Create: `docs/status/decisions/0075-block-attributes-and-lifecycle.md`
- Create: `docs/status/decisions/0076-block-scalar-and-tile-bindings.md`
- Create: `docs/status/decisions/0077-block-start-and-extension-reservations.md`
- Create: `docs/status/decisions/0078-tlsu-and-global-memory-operations.md`
- Create: `docs/status/decisions/0079-cube-and-matrix-operations.md`
- Create: `docs/status/decisions/0080-tile-elementwise-and-irregular-operations.md`
- Create: `docs/status/decisions/0081-tile-scalar-and-immediate-operations.md`
- Create: `docs/status/decisions/0082-tile-reduction-expansion-and-generation.md`
- Create: `docs/status/decisions/0083-tile-conversion-layout-and-partial-operations.md`
- Create: `docs/status/decisions/0084-scalar-system-and-queue-operations.md`
- Create: `docs/status/decisions/0085-numeric-postprocess-and-format-operations.md`
- Modify: `docs/status/decisions/0062-mnemonic-review-decisions.md`
- Modify: `docs/status/decisions/0019-predicate-register-contract.md`
- Modify: `docs/status/decisions/0032-bundle-command-totality-and-profile-boundaries.md`
- Modify: `docs/status/decisions/0046-separate-execution-mask-and-warp-predicates.md`
- Modify: `docs/status/decisions/0051-predicate-state-namespace-boundary.md`
- Modify: the seven ASL files currently found by `git grep -l 'PRD-[0-9][0-9][0-9]' -- 'asl/**/*.asl'`
- Modify: tests and evidence paths found by `git grep -l 'PRD-[0-9][0-9][0-9]' -- ':!docs/status/legacy/**'`
- Create: `scripts/generate-adr-index`
- Create: `spec/evidence/adr-index.json`
- Modify: `tests/scripts/test_adrs.py`
- Modify: `tests/scripts/test_decision_implementation_closure.py`

**Interfaces:**
- Consumes: normalized ADR records from Task 2.
- Produces: zero active PRD references; complete `legacy_ids` mapping in `spec/evidence/adr-index.json`.

- [ ] **Step 1: Add exact migration coverage tests**

Add a baseline set and a one-owner assertion:

```python
EXPECTED_PRDS = {f"PRD-{value:03d}" for value in range(1, 184)}

def test_every_prd_has_exactly_one_adr_owner(self) -> None:
    records = load_adrs(ROOT / "docs/status/decisions")
    owners = {}
    for record in records:
        for legacy_id in record.legacy_ids:
            if legacy_id.startswith("PRD-"):
                self.assertNotIn(legacy_id, owners)
                owners[legacy_id] = record.adr_id
    self.assertEqual(set(owners), EXPECTED_PRDS)

def test_active_semantics_contain_no_prd_reference(self) -> None:
    result = subprocess.run(
        [
            "git", "grep", "-nE", r"\\bPRD-[0-9]{3}\\b", "--",
            "asl/**", "spec/catalog/**", "spec/profile-hooks.json",
            "tests/asl/**",
        ],
        cwd=ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    self.assertEqual(result.returncode, 1, result.stdout)

def test_prd_ids_are_absent_from_adr_bodies(self) -> None:
    for path in sorted((ROOT / "docs/status/decisions").glob("*.md")):
        if path.name == "0000-template.md":
            continue
        body = path.read_text(encoding="utf-8").split("---", 2)[2]
        self.assertNotRegex(body, r"\bPRD-[0-9]{3}\b", path.name)
```

- [ ] **Step 2: Run the tests and prove all 183 PRDs are active**

Run the two new tests. Expected: FAIL with missing legacy owners and active PRD references.

- [ ] **Step 3: Move PRD decision text into the eleven ADR groups**

Use these exact ownership partitions and assert set equality before writing:

```python
GROUPS = {
    "ADR-0075": set(range(1, 18)),
    "ADR-0076": set(range(18, 31)),
    "ADR-0077": set(range(31, 40)),
    "ADR-0078": set(range(40, 49)) | {144, 145},
    "ADR-0079": set(range(49, 56)),
    "ADR-0080": set(range(56, 82)) | {126, 127, 128},
    "ADR-0081": set(range(82, 97)),
    "ADR-0082": set(range(97, 126)) | {129, 130, 131, 132},
    "ADR-0083": set(range(133, 144)),
    "ADR-0084": set(range(146, 174)),
    "ADR-0085": set(range(174, 184)),
}
```

The mapping above must pass this invariant unchanged:

```python
flattened = [value for values in GROUPS.values() for value in values]
assert len(flattened) == 183
assert set(flattened) == set(range(1, 184))
```

The intended correction is that ADR-0078 owns `40..48`, `144`, and `145`; ADR-0083 owns `133..143`; no other group owns those values.

- [ ] **Step 4: Replace active references**

Replace each ASL/test reference with the owning ADR ID and its current NDF clause. Replace `superseded by PRD-039` with `superseded by ADR-0077`. Do not change the surrounding semantic rule.

- [ ] **Step 5: Reduce ADR 0062 to historical audit provenance**

Retain its audit date, coverage method, active/reserved totals at the time, and links to ADR-0075 through ADR-0085. Remove the 183 operative sections.

- [ ] **Step 6: Generate the decision and legacy index**

`scripts/generate-adr-index` emits deterministic JSON with:

```json
{
  "schema": "pto.adr-index",
  "records": [],
  "legacy_map": {},
  "open": [],
  "summary": {
    "record_count": 0,
    "draft_count": 0,
    "legacy_id_count": 0
  }
}
```

Support `--check` and `--output`; default output is `spec/evidence/adr-index.json`.

- [ ] **Step 7: Strengthen decision-to-NDF closure**

Replace backtick mnemonic scanning in `test_decision_implementation_closure.py` with exact `affected_ndf` and `affected_units` joins from `AdrRecord`. Require every accepted ADR impact to exist and every changed accepted NDF clause to have at least one ADR owner.

- [ ] **Step 8: Verify no semantic surface drift**

Run:

```bash
./scripts/generate-adr-index --check
! git grep -nE '\bPRD-[0-9]{3}\b' -- \
  'asl/**' 'spec/catalog/**' 'spec/profile-hooks.json' 'tests/asl/**'
python3 -m unittest tests.scripts.test_adrs \
  tests.scripts.test_decision_implementation_closure -v
python3 scripts/project_asl_catalogs.py --root . --check
./scripts/check-binary-closure
git diff --check
```

Expected: all 183 legacy IDs map exactly once, active PRD references are zero, catalogs and binary closure are unchanged.

- [ ] **Step 9: Commit**

```bash
git add docs/status/decisions asl tests spec/evidence/adr-index.json \
  scripts/generate-adr-index tests/scripts/test_adrs.py \
  tests/scripts/test_decision_implementation_closure.py
git commit -S -m "refactor(governance): migrate mnemonic PRDs to ADRs"
```

---

### Task 4: Migrate numeric PD decisions to accepted and draft ADRs

**Files:**
- Create: `docs/status/decisions/0086-numeric-profile-applicability.md`
- Create: `docs/status/decisions/0087-numeric-format-legality.md`
- Create: `docs/status/decisions/0088-numeric-special-values.md`
- Create: `docs/status/decisions/0089-numeric-exception-flags.md`
- Create: `docs/status/decisions/0090-conversion-range-results.md`
- Create: `docs/status/decisions/0091-elementary-function-accuracy.md`
- Create: `docs/status/decisions/0092-reduction-order-and-stability.md`
- Create: `docs/status/decisions/0093-quantization-contract.md`
- Create: `docs/status/decisions/0094-matrix-numeric-contract.md`
- Create: `docs/status/decisions/0095-bounded-numeric-variation.md`
- Modify: `docs/status/decisions/0047-numeric-rounding-semantics.md`
- Modify: `docs/status/decisions/0049-hardware-subnormal-policy.md`
- Modify: `scripts/generate-numeric-profile-decision-inputs`
- Modify: `scripts/generate-numeric-profile-decision-proposals`
- Modify: every active generator/evidence file returned by `git grep -l '\bPD-[0-9][0-9]\b' -- ':!docs/status/legacy/**'`
- Modify: `scripts/generate-adr-index`
- Modify: `docs/status/open/index.md`
- Modify: `tests/scripts/test_adrs.py`
- Create: `tests/scripts/test_numeric_decision_migration.py`

**Interfaces:**
- Consumes: ADR index and legacy map from Task 3.
- Produces: accepted ADR ownership for former PD-03/PD-04, ten draft ADRs, zero active PD references, and a generated open index.

- [ ] **Step 1: Write failing migration tests**

```python
FORMER_PD_IDS = {f"PD-{value:02d}" for value in range(1, 13)}

def test_every_pd_maps_to_one_adr(self) -> None:
    index = json.loads((ROOT / "spec/evidence/adr-index.json").read_text())
    owners = {key: value for key, value in index["legacy_map"].items() if key.startswith("PD-")}
    self.assertEqual(set(owners), FORMER_PD_IDS)

def test_open_numeric_decisions_are_draft_adrs(self) -> None:
    records = {record.adr_id: record for record in load_adrs(ROOT / "docs/status/decisions")}
    draft_legacy = {
        legacy_id
        for record in records.values()
        if record.status == "draft"
        for legacy_id in record.legacy_ids
    }
    self.assertEqual(draft_legacy, FORMER_PD_IDS - {"PD-03", "PD-04"})
```

- [ ] **Step 2: Prove the existing generator-owned decisions fail**

Run the new test module. Expected: FAIL because only generated proposal data owns the PD set.

- [ ] **Step 3: Create ten draft ADRs and attach accepted legacy IDs**

Use the exact mapping:

```text
PD-01 -> ADR-0086
PD-02 -> ADR-0087
PD-05 -> ADR-0088
PD-06 -> ADR-0089
PD-07 -> ADR-0090
PD-08 -> ADR-0091
PD-09 -> ADR-0092
PD-10 -> ADR-0093
PD-11 -> ADR-0094
PD-12 -> ADR-0095
PD-03 -> ADR-0047
PD-04 -> ADR-0049
```

Move the proposed rules, questions, affected domains, alternatives, and acceptance obligations from generator constants into the draft ADR bodies. Do not mark any new numeric rule accepted.

- [ ] **Step 4: Make numeric generators consume ADRs**

Delete `QUESTION_SPECS`, `ACCEPTED_DECISIONS`, and human-authored `proposed_rule` constants. Load the ADR index and emit only computed fields:

```python
decision_rows.append(
    {
        "adr": adr_id,
        "status": adr.status,
        "affected_domains": sorted(domains_by_adr_id[adr_id]),
        "acceptance_record": str(adr.path) if adr.status == "accepted" else None,
    }
)
```

- [ ] **Step 5: Generate the open index from ADR data**

Extend `generate-adr-index` to write `docs/status/open/index.md`. It must list ten numeric draft ADRs, their target release, implementation issue, affected NDF clauses, and blockers. The file begins with a generated-file marker and rejects hand edits through `--check`.

- [ ] **Step 6: Remove active PD references**

Replace explanatory PD names in accepted ADRs with ADR links or historical
`legacy_ids` context. Only ADR frontmatter, `adr-index.json`, and migration-map
regression fixtures retain PD text. Generated numeric evidence uses ADR IDs and
must not use a PD identity or status as an input.

- [ ] **Step 7: Regenerate and verify numeric evidence**

Run all numeric generators with `--check`, then regenerate their owned files intentionally. Confirm that accepted rule counts remain two and no numeric domain is promoted.

- [ ] **Step 8: Run closure checks**

```bash
! git grep -nE '\bPD-[0-9]{2}\b' -- \
  'asl/**' 'scripts/generate-numeric-*' 'spec/catalog/**' \
  'spec/evidence/*.json' ':!spec/evidence/adr-index.json' 'tests/asl/**'
python3 -m unittest tests.scripts.test_adrs \
  tests.scripts.test_numeric_decision_migration \
  tests.scripts.test_numeric_profile_hook_closure -v
./scripts/generate-adr-index --check
make repo-check
git diff --check
```

- [ ] **Step 9: Commit**

```bash
git add docs/status/decisions docs/status/open scripts spec/evidence \
  tests/scripts/test_adrs.py tests/scripts/test_numeric_decision_migration.py
git commit -S -m "refactor(governance): migrate numeric PDs to ADRs"
```

---

### Task 5: Generate architecture lifecycle and readiness

**Files:**
- Create: `scripts/architecture_readiness.py`
- Create: `scripts/generate-architecture-readiness`
- Create: `spec/evidence/architecture-readiness.json`
- Create: `tests/scripts/test_architecture_readiness.py`
- Modify: `scripts/generate-release-traceability-readiness`
- Modify: `scripts/check-release-closure`
- Modify: `spec/release-inputs.json`
- Modify: `Makefile`
- Modify: `docs/status/open/index.md` through its generator

**Interfaces:**
- Consumes: `AdrRecord`, ASL units/NDF clauses, instruction contracts, AVS inventory, validation events, and release manifest.
- Produces: `ReadinessRow`, `derive_readiness(root: Path, commit: str) -> tuple[ReadinessRow, ...]`, and generated `pto.architecture-readiness` evidence.

- [ ] **Step 1: Write state-derivation tests**

```python
def test_accepted_adr_without_asl_is_architecture_defined(self) -> None:
    row = derive_fixture(adr_status="accepted", ndf=False, avs=False, validation=None)
    self.assertEqual(row.stage, "architecture-defined")

def test_executable_requires_ndf_and_avs(self) -> None:
    row = derive_fixture(adr_status="accepted", ndf=True, avs=False, validation=None)
    self.assertEqual(row.stage, "modeled")

def test_validation_is_exact_commit_scoped(self) -> None:
    row = derive_fixture(
        adr_status="accepted",
        ndf=True,
        avs=True,
        validation={"commit": "a" * 40, "result": "success"},
        commit="b" * 40,
    )
    self.assertEqual(row.stage, "executable")
```

- [ ] **Step 2: Run tests and prove the module is absent**

Expected: `ModuleNotFoundError`.

- [ ] **Step 3: Implement the derived state model**

```python
@dataclass(frozen=True)
class ReadinessRow:
    subject_id: str
    adr_ids: tuple[str, ...]
    ndf_ids: tuple[str, ...]
    unit_ids: tuple[str, ...]
    test_ids: tuple[str, ...]
    stage: str
    blockers: tuple[str, ...]
    validated_commit: str | None
    released_versions: tuple[str, ...]
```

Use only repository facts. Reject an accepted ADR whose affected NDF/unit does not exist unless its stage is explicitly architecture-defined with an open implementation issue.

- [ ] **Step 4: Add checked generation**

`generate-architecture-readiness` supports `--check`, `--output`, and `--commit`. The output includes sources and SHA-256 digests but no wall-clock timestamp.

- [ ] **Step 5: Integrate release traceability and closure**

Make release traceability reference readiness rows instead of free-form decision statuses. Register the new evidence in `spec/release-inputs.json` and require freshness in `release-evidence-check`.

- [ ] **Step 6: Verify no maturity promotion**

```bash
./scripts/generate-architecture-readiness --check --commit "$(git rev-parse HEAD)"
python3 -m unittest tests.scripts.test_architecture_readiness \
  tests.scripts.test_release_closure -v
./scripts/check-release-closure
git diff --check
```

Expected: the new index is current; the repository remains M4 and S5-T2 remains open.

- [ ] **Step 7: Commit**

```bash
git add scripts/architecture_readiness.py scripts/generate-architecture-readiness \
  spec/evidence/architecture-readiness.json tests/scripts/test_architecture_readiness.py \
  scripts/generate-release-traceability-readiness scripts/check-release-closure \
  spec/release-inputs.json Makefile docs/status/open/index.md
git commit -S -m "feat(governance): derive architecture readiness"
```

---

### Task 6: Add explicit release selection and blocker closure

**Files:**
- Create: `spec/release-selection.json`
- Create: `spec/schemas/pto-release-selection.schema.json`
- Create: `tests/scripts/test_release_selection.py`
- Modify: `scripts/generate-release-manifest`
- Modify: `scripts/generate-release-gate-readiness`
- Modify: `scripts/check-release-closure`
- Modify: `spec/release-inputs.json`
- Modify: `spec/release-manifest.json`

**Interfaces:**
- Consumes: current release identity, accepted NDF inventory, ADR target releases, and architecture readiness.
- Produces: exact release-selection contract and blockers that prevent future/draft decisions from being mistaken for the published surface.

- [ ] **Step 1: Write selection failure tests**

Cover unknown ADRs, draft ADR inclusion, missing accepted NDF clauses, target-release mismatch, hidden changes to an already released NDF clause, and duplicate subject selection.

- [ ] **Step 2: Define the schema and current selection**

Use:

```json
{
  "$schema": "spec/schemas/pto-release-selection.schema.json",
  "architecture_version": "0.58.2",
  "baseline_commit": "bc369ec67a07c0260f6ba793fa0d705abb363770",
  "included_ndf_statuses": ["accepted"],
  "excluded_draft_adrs": [],
  "required_readiness_floor": "executable"
}
```

Populate `excluded_draft_adrs` from the generated ADR index, not by hand. The checked-in selection owns policy; generated manifest owns the expanded exact set.

- [ ] **Step 3: Bind release generation to selection**

Extend the manifest generator to include selection hash, expanded NDF IDs, selected ADR IDs, readiness floor, and blockers. Reject a release if an ADR targeted to `0.58.2` is accepted but below the required floor.

- [ ] **Step 4: Protect published behavior**

Compare the current selected catalog/binary fingerprint with the prior `0.58.2` release manifest. A changed fingerprint requires a new architecture version and accepted compatibility ADR.

- [ ] **Step 5: Verify current release remains reproducible**

```bash
python3 -m unittest tests.scripts.test_release_selection \
  tests.scripts.test_release_closure -v
./scripts/check-release-closure
./scripts/check-binary-closure
./scripts/check-release-manifest
git diff --check
```

- [ ] **Step 6: Commit**

```bash
git add spec/release-selection.json spec/schemas/pto-release-selection.schema.json \
  tests/scripts/test_release_selection.py scripts/generate-release-manifest \
  scripts/generate-release-gate-readiness scripts/check-release-closure \
  spec/release-inputs.json spec/release-manifest.json
git commit -S -m "feat(release): declare exact architecture selection"
```

---

### Task 7: Reduce required PR validation below ten minutes P95

**Files:**
- Modify: `.github/workflows/asl.yml`
- Modify: `scripts/check-pr`
- Create: `scripts/pr_timing.py`
- Create: `tests/scripts/test_pr_timing.py`
- Modify: `tests/scripts/test_check_pr.py`
- Modify: `tests/scripts/test_release_workflow.py`
- Modify: `scripts/release_workflow.py`

**Interfaces:**
- Consumes: existing production check commands and script unit tests.
- Produces: parallel `PR / source-contract`, `PR / tooling-tests`, and stable `PR / validate` jobs plus JSON timing summaries.

- [ ] **Step 1: Add workflow-shape and timing tests**

Require exactly three jobs, both worker jobs as aggregator prerequisites, no ASLRef/opam use, one production execution per checker, and an NDF Cargo cache key containing OS, architecture, submodule SHA, and lockfile hash.

Add percentile behavior:

```python
def test_percentile_uses_nearest_rank(self) -> None:
    self.assertEqual(percentile([1, 2, 3, 4, 5], 95), 5)

def test_summary_marks_p95_budget_failure(self) -> None:
    summary = summarize([590, 601], budget_seconds=600)
    self.assertEqual(summary["p95_seconds"], 601)
    self.assertFalse(summary["within_budget"])
```

- [ ] **Step 2: Prove the current single job fails**

Run focused tests. Expected: FAIL because `.github/workflows/asl.yml` has one job and no timing artifact.

- [ ] **Step 3: Remove duplicate production traversals**

Delete `test_repository_checker_accepts_non_executable_python_modules` and `test_publication_hygiene_accepts_the_approved_ndf_reference` from `test_check_pr.py`; their failure modes remain covered by `test_script_entrypoints.py`, `test_active_paths.py`, and fixture-based publication tests. Do not remove the production commands from the source-contract job.

- [ ] **Step 4: Split hosted jobs**

`source-contract` runs ADR/NDF/ASL/test ownership, projections, docs, hygiene, and diff checks. `tooling-tests` runs `python3 -m unittest discover`. `validate` uses `if: always()` and requires both results equal `success`.

- [ ] **Step 5: Cache only the NDF tool build**

Cache `tools/ndf/target` using the exact submodule commit and `tools/ndf/Cargo.lock`. Do not cache generated PTO catalogs, docs, decoder output, AVS points, or test results across commits.

- [ ] **Step 6: Add timing summaries**

Wrap each production command with a unique timing output. For example:

```bash
scripts/pr_timing.py run \
  --output build/pr-timing-check-adrs.json \
  -- ./scripts/check-adrs
```

Merge worker artifacts in the aggregator and publish P50/P95/budget status to
the job summary. The timing budget is observational for the first ten runs;
correctness jobs remain required.

- [ ] **Step 7: Verify locally**

```bash
python3 -m unittest tests.scripts.test_pr_timing tests.scripts.test_check_pr \
  tests.scripts.test_release_workflow -v
./scripts/check-release-workflow
make pr-check
git diff --check
```

- [ ] **Step 8: Commit**

```bash
git add .github/workflows/asl.yml scripts/check-pr scripts/pr_timing.py \
  scripts/release_workflow.py tests/scripts/test_pr_timing.py \
  tests/scripts/test_check_pr.py tests/scripts/test_release_workflow.py
git commit -S -m "perf(ci): parallelize the required PR contract"
```

---

### Task 8: Add shared full validation and nightly main health

**Files:**
- Create: `.github/workflows/full-validation.yml`
- Create: `.github/workflows/nightly.yml`
- Modify: `.github/workflows/release.yml`
- Create: `scripts/full_validation_workflow.py`
- Modify: `scripts/check-release-workflow`
- Modify: `scripts/release_workflow.py`
- Modify: `tests/scripts/test_release_workflow.py`
- Modify: `scripts/generate-release-gate-readiness`
- Modify: `spec/evidence/release-gate-readiness.json`

**Interfaces:**
- Consumes: exact commit, mode `nightly` or `release`, existing ASL matrix planner, strict model, and page runner.
- Produces: reusable complete validation; nightly health artifacts without release authority; unchanged manual exact-head release authority.

- [ ] **Step 1: Write negative workflow tests**

Require nightly schedule plus manual dispatch, exact `origin/main` resolution, no tag/release permission, no release evidence mutation, exact commit in every job, and explicit `authority: nightly`. Require release mode to retain explicit user commit input and evidence aggregation.

- [ ] **Step 2: Prove no nightly workflow exists**

Run the workflow tests. Expected: FAIL on missing files and missing shared contract.

- [ ] **Step 3: Extract the shared validation jobs**

Move exact identity, matrix plan, strict model, and eight-page AVS execution into `full-validation.yml` under `workflow_call`. Inputs are:

```yaml
inputs:
  commit:
    required: true
    type: string
  authority:
    required: true
    type: string
```

Reject authorities other than `nightly` and `release` in the first job.

- [ ] **Step 4: Keep release evidence release-only**

`release.yml` remains `workflow_dispatch`, validates the full commit input, calls shared validation with `authority: release`, then runs canonical evidence aggregation and final `Release / validate`.

- [ ] **Step 5: Add nightly latest-main health**

`nightly.yml` runs daily and by manual dispatch. Its resolver job checks out `main`, records `git rev-parse HEAD`, and calls shared validation with `authority: nightly`. It uploads per-ID results and one health summary; it never runs `make release-prepare` and never modifies checked-in evidence.

- [ ] **Step 6: Add fail-closed workflow validation**

`full_validation_workflow.py` parses the narrow YAML contract without a YAML dependency, matching the existing workflow validator approach. It validates exact action pins, cache keys, matrix count, result aggregation, permissions, conditions, and authority boundaries.

- [ ] **Step 7: Regenerate readiness policy**

Record nightly as non-authoritative feedback and release as the sole publication gate. Do not increment release maturity or fill candidate evidence.

- [ ] **Step 8: Verify**

```bash
python3 -m unittest tests.scripts.test_release_workflow -v
./scripts/check-release-workflow
./scripts/generate-release-gate-readiness --check
make pr-check
git diff --check
```

- [ ] **Step 9: Commit**

```bash
git add .github/workflows/full-validation.yml .github/workflows/nightly.yml \
  .github/workflows/release.yml scripts/full_validation_workflow.py \
  scripts/check-release-workflow scripts/release_workflow.py \
  tests/scripts/test_release_workflow.py scripts/generate-release-gate-readiness \
  spec/evidence/release-gate-readiness.json
git commit -S -m "feat(ci): add non-authoritative nightly validation"
```

---

### Task 9: Reorganize the professional repository documentation surface

**Files:**
- Create: `CHANGELOG.md`
- Create: `docs/governance/adr-process.md`
- Create: `docs/governance/validation.md`
- Create: `docs/development/getting-started.md`
- Create: `docs/development/repository-layout.md`
- Create: `docs/releases/index.md`
- Create: `scripts/generate-changelog`
- Create: `scripts/generate-review-summary`
- Create: `tests/scripts/test_repository_docs.py`
- Modify: `README.md`
- Modify: `CONTRIBUTING.md`
- Modify: `GOVERNANCE.md`
- Modify: `AGENTS.md`
- Modify: `.codex/skills/pto-asl/SKILL.md`
- Modify: `.codex/skills/pto-asl/references/source-map.md`
- Modify: `.github/CODEOWNERS`
- Modify: `scripts/check-active-paths`
- Modify: `tests/scripts/test_active_paths.py`
- Modify: `docs/mkdocs/mkdocs.yml`
- Modify: `scripts/check-publication-hygiene`

**Interfaces:**
- Consumes: ADR index, current release traceability, release manifest, and
  validation workflow contracts. Because Task 9 may execute while Task 4 is
  externally blocked, it must not create a broken architecture-readiness link;
  Task 5 later replaces the release-traceability fallback with the generated
  architecture-readiness view.
- Produces: concise root hubs, focused guidance spokes, generated changelog, and merge-base review summaries.

- [ ] **Step 1: Write navigation and ownership tests**

Require each new hub, forbid stale `spec/requirements.json`, `PRD-`, `PD-`, and manual release-only wording, require one canonical link for each topic, and permit only the new `docs/governance`, `docs/development`, and `docs/releases` roots in addition to existing ASL mirrors/status.

Require `.github/CODEOWNERS` to contain exactly one owner token, `@zhoubot`,
for every active pattern.

- [ ] **Step 2: Prove current path policy rejects the new structure**

Run `tests.scripts.test_repository_docs` and `tests.scripts.test_active_paths`. Expected: FAIL until active path ownership is extended.

- [ ] **Step 3: Create concise hubs**

Keep README outcome-first and under 220 source lines. It contains project identity, release/draft distinction, five-minute quick start, source chain, validation lanes, repository map, contribution link, and license. Move detailed counts and maturity prose to generated status pages.

- [ ] **Step 4: Create contributor and governance spokes**

Document exact ADR states, NDF ownership, merge versus nightly versus release meanings, common change scenarios, environment setup, and troubleshooting. Do not duplicate ASL semantics.

- [ ] **Step 5: Generate changelog and review summary**

`generate-changelog` groups accepted ADRs by release and change category. `generate-review-summary --base REF --head REF` emits changed ADRs, NDF clauses, ASL units, binary fingerprint status, projections, AVS points, compatibility, and blockers.

- [ ] **Step 6: Fix all stale agent routes**

Remove the deleted `spec/requirements.json` route from the skill and source-map reference. Point agents to ADR index, owning ASL/NDF, generated mirror, AVS, and commit-scoped evidence in that order.

Replace the two-owner CODEOWNERS table with one repository-wide rule:

```text
* @zhoubot
```

- [ ] **Step 7: Update MkDocs navigation and hygiene**

Add the governance, development, release, decision, and open indexes without duplicating the 835 generated ASL pages.

- [ ] **Step 8: Verify**

```bash
python3 -m unittest tests.scripts.test_repository_docs \
  tests.scripts.test_active_paths -v
./scripts/generate-changelog --check
./scripts/generate-review-summary --base HEAD^ --head HEAD >/dev/null
python3 scripts/check-publication-hygiene
make pr-check
git diff --check
```

- [ ] **Step 9: Commit**

```bash
git add README.md CONTRIBUTING.md GOVERNANCE.md AGENTS.md CHANGELOG.md \
  .github/CODEOWNERS \
  .codex/skills/pto-asl docs/governance docs/development docs/releases \
  docs/mkdocs/mkdocs.yml scripts/generate-changelog scripts/generate-review-summary \
  scripts/check-active-paths scripts/check-publication-hygiene \
  tests/scripts/test_repository_docs.py tests/scripts/test_active_paths.py
git commit -S -m "docs: professionalize repository navigation"
```

---

### Task 10: Keep the development environment lightweight

**Decision:** reject a repository-owned Docker/devcontainer layer.

**Existing owners:**
- `.aslref-version` owns the ASLRef revision.
- `tools/ndf` and its Rust toolchain own NDF compiler inputs.
- `.github/workflows/asl.yml` owns the lightweight PR execution environment.
- `.github/workflows/full-validation.yml` owns OCaml/opam and full-model setup.
- `docs/development/getting-started.md` owns contributor setup guidance.

**Reasoning:** A container duplicates these identities and introduces registry
digest refresh, package installation, image build, and a second cache/runtime
contract. The hosted experiment added failure and maintenance modes without
adding a new correctness claim. This conflicts with the refactor goal of
reducing required-check latency and management complexity.

- [x] **Step 1: Compare native pinned workflows with a container layer**

The existing PR, nightly, and release lanes already separate fast structural
feedback from pinned full validation. No missing quality claim requires an
image.

- [x] **Step 2: Reject and remove the duplicate layer**

The final tree contains no `.devcontainer/`, Dockerfile, registry checker, or
container-specific PR command. Temporary probe branches are deleted.

- [x] **Step 3: Verify the lightweight contract**

```bash
test ! -e .devcontainer
! git grep -niE 'docker|devcontainer' -- \
  ':!docs/status/plans/2026-08-21-management-system-refactor*.md'
make pr-check
make repo-check
git diff --check
```

Expected: the repository retains the same quality gates and sub-ten-minute PR
critical path without a second environment-management system.

---

### Task 11: Remove active legacy content and obsolete routes

**Files:**
- Delete: `docs/status/legacy/`
- Modify: `scripts/check-active-paths`
- Modify: `tests/scripts/test_active_paths.py`
- Modify: `scripts/check-publication-hygiene`
- Modify: `tests/scripts/test_repository_docs.py`
- Modify: `docs/development/repository-layout.md`
- Modify: `docs/status/decisions/index.md` through its generator
- Modify: `spec/evidence/adr-index.json` through its generator

**Interfaces:**
- Consumes: complete `legacy_ids` mapping and Git history.
- Produces: no checked-in legacy documentation tree; historical lookup through ADR index, tags, and Git history only.

- [ ] **Step 1: Add tests that reject a returning legacy tree**

Change `docs/status/legacy` from an allowed historical root to an obsolete path. Require `check-active-paths` to reject any tracked or untracked file below it.

- [ ] **Step 2: Prove the current tree fails**

Run the focused active-path test. Expected: FAIL because the legacy tree remains tracked.

- [ ] **Step 3: Verify historical recoverability**

Run:

```bash
git ls-tree -r --name-only 1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f docs/status/legacy > build/legacy-paths.txt
test -s build/legacy-paths.txt
git show 1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f:docs/status/legacy/README.md >/dev/null
```

This proves the exact baseline retains the deleted history.

- [ ] **Step 4: Remove the legacy tree and active references**

Delete the tracked tree. Remove negative-route exceptions that mention it from active agent guidance. Keep generated legacy ID mappings without copying legacy prose.

- [ ] **Step 5: Verify repository readability and closure**

```bash
test ! -e docs/status/legacy
! git grep -n 'docs/status/legacy/' -- ':!docs/status/plans/**'
python3 -m unittest tests.scripts.test_active_paths \
  tests.scripts.test_repository_docs -v
python3 scripts/check-publication-hygiene
make pr-check
git diff --check
```

- [ ] **Step 6: Commit**

```bash
git add -A docs/status/legacy scripts/check-active-paths \
  tests/scripts/test_active_paths.py scripts/check-publication-hygiene \
  tests/scripts/test_repository_docs.py docs/development/repository-layout.md \
  docs/status/decisions/index.md spec/evidence/adr-index.json
git commit -S -m "chore: retire checked-in legacy documentation"
```

---

### Task 12: Close the migration and collect verification evidence

**Files:**
- Modify: `docs/status/plans/2026-08-21-management-system-refactor-design.md`
- Modify: `docs/status/plans/2026-08-21-management-system-refactor.md`
- Create: `spec/evidence/management-system-refactor-closure.json`
- Create: `scripts/generate-management-system-refactor-closure`
- Create: `tests/scripts/test_management_system_refactor_closure.py`
- Modify: `spec/release-inputs.json`
- Modify: `scripts/check-release-closure`
- Modify: `README.md`

**Interfaces:**
- Consumes: every prior task, hosted PR timing data, exact local verification,
  the first upstream merge commit, its nightly health result, and release
  evidence contracts.
- Produces: an `awaiting-upstream` pre-merge record followed by immutable
  `closed` migration evidence in a small post-merge evidence PR, without
  claiming ISA semantic changes.

- [ ] **Step 1: Write closure criteria tests**

Require zero active PRD/PDR/PD semantic references, complete legacy map, fresh
ADR/readiness/open indexes, unchanged release identity and binary fingerprint,
required PR timing sample count of at least ten across five workflow run IDs,
P95 at most 600 seconds, no
legacy tree, and one current documentation route per topic. A record with
`status: awaiting-upstream` permits a null nightly commit; `status: closed`
requires a successful latest-main full-validation commit.

- [ ] **Step 2: Prove closure is initially absent**

Run the new test. Expected: FAIL because closure evidence does not exist.

- [ ] **Step 3: Generate deterministic migration closure**

The generator constructs the record from exact inputs:

```python
document = {
    "schema": "pto.management-refactor-closure",
    "status": closure_status(nightly_event),
    "baseline_commit": BASELINE_COMMIT,
    "head_commit": git_head(ROOT),
    "semantic_surface_changed": semantic_surface_changed(ROOT),
    "active_prd_count": active_semantic_identity_count(ROOT, "PRD"),
    "active_pd_count": active_semantic_identity_count(ROOT, "PD"),
    "adr_schema_status": adr_schema_status(ROOT),
    "pr_p95_seconds": timing_summary["p95_seconds"],
    "nightly_health_commit": nightly_event["commit"],
    "release_identity": specification_release(ROOT),
}
```

`active_semantic_identity_count` excludes ADR `legacy_ids`, the generated
legacy map, and migration-map regression fixtures. Define every helper in
`generate-management-system-refactor-closure`; the
checked-in file contains exact values and no null once closure is claimed.

- [ ] **Step 4: Run full local verification**

```bash
make clean
make pr-check
make repo-check
make setup
python3 scripts/manual_semantic_audit.py
make toolchain-check
make check
git diff --check
git status --short
```

Expected: every command succeeds and the tree is clean after regenerated
evidence is committed. The expensive complete AVS suite runs once through the
post-merge nightly workflow rather than being duplicated before merge.

- [ ] **Step 5: Collect hosted PR timing evidence without promoting release**

After explicit user authorization to publish the branch and open migration PRs,
push each reviewed Task 7-11 commit and retain the resulting timing artifacts.
Use natural fix/update runs plus explicit workflow re-runs of distinct reviewed
heads until at least ten post-refactor samples across five workflow run IDs
exist. Do not create no-op
commits solely to increase the sample count. Do not create a release or fill
candidate release evidence.

- [ ] **Step 6: Generate and commit pre-merge closure**

Generate `status: awaiting-upstream` evidence with the ten-sample timing set,
successful local full verification, and `nightly_health_commit: null`:

```bash
./scripts/generate-management-system-refactor-closure --awaiting-upstream
python3 -m unittest tests.scripts.test_management_system_refactor_closure -v
./scripts/check-release-closure
git diff --check
git add docs/status/plans README.md spec/evidence/management-system-refactor-closure.json \
  scripts/generate-management-system-refactor-closure \
  tests/scripts/test_management_system_refactor_closure.py \
  spec/release-inputs.json scripts/check-release-closure
git commit -S -m "chore(governance): prepare management refactor closure"
```

- [ ] **Step 7: Push, open, and merge the upstream implementation pull request**

Run:

```bash
git push -u origin codex/management-system-refactor
gh pr create --repo PTO-ISA/pto-spec \
  --base main \
  --head codex/management-system-refactor \
  --title "Refactor PTO specification management" \
  --body-file .superpowers/sdd/2026-08-21-management-system-refactor/pull-request.md
gh pr checks --repo PTO-ISA/pto-spec --watch
gh pr merge --repo PTO-ISA/pto-spec --squash --delete-branch
```

The PR body summarizes the ADR migration, semantic invariants, PR timing,
nightly authority boundary, README/legacy cleanup, and full verification
evidence. Do not merge until `PR / validate` succeeds on the exact PR head and
all review conversations are resolved.

- [ ] **Step 8: Run and verify nightly health on merged main**

Capture the exact merged commit, dispatch the nightly workflow, and wait for its
non-authoritative full validation result:

```bash
git fetch origin main
merged_commit="$(git rev-parse origin/main)"
gh workflow run nightly.yml --repo PTO-ISA/pto-spec --ref main
nightly_run="$(gh run list --repo PTO-ISA/pto-spec --workflow nightly.yml \
  --branch main --limit 1 --json databaseId --jq '.[0].databaseId')"
gh run watch "$nightly_run" --repo PTO-ISA/pto-spec --exit-status
```

Expected: the nightly event reports `commit == merged_commit` and every shared
full-validation job succeeds.

- [ ] **Step 9: Create and merge the final closure evidence PR**

Create a fresh closure branch from the verified main commit, generate `closed`
evidence, and mark the design and plan implemented:

```bash
git switch -c codex/management-system-refactor-closure origin/main
nightly_run="$(gh run list --repo PTO-ISA/pto-spec --workflow nightly.yml \
  --branch main --limit 1 --json databaseId --jq '.[0].databaseId')"
./scripts/generate-management-system-refactor-closure \
  --nightly-run "$nightly_run"
python3 -m unittest tests.scripts.test_management_system_refactor_closure -v
./scripts/check-release-closure
git diff --check
```

Use `apply_patch` to change the design status to `implemented governance
design`, change this plan status to `implemented`, and add these exact fields:

```markdown
- Closure evidence: `spec/evidence/management-system-refactor-closure.json`
```

```markdown
**Closure evidence:** `spec/evidence/management-system-refactor-closure.json`
```

Then commit and publish the evidence:

```bash
git add docs/status/plans README.md spec/evidence/management-system-refactor-closure.json
git commit -S -m "chore(governance): close the management refactor"
git push -u origin codex/management-system-refactor-closure
gh pr create --repo PTO-ISA/pto-spec \
  --base main \
  --head codex/management-system-refactor-closure \
  --title "Record PTO management refactor closure" \
  --body "Records exact post-merge nightly validation and closes the approved management refactor plan."
gh pr checks --repo PTO-ISA/pto-spec --watch
gh pr merge --repo PTO-ISA/pto-spec --squash --delete-branch
```

- [ ] **Step 10: Verify upstream main after both merges**

```bash
git fetch origin main
git show origin/main:.github/CODEOWNERS
git show origin/main:README.md >/dev/null
git grep -nE '\b(PRD-[0-9]{3}|PD-[0-9]{2})\b' origin/main -- \
  'asl/**' 'scripts/**' 'spec/catalog/**' 'tests/asl/**'
gh run list --repo PTO-ISA/pto-spec --workflow asl.yml --limit 1
```

Expected: CODEOWNERS contains only `* @zhoubot`; the active semantic grep
returns no matches; the latest main PR workflow is successful.

---

## Execution checkpoints

- After Task 2: review ADR schema usability before bulk decision splitting.
- After Task 4: review the generated decision/open indexes and confirm no architecture rule moved accidentally.
- After Task 6: review release selection and blocker behavior before workflow changes.
- After Task 8: review PR/nightly/release authority boundaries and hosted timing.
- After Task 11: review repository navigation and legacy recoverability.
- Before Task 12 full verification: rebase onto the then-latest `origin/main`, regenerate all derived artifacts, and rerun Tasks 1-11 focused tests.

## Rollback boundaries

- Tasks 1-2 can be reverted together without touching normative ASL.
- Tasks 3-4 are identity migrations; revert the complete task commit if any legacy mapping or NDF ownership is incomplete.
- Tasks 5-6 add derived evidence and release selection; they do not modify ASL semantics and can be reverted together.
- Tasks 7-8 change workflow execution only; retain the previous exact-head release workflow until the shared workflow passes its negative contract tests.
- Tasks 9-11 change navigation and historical storage; Git commit `1e91bf98ad2f918c24ddbb394c3be73fa9d5de9f` remains the recovery anchor.
- Task 12 records closure only and must never be used to mask a failed earlier gate.
