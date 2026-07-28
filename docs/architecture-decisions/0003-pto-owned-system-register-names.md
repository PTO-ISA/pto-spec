# ADR-0003: Use PTO-owned system-register names

- Status: accepted
- Formal-model issue: [#4](https://github.com/PTO-ISA/pto-spec/issues/4)
- Decision date: 2026-07-28

## Context

The retained scalar system-register addresses include names that carried
source-specific abbreviations or branding rather than portable architectural meaning. The PTO
normative specification must preserve the address and access contracts without
retaining an identity from a superseded source.

## Decision

PTO assigns these canonical names:

| Address | PTO name | Access |
| --- | --- | --- |
| `0x0000` | `THREAD_PTR` | read-write |
| `0x0001` | `GLOBAL_PTR` | read-write |
| `0x0020` | `CORE_STATE` | read-write |
| `0x0021` | `CORE_ID` | read-only |
| `0x0024` | `CORE_FEATURE` | read-only |
| `0x0025` | `CORE_FEATURE_ENABLE` | read-write |
| `0x0026` | `THREAD_ID` | read-only |
| `0x0027` | `TILE_CAPACITY` | read-only |

The rename changes no address, width, access class, or dynamic behavior.

## Consequences

- ASL enumeration members and record fields use the PTO names.
- Catalog generation and access witnesses remain keyed by the same addresses.
- Future documents and profiles must not restore source-branded aliases.
