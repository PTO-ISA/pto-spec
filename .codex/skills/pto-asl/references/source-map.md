# PTO ASL source map

Use sources in this priority order. The published specification must remain
PTO-owned and must not disclose restricted source identities, paths, prose,
code, or diagrams.

## Language and tooling

- The ASL1 language reference defines syntax and semantics.
- The upstream ASLRef repository provides the parser, strict type checker,
  interpreter, language sources, and conformance tests.
- The reader guide is orientation material, not the language authority.
- The commit in `.aslref-version` is the audited executable baseline.

## Normative PTO contract

- `asl/{arch,block,scalar,tile}/` is the sole normative source. Each mnemonic
  file owns its metadata, legality, operation semantics, and embedded
  documentation regions.
- `docs/{arch,block,scalar,tile}/`, `spec/catalog/`, decoder witnesses, and
  release evidence are generated or checked projections of ASL. They are never
  an independent source of semantics.
- `tests/asl/{arch,block,scalar,tile}/` contains independently runnable AVS
  points that mirror their ASL owner.
- `spec/evidence/release-traceability-readiness.json` is the current generated
  ASL-to-page-to-AVS view. Continue from it to the commit-scoped inputs in
  `spec/release-inputs.json` and the generated release manifest.
- `spec/evidence/architecture-readiness.json` derives each active ADR lifecycle
  stage from the ADR index, release traceability, instruction contracts, and
  exact-commit validation evidence. It is a status projection, not semantics.
- `spec/release-selection.json` owns release inclusion policy. The generated
  manifest expands its exact ADR/NDF set and preserves per-NDF digests.
- `spec/evidence/adr-index.json` is the decision-routing index. Use it to find
  the accepted or draft record behind a change, then return to the affected
  ASL/NDF for current meaning.

The two lookup orders are therefore:

```text
Current semantics: owning ASL/NDF -> generated mirror -> AVS -> commit-scoped evidence
Decision history: ADR index -> affected ASL/NDF
```

## Migration evidence

- Treat a superseded source/release as read-only migration input, not a name or
  namespace to preserve.
- Treat a private reference as independent comparison evidence only.
- Record anonymized provenance hashes and dispositions under `spec/evidence/`.
- Rewrite conclusions in PTO terminology; never copy restricted text or code.
- An incomplete evidence page stays incomplete. A conflict requires an
  explicit PTO decision rather than silent preference.

## Target decisions

- The architecture name and namespaces are PTO-owned.
- Tiles use one architectural level and direct operations only.
- Scalar behavior is retained when it is relevant and not superseded by a
  public PTO decision.
- Target-specific behavior crosses named, machine-audited profile hooks.
- Every accepted operation closes catalog, decode, semantic binding,
  architecture-visible effects, and executable evidence together.
