# ASL-Golden Instruction Reference Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Make mnemonic ASL files the normative instruction source and deterministically generate drift-free Markdown and MkDocs reference surfaces while enforcing power-of-two shape and derived-row legality.

**Architecture:** A checked instruction index maps each mnemonic to one mirrored ASL/Markdown path. ASL documentation regions and instruction metadata generate encoding/decode/operation Markdown regions and MkDocs navigation; hand-written Markdown remains only outside generated regions. Shape helpers enforce one per-PE capacity rule for Local, Shared, and Matrix tiles.

**Tech Stack:** ASL1, Python 3 standard library generators/checkers, Node.js intrinsic-document tooling, Markdown, MkDocs, GNU Make.

## Global Constraints

- ASL is the only normative source for instruction semantics and legality.
- Every active mnemonic has exactly one ASL file and one mirrored Markdown page.
- Generated Markdown regions must be byte-for-byte projections and fail closed on drift.
- Block ISA retains the `block/` name and BSTART/BSTOP/B.* scope.
- Scalar classification is AGU/ALU/AMO/BRU/FSU/SYS.
- Tile classification is sourced from `spec/encoding/PTO-ISA-Encoding.xlsx`.
- Ordinary Col and matrix M/N/K are nonzero powers of two.
- `rows` is derived from per-PE TSize, dtype, and physical columns.
- Active normative ASL and instruction pages contain no release-version label.
- Historical ADR and release records retain historical identifiers.
- No new runtime dependency is permitted.

---

### Task 1: Lock the instruction-index and embed contracts

**Files:**
- Create: `scripts/instruction_docs.py`
- Create: `tests/scripts/test_instruction_docs.py`
- Modify: `scripts/check-repository`
- Modify: `Makefile`

**Interfaces:**
- Produces: `InstructionRecord`, `load_instruction_index(root)`, `render_page(record)`, `check_tree(root)`, and CLI commands `generate`/`--check`.
- Consumes: mnemonic ASL metadata, `spec/catalog/*.json`, and Tile classification metadata synchronized from the workbook.

- [ ] **Step 1: Write failing tests for missing, duplicate, mismatched, and stale mappings**

Create temporary ASL/Markdown fixtures and assert that `check_tree()` rejects an ASL mnemonic without a page, a page without ASL, duplicate mnemonic metadata, a non-mirrored path, an unknown Tile category, and an edited generated ASL region.

- [ ] **Step 2: Run the focused tests and verify the expected import/behavior failures**

Run: `python3 -m unittest tests.scripts.test_instruction_docs -v`

Expected: failure because `scripts.instruction_docs` and its contract functions do not exist.

- [ ] **Step 3: Implement the minimal parser, mirrored-path validator, and generated-region checker**

Use only `dataclasses`, `json`, `pathlib`, `re`, and `argparse`. Parse stable line-comment metadata and `DOC-BEGIN`/`DOC-END` regions without evaluating ASL.

- [ ] **Step 4: Verify focused tests pass and wire the fail-closed repository check**

Run: `python3 -m unittest tests.scripts.test_instruction_docs -v`

Run: `python3 scripts/instruction_docs.py --check`

- [ ] **Step 5: Commit the checked generator contract**

```bash
git add scripts/instruction_docs.py tests/scripts/test_instruction_docs.py scripts/check-repository Makefile
git commit -m "feat: add ASL-golden instruction doc checks"
```

### Task 2: Generate Markdown regions and MkDocs navigation

**Files:**
- Modify: `scripts/instruction_docs.py`
- Modify: `tests/scripts/test_instruction_docs.py`
- Create: `docs/mkdocs/mkdocs.yml`
- Create: `docs/mkdocs/index.md`
- Create: `docs/mkdocs/overrides/main.html`
- Modify: `README.md`
- Modify: `AGENTS.md`

