# ADR 0015: Define explicit tile handoff slots

## Status

Accepted.

## Context

The direct tile catalog gives `TPUSH` and `TPOP` explicit destination and source
tile indices, but both operations previously copied the same complete
`TileInfo` record. That made the two mnemonics architecturally indistinguishable
and left source lifetime, full/empty behavior, ordering, and capacity effects
undefined.

PTO does not expose implementation pipe, semaphore, scheduler, or physical FIFO
state. The direct architecture therefore needs management semantics expressed
only through visible `TileInfo` allocations and instruction operands.

## Decision

- A tile index used as a handoff slot is ordinary visible `TileInfo` state; no
  hidden pipe state or implicit queue cursor is added.
- `TPUSH destination, source` publishes a complete, defined source tile into an
  unallocated destination slot. The source remains allocated and unchanged.
  The publication duplicates the allocation, so the resulting aggregate
  capacity must fit `TILE_CAPACITY`.
- `TPOP destination, source` consumes an allocated, defined source slot into an
  already configured destination with matching shape, valid region, type, and
  layout. It copies payload and element-definedness while retaining the
  destination descriptor, then releases the source slot.
- Source and destination must differ. Push to a full slot, pop from an empty
  slot, a mismatched pop, and self-aliasing are illegal before any effect.
- `TFREE destination` releases an allocated tile or handoff slot. Freeing an
  already free index is illegal.
- Slot selection and ordering are explicit in the tile-index operands and
  architectural program order. PTO defines no hidden FIFO order between
  different indices; software chooses and sequences the slots it uses.

Typed producer/consumer helpers may refine these direct operations with
implementation scheduling and transport behavior, but that evidence cannot add
portable hidden state or change the visible effects above.

## Consequences

`TPUSH` and `TPOP` are observably distinct. Producer lifetime, consumer
descriptor preservation, source-slot release, capacity duplication, full and
empty failures, alias rejection, and explicit multi-slot selection all have
decoded executable witnesses.
