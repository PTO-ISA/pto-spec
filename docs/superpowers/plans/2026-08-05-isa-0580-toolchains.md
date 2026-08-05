# PTO and Linx v0.58 Toolchain Migration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (- [ ]) syntax for tracking.

**Goal:** Upgrade every active Linx/PTO producer and consumer from v0.57.1
to reviewed PTO/Linx v0.58 exact heads, then repin the Linx superproject only
after every leaf is independently validated.

**Architecture:** Treat every downstream repository as a leaf with its own
branch, tests, review, hosted validation, and tree proof. Integrate in
dependency order: producers, execution models/RTL, OS/libc, workloads, then
the superproject.

**Tech Stack:** Git submodules, LLVM/TableGen, PTOAS, QEMU, C++ models,
SystemVerilog, Linux, glibc, musl, pyCircuit, PTO-Kernel, SuperNPUBench.

## Global Constraints

- Start downstream mutations only after PTO v0.58 is merged/tree-proven.
- Repin only merged/tree-proven leaf commits.
- Active tools reject retired v0.57.1 encodings; no dual decode.
- PTO scalar/block equality and Linx-only vectors remain exact.
- Every relevant consumer tests S0-S255, direction-aware C.B.IOS, optional
  Shared TLOAD/TSTORE B.IOT, PE predicates, and negative old encodings.
- Preserve dirty checkouts; use clean isolated worktrees.

---

### Task 1: Create a fail-closed consumer matrix

**Files:**
- Create in Linx superproject: docs/architecture/pto-isa-v0.58.0-upgrade-plan.md
- Create: docs/bringup/gates/isa_v058_consumer_matrix.json
- Create: tools/bringup/check_isa_v058_consumer_matrix.py
- Create: tools/bringup/test_check_isa_v058_consumer_matrix.py

**Interfaces:**
- Consumes: merged PTO and reviewed Linx manifests.
- Produces: hashes, positive/negative vectors, and leaf completion records.

- [ ] **Step 1: Write the failing matrix test**

Require entries for compiler/llvm, compiler/ptoas, emulator/qemu, tools/model,
tools/LinxCoreModel, rtl/LinxCore, kernel/linux, lib/glibc, lib/musl,
workloads/pto_kernels, tools/pyCircuit, and workloads/SuperNPUBench. Each entry
contains repository URL, old commit, reviewed commit, tree, local commands,
hosted run URL, and status.

~~~bash
python3 tools/bringup/test_check_isa_v058_consumer_matrix.py
~~~

Expected: FAIL because the matrix is absent.

- [ ] **Step 2: Add an initial pending matrix**

The checker rejects missing fields, short IDs, skipped status, or any
superproject gitlink pointing to an unproven leaf.

~~~bash
python3 tools/bringup/test_check_isa_v058_consumer_matrix.py
python3 tools/bringup/check_isa_v058_consumer_matrix.py
git add docs/architecture/pto-isa-v0.58.0-upgrade-plan.md docs/bringup/gates tools/bringup
git commit -m "test: track the ISA v0.58 consumer matrix"
~~~

### Task 2: Upgrade LLVM and PTOAS producers

**Files:**
- Modify in compiler/llvm: Linx TableGen instruction definitions, MC
  parser/printer, disassembler, code emitter, generated opcode metadata, and
  Linx target tests that reference v0.57.1.
- Modify in compiler/ptoas: profile manifest, parser/printer, encoder/decoder,
  C.B.IOS grammar, mask-only B.IOT grammar, and golden tests.

**Interfaces:**
- Consumes: Linx v0.58 compiled catalog and PTO vectors.
- Produces: v0.58 assembly/object/disassembly and old-word rejection.

- [ ] **Step 1: Add failing tests**

Test C.B.IOS S0, C.B.IOS S255, C.B.IOS -> S17, mask-only B.IOT, multi-bit
masks, 0000, malformed S#17, wrong arrow role, and retired v0.57.1 words.

- [ ] **Step 2: Verify red**

Run each repository's focused Linx MC and PTOAS test target. Expected: new
syntax or encodings fail before implementation.

- [ ] **Step 3: Generate and implement**

Source constants from the locked Linx catalog. Do not duplicate hand-written
encoding tables.

- [ ] **Step 4: Validate and integrate each leaf**

Run unit, round-trip, disassembly and required-mnemonic gates. Review, push,
require exact-head hosted success, merge, tree-prove, then update the matrix.

### Task 3: Upgrade QEMU and architectural models

**Files:**
- Modify in emulator/qemu: decode metadata, PTO block translation/execution,
  Shared state/reset, and tests.
- Modify in tools/model: decoder metadata, Shared storage, predicates,
  synchronization, and differential tests.
- Modify in tools/LinxCoreModel: decode tables, Shared state/interface, and
  cross-model fixtures.

**Interfaces:**
- Consumes: v0.58 object vectors.
- Produces: matching execution and rejection behavior.

