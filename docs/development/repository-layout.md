# Repository layout

Every topic has one owner. Hubs link to owners; they do not restate architecture
semantics.

| Path | Responsibility | Authority |
| --- | --- | --- |
| `asl/arch/` | Architecture-wide state, types, profiles, memory, and dispatch | Normative ASL/NDF |
| `asl/block/` | Bundle/command instruction and model units | Normative ASL/NDF |
| `asl/scalar/` | Scalar instruction and shared scalar-model units | Normative ASL/NDF |
| `asl/tile/` | Direct Tile instruction and shared Tile-model units | Normative ASL/NDF |
| `docs/{arch,block,scalar,tile}/` | Exact generated mirrors with bounded supplementary prose | Derived projection |
| `tests/asl/` | Independently runnable AVS points mirrored to each ASL owner | Executable evidence |
| `docs/status/decisions/` | ADR rationale and reviewed decision metadata | Decision record; not current semantic owner |
| `docs/status/open/` | Unresolved architecture choices | Gap record |
| `docs/governance/` | ADR and validation workflow guidance | Process policy |
| `docs/development/` | Contributor setup and repository navigation | Developer guidance |
| `docs/releases/` | Release identity and evidence entry points | Release navigation |
| `spec/catalog/` | Accepted-form, register, profile, and selector projections | Derived machine-readable view |
| `spec/evidence/` | Commit-scoped traceability and closure records | Derived evidence |
| `spec/release-inputs.json` | Explicit canonical evidence registry | Release input contract |
| `spec/release-manifest.json` | Content and encoding fingerprints | Generated release contract |
| `scripts/` | Deterministic generators and fail-closed checks | Executable repository policy |
| `.github/workflows/` | Hosted pull-request, nightly, and release lanes | Hosted executable policy |

ASL source order is derived from `PTO-UNIT` dependency metadata. Test discovery
comes from `PTO-TEST` records in the mirrored `tests/asl/` tree. There is no
hand-maintained aggregate semantic source or test owner.

Use the [architecture overview](../arch/overview/architecture.md) to enter the
formal reference, the [ADR process](../governance/adr-process.md) for normative
change control, and the [release hub](../releases/index.md) for commit-scoped
evidence.