**Interfaces:**
- Produces: deterministic generated Markdown encoding/decode/operation regions and `docs/mkdocs/generated-nav.yml`.
- Consumes: Task 1 `InstructionRecord` and exact ASL region bytes.

- [ ] **Step 1: Add failing behavior tests for exact embedding and stable nav order**

Use literal fixture output to prove that generated regions contain their source path, exact ASL text, and stable Scalar/Block/Tile hierarchy. Mutating one ASL byte must make `--check` fail.

- [ ] **Step 2: Run the tests and observe failures caused by missing rendering behavior**

Run: `python3 -m unittest tests.scripts.test_instruction_docs -v`

- [ ] **Step 3: Implement generated-region replacement and nav generation**

Preserve all hand-written Markdown outside generated markers. Generate pages in the order Purpose, Encoding, Decode, Assembler Symbols, Operation, Legality, Operational Information, and Examples; Tile pages include Block Composition before Operation.

- [ ] **Step 4: Add agent indexing guidance and verify deterministic regeneration**

Run twice: `python3 scripts/instruction_docs.py generate`

Run: `git diff --exit-code` after the second generation.

- [ ] **Step 5: Commit the projection pipeline**

```bash
git add scripts/instruction_docs.py tests/scripts/test_instruction_docs.py docs/mkdocs README.md AGENTS.md
git commit -m "feat: generate instruction Markdown from ASL"
```

### Task 3: Refactor Scalar and Block instructions by mnemonic

**Files:**
- Move/split: `asl/scalar/*.asl` to `asl/scalar/{agu,alu,amo,bru,fsu,sys}/*.asl`
- Move: `docs/instructions/scalar/misa_*/*.md` to `docs/instructions/scalar/{agu,alu,amo,bru,fsu,sys}/*.md`
- Split: `asl/bundle/*.asl` mnemonic semantics to `asl/block/{lifecycle,operands,attributes,execution,encoding}/*.asl`
- Preserve/move: `docs/instructions/block/**/*.md` at mirrored ASL paths
- Modify: `asl/scalar/dispatch.asl`
- Modify: `asl/bundle/dispatch.asl`
- Modify: `Makefile`
- Modify: `scripts/intrinsic-docs/intrinsic_docs.mjs`
- Modify: `scripts/check-publication-hygiene`

**Interfaces:**
- Produces: one mnemonic entry point per ASL file and mirrored Markdown records.
- Consumes: Task 1 metadata/region syntax and existing generated decoder declarations.

- [ ] **Step 1: Add failing inventory tests for one-to-one Scalar and Block coverage**

Derive expected mnemonic sets from the canonical catalogs and assert exact equality with the ASL and Markdown mnemonic sets, including dotted mnemonics and multiple encoding forms consolidated under one mnemonic.

- [ ] **Step 2: Verify the inventory tests fail on current family/MISA trees**

Run: `python3 -m unittest tests.scripts.test_instruction_docs -v`

- [ ] **Step 3: Mechanically split mnemonic bodies while retaining common helpers**

Move only instruction-specific decode, legality, and effect functions. Keep types, shared arithmetic helpers, state, and dispatch infrastructure in explicit `common/` files. Update Makefile source order deterministically.

- [ ] **Step 4: Regenerate pages, run inventory checks, and type-check the assembled ASL**

Run: `python3 scripts/instruction_docs.py generate`

Run: `python3 scripts/instruction_docs.py --check`

Run: `make check`

- [ ] **Step 5: Commit Scalar and Block refactoring**

```bash
git add asl/scalar asl/block asl/bundle docs/instructions/scalar docs/instructions/block Makefile scripts
git commit -m "refactor: mirror scalar and block mnemonics"
```

### Task 4: Refactor Tile instructions using workbook classifications