- [ ] **Step 1: Add failing state/decode tests**

Cover atomic partial update, descriptor replacement, undefined-read-no-trap,
fixed-offset masks, unsynchronized old/new whole values, non-overlap, and
retired-word rejection.

- [ ] **Step 2: Verify red in all three leaves**

Expected: v0.58 decode or Shared behavior fails.

- [ ] **Step 3: Implement 256 registers per core**

Do not model registers per PE, impose a conflict winner, or add overlap
detection.

- [ ] **Step 4: Run cross-model validation and integrate**

Require QEMU/model unit tests and superproject differential suites. Review,
push, hosted-validate, merge, tree-prove, then update the matrix.

### Task 4: Upgrade RTL LinxCore

**Files:**
- Modify in rtl/LinxCore: decode package/tables, Shared register file,
  four-PE arbitration, predicate routing, reset, assertions, and tests.

**Interfaces:**
- Consumes: v0.58 encodings and model traces.
- Produces: RTL behavior equivalent to software models.

- [ ] **Step 1: Add failing RTL tests**

Assert one 256-register bank per core, all-PE access, selected-quarter enables,
zero-mask no-op, atomic descriptor/payload commit, and retired-word rejection.

- [ ] **Step 2: Implement atomic selected-quarter commit**

Arbitration order is unspecified. Do not test a winner for overlapping
requests.

- [ ] **Step 3: Validate and integrate**

Run decode parity, assertions, directed simulation and LinxCoreModel
comparison. Review, push, hosted-validate, merge, tree-prove, update matrix.

### Task 5: Upgrade Linux, glibc, and musl identity

**Files:**
- Modify in kernel/linux: Linx ELF/ISA identity, visible ISA strings,
  feature/profile validation, and selftests.
- Modify in lib/glibc: loader/profile checks, startup identity, and tests.
- Modify in lib/musl: loader/profile checks, startup identity, and tests.

**Interfaces:**
- Consumes: v0.58 compiler output and QEMU.
- Produces: runtimes that accept v0.58 and reject incompatible v0.57.1 objects
  where version identity is checked.

- [ ] **Step 1: Add failing positive/negative loader tests**

Diagnostics name actual and required versions.

- [ ] **Step 2: Implement the hard break**

Do not add dual-loader fallback.

- [ ] **Step 3: Validate and integrate**

Run kernel selftests and static/shared glibc/musl smoke tests under QEMU.
Review, push, hosted-validate, merge, tree-prove, update matrix.

### Task 6: Upgrade workloads and generators

**Files:**
- Modify in workloads/pto_kernels: profile identity, checked assembly/golden
  encodings, and workload tests.
- Modify in tools/pyCircuit: target metadata, emitted assembly fixtures, and
  compiler tests.
- Modify in workloads/SuperNPUBench: generated kernels/binaries,
  disassembly, and manifests.

**Interfaces:**
- Consumes: merged v0.58 producers/runtime.
- Produces: representative workloads built only with v0.58.

- [ ] **Step 1: Add stale-profile scans**

Reject active v0.57.1 identities and S#n outside historical files.

- [ ] **Step 2: Regenerate from source**

Do not hand-edit binaries or generated disassembly.

- [ ] **Step 3: Validate representative workloads**

Include scalar, block, Shared TLOAD/TSTORE/TMOV, cooperative CUBE, and Linx
vector cases on QEMU/models.

- [ ] **Step 4: Integrate each leaf**

Review, push, hosted-validate, merge, tree-prove, update matrix.

### Task 7: Repin and validate the Linx superproject

**Files:**
- Modify: proven leaf gitlinks.
- Modify: docs/bringup/gates/isa_v058_consumer_matrix.json
- Modify: docs/bringup/PROGRESS.md
- Modify: docs/bringup/SUPERPROJECT_MILESTONES.md

**Interfaces:**
- Consumes: merged/tree-proven leaf commits.
- Produces: one coherent superproject v0.58 exact head.

- [ ] **Step 1: Update gitlinks from the matrix**

Verify each gitlink equals the recorded commit and tree before staging.

- [ ] **Step 2: Run superproject gates**

~~~bash
python3 tools/isa/build_golden.py --profile v0.58 --check
python3 tools/isa/validate_spec.py --profile v0.58
python3 tools/bringup/check_isa_v058_consumer_matrix.py
python3 tools/bringup/check_gate_consistency.py
python3 tools/bringup/check_avs_profile_closure.py
python3 tools/bringup/check_linxcore_arch_contract.py
python3 tools/bringup/check_sail_model.py
git diff --check
~~~

Expected: every command exits zero.

- [ ] **Step 3: Run end-to-end validation**

Build with LLVM/PTOAS; execute on QEMU and C++ models; run RTL comparison; boot
glibc and musl smoke images.

- [ ] **Step 4: Publish exact head**

Require clean status, exact commit/tree, fresh hosted checks, no conflicts,
independent review, squash/tree equality, then cleanup.
