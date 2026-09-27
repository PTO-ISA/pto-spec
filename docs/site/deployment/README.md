# Root Pages deployment handoff

The production controller is `PTO-ISA/pto-isa.github.io`. It must not infer PTO
semantics. PTO-SPEC's Release workflow certifies ISA evidence only; it does not
build or upload a site preview. The controller must own site publication from
an immutable PTO-SPEC release commit and a separately validated site artifact.
The current PTO-SPEC `Site` workflow checks source quality but does not yet
produce a deployable preview or grant production authority.

## Cutover contract

- Disable the existing `hw-native-sys/pto-isa` MkDocs publisher before enabling
  the new controller.
- Switch `PTO-ISA/pto-isa.github.io` from legacy branch publication to GitHub
  Actions Pages.
- Accept only an immutable PTO-SPEC release tag backed by a successful PTO-only
  release run. Resolve the tag to the exact source commit and verify its release
  manifest before building the site.
- Build from that commit with locked dependencies and run the site security,
  typecheck, unit, browser, and Lighthouse checks in the site publication
  pipeline. A passing PTO-SPEC release run does not substitute for these checks.
- Produce and verify a content-addressed site preview artifact in that pipeline;
  do not request `pto-site-preview-<commit>` from PTO-SPEC's Release workflow.
- Read the independently generated `pto-site-publication.json` and require:
  - `schema` is `pto.site-publication.v1`;
  - `release_eligible` is `true`;
  - `publication_state` is `release`;
  - `architecture_version` remains the normative ISA version;
  - `publication_version` equals the accepted four-part publication revision;
  - `source_commit` equals the accepted release commit;
  - `tag` equals the accepted release tag;
  - recomputed `site_tree_sha256`, `redirect_manifest_sha256`, and
    `dependency_lock_sha256` values match the manifest.
- Deploy the independently verified directory atomically through the `github-pages`
  environment.
- Do not push generated HTML back into `PTO-ISA/pto-spec`.

The controller workflow is intentionally not activated from this repository.
Changing the live Pages source, disabling the existing publisher, and granting
cross-repository deployment authority are external production actions performed
only during the approved root-site cutover.
