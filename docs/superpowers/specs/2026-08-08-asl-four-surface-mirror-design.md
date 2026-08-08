# ASL Four-Surface Mirror and Independent AVS Design

## Status

Approved by the architecture owner on 2026-08-08.

## Purpose

PTO requires one repository structure that remains easy to navigate while the
ISA evolves. The checked-in ASL model is the only active architecture source.
Documentation explains and renders that model, and verification tests sample
its requirements without creating another interpretation.

This design reorganizes the active architecture into four surfaces, mirrors
those surfaces in documentation and tests, replaces coarse ASL shards with
independent validation points, and moves non-normative historical material out
of the active navigation.

The design follows the NDF tree, graph, and history separation:

- the directory tree owns and exposes each clause exactly once;
- stable IDs and checked cross-references form the semantic graph;
- Git and decision records preserve evolution history.

## Supersession

This design refines and partially supersedes
`docs/superpowers/specs/2026-08-08-ndf-governance-and-release-design.md`.

The earlier prohibition on every `legacy` directory is replaced by a narrower
rule. `docs/status/legacy/` MAY preserve non-normative historical material, but
it MUST NOT participate in the active manual, ASL ownership, requirement
resolution, test coverage, release closure, or generated navigation. No other
legacy or backup specification tree is permitted.

The lightweight PR lane and manual exact-head release lane remain in force.

## Architectural source hierarchy

The `asl/` root MUST contain exactly these four directories and no files:

```text
asl/
├── arch/
├── block/
├── scalar/
└── tile/
```

The repository structure checker MUST reject any additional top-level ASL
entry.

### Mnemonic granularity

Every instruction mnemonic MUST own one ASL file. Multiple mnemonics MUST NOT
share one mnemonic ASL file. Each mnemonic file owns its instruction metadata,
decode and legality regions, operation semantics, architectural effects, and
instruction-local NDF clauses.

Examples:

```text
asl/scalar/alu/ADD.asl
asl/block/operands/B.IOR.asl
asl/tile/memory/TLOAD.asl
```

Common model code is not duplicated into mnemonic files. It is split by one
cohesive architecture concept and placed in the matching surface model tree.

### File-size and cohesion rule

Every hand-written ASL file MUST contain no more than 500 physical lines. The
limit applies equally to `arch`, `block`, `scalar`, and `tile`.

Files approaching the limit SHOULD be split before they cross it. A split MUST
follow a semantic boundary such as architecture state, feature, instruction
class, dispatch family, legality dimension, or lifecycle phase. Permanent size
exceptions are not allowed.

Generated concatenations under `build/` are not hand-written ASL files and are
not subject to the per-unit limit.

## Architecture surface

The `arch/` surface owns architecture-wide concepts that do not belong to one
instruction surface. It uses subdirectories so each concept remains readable
and has its own manual page and verification owner.

The initial target taxonomy is:

```text
asl/arch/
├── overview/
│   ├── architecture.asl
│   └── instruction-classification.asl
├── programming-model/
│   ├── core-pe-topology.asl
│   ├── execution-context.asl
│   ├── scalar-registers.asl
│   ├── predicate-registers.asl
│   ├── tile-registers.asl
│   └── shared-tile-registers.asl
├── state/
│   ├── program-counter.asl
│   ├── execution-mask.asl
│   ├── trap-context.asl
│   ├── tile-descriptor.asl
│   └── definedness.asl
├── system-registers/
│   ├── addressing.asl
│   ├── access-control.asl
│   ├── context.asl
│   ├── interrupt.asl
│   ├── timer.asl
│   └── maintenance.asl
├── memory-model/
│   ├── address-space.asl
│   ├── memory-events.asl
│   ├── ordering.asl
│   ├── atomicity.asl
│   └── fault-precision.asl
├── data-types/
│   ├── integer.asl
│   ├── floating-point.asl
│   ├── packed.asl
│   ├── tile-data-types.asl
│   ├── numeric-classification.asl
│   └── rounding.asl
├── features/
│   ├── predication.asl
│   ├── mx-formats.asl
│   ├── tile-allocation.asl
│   └── shared-tile-state.asl
├── profile/
│   ├── reset.asl
│   ├── applicability.asl
│   └── reference-profile.asl
└── dispatch/
    └── top-level.asl
```

The migration MAY refine leaf names when existing ASL dependencies reveal a
cleaner boundary. It MUST preserve the approved subject ownership, mirror rule,
and 500-line limit.

The current `numeric/` and `profiles/` roots cease to exist. Their active
contracts move into `arch/data-types/`, `arch/features/`, and `arch/profile/`
according to subject ownership.

