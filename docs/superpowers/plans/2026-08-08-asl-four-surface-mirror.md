# PTO ASL Four-Surface Mirror Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task in the current session. Do not dispatch implementation or review subagents for this plan. Steps use checkbox (`- [ ]`) syntax for tracking.

**Execution mode:** Inline execution was selected by the architecture owner on 2026-08-08. The active session owns implementation, verification, review checkpoints, commits, and final release validation directly.

**Goal:** Make the checked-in ASL tree the sole active PTO architecture source, organized as `arch`, `block`, `scalar`, and `tile`, with exactly mirrored documentation, independent AVS test points, lightweight PR checks, and exact-head manual release verification.

**Architecture:** Every hand-written ASL file is a stable metadata-bearing unit discovered from the four approved roots. Deterministic projections derive source order, catalogs, decoders, documentation, navigation, test matrices, coverage evidence, and release manifests from those units; checked-in projections are accepted only when regeneration is byte-identical. Tests are one-entry-point ASL programs stored below the owning source path, and the release workflow discovers and executes each stable test ID independently.

**Tech Stack:** ASL/ASLRef, Python 3 standard library, JSON, Markdown/MkDocs, GNU Make, Bash, GitHub Actions, and `unittest` repository script tests.

## Global Constraints

- `asl/` MUST contain exactly `arch/`, `block/`, `scalar/`, and `tile/`, with no root files and no additional top-level entries.
- Every mnemonic MUST own exactly one ASL file and one matching active Markdown page.
- Every non-mnemonic architecture concept MUST own one cohesive ASL file and one matching active Markdown page.
- Every hand-written ASL file MUST contain at most 500 physical lines; permanent exceptions are forbidden.
- Bundle state and dispatch MUST move under `block/`; active `bundle/`, `numeric/`, and `profiles/` ASL roots MUST not remain.
- Active docs MUST mirror ASL paths exactly by replacing `asl/` with `docs/` and `.asl` with `.md`.
- `docs/status/legacy/` is non-normative and MUST be excluded from navigation, NDF resolution, coverage, release closure, and normative references.
- Every active ASL unit MUST own at least one independent test point.
- Every test point MUST be one `.asl` file with one `PTO-TEST` record, one stable ID, and exactly one integer `main()`.
- Every executable NDF requirement MUST be referenced by at least one test point.
- PR validation MUST remain lightweight and MUST NOT install or execute ASLRef.
- Manual release validation MUST bind to one exact commit and execute every discovered test ID fail-closed.
- Pure moves and model splits MUST preserve behavior; architecture changes discovered during migration require a separate NDF semantic delta.
- No new runtime dependency is permitted; discovery, projection, and validation tooling uses the Python 3 standard library.
- The existing uncommitted release fixture corrections MUST be inspected, pass lightweight checks, and be committed independently before structural migration; their ASL runtime shards are verified with the complete exact-head suite in Task 14.

---

## Target File Map

The implementation establishes these ownership boundaries before deleting old aggregate files:

```text
asl/
├── arch/
│   ├── overview/
│   ├── programming-model/
│   ├── state/
│   ├── system-registers/
│   ├── memory-model/
│   ├── data-types/
│   ├── features/
│   ├── profile/
│   └── dispatch/
├── block/
│   ├── model/
│   │   ├── state/
│   │   ├── lifecycle/
│   │   ├── operands/
│   │   ├── schema/
│   │   ├── commit/
│   │   ├── faults/
│   │   └── dispatch/
│   └── <instruction-class>/<MNEMONIC>.asl
├── scalar/
│   ├── model/
│   │   ├── types/
│   │   └── dispatch/
│   └── <agu|alu|amo|bru|fsu|sys>/<MNEMONIC>.asl
└── tile/
    ├── model/
    │   ├── state/
    │   ├── shape/
    │   ├── capacity/
    │   ├── definedness/
    │   ├── memory/
    │   ├── legality/
    │   ├── numeric/
    │   └── dispatch/
    └── <pto-class>/<MNEMONIC>.asl
```

The active docs tree has the same relative paths. A source such as
`asl/tile/memory/TLOAD.asl` owns `docs/tile/memory/TLOAD.md` and the test
directory `tests/asl/tile/memory/TLOAD/`.

Core tooling responsibilities:

- `scripts/asl_units.py`: parse unit metadata, validate four-surface paths, enforce the line limit, resolve dependencies, and produce deterministic order.
- `scripts/check-asl-layout`: command-line structural gate over `asl_units.py`.
- `scripts/generate-asl-source-order`: emit the deterministic assembly order and generated decoder insertion marker.
- `scripts/project_asl_catalogs.py`: reproduce checked-in catalogs from instruction metadata.
- `scripts/asl_tests.py`: parse test metadata, validate path/source/requirement ownership, and build the exact-head test matrix and coverage report.
- `scripts/check-asl-tests`: lightweight test-index and coverage gate.
- `scripts/run-asl-test`: assemble the normative model plus one test point and execute it with ASLRef.
- `scripts/print-asl-test-matrix`: emit GitHub Actions paging data from the exact commit.
- `scripts/instruction_docs.py`: generate every active page and MkDocs navigation from unit metadata and ASL documentation regions.

---

### Task 1: Record and Commit the Existing Release Fixture Corrections

**Files:**
- Modify: `tests/asl/bundle-tests.asl`
- Modify: `tests/asl/tepl-totality-tests.asl`
- Modify: `tests/asl/tlsu-totality-tests.asl`

**Interfaces:**
- Consumes: current ASL model and the existing `make test-shard-*` targets.
- Produces: an independently recorded fixture baseline on which every structural move is based; runtime proof is deferred to the final exact-head release gate.

- [x] **Step 1: Record the exact pending diff and assert no production ASL changed**

Run:

```bash
git diff -- tests/asl/bundle-tests.asl tests/asl/tepl-totality-tests.asl tests/asl/tlsu-totality-tests.asl
git diff --quiet -- asl scripts spec docs .github Makefile
```

Expected: the first command shows only fixture size/shape/order corrections; the second exits 0.

- [x] **Step 2: Confirm each correction is exercised by a final-release test point**

Run:

```bash
rg -n 'ConfigureTeplTile|ConfigureTlsu|B\.IOT|SetBundleDimension|TLOAD|TSTORE' \
  tests/asl/bundle-tests.asl tests/asl/tepl-totality-tests.asl tests/asl/tlsu-totality-tests.asl
```

Expected: every changed fixture is part of an existing named test that Task 12 will migrate into an independently executable final-release test point.

- [x] **Step 3: Run the lightweight repository gate**

Run:

```bash
make pr-check
git diff --check
```

Expected: both commands exit 0.

Do not run ASLRef shards in this task. Task 14 runs the complete exact-head release suite after the structural migration and projection cutover are finished.

- [x] **Step 4: Commit only the fixture corrections**

```bash
git add tests/asl/bundle-tests.asl tests/asl/tepl-totality-tests.asl tests/asl/tlsu-totality-tests.asl
git commit -m "test: correct release shard fixtures"
```

---

### Task 2: Introduce ASL Unit Discovery and Four-Surface Layout Validation

**Files:**
- Create: `scripts/asl_units.py`
- Create: `scripts/check-asl-layout`
- Create: `scripts/compare-asl-semantic-surface`
- Create: `tests/scripts/test_asl_units.py`
- Create: `tests/scripts/test_compare_asl_semantic_surface.py`
- Modify: `scripts/check-repository`

