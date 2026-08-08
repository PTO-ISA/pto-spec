# LinxISA v0.58 Projection Implementation Plan

> Historical, non-normative material. This page is excluded from the active PTO architecture and release closure.

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** Create a standalone LinxISA v0.58 profile that imports the reviewed
PTO v0.58 scalar/block ABI exactly, preserves Linx-only vector definitions,
and rejects the active v0.57.1 PTO ABI.

**Architecture:** Add isa/v0.58 from a checked PTO exact-head lock. Carry
forward only Linx-owned/vector definitions, generate codecs and Sail from the
new profile, and retain isa/v0.57.1 only as immutable history.

**Tech Stack:** Python 3, JSON opcode/profile sources, Sail, generated C/decode
tables, AsciiDoc, Markdown.

## Global Constraints

- Linx version is 0.58.0 and PTO source version is 0.58.0.
- All 474 PTO scalar forms and all PTO block forms match source identities,
  assembly, lengths, masks, matches, fields, and constraints exactly.
- Linx retains 182 vector forms plus six Linx-only vector-control forms.
- The six vector-control patterns are reserved by PTO and executable only in
  Linx.
- No active v0.58 decoder accepts retired v0.57.1 PTO patterns.
- Historical isa/v0.57.1 files remain immutable.

---

### Task 1: Add failing v0.58 profile tests

**Files:**
- Create: tools/isa/test_v058_profile.py
- Create: tools/isa/check_pto_v058_manifest.py
- Create: tools/isa/check_canonical_v058.py
- Modify: tools/isa/test_golden_contract.py

**Interfaces:**
- Produces: identity, parity, collision, reservation, and hard-break gates.

- [ ] **Step 1: Test release identity**

Require isa/v0.58/meta.json, release_manifest.json and linxisa-v0.58.json to
report 0.58.0 and disable v0.57.1 decode compatibility.

- [ ] **Step 2: Test exact PTO parity**

Compare every PTO source form by source ID and exact mnemonic, assembly,
length, encoding parts, field pieces, and legality constraints.

- [ ] **Step 3: Test Linx extensions and PTO reservations**

Assert all existing 182 vector forms plus BSTART.VPAR, BSTART.VSEQ,
C.BSTART.VPAR, C.BSTART.VSEQ, V.QPOP and V.QPUSH remain present, do not claim a
PTO source ID, and match PTO's reserved pattern list.

- [ ] **Step 4: Test hard-break rejection**

Feed removed/re-encoded v0.57.1 PTO words to the v0.58 matcher and require zero
matches. Require every current word to match exactly one form.

- [ ] **Step 5: Verify red and commit**

~~~bash
python3 tools/isa/test_v058_profile.py
python3 tools/isa/check_pto_v058_manifest.py
python3 tools/isa/check_canonical_v058.py
git add tools/isa
git commit -m "test: define LinxISA v0.58 profile contract"
~~~

Expected: the tests fail before isa/v0.58 exists.

### Task 2: Import PTO v0.58 and create the golden profile

**Files:**
- Create: isa/v0.58/pto-spec.lock.json
- Create: isa/v0.58/state/pto_ops.json
- Create: isa/v0.58/state/pto_encoding_map.json
- Create: isa/v0.58/state/pto_command_forms.json
- Create: isa/v0.58/state/engine_ops.json
- Create: isa/v0.58/state/architectural_state.json
- Create: isa/v0.58/state/memory_model.json
- Create: isa/v0.58/state/kernel_execution.json
- Create: isa/v0.58/state/rendering_profile.json
- Create: isa/v0.58/state/system_registers.json
- Create: isa/v0.58/meta.json
- Create: isa/v0.58/release_manifest.json
- Create: isa/v0.58/semantics_conventions.json
- Create: isa/v0.58/encoding/fields.json
- Create: isa/v0.58/encoding/formats.json
- Create: isa/v0.58/encoding/retired_encodings.json
- Create: isa/v0.58/opcodes/lx_32.opc
- Create: isa/v0.58/opcodes/lx_64_prefix.opc
- Create: isa/v0.58/opcodes/lx_c.opc
- Create: isa/v0.58/opcodes/lx_hl48.opc
- Create: isa/v0.58/registers/gpr_reg5.json
- Create: isa/v0.58/registers/tile_reg.json
- Create: isa/v0.58/uop_classification_v0.58/
- Create: isa/v0.58/linxisa-v0.58.json

**Interfaces:**
- Consumes: merged/tree-proven PTO exact head and Linx v0.57.1 Linx-owned
  forms.
- Produces: deterministic standalone Linx v0.58 catalog.

- [ ] **Step 1: Generate the exact PTO lock**

Record PTO commit, tree, release, encoding ABI, source paths, counts and
SHA-256 hashes. Validation fails if any copied projection differs.

- [ ] **Step 2: Copy PTO projections deterministically**

Import scalar, command, tile, Shared architectural state, memory rules, and
release metadata without editing source identities.

- [ ] **Step 3: Carry forward only Linx-owned definitions**

Retain scalar extensions and the full two-level vector ISA. Replace all
PTO-owned block forms from the v0.58 lock.

- [ ] **Step 4: Record retired v0.57.1 patterns**

