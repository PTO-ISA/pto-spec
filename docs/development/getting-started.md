# Getting started

## Pull-request environment

Install Git, GNU Make, and Python 3.11 or newer. Clone submodules and run the
lightweight lane:

```bash
git clone --recurse-submodules https://github.com/PTO-ISA/pto-spec.git
cd pto-spec
make pr-check
```

If the repository was cloned without submodules, run:

```bash
git submodule update --init --recursive
```

The pull-request lane does not need opam or a prepared ASLRef checkout.

## Full-model environment

Full verification additionally requires OCaml, opam, network access, and the
repository-pinned ASLRef source. Prepare it once, then run the release-equivalent
sequence:

```bash
make setup
make release-verify
make release-prepare
```

The setup command verifies the upstream origin and full commit pin before it
builds the read-only executable cache.

## Typical edit loop

1. Identify the one owning ASL/NDF, ADR, policy page, or generator.
2. Add a failing focused test for changed behavior.
3. Make the smallest owner change.
4. Run the owner’s generator rather than editing derived output.
5. Run `make pr-check`, `make repo-check`, and `git diff --check`.
6. Inspect `scripts/generate-review-summary --base REF --head REF` before review.

Architecture changes also follow the [ADR process](../governance/adr-process.md).

## Troubleshooting

- **Submodule or NDF tool missing:** run `git submodule update --init --recursive`.
- **ASLRef cache absent or wrong commit:** rerun `make setup`; do not alter the
  launcher or pin to reuse an unverified cache.
- **Generated Markdown or navigation is stale:** run
  `python3 scripts/instruction_docs.py`, inspect the diff, and rerun its
  `--check` mode.
- **A generated evidence file drifts:** run the named generator without
  `--check`, inspect all owner inputs and output, then rerun the check.
- **A negative canary fails the overall lane:** confirm it was rejected for the
  expected reason; a rejection fixture must not be converted into accepted ASL.
- **Release result is not for the candidate SHA:** dispatch or run validation
  for the exact candidate. Earlier results cannot be reused.

The [validation guide](../governance/validation.md) explains lane authority and
failure rules.
