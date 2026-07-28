# Formal model coverage

Coverage grades describe executable architecture evidence, not only parser or
mnemonic presence. The accepted PTO surface is scalar, block/command, and
direct tile. PTO does not include vector instruction execution.

| Area | Accepted surface | Current ASL grade | Executable evidence | Remaining closure |
| --- | ---: | --- | --- | --- |
| Scalar state | 24 absolute GPRs, four-entry T/U queues, P0..P7, TPC, return, commit, trap, ACR, system, time, and memory-order state | implemented under PTO v0 | reset, R0, queue, predicate, ACR, time, trap-envelope, and state tests | platform-specific exception routing outside PTO v0 |
| Block state | TPC, BPC, active/body flags, block condition, arguments, dimensions, scalar IO, tile IO, control attributes, and data attributes | implemented under PTO v0 | block start, stop, argument, dimension, IO, transfer, and fault tests | target-specific scheduling and vector execution are excluded |
| Scalar forms | 474 | complete decode, operand extraction, Reg5 mapping, handler linkage, and decoded execution | one positive decode, every operand-field witness, one semantic-handler witness per form, all-form canonical execution, aliasing order, queue behavior, DMA, and reserved-encoding rejection | none for current decoded dispatch |
| Block/command forms | 107 | complete decode, operand extraction, form constraints, handler linkage, and decoded execution | generated witnesses and block tests for accepted command classes | vector-only block and queue forms are rejected by catalog policy |
| Scalar semantics | AGU, ALU, AMO, BRU, FSU, SYS | complete under PTO v0 | arithmetic, division, wide multiply, bitfields, control, memory, atomic, DMA, system, raw-carrier FP, profile, and ACR tests | alternate IEEE or hardware profiles only if separately specified |
| System registers | 54 definitions, 13 trap numbers | executable catalog with explicit ACR policy and reset | generated access witnesses plus read/write/trap/ACR/reset tests | none for PTO v0 |
| Tile registers | 64 `TileInfo` records | implemented | hand mapping, undefined-after-allocation, layout, descriptor, and system-register capacity tests | profile-specific implementation-defined indexing |
| TEPL | 98 operations | decoded execution with explicit legality under PTO v0 | elementwise, reduction, expansion, generation, conversion, rearrangement, complex, management, decoded-effect, profile, negative-data/descriptor, and no-partial-effect tests | none for accepted selectors |
| TMA | 9 operations | decoded execution with explicit legality, PTO v0 access policy, precise completion, and shared PTO-TSO events | load/store/move/prefetch/gather/scatter, masked gather/scatter, gather-CAS, profile, descriptor, fault, preservation, restart, and concurrency tests | mixed-size concurrency extension |
| CUBE | 13 operations | decoded execution with explicit legality under PTO v0 | matrix multiply, matrix/vector, bias, accumulate, MX, ACCCVT, profile, and composite preflight tests | alternate hardware numeric profile only if desired |
| Encodings | 474 scalar forms + 107 block/command forms + 120 direct tile operations | executable complete for the accepted PTO surface | generated ASL decoders, operand/handler bindings, rejected-code assertions, and decoded family effects | vector instructions are intentionally out of scope |
| PTO-TSO concurrency | 16-event/four-agent verification bound | executable axiomatic candidate model | store buffering, fenced store buffering, message passing, IRIW, same-location forwarding/stale-read, and atomicity tests | byte-level mixed-size coherence |

`complete under PTO v0` means every accepted operation is connected to an ASL
semantic primitive and every registered implementation-defined interface has a
concrete override and direct conformance witness. PTO v0 is a deterministic
raw-carrier reference profile, not an IEEE-754 or hardware-performance claim.

## Decoder evidence

The scalar catalog contains 45 operand-field kinds, 1,867 encoded field pieces,
three form constraints, and no family-wide operand constraints. Build
generation emits strict ASL for:

- all 474 scalar form masks and matches, ordered by mask specificity;
- every scalar operand field, including split-field reconstruction;
- operand width, signedness, presence, and form-local legality;
- Reg5 mapping across absolute GPR and T/U queue selectors;
- exact linkage of every scalar form to one of 68 checked ASL semantic
  handlers;
- decoded execution for all 474 scalar forms, including legality, operand
  binding, Reg5 reads, address classes and update modes, atomic width/order/
  reservation effects, DMA, predicate/commit state, system-register addressing,
  maintenance, fences, requests, faults, floating carrier/type legality,
  ordered comparisons, NaN/signed-zero min/max, and sticky FP flags;
- all 107 block/command form masks and matches, operand extraction, constraints,
  command-state bindings, and handler dispatch;
- all 120 direct tile operation selectors, semantic handlers, typed operand
  presence, ordered handler arguments, and decoded execution cases; and
- positive witnesses for every accepted form, operand occurrence, block command,
  and tile selector; negative witnesses for each declared constraint and
  rejected selector range.

The repository checker independently rejects out-of-width masks, unmasked match
bits, overlapping field pieces, non-contiguous reconstructed values, dangling
constraints, ambiguous equal-priority encodings, and unreviewed overlaps. It
also requires accepted handlers to appear in executable ASL feature evidence and
requires generated instruction-reference freshness.

## Explicit limits and future extensions

- PTO has no vector instruction execution surface. Adding one would require new
  catalogs, state, semantics, tests, and profile evidence.
- PTO v0 closes numeric interfaces with deterministic raw-carrier behavior; it
  deliberately does not claim correctly rounded IEEE-754 arithmetic.
- PTO v0 uses identity translation and explicit ACR0..ACR15 permissions.
- Scalar pairs, DMA, and tile memory operations preflight every access and
  commit atomically at instruction granularity. Fault witnesses prove original
  address reporting, preservation, and restart by full reissue.
- Platform-specific interpretation of address-class hints remains a named
  refinement of the portable flat-address baseline.
- PTO-TSO is executable for exact address-and-size locations. Mixed-size and
  partially overlapping candidate accesses fail closed pending byte-level
  coherence rules and litmus evidence.

The profile registry is closed for PTO v0: CI requires exact equality among all
registered hooks, ASL `impdef` declarations, active implementations, and direct
conformance calls. Green validation does not turn PTO v0 into an IEEE or
hardware profile.
