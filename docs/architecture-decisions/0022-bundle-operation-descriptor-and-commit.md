# ADR 0022: Bundle operation descriptor and transactional commit

## Status

Accepted.

## Context

The command catalog contains 71 bundle-start forms. Several carry an operation
selector, DataType, Mode, or compressed BrType, but the earlier model retained
only a coarse bundle kind and transfer. A start could therefore decode
successfully while discarding the field that distinguishes its operation. The
earlier start/stop path also had no direct connection to the accepted tile
catalog and could not prove that a failed commit preserved the destination.

Priority decoding matters because some variable-width command masks overlap.
A match-only witness can name one catalog row while the architectural decoder
selects a more-specific row. Exact-form evidence must therefore use the same
priority order as execution.

## Decision

- Every accepted bundle start constructs a `BundleOperationDescriptor` with
  the exact command-form identity, operation class, selector-presence and
  selector value, DataType-presence and value, Mode-presence and value, and
  BrType-presence and value.
- Specific TLSU and CUBE starts use constants from the direct Tile-operation
  catalog. Generic TEPL and CUBE starts retain their encoded selector. No
  independent selector table is permitted.
- PTO v0 recognizes compressed BrType values 1 (`FALL`), 5 (`IND`), 6
  (`ICALL`), and 7 (`RET`). Values 0, 2, 3, and 4 are illegal and install no
  descriptor.
- DataType codes map to tile types as follows. Codes not listed are illegal for
  a PTO v0 tile-operation bundle start.

| Codes | Tile types |
| --- | --- |
| 0, 1 | F64, F32 |
| 4, 5 | F16, BF16 |
| 7, 8 | FP8, FPL8 |
| 13, 14 | E8M0, FPL4 |
| 16–20 | S64, S32, S16, S8, S4 |
| 24–28 | U64, U32, U16, U8, U4 |

- PTO v0 has no direct FIXP selector family. `BSTART.FIXP` remains recognizable
  as a catalog encoding but returns `CommandExecution_Rejected` with
  `Fault_IllegalInstruction` before changing bundle state.
- A generic CUBE selector must name one of the 13 accepted direct CUBE
  operations. Holes are illegal. Reserved TEPL carrier selectors, TLSU
  functions, CUBE functions, and
  unsupported DataTypes fault before an active bundle is committed.
- BSTART validates the new descriptor and target before committing an existing
  bundle. After a successful boundary commit it clears the prior header state,
  installs the new descriptor, records the pending transfer, and advances TPC
  sequentially to the following header command. BPC records the selected
  bundle target.
- BSTOP and the next BSTART are commit boundaries. A tile-operation descriptor
  must have a final B.IOT binding that supplies every required operand. The
  bound allocated tile types must match the start DataType. PTO v0 currently
  supports the B.IOT slot-zero shape: destination0, source0, and source1.
  Operations requiring other operands are explicitly rejected at commit.
- A legal commit invokes exactly one direct tile semantic operation without a
  second architectural-time increment. The enclosing command remains the one
  decoded execution attempt.
- Descriptor, binding, type, or tile-legality failure leaves tile destinations
  unchanged. Trap entry preserves the live bundle descriptor and header state
  for diagnosis and recovery.
- Generated command witnesses must select their intended form through the real
  priority decoder. Exact-form checks execute in the normal ASL test entrypoint.

## Consequences

Bundle starts are observably distinct wherever their architectural fields are
distinct. A green decode can no longer hide a discarded selector or modifier,
and a bundle can no longer launch a default tile operation accidentally.
Unsupported families and operand shapes have an explicit rejection boundary
instead of placeholder behavior.

The direct B.IOT shape is intentionally narrower than the full direct tile
catalog. Extending it requires a new binding representation, legality rules,
alias ordering, rollback tests, and an update to this decision; it must not fill
missing operands with fixed zero values.