**Interfaces:**
- Consumes: one-line `PTO-UNIT` JSON records and extended `PTO-INSTRUCTION` JSON records.
- Produces:
  - `AslUnit(unit_id: str, surface: str, classification: tuple[str, ...], depends_on: tuple[str, ...], source_path: pathlib.Path, mnemonic: str | None)`
  - `load_units(root: pathlib.Path) -> tuple[AslUnit, ...]`
  - `validate_layout(root: pathlib.Path, units: Sequence[AslUnit]) -> list[str]`
  - `validate_surface(root: pathlib.Path, surface: str, units: Sequence[AslUnit]) -> list[str]`
  - `topological_order(units: Sequence[AslUnit], synthetic_nodes: tuple[str, ...] = ("generated:decoders",)) -> tuple[str, ...]`
  - `compare_ref_to_tree(repo: pathlib.Path, before_ref: str, after_root: pathlib.Path, surfaces: tuple[str, ...]) -> list[str]`

- [x] **Step 1: Write parser and validation tests**

Add tests that construct temporary four-surface trees and assert:

```python
def test_load_units_accepts_one_unit_per_matching_path(self):
    unit = load_units(self.root)[0]
    self.assertEqual(unit.unit_id, "PTO-ARCH-MEMORY-ORDERING")
    self.assertEqual(unit.surface, "arch")
    self.assertEqual(unit.classification, ("memory-model", "ordering"))

def test_validate_layout_rejects_fifth_root(self):
    (self.root / "numeric").mkdir()
    self.assertIn("unexpected ASL root entry: numeric", validate_layout(self.root, ()))

def test_validate_layout_rejects_metadata_path_mismatch(self):
    self.assertIn(
        "classification does not match path",
        "\n".join(validate_layout(self.root, load_units(self.root))),
    )

def test_validate_layout_rejects_501_lines(self):
    self.assertIn("exceeds 500 physical lines", "\n".join(validate_layout(self.root, load_units(self.root))))

def test_topological_order_rejects_cycle(self):
    with self.assertRaisesRegex(ValueError, "dependency cycle"):
        topological_order(self.units)
```

- [x] **Step 2: Run the tests and observe the missing module failure**

Run:

```bash
python3 -m unittest tests.scripts.test_asl_units -v
```

Expected: FAIL because `scripts.asl_units` does not exist.

- [x] **Step 3: Implement the unit model and CLI**

Use these exact record rules in `scripts/asl_units.py`:

```python
@dataclass(frozen=True)
class AslUnit:
    unit_id: str
    surface: str
    classification: tuple[str, ...]
    depends_on: tuple[str, ...]
    source_path: Path
    mnemonic: str | None

UNIT_PREFIX = "// PTO-UNIT: "
INSTRUCTION_PREFIX = "// PTO-INSTRUCTION: "
APPROVED_SURFACES = ("arch", "block", "scalar", "tile")
MAX_HANDWRITTEN_LINES = 500
```

`load_units()` MUST scan `root.rglob("*.asl")`, require exactly one metadata record per file, derive the expected surface/classification from the relative parent path, and sort by POSIX path. `validate_layout()` MUST report all errors in one run. `validate_surface()` MUST enforce metadata, path, dependency, and line-limit rules for one migrated surface while ignoring unmigrated sibling roots. `check-asl-layout` MUST print each error to stderr and return 1 when any error exists; `--surface <name>` selects `validate_surface()`, while no option selects strict whole-tree validation.

- [x] **Step 4: Prove the checker catches all structural canaries**

Run:

```bash
python3 -m unittest tests.scripts.test_asl_units -v
```

Expected: PASS for duplicate IDs, missing dependencies, cycles, root-entry, path mismatch, missing metadata, duplicate metadata, and 501-line canaries.

- [x] **Step 5: Implement Git-backed semantic-surface comparison**

`scripts/compare-asl-semantic-surface` MUST read the before tree with `git ls-tree` and `git show`, parse named ASL constants/types/globals/functions/procedures, strip comments and metadata, normalize whitespace, and compare each symbol signature and body hash with the current tree. It accepts:

```text
--before-ref <commit>
--after-root <path>
--surface <arch|block|scalar|tile>  # repeatable
```

The test MUST prove that pure moves/splits pass while a changed expression, removed declaration, duplicated symbol, or signature change fails.

Run:

```bash
python3 -m unittest tests.scripts.test_compare_asl_semantic_surface -v
```

Expected: PASS.

- [x] **Step 6: Add an opt-in repository check without breaking the old tree**

Add `--four-surface` to `scripts/check-repository`; when present it invokes `scripts/check-asl-layout`. Do not add it to `make pr-check` until Task 13.

Run:

```bash
./scripts/check-repository
python3 -m unittest tests.scripts.test_asl_units -v
```

Expected: both commands exit 0 on the transitional tree.

- [x] **Step 7: Commit**

```bash
git add scripts/asl_units.py scripts/check-asl-layout scripts/compare-asl-semantic-surface scripts/check-repository tests/scripts/test_asl_units.py tests/scripts/test_compare_asl_semantic_surface.py
git commit -m "feat: validate ASL unit layout"
```

---

### Task 3: Permit Only the Non-Normative Status Archive

**Files:**
- Modify: `scripts/ndf.py`
- Modify: `tests/scripts/test_ndf.py`
- Create: `docs/status/legacy/README.md`

**Interfaces:**
- Consumes: repository-relative documentation paths and parsed NDF references.
- Produces: `is_allowed_legacy_path(path: pathlib.PurePosixPath) -> bool`, true only below `docs/status/legacy/`.

- [x] **Step 1: Add narrow archive tests**

Add tests asserting:

```python
def test_status_legacy_is_allowed_as_nonnormative_storage(self):
    self.assertTrue(is_allowed_legacy_path(PurePosixPath("docs/status/legacy/old.md")))

def test_other_legacy_tree_is_rejected(self):
    self.assertFalse(is_allowed_legacy_path(PurePosixPath("docs/legacy/old.md")))

def test_normative_reference_into_status_legacy_is_rejected(self):
    errors = validate_reference(self.active_clause, "docs/status/legacy/old.md")
    self.assertIn("normative reference targets non-normative legacy material", errors)
```

- [x] **Step 2: Run the focused test and observe the missing API failure**

Run:

```bash
python3 -m unittest tests.scripts.test_ndf -v
```

Expected: FAIL because `is_allowed_legacy_path` is not defined.

- [x] **Step 3: Implement the narrow exception and archive notice**

Use:

```python
STATUS_LEGACY_PREFIX = PurePosixPath("docs/status/legacy")

def is_allowed_legacy_path(path: PurePosixPath) -> bool:
    return path == STATUS_LEGACY_PREFIX or STATUS_LEGACY_PREFIX in path.parents
```

The archive README MUST state that every descendant is historical, non-normative, excluded from active navigation, excluded from NDF requirement resolution, and retained only for Git-facing discovery.

- [x] **Step 4: Run NDF and publication checks**

Run:

```bash
python3 -m unittest tests.scripts.test_ndf -v
./scripts/check-ndf
./scripts/check-publication-hygiene
```

Expected: all commands exit 0.

