---
{
  "id": "ADR-0018",
  "title": "Define the PTO v0 disposition of every trap identity",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ACRC-DECISION-BINDING-001",
    "PTO-ACRE-IMPLICIT-STOP-001",
    "PTO-BSE-DECISION-BINDING-001",
    "PTO-BWE-DECISION-BINDING-001",
    "PTO-BWI-DECISION-BINDING-001",
    "PTO-BWT-DECISION-BINDING-001",
    "PTO-C-EBREAK-CAUSE-001",
    "PTO-C-SSRGET-DIRECT-IDS-001",
    "PTO-EBREAK-DECISION-BINDING-001",
    "PTO-FENCE-D-DECISION-BINDING-001",
    "PTO-FENCE-I-DECISION-BINDING-001",
    "PTO-HL-SSRGET-DECISION-BINDING-001",
    "PTO-HL-SSRSET-DECISION-BINDING-001",
    "PTO-LSRGET-BARG-001",
    "PTO-SETC-TGT-ADR-CONTRACT-001",
    "PTO-SSRGET-ADR-CONTRACT-001",
    "PTO-SSRSET-ADR-CONTRACT-001",
    "PTO-SSRSWAP-ADR-CONTRACT-001",
    "PTO-TLB-IA-ADR-CONTRACT-001",
    "PTO-TLB-IALL-ADR-CONTRACT-001",
    "PTO-TLB-IAV-ADR-CONTRACT-001",
    "PTO-TLB-IV-ADR-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-FAULT",
    "PTO-ARCH-DATA-TYPES-TRAP-CONTEXT",
    "PTO-ARCH-STATE-TRAP-CONTEXT",
    "PTO-SCALAR-ACRC",
    "PTO-SCALAR-ACRE",
    "PTO-SCALAR-ASSERT",
    "PTO-SCALAR-BC-IALL",
    "PTO-SCALAR-BC-IVA",
    "PTO-SCALAR-BSE",
    "PTO-SCALAR-BWE",
    "PTO-SCALAR-BWI",
    "PTO-SCALAR-BWT",
    "PTO-SCALAR-C-EBREAK",
    "PTO-SCALAR-C-SSRGET",
    "PTO-SCALAR-DC-CISW",
    "PTO-SCALAR-DC-CIVA",
    "PTO-SCALAR-DC-CSW",
    "PTO-SCALAR-DC-CVA",
    "PTO-SCALAR-DC-IALL",
    "PTO-SCALAR-DC-ISW",
    "PTO-SCALAR-DC-IVA",
    "PTO-SCALAR-DC-ZVA",
    "PTO-SCALAR-EBREAK",
    "PTO-SCALAR-FENCE-D",
    "PTO-SCALAR-FENCE-I",
    "PTO-SCALAR-HL-SSRGET",
    "PTO-SCALAR-HL-SSRSET",
    "PTO-SCALAR-IC-IALL",
    "PTO-SCALAR-IC-IVA",
    "PTO-SCALAR-LSRGET",
    "PTO-SCALAR-SETC-TGT",
    "PTO-SCALAR-SSRGET",
    "PTO-SCALAR-SSRSET",
    "PTO-SCALAR-SSRSWAP",
    "PTO-SCALAR-TLB-IA",
    "PTO-SCALAR-TLB-IALL",
    "PTO-SCALAR-TLB-IAV",
    "PTO-SCALAR-TLB-IV"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": []
}
---
# ADR 0018: Define the PTO v0 disposition of every trap identity

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
- Stable per-trap witness IDs bind every catalog row to its exact executable
  envelope case and number, argument, cause, and restart assertions. `SCALL`
  has a dedicated `RaiseServiceRequest` witness for source-TPC argument,
  request-type cause, and next-instruction recovery rather than sharing the
  ordinary synchronous `SetFault` helper. A fail-closed guard permits
  `INST_PAGE_FAULT`, `HW_BREAKPOINT`, and `HW_WATCHPOINT` only in the
  `FaultCode` declaration and `SetFault` mapping, and content-addresses every
  normative trap producer/mutator plus every function mentioning canonical
  numbers 33, 49, or 51. Direct-number, helper, and indirect-`SetFault`
  negative canaries must all reject.

## Consequences

All 13 trap identities have a machine-readable disposition and executable
entry/routing/recovery evidence. “Envelope only” is not a claim that the event
can occur in PTO v0; a future active MMU or debug profile must define trigger
conditions, precedence, and conformance tests before changing that status.