Populate retired_encodings.json and mark every former active incompatible PTO
pattern non-decodable in v0.58.

- [ ] **Step 5: Build and verify**

~~~bash
python3 tools/isa/build_golden.py --profile v0.58
python3 tools/isa/build_golden.py --profile v0.58 --check
python3 tools/isa/check_pto_v058_manifest.py
python3 tools/isa/test_v058_profile.py
python3 tools/isa/check_canonical_v058.py
~~~

Expected: PASS.

- [ ] **Step 6: Commit**

~~~bash
git add isa/v0.58 tools/isa
git commit -m "feat: add standalone LinxISA v0.58 profile"
~~~

### Task 3: Generate active codecs and Sail

**Files:**
- Modify: tools/isa/gen_sail_decode.py
- Modify: isa/generated/codecs/linxisa16.decode
- Modify: isa/generated/codecs/linxisa32.decode
- Modify: isa/generated/codecs/linxisa48.decode
- Modify: isa/generated/codecs/linxisa64.decode
- Modify: isa/generated/codecs/linxisa_opcodes.c
- Modify: isa/generated/codecs/linxisa_opcodes.h
- Modify: isa/sail/model/decode/decode.sail
- Modify: isa/sail/model/execute/execute.sail
- Modify: isa/sail/model/state/state.sail
- Modify: isa/sail/tests/directed.sail
- Modify: isa/sail/coverage.json
- Modify: isa/sail/semantics_status.json

**Interfaces:**
- Consumes: linxisa-v0.58.json.
- Produces: active v0.58 decoders and Shared semantics.

- [ ] **Step 1: Switch generator defaults to v0.58**

Keep v0.57.1 available only through an explicit historical profile argument.

- [ ] **Step 2: Regenerate codecs and Sail decode**

Use repository generators, then run:

~~~bash
python3 tools/isa/test_gen_sail_decode.py
~~~

- [ ] **Step 3: Add directed Shared tests**

Cover S0/S255, source/destination rendering, optional masks, 0000, multi-bit
masks, descriptor compatibility, and retired-word rejection.

- [ ] **Step 4: Verify and commit**

~~~bash
python3 tools/bringup/check_sail_model.py
python3 tools/isa/test_gen_sail_decode.py
git add tools/isa isa/generated isa/sail
git commit -m "feat: generate LinxISA v0.58 codecs and Sail"
~~~

### Task 4: Publish active v0.58 documentation

**Files:**
- Modify: README.md
- Modify: CONTRIBUTING.md
- Modify: isa/README.md
- Create: docs/releases/v0.58.0.md
- Create: docs/architecture/v0.58-architecture-contract.md
- Create: docs/reference/examples/v0.58/README.md
- Create: docs/reference/examples/v0.58/index.yaml
- Modify: docs/architecture/isa-manual/src/chapters/00_preamble.adoc
- Modify: docs/architecture/isa-manual/src/chapters/02_isa_overview.adoc
- Modify: docs/architecture/isa-manual/src/chapters/04_block_isa.adoc
- Modify: docs/architecture/isa-manual/src/chapters/06_assembly_conventions.adoc
- Modify: docs/architecture/isa-manual/src/chapters/08_tile_blocks.adoc
- Modify: docs/architecture/isa-manual/src/chapters/20_vec.adoc
- Modify generated files under docs/architecture/isa-manual/src/generated/

**Interfaces:**
- Consumes: validated v0.58 catalog.
- Produces: release notes, active commands, examples, and manual.

- [ ] **Step 1: Switch active commands to profile v0.58**

Retain v0.57.1 references only in historical release/upgrade documents.

- [ ] **Step 2: Document PTO equality and Linx vector additions**

Include absolute Shared syntax, masks, atomicity, hard-break behavior and
reserved PTO patterns.

- [ ] **Step 3: Generate and validate**

~~~bash
python3 docs/check_documentation.py
make -C docs/architecture/isa-manual
git add README.md CONTRIBUTING.md isa/README.md docs
git commit -m "docs: publish the LinxISA v0.58 contract"
~~~

### Task 5: Validate and publish the exact Linx head

**Files:**
- Verify only: entire repository.

- [ ] **Step 1: Run all profile gates**

~~~bash
python3 tools/isa/build_golden.py --profile v0.58 --check
python3 tools/isa/validate_spec.py --profile v0.58
python3 tools/isa/check_canonical_v058.py
python3 tools/isa/check_pto_v058_manifest.py
python3 tools/isa/test_v058_profile.py
python3 tools/isa/test_golden_contract.py
python3 tools/isa/test_gen_sail_decode.py
python3 docs/check_documentation.py
git diff --check
~~~

Expected: every command exits zero.

- [ ] **Step 2: Record identity and push**

~~~bash
git status --short
git rev-parse HEAD
git rev-parse HEAD^{tree}
git push --set-upstream origin codex/linx-isa-0580
~~~

Expected: clean worktree and new remote branch at the reviewed exact head.

- [ ] **Step 3: Require fresh hosted success**

Do not mutate Linx before PTO v0.58 is merged/tree-proven. Require exact-head
checks, independent review, no conflicts, squash/tree equality, then cleanup.
