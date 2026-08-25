# Root Pages deployment handoff

The production controller is `PTO-ISA/pto-isa.github.io`. It must not build or
infer PTO semantics. It deploys only an accepted, content-addressed site artifact
produced by the exact `PTO-ISA/pto-spec` release workflow.

## Cutover contract

- Disable the existing `hw-native-sys/pto-isa` MkDocs publisher before enabling
  the new controller.
- Switch `PTO-ISA/pto-isa.github.io` from legacy branch publication to GitHub
  Actions Pages.
- Accept only a successful `PTO-ISA/pto-spec` release run whose input commit is
  the commit named by the accepted release tag.
- Download `pto-site-preview-<commit>` and verify its GitHub artifact digest.
- Read `pto-site-publication.json` and require:
  - `schema` is `pto.site-publication.v1`;
  - `release_eligible` is `true`;
  - `publication_state` is `release`;
  - `architecture_version` remains the normative ISA version;
  - `publication_version` equals the accepted four-part publication revision;
  - `source_commit` equals the accepted release commit;
  - `tag` equals the accepted release tag;
  - recomputed `site_tree_sha256`, `redirect_manifest_sha256`, and
    `dependency_lock_sha256` values match the manifest.
- Deploy the verified directory atomically through the `github-pages`
  environment.
- Do not push generated HTML back into `PTO-ISA/pto-spec`.

The controller workflow is intentionally not activated from this repository.
Changing the live Pages source, disabling the existing publisher, and granting
cross-repository deployment authority are external production actions performed
only during the approved root-site cutover.