- [x] **Step 5: Commit**

```bash
git add scripts/ndf.py tests/scripts/test_ndf.py docs/status/legacy/README.md
git commit -m "feat: define nonnormative status archive"
```

---

### Task 4: Derive Deterministic ASL Source Order

**Files:**
- Create: `scripts/generate-asl-source-order`
- Create: `tests/scripts/test_asl_source_order.py`

**Interfaces:**
- Consumes: `load_units()` and `topological_order()` from `scripts/asl_units.py`.
- Produces: `build/asl-source-order.txt`, one path per line, with the exact synthetic line `@generated-decoder@` at the declared decoder dependency position.

- [x] **Step 1: Write deterministic-order tests**

Cover dependency ordering, path-order tie breaking, the decoder marker, missing marker dependencies, and byte-identical repeated generation:

```python
first = generate_source_order(root)
second = generate_source_order(root)
self.assertEqual(first, second)
self.assertLess(first.index("asl/arch/state/base.asl"), first.index("asl/scalar/alu/ADD.asl"))
self.assertEqual(first.count("@generated-decoder@"), 1)
```

- [x] **Step 2: Run the focused test and observe the missing generator failure**

Run:

```bash
python3 -m unittest tests.scripts.test_asl_source_order -v
```

Expected: FAIL because the generator is absent.

- [x] **Step 3: Implement source-order generation**

`scripts/generate-asl-source-order` MUST support:

```text
--root <repository-root>
--output <path>
--check
```

`--check` compares generated bytes with the output and returns 1 on drift. `scripts/assemble-asl` MUST read this file, splice generated decoder declarations at `@generated-decoder@`, and reject duplicate or missing paths.

- [x] **Step 4: Run tests against a complete four-surface fixture**

Run:

```bash
python3 -m unittest tests.scripts.test_asl_source_order -v
```

Expected: tests pass and repeated generation of the fixture is byte-identical.

- [x] **Step 5: Commit**

```bash
git add scripts/generate-asl-source-order tests/scripts/test_asl_source_order.py
git commit -m "feat: derive deterministic ASL source order"
```

---

### Task 5: Migrate and Split the Architecture Surface

**Files:**
- Move/split: `asl/architecture.asl`
- Move/split: `asl/types.asl`
- Move/split: `asl/state.asl`
- Move/split: `asl/concurrency.asl`
- Move/split: `asl/numeric/formats.asl`
- Move/split: `asl/profiles/pto-v0.asl`
- Move: `asl/dispatch.asl` to `asl/arch/dispatch/top-level.asl`
- Create: architecture leaves listed under `asl/arch/` in the approved design
- Create: `tests/scripts/test_arch_migration.py`
- Modify: `Makefile`

**Interfaces:**
- Consumes: stable unit metadata and dependency ordering from Tasks 2 and 4.
- Produces: architecture-wide declarations and functions below `asl/arch/`, with no `asl/numeric/`, `asl/profiles/`, or architecture root files.

- [x] **Step 1: Capture a declaration and function inventory**

Add a test that reads `PTO_MIGRATION_BASE_REF` (set to `git merge-base origin/main HEAD`) and parses the pre-migration baseline with `git show "$PTO_MIGRATION_BASE_REF:<path>"`. Compare named declarations with the migrated tree. The expected inventory MUST include every type, global variable, function, procedure, and constant from the seven old source files.

```python
self.assertEqual(old_symbols, new_symbols)
self.assertEqual(old_function_signatures, new_function_signatures)
```

- [x] **Step 2: Run the inventory test before moves**

Run:

```bash
PTO_MIGRATION_BASE_REF="$(git merge-base origin/main HEAD)" python3 -m unittest tests.scripts.test_arch_migration -v
```

Expected: FAIL because `asl/arch/` is incomplete.

- [x] **Step 3: Split base and state ownership with `git mv` plus extraction commits**

Use these boundaries:

```text
asl/arch/overview/architecture.asl                 architecture constants
asl/arch/overview/instruction-classification.asl   execution-surface and class enums
asl/arch/data-types/integer.asl                    integer/index/base types
asl/arch/data-types/floating-point.asl             floating types and rounding modes
asl/arch/data-types/packed.asl                     packed and sub-byte formats
asl/arch/data-types/tile-data-types.asl            tile dtype and layout types
asl/arch/data-types/numeric-classification.asl     zero/normal/subnormal/NaN/infinity helpers
asl/arch/programming-model/core-pe-topology.asl    core, PE, queue topology
asl/arch/programming-model/scalar-registers.asl    GPR declarations and accessors
asl/arch/programming-model/predicate-registers.asl predicate state and accessors
asl/arch/programming-model/tile-registers.asl      local tile register state
asl/arch/programming-model/shared-tile-registers.asl shared S0-S255 state
asl/arch/state/program-counter.asl                  PC/TPC/BPC state and accessors
asl/arch/state/execution-mask.asl                   PE mask state and helpers
asl/arch/state/trap-context.asl                     trap context type/save/recover
asl/arch/state/tile-descriptor.asl                  descriptor base types
asl/arch/state/definedness.asl                      undefined-value contracts
```

To preserve declaration-before-state assembly while keeping each unit cohesive,
the migration also creates `asl/arch/data-types/{fault,memory-model,memory-operations,system-registers,trap-context}.asl`,
`asl/block/model/state/types.asl`, `asl/scalar/model/types/operations.asl`, and
`asl/tile/model/state/types.asl`. Stateful behavior remains in the owning
architecture unit and these type units remain part of the same semantic-preservation inventory.

Every file receives one `PTO-UNIT` record whose classification matches its path. Dependencies MUST refer to unit IDs, not file paths.
Update the transitional explicit Makefile source list to the moved paths so `make build` remains usable during migration.

- [x] **Step 4: Split system-register and memory-model ownership**

Use these boundaries:

```text
asl/arch/system-registers/addressing.asl
asl/arch/system-registers/access-control.asl
asl/arch/system-registers/context.asl
asl/arch/system-registers/interrupt.asl
asl/arch/system-registers/timer.asl
asl/arch/system-registers/maintenance.asl
asl/arch/memory-model/address-space.asl
asl/arch/memory-model/memory-events.asl
asl/arch/memory-model/ordering.asl
asl/arch/memory-model/atomicity.asl
asl/arch/memory-model/fault-precision.asl
```

Move `MemoryEventIs*`, event creation, captured read-from, ordering, and recording functions to the matching memory-model unit without changing their bodies.

- [x] **Step 5: Split profile and feature ownership**

Move reset/time/numeric/trap profile functions under:

```text
asl/arch/profile/reset.asl
asl/arch/profile/applicability.asl
asl/arch/profile/reference-profile.asl
asl/arch/features/predication.asl
asl/arch/features/mx-formats.asl
asl/arch/features/tile-allocation.asl
asl/arch/features/shared-tile-state.asl
```

Move block-specific profile encoding maps to `asl/block/model/schema/profile-encoding.asl` and declare its architecture dependencies explicitly.

- [x] **Step 6: Verify symbol preservation, layout, and line limits**

Run:

```bash
PTO_MIGRATION_BASE_REF="$(git merge-base origin/main HEAD)" python3 -m unittest tests.scripts.test_arch_migration -v
./scripts/check-asl-layout --surface arch
baseline_ref="$(git merge-base origin/main HEAD)"
./scripts/compare-asl-semantic-surface --before-ref "$baseline_ref" --after-root asl \
  --surface arch --surface block --surface scalar --surface tile
make build
git diff --check
```