**Files:**
- Split: `asl/tile/*.asl` to `asl/tile/<type>/<subtype>/<MNEMONIC>.asl`
- Move: `docs/instructions/tile/*.md` to matching classified paths
- Modify: `spec/catalog/tile-operations.json`
- Modify: `scripts/intrinsic-docs/intrinsic_docs.mjs`
- Modify: `scripts/intrinsic-docs/intrinsic_docs_lib.mjs`
- Modify: `scripts/intrinsic-docs/test_intrinsic_docs.mjs`
- Modify: `scripts/generate-instruction-reference`
- Modify: `scripts/generate-release-manifest`
- Modify: `Makefile`

**Interfaces:**
- Produces: a checked stable slug mapping for the workbook's type/subtype labels and one mirrored ASL/page pair for each active Tile mnemonic.
- Consumes: Task 1 instruction index and workbook-synchronized frontmatter category/subcategory fields.

- [ ] **Step 1: Add failing tests for exact workbook category and block-composition coverage**

Assert all active workbook mnemonics map exactly once, retain their type/subtype order, and expose a nonempty ordered block composition ending in BSTOP.

- [ ] **Step 2: Run tests and verify failures on the flat Tile tree and missing BSTOP contracts**

Run: `node --test scripts/intrinsic-docs/test_intrinsic_docs.mjs`

Run: `python3 -m unittest tests.scripts.test_instruction_docs -v`

- [ ] **Step 3: Split Tile ASL and relocate pages using the checked category mapping**

Preserve Excel order. Put operation-specific execution and legality in the mnemonic ASL file; leave reusable element, reduction, conversion, memory, and matrix helpers in category `common/` files.

- [ ] **Step 4: Generate complete Block Composition and ASL sections for every Tile page**

Each page records required/optional/defaulted/forbidden headers, repeated operand-header order, and exact BSTART-to-BSTOP assembly.

- [ ] **Step 5: Run Tile inventory, renderer, and ASL type checks**

Run: `node --test scripts/intrinsic-docs/test_intrinsic_docs.mjs scripts/intrinsic-docs/test_public_html.mjs`

Run: `python3 scripts/instruction_docs.py --check`

Run: `make check`

- [ ] **Step 6: Commit Tile refactoring**

```bash
git add asl/tile docs/instructions/tile spec/catalog/tile-operations.json scripts Makefile
git commit -m "refactor: classify tile mnemonics from PTO inventory"
```

### Task 5: Enforce power-of-two dimensions and derived rows

**Files:**
- Modify: `asl/tile/common/state.asl`
- Modify: `asl/tile/common/legality.asl`
- Modify: matrix mnemonic ASL files under `asl/tile/matrix/`
- Modify: memory mnemonic ASL files under `asl/tile/memory/`
- Modify: `tests/asl/tile-tests.asl`
- Modify: relevant `tests/asl/shards/*.asl`
- Modify: `docs/architecture.md`
- Modify: `docs/instructions/block/attributes/B.DIM.md`
- Modify: `docs/instructions/block/operands/B.IOT.md`
- Modify: `docs/instructions/block/operands/B.IOS.md`

**Interfaces:**
- Produces: `IsNonzeroPowerOfTwo(value)`, `DerivedTileRows(capacity_bytes, columns, dtype)`, and pre-effect descriptor legality shared by Local, Shared, and Matrix paths.
- Consumes: existing `DecodeTileCapacityBytes()` and `TileElementBits()`.

- [ ] **Step 1: Add failing ASL tests for ordinary Col and matrix M/N/K**

Use literal positive cases `1, 2, 4, 8, 16` and negative cases `0, 3, 6, 12`. Include Local and Shared destinations, all TSize codes, and 4-bit packed dtype boundaries.

- [ ] **Step 2: Add failing tests for derived rows and pre-effect rejection**

Check exact rows, `rows == valid_rows`, `rows > valid_rows`, `rows < valid_rows`, and prove rejection occurs before allocation, rename, reads, writes, consume, or fault effects.

- [ ] **Step 3: Run focused shards and observe the intended failures**

Run: `make test-shard-tile-capacity`

