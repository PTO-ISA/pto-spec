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
ignored build artifact. Keep the order explicit and deterministic.

## Upstream source build

The upstream workflow requires OCaml, opam, dune, menhir, and zarith. A source checkout can run ASLRef without
installing it globally:

```bash
opam exec -- dune exec --root=/path/to/herdtools7 asllib/aslref.exe -- --version
```

CI fetches exactly the commit in `.aslref-version`, installs build dependencies, and uses this source-execution path.