Expected: the symbol/signature inventory is identical, every new unit is at most 500 lines, and assembly succeeds.

- [x] **Step 7: Commit**

```bash
git add asl/arch asl/block/model/schema/profile-encoding.asl Makefile tests/scripts/test_arch_migration.py
git commit -m "refactor: split architecture ASL surface"
```

---

### Task 6: Merge Bundle Ownership into the Block Surface

**Files:**
- Move/split: `asl/bundle/state.asl`
- Move/split: `asl/bundle/dispatch.asl`
- Move: all block mnemonic sources into `asl/block/<classification>/<MNEMONIC>.asl`
- Create: focused units below `asl/block/model/`
- Create: `tests/scripts/test_block_migration.py`
- Modify: `Makefile`

**Interfaces:**
- Consumes: architecture types/state and `profile-encoding.asl` from Task 5.
- Produces: `PTO-BLOCK-*` units for block state, lifecycle, operands, schema, commit, faults, command families, and top-level dispatch.

- [x] **Step 1: Write block symbol and instruction-record preservation tests**

Compare the old bundle/block files with the new tree:

```python
self.assertEqual(old_block_symbols, new_block_symbols)
self.assertEqual(old_instruction_records, new_instruction_records)
self.assertFalse((repo / "asl/bundle").exists())
```

Also assert one mnemonic per file and that the metadata mnemonic equals the filename stem.

- [x] **Step 2: Run the test and observe the expected migration failure**

Run:

```bash
PTO_MIGRATION_BASE_REF="$(git merge-base origin/main HEAD)" python3 -m unittest tests.scripts.test_block_migration -v
```

Expected: FAIL while `asl/bundle/` remains.

- [x] **Step 3: Split state and lifecycle units**

Create focused files:

```text
asl/block/model/state/control-state.asl
asl/block/model/state/descriptor-state.asl
asl/block/model/state/binding-state.asl
asl/block/model/lifecycle/reset.asl
asl/block/model/lifecycle/begin.asl
asl/block/model/lifecycle/enter-stop.asl
asl/block/model/lifecycle/lifetime.asl
asl/block/model/operands/scalar-bindings.asl
asl/block/model/operands/tile-bindings.asl
asl/block/model/operands/shared-bindings.asl
asl/block/model/schema/header.asl
asl/block/model/schema/dimensions.asl
asl/block/model/schema/attributes.asl
asl/block/model/commit/validation.asl
asl/block/model/commit/effects.asl
asl/block/model/faults/rollback.asl
```

Do not rename public ASL functions during extraction.

- [x] **Step 4: Split dispatch by responsibility**

Create:

```text
asl/block/model/dispatch/decode.asl
asl/block/model/dispatch/descriptor-legality.asl
asl/block/model/dispatch/scalar-schema.asl
asl/block/model/dispatch/tile-schema.asl
asl/block/model/dispatch/numeric-control.asl
asl/block/model/dispatch/destination-shape.asl
asl/block/model/dispatch/shared-cube.asl
asl/block/model/dispatch/shared-tlsu.asl
asl/block/model/dispatch/tile-execution.asl
asl/block/model/dispatch/start.asl
asl/block/model/dispatch/commands.asl
asl/block/model/dispatch/top-level.asl
```

The top-level file MUST only select the already-defined start/command/stop handlers and remain below 150 lines.
Update the transitional explicit Makefile source list to preserve the old declaration order across the new files.

- [x] **Step 5: Move mnemonic files and update unit dependencies**

Use `git mv` for each mnemonic source. Preserve the existing `PTO-INSTRUCTION` JSON, add `id`, `surface`, `classification`, and `depends_on`, and ensure filename stem and mnemonic match exactly.

- [x] **Step 6: Verify preservation and run block-focused checks**

Run:

```bash
PTO_MIGRATION_BASE_REF="$(git merge-base origin/main HEAD)" python3 -m unittest tests.scripts.test_block_migration -v
./scripts/check-asl-layout --surface block
baseline_ref="$(git merge-base origin/main HEAD)"
./scripts/compare-asl-semantic-surface --before-ref "$baseline_ref" --after-root asl \
  --surface arch --surface block --surface scalar --surface tile
make build
```

Expected: all commands exit 0 and `find asl -maxdepth 1 -name bundle` prints nothing.

Do not run ASLRef shards or catalog/evidence closure during this structural task.
Task 9 regenerates catalog projections from the migrated ASL authority, and Task 14
runs the complete exact-head runtime and release-evidence suite.

- [x] **Step 7: Commit**

```bash
git add -A asl/block asl/bundle Makefile tests/scripts/test_block_migration.py
git commit -m "refactor: merge bundle ASL into block"
```

---

### Task 7: Split Scalar Common Execution by Class

**Files:**
- Move/split: `asl/scalar/dispatch.asl`
- Move/split: scalar common types from old aggregate files
- Update: every scalar mnemonic file metadata
- Create: `tests/scripts/test_scalar_migration.py`
- Modify: `Makefile`

**Interfaces:**
- Consumes: architecture state/data types and block scalar-binding contracts.
- Produces: scalar model units under `asl/scalar/model/types/` and `asl/scalar/model/dispatch/`.

- [ ] **Step 1: Write scalar symbol, encoding, and mnemonic ownership tests**

Assert that old and new scalar function signatures and `PTO-INSTRUCTION` records are equal after removing only the newly added unit fields.

- [ ] **Step 2: Run the focused test and observe the expected aggregate-file failure**

Run:

```bash
PTO_MIGRATION_BASE_REF="$(git merge-base origin/main HEAD)" python3 -m unittest tests.scripts.test_scalar_migration -v
```

Expected: FAIL because `asl/scalar/dispatch.asl` still owns every class.

- [ ] **Step 3: Split scalar types and dispatch**

Create:

```text
asl/scalar/model/types/operations.asl
asl/scalar/model/types/operands.asl
asl/scalar/model/dispatch/decode.asl
asl/scalar/model/dispatch/alu.asl
asl/scalar/model/dispatch/bru.asl
asl/scalar/model/dispatch/sys.asl
asl/scalar/model/dispatch/amo.asl
asl/scalar/model/dispatch/agu.asl
asl/scalar/model/dispatch/fsu.asl
asl/scalar/model/dispatch/top-level.asl
```

Move function bodies unchanged by the existing class boundaries. The top-level dispatcher MUST select one class dispatcher and remain below 120 lines.
Update the transitional explicit Makefile source list to preserve the old declaration order across the split class files.

- [ ] **Step 4: Extend mnemonic metadata without changing catalog payloads**

For every scalar mnemonic, add stable unit fields while keeping `catalog_records`, `catalog_indices`, encoding values, constraints, and documentation regions byte-equivalent after JSON normalization.

- [ ] **Step 5: Verify scalar preservation**

Run:

```bash
PTO_MIGRATION_BASE_REF="$(git merge-base origin/main HEAD)" python3 -m unittest tests.scripts.test_scalar_migration -v
./scripts/check-asl-layout --surface scalar
baseline_ref="$(git merge-base origin/main HEAD)"
./scripts/compare-asl-semantic-surface --before-ref "$baseline_ref" --after-root asl \
  --surface arch --surface block --surface scalar --surface tile
make build
```