## Block surface

`block/` owns BSTART, BSTOP, B.*, block attributes, block operands, block
execution selection, and block lifecycle. The current `bundle/` root ceases to
exist because bundle state and dispatch implement the block architecture.

Common block code MUST be divided into cohesive model units, for example:

```text
asl/block/model/
├── state/
├── lifecycle/
├── operands/
├── schema/
├── commit/
├── faults/
└── dispatch/
```

Each leaf ASL file in those directories MUST remain below 500 lines. A single
block dispatch file MUST NOT accumulate every command handler. Dispatch MUST be
split by block instruction class or lifecycle responsibility, with one small
top-level dispatcher composing those units.

Mnemonic files remain one mnemonic per file under the appropriate block
classification.

## Scalar surface

Scalar mnemonic files remain classified by scalar execution class, including
AGU, ALU, AMO, BRU, FSU, and SYS. Common execution and dispatch code moves into
cohesive `scalar/model/` units. Large dispatch switches MUST be split by scalar
class and composed by a small scalar top-level dispatcher.

## Tile surface

Tile mnemonic files remain classified by the PTO tile-operation taxonomy.
Common state, shape, capacity, definedness, memory, legality, numeric, and
dispatch behavior moves into cohesive `tile/model/` units. Tile legality MUST
be split by independent constraint domains instead of remaining one monolithic
file.

## ASL unit metadata and assembly

Every ASL file MUST carry one stable unit identity. A non-mnemonic unit uses a
single-line record of this form:

```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-ORDERING","surface":"arch","classification":["memory-model","ordering"],"depends_on":["PTO-ARCH-MEMORY-EVENTS"]}
```

Mnemonic files extend their existing `PTO-INSTRUCTION` metadata with the same
unit identity and dependency information.

The ASL assembly tool MUST:

1. discover units only below the four approved surface roots;
2. reject duplicate unit IDs and path or metadata classification mismatches;
3. reject missing or cyclic dependencies;
4. topologically order units and the generated decoder node;
5. emit a deterministic assembled specification.

The Makefile MUST NOT contain a hand-maintained list of every ASL source or
test shard.

## ASL as the only active definition

Architecture behavior, mnemonic classification, encoding metadata, assembly
forms, dependencies, NDF clauses, and documentation regions originate in ASL.

Catalog JSON, decoder declarations, Markdown pages, MkDocs navigation, test
matrices, coverage reports, traceability evidence, and release manifests are
deterministic projections or verification results. They MUST NOT become
independent authoring surfaces for ISA behavior.

Checked-in release projections MAY be retained when they are required release
artifacts, but the lightweight checker MUST prove they reproduce exactly from
the ASL source.

## Documentation mirror

Active documentation MUST mirror every ASL source path exactly, replacing only
the `.asl` suffix with `.md`:

```text
asl/arch/system-registers/interrupt.asl
docs/arch/system-registers/interrupt.md

asl/block/operands/B.IOR.asl
docs/block/operands/B.IOR.md

asl/scalar/alu/ADD.asl
docs/scalar/alu/ADD.md
```

Each active page MUST identify its exact ASL source and embed the generated ASL
documentation regions. Hand-written supplementary text MAY add rationale,
examples, diagrams, and programmer guidance, but MUST NOT define behavior that
is absent from the owning ASL clauses.

The documentation checker MUST reject:

- an ASL source without its matching page;
- an active page without its matching ASL source;
- a page whose declared source differs from its path;
- stale generated regions or navigation;
- normative references to `docs/status/legacy/`.

MkDocs navigation is generated from the ASL unit tree. Generated HTML is built
under `build/mkdocs-site/` and is not committed as active documentation.

## Status and historical material

Active architecture decision records move to `docs/status/decisions/`. They
record rationale and supersession without becoming a second behavior owner.

DavinciOO material, outdated root documents, superseded projections, and old
generated HTML move to `docs/status/legacy/`. Legacy material MUST carry a
visible non-normative status notice and MUST remain outside active navigation,
requirement resolution, test coverage, and release closure.

## Independent ASL validation points

Tests mirror the owning ASL classification. One ASL unit may own many test
points, but every test point is one independently executable `.asl` file with a
stable ID.

Example:

```text
asl/scalar/alu/ADD.asl
docs/scalar/alu/ADD.md
tests/asl/scalar/alu/ADD/PTO-AVS-SCALAR-ADD-001.asl
tests/asl/scalar/alu/ADD/PTO-AVS-SCALAR-ADD-002.asl
```

