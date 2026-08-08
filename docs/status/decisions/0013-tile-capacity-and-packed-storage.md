# ADR 0013: Define tile capacity and packed storage

## Status

Accepted, with the minimum-allocation clause superseded by
[ADR 0045](0045-pto-isa-release-tile-contract.md).

ADR 0045 fixes the PTO ISA 0.57.1 architectural CELL at 128 bytes and makes
`B.IOT` size code 3 the minimum active allocation. The capacity-accounting,
packed-storage, precision, and rollback decisions below remain current.

## Context

`TileInfo` records an allocation capacity independently from the bounded ASL
payload used for executable verification. The previous model treated zero as
both a legal capacity and a release request, and it did not prove that the
declared shape fit in the allocation. It also counted four-bit formats as one
byte per element because each model payload slot uses a 64-bit carrier. Those
choices confused architectural storage with model representation.

The direct `TALLOC` form must reject an illegal descriptor before changing the
old destination. `TFREE` needs a distinct release transition so zero capacity
cannot be mistaken for an active allocation.

## Decision

- An active tile allocation has a capacity from 128 bytes through the current
  `TILE_CAPACITY` value, inclusive. Zero is never an active capacity.
- `TFREE` invokes a separate release transition. Release clears allocation,
  definedness, capacity, shape, valid region, data type, layout, and location
  descriptor state; it does not need a zero-capacity `TALLOC` surrogate.
- The sum of all active allocation capacities cannot exceed `TILE_CAPACITY`.
  Reconfiguration replaces the destination's prior contribution before the
  new capacity is checked.
- Shape storage is `ceil(rows * columns * element_bits / 8)` bytes. Four-bit
  formats use four bits per element for this calculation, including rounding
  an odd final element up to a whole byte. Other formats use their declared
  8-, 16-, 32-, or 64-bit width.
- A legal allocation has positive shape dimensions, a valid region contained
  by that shape, architectural storage no larger than its capacity, and a
  shape representable by the selected executable-model bound.
- Decoded allocation and tile-copy management operations perform every
  capacity check before their first descriptor or payload effect.

This decision defines descriptor storage accounting. It does not silently
choose the byte-addressing or packing protocol for sub-byte tile-memory
transfers; that instruction-level rule remains a separate TMA closure item.

## Consequences

Zero, below-128-byte-minimum, shape overflow, and aggregate overflow are
tile-legality faults with the previous destination preserved. The 128-byte
minimum, maximum, exact-fit, reconfiguration, and release boundaries have
executable witnesses. The ASL payload carrier width remains verification
infrastructure and no longer determines architectural capacity for four-bit
formats.