Expected: every command exits 0.

Catalog/evidence projection and ASLRef runtime checks remain deferred to Tasks 9
and 14 respectively.

- [ ] **Step 6: Commit**

```bash
git add asl/scalar Makefile tests/scripts/test_scalar_migration.py
git commit -m "refactor: split scalar ASL execution classes"
```

---

### Task 8: Split Tile State, Legality, Memory, Numeric, and Dispatch

**Files:**
- Move/split: `asl/tile/state.asl`
- Move/split: `asl/tile/legality.asl`
- Move/split: `asl/tile/memory.asl`
- Move/split: remaining tile common aggregates
- Update: every tile mnemonic file metadata and classification path
- Create: `tests/scripts/test_tile_migration.py`
- Modify: `scripts/assemble-asl`
- Modify: `Makefile`

**Interfaces:**
- Consumes: architecture tile data types, allocation, memory model, and block tile-binding contracts.
- Produces: focused `PTO-TILE-*` model units and one mnemonic source for every PTO tile operation.

- [ ] **Step 1: Write tile preservation and taxonomy tests**

The test MUST compare old/new symbols, normalized instruction records, and the checked PTO taxonomy source. It MUST reject a mnemonic stored outside its catalog classification.

- [ ] **Step 2: Run the focused test and observe the expected aggregate-file failure**

Run:

```bash
PTO_MIGRATION_BASE_REF="$(git merge-base origin/main HEAD)" python3 -m unittest tests.scripts.test_tile_migration -v
```

Expected: FAIL because one or more tile common files exceed 500 lines and tile metadata lacks stable unit fields.

- [ ] **Step 3: Split tile state and shape/capacity units**

Create:

```text
asl/tile/model/state/local-registers.asl
asl/tile/model/state/shared-registers.asl
asl/tile/model/state/descriptors.asl
asl/tile/model/state/allocation.asl
asl/tile/model/definedness/elements.asl
asl/tile/model/shape/rows-columns.asl
asl/tile/model/shape/valid-region.asl
asl/tile/model/capacity/local.asl
asl/tile/model/capacity/shared.asl
```

Keep `rows`, `columns`, `valid_rows`, `valid_columns`, `TSize`, dtype, and PE-mask contracts in their owning units without duplicating formulas.

- [ ] **Step 4: Split legality by independent constraint domain**

Create:

```text
asl/tile/model/legality/descriptor-shape.asl
asl/tile/model/legality/allocation-capacity.asl
asl/tile/model/legality/dtype-layout.asl
asl/tile/model/legality/operand-schema.asl
asl/tile/model/legality/matrix-shape.asl
asl/tile/model/legality/pe-mask.asl
```

Each exported legality predicate MUST have one owning file and all callers MUST depend on that unit ID.

- [ ] **Step 5: Split memory and numeric behavior**

Create:

```text
asl/tile/model/memory/addressing.asl
asl/tile/model/memory/stride.asl
asl/tile/model/memory/load-store.asl
asl/tile/model/memory/gather-scatter.asl
asl/tile/model/memory/atomics.asl
asl/tile/model/memory/restart.asl
asl/tile/model/numeric/formats.asl
asl/tile/model/numeric/rounding.asl
asl/tile/model/numeric/exceptions.asl
```

Preserve TLOAD/TSTORE stride encoding and omitted/default/encoded-zero distinctions exactly.

- [ ] **Step 6: Split dispatch and move mnemonic files to PTO taxonomy paths**

Create one dispatcher per tile class plus `asl/tile/model/dispatch/top-level.asl`. Use `git mv` for mnemonic files and retain their encoding/operation metadata unchanged except for unit fields.

- [ ] **Step 7: Prove assembled-tree and focused behavior equivalence**

Run:

```bash
PTO_MIGRATION_BASE_REF="$(git merge-base origin/main HEAD)" python3 -m unittest tests.scripts.test_tile_migration -v
./scripts/check-asl-layout
./scripts/generate-asl-source-order --root . --output build/asl-source-order.txt
make build
git diff --check
```

Expected: all commands exit 0; every ASL file is at most 500 lines.

Catalog/evidence projection and ASLRef runtime checks remain deferred to Tasks 9
and 14 respectively.

- [ ] **Step 8: Cut the assembler over to generated source order**

Remove `ASL_SOURCES_BEFORE_DECODER`, `ASL_MNEMONIC_SOURCES`, and `ASL_SOURCES_AFTER_DECODER`. Add:

```make
ASL_SOURCE_ORDER := build/asl-source-order.txt

$(ASL_SOURCE_ORDER): scripts/generate-asl-source-order
	@mkdir -p build
	./scripts/generate-asl-source-order --root . --output $@

$(SPEC): $(ASL_SOURCE_ORDER) $(DECODER_SPEC) scripts/assemble-asl
	./scripts/assemble-asl --order $(ASL_SOURCE_ORDER) --decoder $(DECODER_SPEC) --output $@
```

Extend `scripts/assemble-asl` with the exact `--order`, `--decoder`, and `--output` options. It MUST splice the decoder at `@generated-decoder@` and reject an absent/duplicate marker or absent/duplicate source path.

- [ ] **Step 9: Prove migration equivalence and commit**

Compare normalized named symbols and bodies directly with the Git baseline:

```bash
baseline_ref="$(git merge-base origin/main HEAD)"
./scripts/compare-asl-semantic-surface --before-ref "$baseline_ref" --after-root asl --surface arch --surface block --surface scalar --surface tile
make clean build
```

Expected: semantic comparison exits 0 with `ASL named signatures and bodies preserved`; clean generated-order assembly succeeds.

```bash
git add asl scripts tests/scripts/test_tile_migration.py Makefile
git commit -m "refactor: split tile ASL model"
```

---

### Task 9: Project Catalogs and Decoders from ASL Metadata

**Files:**
- Create: `scripts/project_asl_catalogs.py`
- Create: `tests/scripts/test_asl_catalog_projection.py`
- Modify: `scripts/check-catalogs`
- Modify: decoder generation scripts identified by `rg -l 'catalog_records|catalog_indices' scripts`
- Update: checked-in catalog and decoder projections

**Interfaces:**
- Consumes: mnemonic `PTO-INSTRUCTION` records with `catalog_records` and `catalog_indices`.
- Produces:
  - `project_catalogs(units: Sequence[AslUnit]) -> dict[pathlib.Path, bytes]`
  - deterministic scalar forms, command forms, tile-operation catalogs, and decoder declarations.

- [ ] **Step 1: Write round-trip and conflict tests**

Cover byte-identical projection, duplicate catalog slot rejection, missing slot rejection, conflicting record rejection, and deterministic JSON formatting.

```python
projected = project_catalogs(load_units(repo / "asl"))
self.assertEqual(projected[Path("spec/catalog/scalar-forms.json")], committed_bytes)
```

- [ ] **Step 2: Run the focused test and observe the missing projector failure**

Run:

```bash
python3 -m unittest tests.scripts.test_asl_catalog_projection -v
```

Expected: FAIL because `project_asl_catalogs.py` does not exist.

- [ ] **Step 3: Implement projection and `--check`**

The CLI MUST accept:

```text
--root <repository-root>
--write
--check
```

