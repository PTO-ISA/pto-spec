# Mnemonic-owned ASL test shards implementation plan

## Goal

Fix the exact `TLOADShared` regression from Actions run `31140187057`, make the
Shared/local TSize capacity invariant explicit, and make hosted ASL failures
directly navigable by named runtime shard.

## Tasks

1. Add a targeted Shared TSize/shape regression covering all seven power-of-two
   capacities, full-shape capacity checking, and smaller valid regions.
2. Correct the descriptor-mismatch fixture from TSize `001` to `011` while
   preserving its 63-element U64 shape and no-memory-effect assertions.
3. Replace composite tile runtime entrypoints with mnemonic-owned or explicitly
   cross-cutting shard files while retaining the shared test library to avoid
   duplicating helpers and fixtures.
4. Update `ASL_TEST_LIB`, per-shard libraries, and canonical/shard mains without
   changing the set of canonical calls.
5. Export the checked shard-name inventory in a form suitable for a GitHub
   Actions matrix while retaining rejection canaries for missing, duplicate,
   empty, and orphan shards.
6. Split the workflow into static planning, named runtime matrix jobs, and the
   protected `validate` aggregator. Keep strict checks and fail-fast behavior.
7. Run targeted failing/positive tests, `make repo-check`, `make release-check`,
   `make toolchain-check`, the full local ASL gate, and `git diff --check`.
8. Review the exact new head, push it to PR 52, and require a fresh exact-head
   hosted validation before merge.
