## Change class

- [ ] Repository or documentation maintenance only
- [ ] ASLRef/toolchain pin update
- [ ] Normative architecture model change
- [ ] Non-normative refactor

## Requirement traceability

List stable PTO requirement IDs and source links, or write `N/A - non-normative`.

## Architecture impact

Describe visible state, legality, results, ordering, faults, profile scope, and intentionally unspecified behavior.
Write `None` for non-normative changes.

## Evidence

- [ ] `make ci`
- [ ] `git diff --check`
- [ ] Positive and boundary tests, when semantics change
- [ ] Negative-legality and state-transition tests, when applicable
- [ ] New tests listed in `ASL_TESTS`
- [ ] `spec/requirements.json` updated when normative claims change
- [ ] No generated files committed
- [ ] No validation check or canary was weakened to make this change pass

## Review risks

List known gaps, assumptions, ASLRef limitations, and follow-up architecture decisions.