Records are sorted by `catalog_indices`; JSON uses UTF-8, two-space indentation, sorted object keys only where the current artifact contract requires it, and one final newline. Conflicting ownership is a hard error.

- [ ] **Step 4: Make decoder generation consume in-memory projected records**

Decoder generators MUST import `project_catalogs()` or the parsed instruction records directly. They MUST NOT read catalog JSON as an architecture authority.

- [ ] **Step 5: Regenerate and prove exactness**

Run:

```bash
python3 scripts/project_asl_catalogs.py --root . --write
python3 scripts/project_asl_catalogs.py --root . --check
./scripts/check-catalogs
./scripts/check-binary-closure
python3 -m unittest tests.scripts.test_asl_catalog_projection -v
```

Expected: all commands exit 0 and `git diff` shows no semantic catalog delta.

- [ ] **Step 6: Commit**

```bash
git add scripts spec tests/scripts/test_asl_catalog_projection.py
git commit -m "feat: project catalogs from ASL units"
```

---

### Task 10: Generate the Exact Documentation Mirror and Status Taxonomy

**Files:**
- Modify: `scripts/instruction_docs.py`
- Modify: `tests/scripts/test_instruction_docs.py`
- Modify: `docs/mkdocs/mkdocs.yml`
- Move: valid ADRs to `docs/status/decisions/`
- Move: open-question records to `docs/status/open/`
- Move: DavinciOO, outdated root pages, superseded projections, and committed old HTML to `docs/status/legacy/`
- Generate: `docs/arch/**/*.md`
- Generate: `docs/block/**/*.md`
- Generate: `docs/scalar/**/*.md`
- Generate: `docs/tile/**/*.md`
- Generate: MkDocs navigation projection

**Interfaces:**
- Consumes: every `AslUnit`, its NDF clauses, and ASL documentation regions.
- Produces: `render_unit_page(unit: AslUnit, source_text: str) -> str` and a deterministic navigation tree matching ASL order.

- [ ] **Step 1: Write mirror and stale-content tests**

Add assertions for:

```python
self.assertEqual(doc_path_for(Path("asl/arch/state/program-counter.asl")), Path("docs/arch/state/program-counter.md"))
self.assertEqual(doc_path_for(Path("asl/block/operands/B.IOR.asl")), Path("docs/block/operands/B.IOR.md"))
self.assertEqual(set(discovered_doc_paths), set(expected_doc_paths))
```

Also test source-path declaration mismatch, orphan page, missing page, stale embedded region, legacy nav entry, and normative legacy link rejection.

- [ ] **Step 2: Run the focused test and observe old-path failures**

Run:

```bash
python3 -m unittest tests.scripts.test_instruction_docs -v
```

Expected: FAIL because pages are still rooted at `docs/instructions/` and non-mnemonic units lack generated pages.

- [ ] **Step 3: Extend the generator to every ASL unit**

Each generated page MUST begin with:

```markdown
<!-- GENERATED FROM: asl/arch/state/program-counter.asl -->
# Program Counter

**Normative ASL source:** `asl/arch/state/program-counter.asl`
```

The generator MUST preserve marked supplementary prose regions and replace only generated ASL/NDF regions. Mnemonic pages retain syntax, encoding, legality, operation, effects, faults, and examples derived from their owning ASL.

- [ ] **Step 4: Move decisions, open questions, and historical material**

Use `git mv` for decisions and open questions, preserving their stable NDF IDs and updating checked references. Add the non-normative banner immediately below the title of every legacy Markdown page:

```markdown
> Historical, non-normative material. This page is excluded from the active PTO architecture and release closure.
```

- [ ] **Step 5: Generate pages and navigation**

Run:

```bash
python3 scripts/instruction_docs.py --write
python3 scripts/instruction_docs.py --check
mkdocs build --config-file docs/mkdocs/mkdocs.yml --site-dir build/mkdocs-site --strict
```

Expected: all commands exit 0; generated navigation contains only `arch`, `block`, `scalar`, `tile`, and active status pages.

- [ ] **Step 6: Run documentation closure**

Run:

```bash
python3 -m unittest tests.scripts.test_instruction_docs -v
./scripts/check-ndf
./scripts/check-instruction-docs
./scripts/check-publication-hygiene
```

Expected: every active ASL source has exactly one mirrored page and no orphan active page exists.

- [ ] **Step 7: Commit**

```bash
git add scripts/instruction_docs.py tests/scripts/test_instruction_docs.py docs
git commit -m "docs: mirror the four ASL surfaces"
```

---

### Task 11: Define Independent ASL Test Metadata, Coverage, and Execution

**Files:**
- Create: `scripts/asl_tests.py`
- Create: `scripts/check-asl-tests`
- Create: `scripts/run-asl-test`
- Create: `scripts/print-asl-test-matrix`
- Create: `tests/scripts/test_asl_tests.py`
- Create: `tests/fixtures/asl-tests/` fixture trees

**Interfaces:**
- Consumes: `load_units()`, NDF requirement index, and test files below `tests/asl/<source-relative-without-suffix>/<ID>.asl`.
- Produces:
  - `AslTestPoint(test_id: str, source: pathlib.Path, requirements: tuple[str, ...], kind: str, summary: str, pass_condition: str, related_sources: tuple[pathlib.Path, ...], path: pathlib.Path, sha256: str)`
  - `load_test_points(root: pathlib.Path, units: Sequence[AslUnit]) -> tuple[AslTestPoint, ...]`
  - `validate_test_coverage(points: Sequence[AslTestPoint], units: Sequence[AslUnit], requirements: Mapping[str, bool]) -> list[str]`, where each boolean states whether the NDF requirement is executable.
  - `matrix(points: Sequence[AslTestPoint]) -> list[dict[str, object]]`

- [ ] **Step 1: Write fail-closed metadata and coverage tests**

Cover duplicate IDs, path mismatch, absent source, absent requirement, unsupported kind, zero/multiple `main()` declarations, cross-test function dependencies, missing unit coverage, missing executable requirement coverage, deterministic hashes, and exact JSON matrix fields.

```python
self.assertEqual(
    matrix((point,))[0].keys(),
    {"id", "path", "source", "requirements", "kind", "sha256"},
)
```

- [ ] **Step 2: Run the focused test and observe the missing module failure**

Run:

```bash
python3 -m unittest tests.scripts.test_asl_tests -v
```

Expected: FAIL because `scripts.asl_tests` does not exist.

- [ ] **Step 3: Implement metadata parsing and validation**

Use exact supported kinds:

```python
SUPPORTED_KINDS = frozenset({
    "decode-positive", "decode-negative", "execution", "boundary", "fault",
    "atomicity", "ordering", "state-transition", "static-invariant",
})
```

Require exactly one line beginning `// PTO-TEST: ` and parse `main` with the repository ASL declaration parser, not a raw substring count.

- [ ] **Step 4: Implement individual execution**

`scripts/run-asl-test --id PTO-AVS-...` MUST:

1. resolve the ID from `load_test_points()`;
2. regenerate source order and decoder projections;
3. assemble the complete normative model plus exactly one test file;
4. run the pinned ASLRef command with the existing timeout contract;
5. write `build/asl-test-results/<ID>/result.json` and `aslref.log`;
6. return nonzero for lookup, assembly, timeout, or execution failure.

- [ ] **Step 5: Implement exact matrix output**

`scripts/print-asl-test-matrix --page-size 200 --page 0` MUST emit one compact JSON object with `include` entries sorted by test ID and no omitted IDs. Page metadata includes `page`, `page_count`, `test_count`, and exact commit SHA.

- [ ] **Step 6: Run the tooling tests**

Run:

```bash
python3 -m unittest tests.scripts.test_asl_tests -v
./scripts/check-asl-tests --fixtures-only tests/fixtures/asl-tests/valid
```

Expected: all tests pass and the valid fixture emits a stable matrix.

- [ ] **Step 7: Commit**

```bash
git add scripts/asl_tests.py scripts/check-asl-tests scripts/run-asl-test scripts/print-asl-test-matrix tests/scripts/test_asl_tests.py tests/fixtures/asl-tests
git commit -m "feat: add independent ASL test points"
```

---

### Task 12: Replace Monolithic Shards with Mirrored Per-Unit AVS Tests

**Files:**
- Create: `scripts/generate-mnemonic-avs.py`
- Create: `tests/scripts/test_generate_mnemonic_avs.py`
- Generate: `tests/asl/{arch,block,scalar,tile}/**/PTO-AVS-*.asl`
- Remove: `tests/asl/main.asl`
- Remove: `tests/asl/shards/`
- Remove: old monolithic `tests/asl/*-tests.asl` libraries after every assertion is migrated
- Modify: NDF requirement metadata in owning ASL units where executable classification is missing

**Interfaces:**
- Consumes: mnemonic metadata, canonical catalog records, unit dependencies, and current test assertions.
- Produces: one generated canonical decode/static-invariant test per mnemonic plus focused manual behavior tests for every active unit and executable NDF requirement.

- [ ] **Step 1: Write mnemonic AVS generation tests**

For scalar, block, and tile fixtures, assert stable IDs, one `main()`, mirrored paths, canonical decode/operation checks, and byte-identical regeneration:

```python
self.assertEqual(path.name, "PTO-AVS-SCALAR-ADD-DECODE-001.asl")
self.assertEqual(document.count("integer main("), 1)
self.assertIn('"source":"asl/scalar/alu/ADD.asl"', document)
```

- [ ] **Step 2: Run the focused test and observe the missing generator failure**

Run:

```bash
python3 -m unittest tests.scripts.test_generate_mnemonic_avs -v
```

Expected: FAIL because the generator is absent.

- [ ] **Step 3: Implement deterministic mnemonic smoke tests**

Generate one checked-in test per mnemonic:

- scalar: decode the canonical word and assert handler, operation, and canonical operand selectors;
- block: decode the canonical word and assert command/start/stop handler and schema selector;
- tile: assert the registered operation selector, classification, and block composition contract.

Generated IDs use `PTO-AVS-<SURFACE>-<SANITIZED-MNEMONIC>-<KIND>-001`; sanitization replaces punctuation with single hyphens and uppercases ASCII.

- [ ] **Step 4: Generate mnemonic tests and verify them independently**

Run:

```bash
python3 scripts/generate-mnemonic-avs.py --write
python3 scripts/generate-mnemonic-avs.py --check
./scripts/check-asl-tests
```

Expected: generation is stable; the coverage checker now reports only non-mnemonic units or executable semantic requirements that lack focused behavior tests.

- [ ] **Step 5: Migrate architecture behavior tests by primary owner**

Create one-file tests below each owning architecture unit for reset, registers, predicates, PC/trap context, system registers, memory events, ordering, atomicity, numeric classification, tile allocation, shared state, and reference profile behavior. Copy the existing assertions and their smallest test-local helpers; do not call another test file.

- [ ] **Step 6: Migrate block behavior tests by primary owner**

Split lifecycle, schema/defaults, B.IOR, B.IOS, B.IOT, descriptor, commit, rollback, zero-mask, shared allocation, and command-totality assertions into mirrored one-main files. Cross-unit tests declare `related_sources` but reside under one primary source.

- [ ] **Step 7: Migrate scalar behavior tests by mnemonic/model owner**

Split class decode, execution, selector-boundary, duplicate operand, absent/default, fault, AMO atomicity, AGU address, FSU numeric, and SYS state-transition assertions into independent files.

- [ ] **Step 8: Migrate tile behavior tests by mnemonic/model owner**

Split shape/capacity/valid-region, dtype/layout, matrix power-of-two, TLSU stride/default/encoded-zero, U4X2 indexing, TEPL, gather/scatter, atomic, shared/local, and totality assertions into independent files.

- [ ] **Step 9: Prove assertion and requirement closure before deletion**

Add a migration test that inventories old named test functions from the baseline commit and maps each to one new `PTO-TEST` ID. Run:

```bash
python3 -m unittest tests.scripts.test_generate_mnemonic_avs -v
./scripts/check-asl-tests
python3 scripts/print-asl-test-matrix --page-size 10000 --page 0 > build/asl-test-matrix.json
```

Expected: zero unmapped old test functions, zero uncovered units, zero uncovered executable requirements, and a matrix entry for every discovered file.

- [ ] **Step 10: Remove aggregate test infrastructure and reject its return**

Delete `tests/asl/main.asl`, `tests/asl/shards/`, and monolithic libraries. Add canaries to `test_asl_tests.py` that reject those paths and reject any test file outside the mirrored source directory.

- [ ] **Step 11: Run a bounded independent smoke set**

Run one test ID from each surface:

```bash
./scripts/run-asl-test --id PTO-AVS-ARCH-PROGRAM-COUNTER-STATE-001
./scripts/run-asl-test --id PTO-AVS-BLOCK-B-IOR-EXECUTION-001
./scripts/run-asl-test --id PTO-AVS-SCALAR-ADD-EXECUTION-001
./scripts/run-asl-test --id PTO-AVS-TILE-TLOAD-EXECUTION-001
```

Expected: all four return 0 and create separate result directories.

- [ ] **Step 12: Commit**

```bash
git add scripts/generate-mnemonic-avs.py tests/asl tests/scripts/test_generate_mnemonic_avs.py tests/scripts/test_asl_tests.py asl
git commit -m "test: split ASL verification into mirrored AVS points"
```

---

### Task 13: Cut Over Lightweight PR Checks and Dynamic Release Parallelism

**Files:**
- Modify: `Makefile`
- Modify: `.github/workflows/asl.yml`
- Modify: `.github/workflows/release.yml`
- Modify: `scripts/check-release-workflow`
- Modify: `tests/scripts/test_release_workflow.py`
- Create: `scripts/run-asl-release-suite`
- Create: `tests/scripts/test_run_asl_release_suite.py`
- Remove: `scripts/check-asl-test-shards`
- Remove: hand-maintained shard variables and per-shard targets

**Interfaces:**
- Consumes: `check-asl-layout`, projection `--check` modes, `check-asl-tests`, `print-asl-test-matrix`, and `run-asl-test`.
- Produces: lightweight `make pr-check`, local `make release-check RELEASE_COMMIT=<sha>`, and manual exact-head paged GitHub Actions matrices.

- [ ] **Step 1: Write workflow-contract tests**

Assert that PR CI contains no ASLRef install/run command and invokes these gates:

```text
check-asl-layout
check-ndf
check-asl-tests
project_asl_catalogs.py --check
instruction_docs.py --check
check-publication-hygiene
```

