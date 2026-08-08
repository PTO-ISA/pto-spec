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
- `spec/requirements.json` traces every accepted surface to its ASL owner and
  independently executable evidence.
- `docs/status/legacy/` is historical, non-normative, excluded from agent
  routing, and never a source for current behavior.

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
