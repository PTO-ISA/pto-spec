# Formal model coverage

Coverage grades describe executable architecture evidence, not only parser or
mnemonic presence. The accepted surface is complete; the repository remains a
normative draft until the named profile hooks and independent evidence gaps are
closed.

| Area | Accepted surface | Current ASL grade | Executable evidence | Remaining closure |
| --- | ---: | --- | --- | --- |
| Scalar state | 24 GPRs, PC, return, commit, predicate, trap, system state | implemented | reset, R0, predicate, trap envelope, and state tests | platform-specific exception routing |
| Scalar forms | 474 | complete decode, operand extraction, handler linkage, and decoded execution | one positive decode, every operand-field witness, one semantic-handler witness per form, all-form canonical execution, and family effect witnesses | none for current decoded dispatch |
| Scalar semantics | AGU, ALU, AMO, BRU, FSU, SYS | surface-complete draft | arithmetic, division, wide multiply, bitfields, control, memory, atomic, system, raw FP carrier/comparison/min-max/flag, and mathematical FP tests | concrete correctly rounded FP arithmetic/conversion and privileged profiles |
| System registers | 52 definitions, 13 trap numbers | executable catalog | generated access witnesses and read/write/trap tests | platform-specific reset values |
| Tile registers | 64 | implemented | hand mapping, descriptor, capacity, and alias tests | none in the portable state model |
| TEPL | 97 operations | decoded execution complete | elementwise, reduction, expansion, generation, conversion, rearrangement, complex, pipe, and decoded-effect tests | explicit legality, numeric profile hooks, and independent evidence gaps |
| TMA | 6 operations | decoded execution complete | decoded load plus load/store/move/prefetch/gather/scatter tests | explicit legality and concrete completion/translation/permission profiles |
| CUBE | 8 operations | decoded execution complete | decoded matrix multiply plus matrix/vector base, bias, accumulate, and MX tests | explicit legality and numeric type/accumulation profiles |
| Encodings | 474 scalar forms + 111 tile operations | executable complete | generated ASL decoders, operand/handler bindings, reserved-code assertions, and decoded family effects | none for accepted selector-to-handler identity |
| Independent tile cross-check | 111 operations | complete disposition inventory | 97 agree, 1 conflict, 13 incomplete | resolve incomplete evidence pages |

`surface-complete draft` means every accepted operation is connected to an ASL
semantic primitive, while explicitly named numeric or system profiles can still
determine portable details. It does not mean `architecturally-complete`.

## Decoder evidence

The scalar catalog contains 45 operand-field kinds, 1,867 encoded field pieces,
and three form-legality constraints. Build generation emits strict ASL for:

- all 474 scalar form masks and matches, ordered by mask specificity;
- every scalar operand field, including split-field reconstruction;
- operand width, signedness, presence, and form-legality queries;
- one-level Reg5 mapping across GPR and direct T/U bridge selectors;
- exact linkage of every scalar form to one of 68 checked ASL semantic handlers;
- decoded execution for all 474 forms, including legality, operand binding,
  Reg5 reads, all scalar address classes and update modes, atomic width/order/
  reservation effects, predicate/commit state, system-register addressing,
  maintenance, fences, requests, faults, floating carrier/type legality,
  ordered comparisons, NaN/signed-zero min/max, and sticky FP flags;
- all 111 direct tile operation selectors, semantic handlers, typed operand
  presence, ordered handler arguments, and decoded execution cases; and
- positive witnesses for every accepted form, operand occurrence, and tile
  selector, every catalog-reserved and review-only tile code, plus
  out-of-width representatives.

The repository checker independently rejects out-of-width masks, unmasked match
bits, overlapping field pieces, non-contiguous reconstructed values, dangling
constraints, ambiguous equal-priority encodings, and unreviewed overlaps.
It also requires every one of the 68 scalar semantic primitives and all 51 tile
handler groups to appear in executable ASL feature evidence, every scalar form
to have a checked-in decoded-operation binding, and the tile catalog to generate
the public decoded execution boundary. Handler-name presence in the normative
sources alone is insufficient.

## Explicit gaps

- Thirteen accepted tile operations have incomplete independent evidence pages.
- TPREFETCH is destination-free in PTO while the current independent evidence
  shows a tile destination; PTO remains authoritative.
- Backend availability is not evidence of portable semantics.
- Floating arithmetic, transcendental, and low-precision conversion hooks still
  require a concrete correctly rounded numeric profile. Carrier widths,
  type-code legality, ordered comparison behavior, NaN/signed-zero min/max,
  destination packing, and sticky flags are executable in the portable model.
- `ExecuteScalarInstruction` runs every accepted scalar form through legality,
  operand binding, Reg5 access, and its architecture state transition.
- `ExecuteTileInstruction` runs every accepted tile selector through its
  catalog-declared operand binding and architecture state transition. Explicit
  per-operation legality and restart rules remain closure work.
- Translation, permission, and some numeric conversion details remain named
  profiles rather than silent implementation behavior. Tile memory accesses
  use the scalar data-access hooks, including destination-free prefetch.
- Platform-specific interpretation of the atomic FAR address-class hint remains
  a named refinement of the portable flat-address baseline.

These gaps remain machine-readable in
`spec/evidence/independent-tile-crosscheck.json` and
`spec/profile-hooks.json`. CI requires the profile registry to match every ASL
`impdef` declaration exactly. Green validation does not erase them.
