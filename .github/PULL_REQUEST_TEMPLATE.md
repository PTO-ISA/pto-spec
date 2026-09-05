## Change contract

- Change classes / reviewed head: <!-- from scripts/prepare-pr; final full SHA -->
- Linked NDF architecture issue: <!-- issue URL, or N/A for non-normative maintenance -->
- Baseline commit: <!-- full 40-character SHA -->
- Changed NDF clause IDs: <!-- PTO-* IDs, or N/A -->
- Normative ASL owner files: <!-- asl/... paths, or N/A -->

## Normative delta

Describe architecture-visible behavior, defaults, intentionally unspecified
behavior, compatibility, and toolchain impact. Do not restate executable ASL in
prose.

- Compatibility: <!-- compatible | breaking | unspecified; name the consumer contract, or not-applicable -->
- Downstream obligations: <!-- repository PR/case URLs and landing order, or not-applicable -->

## Agent review

- Independent reviewer execution: <!-- transcript/host record; agents may share a GitHub account -->
- Review verdict / findings: <!-- explicit verdict bound to final prepare-pr identity; unresolved findings -->
- Receipt check: <!-- prepare-pr --review result; this does not replace required hosted checks -->

## Projections and focused evidence

- [ ] Generated instruction pages and navigation were regenerated from ASL.
- [ ] Focused positive, boundary, negative, and state-transition tests cover the delta.
- [ ] Catalog, requirement, profile, and evidence projections were updated when owned by this change.
- [ ] No legacy, archive, backup, or second normative explanation was added.
- [ ] `make pr-check`
- [ ] `git diff --check`

## Release boundary

- [ ] I understand that PR validation is intentionally lightweight.
- [ ] Full ASLRef verification, every independent AVS result, and reproducible release evidence are deferred to the manually dispatched exact-head release workflow.
- [ ] Release verification is required for this change, or the reason it is not required is stated below.

Release impact and known gaps:
