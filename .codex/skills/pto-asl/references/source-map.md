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

## Public PTO contract

- Public architecture manuals and instruction-family pages define intended PTO
  behavior.
- `spec/catalog/` is authoritative for accepted forms, fields, constraints,
  registers, traps, selectors, and reserved values once reconciled.
- `spec/requirements.json` and the ASL model must trace every accepted surface
  to executable evidence.

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
