---
{
  "id": "ADR-0003",
  "title": "Use PTO-owned system-register names",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-28",
  "accepted": "2026-07-28",
  "rejected": null,
  "superseded": null,
  "baseline": "edf3ae2df13778317674553a1f1d655b46508f99",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-C-SSRGET-DIRECT-IDS-001",
    "PTO-HL-SSRGET-DECISION-BINDING-001",
    "PTO-HL-SSRSET-DECISION-BINDING-001",
    "PTO-SSRGET-ADR-CONTRACT-001",
    "PTO-SSRSET-ADR-CONTRACT-001",
    "PTO-SSRSWAP-ADR-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL",
    "PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING",
    "PTO-ARCH-SYSTEM-REGISTERS-CONTEXT",
    "PTO-ARCH-SYSTEM-REGISTERS-INTERRUPT",
    "PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE",
    "PTO-ARCH-SYSTEM-REGISTERS-TIMER",
    "PTO-SCALAR-C-SSRGET",
    "PTO-SCALAR-HL-SSRGET",
    "PTO-SCALAR-HL-SSRSET",
    "PTO-SCALAR-SSRGET",
    "PTO-SCALAR-SSRSET",
    "PTO-SCALAR-SSRSWAP"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/4",
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR-0003: Use PTO-owned system-register names

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
