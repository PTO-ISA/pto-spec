# Formal model coverage

Coverage grades describe executable architecture evidence, not only parser or
mnemonic presence. The accepted surface is complete; the repository remains a
normative draft until the named profile hooks and independent evidence gaps are
closed.

| Area | Accepted surface | Current ASL grade | Executable evidence | Remaining closure |
| --- | ---: | --- | --- | --- |
| Scalar state | 24 GPRs, PC, return, commit, trap, system state | implemented | reset, R0, trap envelope, and state tests | platform-specific exception routing |
| Scalar forms | 474 | complete decode, operand extraction, and handler linkage | one positive decode, every operand-field witness, and one semantic-handler witness per form | none at the accepted-surface layer |
| Scalar semantics | AGU, ALU, AMO, BRU, FSU, SYS | surface-complete draft | arithmetic, division, wide multiply, bitfields, control, memory, atomic, system, and mathematical FP tests | raw FP encoding, NaN/flag, and privileged profiles |
| System registers | 52 definitions, 13 trap numbers | executable catalog | generated access witnesses and read/write/trap tests | platform-specific reset values |
| Tile registers | 64 | implemented | hand mapping, descriptor, capacity, and alias tests | none in the portable state model |
| TEPL | 97 operations | 97/97 handler-mapped | elementwise, reduction, expansion, generation, conversion, rearrangement, complex, and pipe tests | numeric profile hooks and independent evidence gaps |
| TMA | 6 operations | 6/6 handler-mapped | load/store/move/prefetch/gather/scatter tests | translation, permission, ordering, and restart profile |
| CUBE | 8 operations | 8/8 handler-mapped | matrix/vector base, bias, accumulate, and MX tests | numeric type and accumulation profile |
| Encodings | 474 scalar forms + 111 tile operations | executable complete | generated ASL decoder and reserved-code assertions | none for accepted selector identity |
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
- all 111 direct tile operation selectors; and
- positive witnesses for every accepted form, operand occurrence, and tile
  selector, every catalog-reserved and review-only tile code, plus
  out-of-width representatives.

The repository checker independently rejects out-of-width masks, unmasked match
bits, overlapping field pieces, non-contiguous reconstructed values, dangling
constraints, ambiguous equal-priority encodings, and unreviewed overlaps.
It also requires every one of the 68 scalar semantic primitives and all 51 tile
handler groups to appear in executable ASL feature evidence; handler-name
presence in the normative sources alone is insufficient.

## Explicit gaps

- Thirteen accepted tile operations have incomplete independent evidence pages.
- TPREFETCH is destination-free in PTO while the current independent evidence
  shows a tile destination; PTO remains authoritative.
- Backend availability is not evidence of portable semantics.
- Mathematical floating semantics still require raw encoding, NaN payload,
  exception, and rounding-profile completion.
- Generated scalar decoding currently ends at form identity, operand extraction,
  legality, and semantic-primitive linkage. An end-to-end fetched-instruction
  dispatcher that binds each decoded form to its architecture state transition
  remains open.
- Translation, permission, restart, and some numeric conversion details remain
  named profiles rather than silent implementation behavior.

These gaps remain machine-readable in
`spec/evidence/independent-tile-crosscheck.json` and in ASL `impdef` declarations.
Green validation does not erase them.
