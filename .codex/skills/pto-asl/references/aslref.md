# ASLRef and ASL1 reference

## Source hierarchy

1. The Arm ASL Reference is the formal language definition for ASL1.
2. [`herd/herdtools7`](https://github.com/herd/herdtools7/tree/master) contains ASLRef, its parser, type checker,
   interpreter, language reference sources, and conformance tests.
3. The Architecture Specification Language Readers' Guide is an orientation aid, not the formal language definition.

Use `asllib/README.md` for upstream installation and basic invocation. Use `asllib/aslspec/` and `asllib/tests/` when
language behavior or diagnostics are uncertain. Prefer a minimal ASLRef reproducer over guessing.

## Repository pin

`.aslref-version` contains the audited herdtools7 commit used by CI. Treat it as a supply-chain and language-semantics
pin. To update it:

1. Compare the old and new commits, focusing on `asllib/`, its tests, and release notes.
2. Record parser, typing, interpreter, and standard-library changes that can affect PTO.
3. Run all repository validation against the new commit.
4. Update documentation when accepted syntax or diagnostics change.
5. Keep the update isolated from normative PTO changes.

## Validation modes

Use strict type-checking for checked-in ASL1:

```bash
aslref --type-check-strict --no-exec build/pto-spec.asl
```

Use execution only for a combined specification containing one test `main` that returns zero on success:

```bash
aslref --type-check-strict build/test-suite.asl
```

ASLRef accepts one primary ASL input file. The Makefile therefore concatenates ordered checked-in sources into an
ignored build artifact. It also generates decoder declarations from the normative JSON catalogs into that same ignored
build tree. Keep source order and generation deterministic; never edit or commit the assembled files.

Use `DIV` only when exact divisibility is an architectural precondition. Use `DIVRM` for Euclidean quotient behavior.
ASLRef deliberately rejects an inexact `DIV` at run time, which is useful for exposing accidental arithmetic assumptions.

## Upstream source build

The upstream workflow requires OCaml, opam, dune, menhir, and zarith. A source checkout can run ASLRef without
installing it globally:

```bash
opam exec -- dune exec --root=/path/to/herdtools7 asllib/aslref.exe -- --version
```

CI fetches exactly the commit in `.aslref-version` and installs the build dependencies. For a one-shot invocation, the
source-execution path above is sufficient. For repository tests, especially parallel shards, build once and invoke the
pinned executable directly:

```bash
opam exec -- dune build --root=/path/to/herdtools7 asllib/aslref.exe
/path/to/herdtools7/_build/default/asllib/aslref.exe --version
```

Do not wrap every long-running ASLRef shard in `dune exec`. Dune retains the source workspace lock until the child exits,
so multiple shards that appear parallel will serialize on the shared build tree. Run `make setup` before scheduling
shards. Its `scripts/prepare-aslref` step is the sole owner of fetching, checking out, and building the exact pinned
checkout. The repository `scripts/aslref` wrapper remains the canonical entry point for local and CI validation, but it
is deliberately read-only: it verifies the prepared checkout origin, commit, and executable, then runs it. If preparation
is missing or stale, the launcher fails closed and instructs the caller to run `make setup`; it must not mutate a shared
cache from a parallel shard.

ASLRef parses and types every declaration assembled into a shard, including test functions that its `main()` never
calls. A parallel shard should therefore include the complete normative specification but only the test-library sources
needed by that shard. Preserve a canonical full-suite assembly as the coverage reference, and fail closed unless the
shard mains partition its direct calls exactly once and retain reachability of every declared test entry point.
