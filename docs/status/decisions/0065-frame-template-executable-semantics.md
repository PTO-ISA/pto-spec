# ADR 0065: PTO-v0 Frame-Template Executable Semantics

- **Status**: accepted
- **Date**: 2026-08-12
- **Deciders**: PTO ISA maintainers
- **Issue**: [#73](https://github.com/PTO-ISA/pto-spec/issues/73)
- **Supersedes**: the PTO-v0 frame-handler rejection in ADR-0032 only

## Decision

`FENTRY`, `FEXIT`, `FRET.RA`, and `FRET.STK` are executable PTO-v0 commands. All
other ADR-0032 unsupported-handler boundaries remain unchanged. Architectural
`sp` is R1 and `ra` is R10. Frame endpoints are the inclusive R2..R23 ring,
wrapping R23 to R2; singleton, wrap, and full-ring ranges are legal, while R0,
R1, and selectors 24..31 are illegal endpoints. If `N` is the inclusive range
length and `F` is the decoded byte size, legality requires `1 <= N <= 22`,
`F % 8 == 0`, and `F >= 8*N`; `FRET.STK` additionally requires Begin == R10.
Malformed forms fault `Fault_IllegalInstruction` before effects.

For caller SP `C`, saved slot `i` is `C - 8*(i+1)` in ring order. `FENTRY`
uses pre-instruction R1 as `C` and sets R1 to `C-F`; exits/returns use pre-R1
frame SP `A` and set R1 to `A+F`. Every slot is one existing PTO-v0 translated,
permission-checked, aligned 8-byte little-endian relaxed scalar access. All
possibly faulting accesses and return-target checks are preflighted before any
frame effect; faults have zero SP/GPR/memory/frame-bookkeeping/return-state
effects and ordinary trap recovery retries the whole instruction. The bounded
memory-event array is verification infrastructure, not a frame-size limit.

`FRET.STK` obtains its target from slot zero (saved R10), reads that slot once,
and mirrors restored R10 into `_ReturnAddress`. `FRET.RA` retains the
pre-restore `_ReturnAddress` target; restoring R10 in any frame restore mirrors
that restored value into `_ReturnAddress`, while ordinary direct R10 writes do
not. `_BundleReturnTarget` is not a frame-return source. Return targets use the
portable PTO rule: odd targets fault `Fault_InstructionPC`, and even targets
are accepted without Linx marker/fetchability requirements. Successful FENTRY
and FEXIT retire sequentially by +4; successful FRET.RA and FRET.STK own their
return TPC and receive no sequential +4.

FENTRY preflights stores in slot order; FEXIT preflights and snapshots all
loads; FRET.RA validates its retained target before probing frame slots; and
FRET.STK probes/reads slot zero before validating its target, then probes later
slots in order. A failed slot reports the existing
`Fault_DataAlignment`/`Fault_DataPage` identity at that address, with target
faults taking the stated precedence. Successful accesses emit one relaxed
8-byte event per slot in ring order. `_FrameDepth` and `_LastFrame*` are
diagnostic bookkeeping updated only after successful commit and never resolve
addresses or impose a portable nesting limit. PTO-v0 adds no template-step,
lease, ROB, replay, or partial-restart state; ordinary trap recovery retries
the complete instruction.

## Consequences

The normative owners are the four frame instruction units and block lifecycle,
dispatch-decode, and dispatch-command units, with existing scalar program
control, block state, and PTO memory contracts as direct consumers. Generated
instruction pages, catalogs, decoder/totality evidence, requirements and
traceability projections, and decoded AVS tests must agree with these owners.
No LinxISA marker, lease, restart cursor, ROB, MMIO, CFI, or nested-body
mechanism is added to PTO-v0.
