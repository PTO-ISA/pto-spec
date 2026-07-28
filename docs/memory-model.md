# PTO total store order

PTO uses a multi-copy-atomic total store order named `PTO-TSO`. The normative
executable definition is `asl/concurrency.asl`. It checks a bounded candidate
execution rather than pretending that counters attached to a sequential test
run prove concurrency behavior.

The ASL checker defines per-location order separately from the
global-happens-before relation. PTO owns the event classes, acquire/release
rules, fence masks, and atomic contract below. No external instruction behavior
is imported by reference.

## Candidate execution

A candidate contains a finite set of events. Event indices define program order
only between events with the same agent; indices do not define a cross-agent
execution order.

| Event | Reads | Writes | Additional fields |
| --- | --- | --- | --- |
| Initial write | no | yes | coherence rank 0 |
| Load | yes | no | value and reads-from source |
| Store | no | yes | value and positive coherence rank |
| Atomic | yes | yes | read/write values, reads-from source, order, coherence rank |
| `FENCE.D` | no | no | predecessor and successor masks |

Every accessed location has exactly one initial write. Writes to one location
have unique contiguous coherence ranks. A read takes its value from exactly one
write at the same location. An atomic event reads from the immediately preceding
write in coherence order and contributes the next write as one indivisible
event.

The current executable bound is 16 events across four agents. It is a model
checking bound, not an architecture limit. A location is an exact address and
size pair. A candidate containing mixed-size or partially overlapping accesses
fails validity until a byte-level coherence extension is specified; it is not
silently accepted under independent locations.

Successful scalar and tile data accesses contribute load or store events to a
candidate. Each architecturally indivisible atomic contributes one atomic
event. A completed `FENCE.D` contributes one fence event. A faulting instruction
contributes no access events because the instruction-wide completion contract
preflights all accesses before effects. Multi-access tile instructions
contribute their completed accesses in instruction program order.

## Relations

For candidate events `a` and `b`:

- `po-loc` orders same-agent accesses in program order at one exact location.
- `rf` orders the write selected by a read before that read; `rfe` restricts
  this to initial or different-agent sources.
- `co` orders writes at one location by coherence rank.
- `fr` orders a read before every write later than its reads-from source in
  coherence order.
- `ppo` preserves read-to-memory and memory-to-write program order. The normal
  store-to-load pair is relaxed. Atomics, applicable acquire/release order, or
  a matching data fence restore that pair.

`FENCE.D` mask bits 0 through 3 select data read, data write, device, and
instruction classes. The current candidate events exercise data bits 0 and 1.
A fence orders a preceding event to a following event only when both event
classes are selected by its predecessor and successor masks. Thus predecessor
`0010` and successor `0001` orders a data write before a later data read.

PTO acquire and release annotations never weaken TSO. Acquire orders its event
before later memory events; release orders earlier memory events before its
event. Acquire-release provides both. Atomic events are full ordering points.

## Axioms

A valid candidate is PTO-TSO-allowed exactly when both relations are acyclic:

```text
uniproc = po-loc | rf  | fr | co
ghb     = ppo    | rfe | fr | co
```

The first axiom supplies sequential consistency per location, including local
store forwarding and stale-read rejection. The second permits the classic
store-buffering result when both agents observe zero, but forbids it when a
write-to-read fence is present. It also forbids a message-passing observer from
seeing the publication store while missing an earlier data store.

## Executable evidence

`tests/asl/concurrency-tests.asl` checks:

- permitted store buffering;
- forbidden write-to-read fenced store buffering and permitted mismatched-mask
  store buffering;
- permitted and forbidden message-passing outcomes;
- forbidden independent-reads-of-independent-writes disagreement;
- forbidden same-location stale reads and permitted local store forwarding;
  and
- rejection of a non-contiguous atomic read-modify-write candidate.

ADR-0006 records why PTO uses this axiomatic candidate boundary.