Assert that release CI obtains every matrix entry from `print-asl-test-matrix`, invokes `run-asl-test --id`, uploads per-ID results, checks the exact commit, and aggregates all pages fail-closed.

- [ ] **Step 2: Run workflow tests and observe old shard assumptions failing**

Run:

```bash
python3 -m unittest tests.scripts.test_release_workflow -v
```

Expected: FAIL because release still reads hand-maintained shard names.

- [ ] **Step 3: Replace Makefile shard lists**

Define:

```make
.PHONY: check-asl-layout check-ndf check-asl-tests check-projections check-publication-hygiene pr-check release-check

check-asl-layout:
	./scripts/check-asl-layout

check-ndf:
	./scripts/check-ndf

check-asl-tests:
	./scripts/check-asl-tests

check-projections:
	python3 scripts/project_asl_catalogs.py --root . --check
	python3 scripts/instruction_docs.py --check
	python3 scripts/generate-mnemonic-avs.py --check

check-publication-hygiene:
	python3 scripts/check-publication-hygiene

pr-check: check-asl-layout check-ndf check-asl-tests check-projections check-publication-hygiene
	git diff --check

release-check: pr-check toolchain-check check
	./scripts/run-asl-release-suite --commit "$(RELEASE_COMMIT)"
```

`pr-check` MUST not depend on `assemble-asl`, ASLRef, or any `run-asl-test` target.

- [ ] **Step 4: Build the release paging jobs**

The planning job checks out the requested exact SHA, runs lightweight checks, validates pinned ASLRef, writes `build/asl-test-matrix.json`, and emits page numbers. Each page job regenerates its page, verifies commit/hash equality with the plan artifact, and runs every included ID as its own matrix entry with bounded concurrency.

- [ ] **Step 5: Add fail-closed aggregation**

Aggregation MUST compare planned IDs with uploaded result IDs and hashes using set equality, reject missing/duplicate/unplanned results, require every status to equal `pass`, regenerate coverage, catalogs, decoder, docs, evidence, and manifest, then require a clean exact-head tree.

- [ ] **Step 6: Implement the local release-suite runner**

`scripts/run-asl-release-suite --commit <sha>` MUST reject a SHA different from `git rev-parse HEAD`, discover the full matrix, execute each ID through `scripts/run-asl-test`, aggregate the same result schema as hosted CI, write `build/asl-test-coverage.json`, write `spec/evidence/asl-test-matrix.sha256`, regenerate the release manifest, and return nonzero for any missing, duplicate, unplanned, failed, or hash-mismatched result.

Add unit tests using a fake test runner that cover exact-head mismatch, one pass, one failure, timeout, missing result, duplicate result, and complete set equality.

Run:

```bash
python3 -m unittest tests.scripts.test_run_asl_release_suite -v
```

Expected: PASS.

- [ ] **Step 7: Remove old shard code and run lightweight gates**

Run:

```bash
python3 -m unittest tests.scripts.test_release_workflow -v
make pr-check
git diff --check
```

Expected: all commands exit 0 and `rg 'ASL_TEST_SHARD|test-shard-|check-asl-test-shards' Makefile .github scripts tests/scripts` returns no active infrastructure references.

- [ ] **Step 8: Commit**

```bash
git add Makefile .github scripts tests/scripts/test_release_workflow.py tests/scripts/test_run_asl_release_suite.py
git commit -m "ci: discover independent ASL release tests"
```

---

### Task 14: Regenerate Release Evidence and Prove Final Closure

**Files:**
- Update: generated catalogs and decoders
- Update: generated docs and MkDocs navigation
- Update: release evidence and manifest paths used by the current release workflow
- Modify: `scripts/check-repository` to remove transitional old-path allowlists
- Modify: publication/closure tests to reject obsolete active trees

**Interfaces:**
- Consumes: the complete four-surface model, mirrored docs, independent AVS matrix, and release workflow from Tasks 1–13.
- Produces: a clean exact-head tree eligible for a manual release run.

- [ ] **Step 1: Add final obsolete-path canaries**

The repository checker MUST reject:

```text
asl/bundle
asl/numeric
asl/profiles
asl/architecture.asl
asl/types.asl
asl/state.asl
asl/concurrency.asl
asl/dispatch.asl
docs/instructions
tests/asl/main.asl
tests/asl/shards
```

It MUST also reject active Markdown outside the exact mirror or `docs/status/` ownership model.

- [ ] **Step 2: Regenerate every projection**

Run:

```bash
./scripts/generate-asl-source-order --root . --output build/asl-source-order.txt
python3 scripts/project_asl_catalogs.py --root . --write
python3 scripts/instruction_docs.py --write
python3 scripts/generate-mnemonic-avs.py --write
python3 scripts/print-asl-test-matrix --page-size 10000 --page 0 > build/asl-test-matrix.json
```

Expected: all generators exit 0.

- [ ] **Step 3: Run all lightweight checks twice**

Run:

```bash
make pr-check
make pr-check
git diff --check
```

Expected: both runs pass and the second run does not modify tracked files.

- [ ] **Step 4: Run the full manual release verification locally**

Run the repository release entry point bound to the current commit:

```bash
release_sha="$(git rev-parse HEAD)"
make release-check RELEASE_COMMIT="$release_sha"
```

Expected: pinned ASLRef validation passes, strict whole-model type-check passes, every matrix ID passes independently, all executable requirements are covered, and projections/evidence reproduce exactly.

- [ ] **Step 5: Inspect exact-head result equality**

Run:

```bash
test "$(git rev-parse HEAD)" = "$(git rev-parse HEAD^{commit})"
git status --short
sha256sum -c spec/evidence/asl-test-matrix.sha256
```

Expected: status is clean after committing regenerated release artifacts; the release evidence checksum validates `build/asl-test-matrix.json`.

- [ ] **Step 6: Request independent code and verification review**

Review must explicitly check:

- no ASL unit exceeds 500 lines;
- one mnemonic equals one ASL file and one page;
- no catalog/docs/test manifest is an independent architecture owner;
- every unit and executable requirement has an AVS owner;
- PR CI remains ASLRef-free;
- release matrix/result set equality is fail-closed;
- `docs/status/legacy/` cannot enter active closure.

- [ ] **Step 7: Commit regenerated closure artifacts**

```bash
git add -A
git commit -m "release: regenerate four-surface ASL evidence"
```

- [ ] **Step 8: Re-run final clean-tree gates on the committed exact head**

Run:

```bash
make pr-check
release_sha="$(git rev-parse HEAD)"
make release-check RELEASE_COMMIT="$release_sha"
test -z "$(git status --short)"
```

Expected: both gates exit 0 and the worktree is clean.

---

## Completion Evidence

The implementation is complete only when the final report includes:

- exact branch and commit SHA;
- `find asl -mindepth 1 -maxdepth 1 -print` showing only four directories;
- maximum hand-written ASL line count and owning path;
- counts of ASL units, mirrored pages, AVS test points, and executable NDF requirements;
- proof that uncovered units and uncovered executable requirements both equal zero;
- passing `make pr-check` output from the committed exact head;
- passing `make release-check RELEASE_COMMIT=<exact-sha>` output;
- clean `git status --short`;
- independent review verdict and any residual non-blocking risks.