Run: `make test-shard-tmatmul-tgemv`

Run: `make test-shard-shared-tload-atomic`

- [ ] **Step 4: Implement the minimal shared helpers and use them in all destination paths**

Derive rows exactly; do not round. Reject a zero/non-power-of-two physical column count, a row wider than capacity, or a valid region larger than the derived physical shape.

- [ ] **Step 5: Run focused shards and repository structural checks**

Run: `make test-shard-tile-capacity test-shard-tmatmul-tgemv test-shard-shared-tload-atomic`

Run: `./scripts/check-catalogs`

- [ ] **Step 6: Commit shape semantics**

```bash
git add asl/tile tests/asl docs/architecture.md docs/instructions/block
git commit -m "feat: derive tile rows from per-PE capacity"
```

### Task 6: Remove active normative version labels and finalize publication

**Files:**
- Modify: active files under `asl/`
- Modify: active instruction/manual pages under `docs/instructions/` and `docs/architecture.md`
- Modify: `scripts/instruction_docs.py`
- Modify: `tests/scripts/test_instruction_docs.py`
- Modify: `docs/mkdocs/mkdocs.yml`

**Interfaces:**
- Produces: version-neutral active normative surfaces and a check that excludes only historical ADR/release paths.
- Consumes: Task 2 page generator and Task 3/4 mirrored trees.

- [ ] **Step 1: Add a failing active-surface version-neutrality test**

The test scans active ASL and generated/current instruction pages, reports exact offending paths/lines, and explicitly excludes historical ADRs, plans, status snapshots, and release manifests.

- [ ] **Step 2: Run the test and record the current offending active pages**

Run: `python3 -m unittest tests.scripts.test_instruction_docs -v`

- [ ] **Step 3: Remove release-number wording without changing architectural meaning**

Use `current PTO architecture`, `active profile`, or the concrete profile name where a real profile distinction remains. Do not rewrite historical records.

- [ ] **Step 4: Generate and strictly build the MkDocs site**

Run: `python3 scripts/instruction_docs.py generate`

Run: `python3 -m mkdocs build -f docs/mkdocs/mkdocs.yml --strict`

- [ ] **Step 5: Commit publication cleanup**

```bash
git add asl docs scripts tests
git commit -m "docs: publish version-neutral ASL-backed reference"
```

### Task 7: Full verification and release projection regeneration

**Files:**
- Regenerate: all catalog, evidence, release, Markdown, HTML, and MkDocs projections affected by earlier tasks
- Modify only if stale generators are discovered: corresponding scripts and their focused tests

**Interfaces:**
- Consumes: all preceding tasks.
- Produces: clean deterministic repository and verification evidence.

- [ ] **Step 1: Regenerate all checked projections**

Run the repository's canonical generators, including instruction reference, intrinsic docs/HTML, release manifest, and ASL decoder generation.

- [ ] **Step 2: Run focused script and renderer tests**

Run: `python3 -m unittest tests.scripts.test_instruction_docs -v`

Run: `node --test scripts/intrinsic-docs/test_intrinsic_docs.mjs scripts/intrinsic-docs/test_public_html.mjs`

- [ ] **Step 3: Run repository and catalog gates**

Run: `make repo-check`

Run: `./scripts/check-catalogs`

Run: `./scripts/check-binary-closure`

- [ ] **Step 4: Run ASL type-check and focused semantic shards**

Run: `make check`

Run: `make test-shard-tile-capacity test-shard-tmatmul-tgemv test-shard-shared-tload-atomic`

- [ ] **Step 5: Build documentation and verify clean regeneration**

Run: `python3 -m mkdocs build -f docs/mkdocs/mkdocs.yml --strict`

Run: `python3 scripts/instruction_docs.py --check`

Run: `git diff --check`

- [ ] **Step 6: Commit regenerated projections**

```bash
git add -A
git commit -m "chore: regenerate ASL-backed ISA reference"
```

