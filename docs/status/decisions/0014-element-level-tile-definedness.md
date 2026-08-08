# ADR 0014: Track tile definedness per element

## Status

Accepted.

## Context

Allocation deliberately leaves tile payload undefined. A single
`contents_defined` flag previously changed to true after any element write,
which made every other element in the valid region readable. Whole-tile
arithmetic, reductions, and payload-dependent legality checks could therefore
observe carrier values that no architectural operation had produced.

The architecture needs both element-precise reads and an efficient legality
predicate for operations that consume an entire valid region.

## Decision

- Every `TileInfo` has one definedness bit for each executable-model payload
  element and a count of defined elements in its current valid region.
- `contents_defined` is the maintained summary that every element of the valid
  region is defined. It is not an independent source of truth.
- An element write defines only its addressed element. Rewriting an already
  defined element does not increment the valid-region count.
- A generic element read requires the selected element's definedness bit. It
  does not gain access to sibling elements merely because one write occurred.
- Operations that overwrite their complete destination valid region mark that
  region defined after all payload effects. Partial update operations require
  the untouched destination region to be defined before execution.
- Decoded operations that consume a whole source valid region reject an
  incomplete source before the first destination effect. Payload-dependent
  legality checks likewise fail closed on incomplete inputs.
- Allocation, reconfiguration, release, and reset clear all element
  definedness and the valid-region count. Descriptor-and-payload copies carry
  the corresponding definedness state.

Elements outside the valid region remain unobservable unless an operation
explicitly defines and addresses them. Such writes set their element bit but do
not contribute to the valid-region summary.

## Consequences

One-element initialization can be tested without accidentally defining a
whole tile. Reductions and other whole-region consumers cannot expose unwritten
payload. The ASL model retains `contents_defined` for concise dispatch
legality, but its value is now derived and covered by per-element regression
tests.
