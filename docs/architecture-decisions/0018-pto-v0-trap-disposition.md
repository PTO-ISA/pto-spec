# ADR 0018: Define the PTO v0 disposition of every trap identity

## Status

Accepted.

## Context

The canonical catalog assigns 13 trap numbers, but mnemonic presence did not
prove a production trigger or a complete entry and restart contract. The
initial review identified four identities without justified PTO v0 triggers:
execution-state check, instruction page fault, hardware breakpoint, and
hardware watchpoint. Execution-state check now has a defined recovery trigger;
the other three remain envelope-only. Assigning them to convenient instructions
or inventing debug and translation field layouts would import behavior that PTO
has not defined.

Trap number zero also cannot use a zero number alone to indicate “no trap.” The
visible argument-valid state distinguishes an execution-state-check entry from
an empty trap bank.

## Decision

- Every catalog row defines its PTO v0 status, producer envelope, cause,
  argument, and restart class.
- `EXEC_STATE_CHECK`, `ILLEGAL_INST`, `BUNDLE_TRAP`, `SCALL`, `INST_PC_FAULT`,
  `DATA_ALIGN_FAULT`, `DATA_PAGE_FAULT`, `INTERRUPT`, `SW_BREAKPOINT`, and
  `ASSERT_FAIL` are production-active in PTO v0.
- `INST_PAGE_FAULT`, `HW_BREAKPOINT`, and `HW_WATCHPOINT` have complete
  synchronous `SetFault` envelopes but no PTO v0
  production trigger. They remain visible identities for a future profile.
- An unsupported ACRE request-type encoding produces `ILLEGAL_INST`. A legal
  ACRE request with missing, inconsistent, reserved, or otherwise unrecoverable
  saved execution state produces `EXEC_STATE_CHECK`. This follows the canonical
  trap identity while documenting that the comparison Sail implementation
  currently routes its analogous target check through illegal instruction.
- PTO v0 receives already-decoded instruction bits and uses identity
  translation; it therefore has no instruction-fetch translation source for
  `INST_PAGE_FAULT`.
- ADR 0017 disables debug matching in PTO v0; writes to debug storage do not
  produce hardware breakpoint or watchpoint traps.
- Synchronous envelopes route through the normal manager policy, save the
  complete source context, report their declared argument, and recover to the
  saved TPC. `SCALL` additionally uses its established next-instruction resume
  rule. Interrupt entry retains its asynchronous status, source-supplied cause,
  pending ID argument, and saved-context recovery.
- Generated/catalog checks reject a missing producer declaration, missing
  cause/argument/restart contract, or a change to the three envelope-only
  identities without an explicit normative update.

## Consequences

All 13 trap identities have a machine-readable disposition and executable
entry/routing/recovery evidence. “Envelope only” is not a claim that the event
can occur in PTO v0; a future active MMU or debug profile must define trigger
conditions, precedence, and conformance tests before changing that status.