Each test file MUST contain exactly one integer `main()` and one `PTO-TEST`
metadata record:

```asl
// PTO-TEST: {"id":"PTO-AVS-SCALAR-ADD-001","source":"asl/scalar/alu/ADD.asl","requirements":["PTO-REQ-SCALAR-ADD-EXEC-001"],"kind":"execution","summary":"ADD produces the defined XLEN result","pass":"destination equals the wrapped source sum"}
```

A test file MUST NOT depend on functions defined by another test file. Small
test-local helpers stay in that test file. Shared reset or architecture helper
behavior belongs to the normative ASL model rather than a giant test library.

Cross-unit tests choose one primary owner and MAY declare `related_sources`.
The test path MUST still mirror the primary source.

The supported initial test kinds are:

- `decode-positive`;
- `decode-negative`;
- `execution`;
- `boundary`;
- `fault`;
- `atomicity`;
- `ordering`;
- `state-transition`;
- `static-invariant`.

The test index checker MUST reject duplicate IDs, path mismatches, absent source
units, absent requirement IDs, multiple entry points, unreachable test files,
and uncovered executable requirements.

`tests/asl/main.asl`, `tests/asl/shards/`, monolithic test libraries, and
hand-maintained shard lists are removed after migration.

## Pull-request workflow

The required PR workflow remains lightweight. It runs structural and
projection checks without installing or executing ASLRef. It verifies:

- the four-surface ASL root contract;
- the 500-line limit;
- ASL unit, NDF, instruction, and test metadata;
- dependency and cross-reference structure;
- exact ASL, docs, and test-path mirroring;
- generated docs, navigation, catalogs, and decoder projection freshness;
- test ID uniqueness and requirement mapping;
- publication hygiene and ordinary text or data lint.

The PR result MUST NOT claim formal ASL verification or coverage.

## Manual release workflow

The manual release workflow binds to one exact commit and runs fail-closed:

1. run the lightweight repository contract;
2. validate the pinned ASLRef toolchain;
3. strictly type-check the complete assembled specification;
4. discover every `PTO-AVS-*.asl` test point;
5. generate an exact-head matrix containing ID, path, source, requirements,
   kind, and file hash;
6. execute each test ID independently with bounded parallelism;
7. aggregate per-ID logs and results;
8. require all test IDs to pass and all executable requirements to be covered;
9. reproduce documentation, catalogs, decoder, evidence, and release manifest;
10. prove a clean exact-head release tree before publication.

Hosted workflow paging MAY be used to respect platform matrix limits. Paging
MUST NOT merge multiple test points into one ASL test program or hide the
result of any test ID.

## Migration sequence

The implementation proceeds in reviewable semantic-preserving stages:

1. preserve the current exact-head baseline and the three pending release
   fixture corrections;
2. inventory ASL units, NDF requirements, generated pages, and existing test
   functions;
3. introduce unit metadata and the four-surface structure checker;
4. move and split ASL files with `git mv`, preserving instruction behavior and
   dependency order;
5. prove every hand-written ASL file is within 500 lines;
6. derive catalogs, decoders, source order, docs, and navigation from ASL;
7. create the exact documentation mirror and archive non-normative history;
8. split every current test point into its independent mirrored file;
9. replace shard discovery with the generated exact-head test matrix;
10. delete obsolete aggregate entries and reject their return;
11. run the complete manual release workflow and regenerate release evidence.

Pure file moves and model splits MUST NOT silently change architecture
semantics. Any discovered architecture defect is handled as a separate NDF
semantic delta with focused tests and review.

## Acceptance criteria

- `asl/` contains exactly `arch`, `block`, `scalar`, and `tile` at its root.
- Every instruction mnemonic owns one ASL source and one matching active page.
- Every architecture concept owns a cohesive ASL source and matching page.
- Every hand-written ASL source is at most 500 physical lines.
- Bundle state and dispatch are owned by `block`; no active `bundle/` root
  remains.
- Numeric and profile contracts are owned by `arch`; no active `numeric/` or
  `profiles/` root remains.
- Active docs and ASL paths match exactly.
- Tests mirror ASL classification paths and each test file owns one stable ID
  and one entry point.
- Every test ID can run independently.
- Every executable NDF requirement has release verification coverage.
- PR validation remains lightweight and does not install ASLRef.
- Manual release verification runs every exact-head test ID fail-closed.
- No active catalog, document, test list, or historical file acts as a second
  architecture definition.
- `docs/status/legacy/` is non-normative and excluded from all active closure.
