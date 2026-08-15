# ADR-0031: Scalar SYS totality and PTO-v0 profile boundaries

- Status: Accepted
- Date: 2026-07-30
- Requirements: PTO-REQ-SCALAR-SYS-001, PTO-REQ-SCALAR-SSR-001,
  PTO-REQ-ACRC-001, PTO-REQ-FAULT-001, PTO-REQ-INTERRUPT-001

## Context

PTO accepts 35 scalar SYS forms in thirteen effect classes. Stage 1 reached
every form, while Stage 2 separately closed 72 system-register definitions in
25 behavior classes and all 13 synchronous trap identities. Stage 4 still
needed exact transfer-shape coverage and explicit dispositions for
maintenance, scheduling requests, ACRE modes, profile-gated registers, and the
boundary between instruction-local ACRC behavior and bundle formation.

## Decision

### System-register transfers

Every transfer first resolves the complete encoded address. Read and write
instructions then apply the register's RO, WO, or RW class and the current ACR
permission rule. A rejected transfer leaves its scalar destination and target
register unchanged, apart from the ordinary execution-attempt time tick and
trap entry.

`SSRSWAP` is one read/write transaction. It preflights read permission, write
permission, and the RW access class before reading the old value. This ordering
is normative: a rejected swap to `IPENDING`, `TOPEI`, `EOIEI`, a read-only time
register, an unknown address, or a denied bank cannot perform read-side effects
or write a destination. A successful swap snapshots the Reg5 source before the
register write and destination effect.

The decoded closure matrix contains all 1,937 form/address combinations:
three `C.SSRGET`, 65 each for the four 12-bit read/write forms and `SSRSWAP`,
and 837 each for `HL.SSRGET` and `HL.SSRSET`. These cases cover all 837 concrete
addresses obtained by expanding the 72 definitions over their ACR banks. An
additional 1,184 cases cover every Reg5 read destination, every write source,
and the complete 32-by-32 `SSRSWAP` source/destination alias product.

### Maintenance and fences

PTO-v0 models cache and TLB completion synchronously. A successful operation
records the exact operation and 64-bit operand, then advances the selected
family epoch. Cache operand-bearing operations accept the operand as an opaque
scope token; PTO-v0 does not claim a physical cache topology or line size.

Cache maintenance is available at every ACR because its PTO-v0 effect is a
local hint completion. TLB maintenance is restricted to ACR0. `TLB.IV` and
`TLB.IAV` require a canonical 48-bit virtual address. `TLB.IA` requires bits
63:16 to be zero and interprets the low 16 bits as its ASID token. `TLB.IALL`
has no operand. Privilege is checked before operand legality, and no rejected
operation advances an epoch or replaces the last successful operation/operand.

`FENCE.D` records all sixteen predecessor and successor mask combinations,
invalidates the local reservation, and emits the closed Stage 3 fence event.
The instruction-cache epoch also advances when either mask contains the
instruction-visibility bit. `FENCE.I` invalidates the reservation and advances
the instruction-cache epoch.

### Execution-control requests

`BSE`, `BWE`, `BWI`, and `BWT` are nonblocking scheduling handoffs in PTO-v0.
They retire normally after publishing the exact request kind and snapshotted
Reg5 operand. An implementation may suspend or resume the physical thread in
response, but PTO-v0 defines no additional architecture-visible asleep,
pending-wake, event-mailbox, or timeout-counter state. A profile that exposes
such state requires a distinct identity and contract.

This disposition makes the instructions total without inventing additional
wake state. The generated evidence executes every Reg5 selector for all four
requests.

### ACRE and ACRC

`ACRE` request types zero and one are exact aliases in PTO-v0. Both recover the
same complete visible snapshot. Accepted modes validate context before
changing architectural state; missing, invalid-control, inconsistent, or
misaligned saved context produces `EXEC_STATE_CHECK`. Values two through
fifteen produce `ILLEGAL_INST` before context validation.

`ACRC` instruction-local legality, manager routing, `SCALL` trap state, next-
instruction resume TPC, and illegal-request precedence are closed for every
source ACR and four-bit request value. Whether a bundle is permitted to place
ACRC at a particular position is a bundle-formation rule owned by `S4-T7`, not
an unresolved SYS instruction effect.

### Profile-gated register families

Translation, `XBINFO`, `ACR_PARAM`, and debug registers retain the named
`pto-v0-storage-only` behavior established by ADR 0017. Their deterministic
read, write, reset, access, and trap behavior is complete for PTO-v0. Storage-
only does not claim an active MMU, breakpoint matcher, or watchpoint matcher;
activating one requires a separately named profile, field definitions,
precedence rules, and executable evidence.

## Evidence contract

`spec/evidence/scalar-sys-totality.json` is the fail-closed ledger. It retains
35 Stage 1 effects and adds 4,401 unique Stage 4 decoded attempts: 1,937
bank-expanded transfers, 1,184 Reg5 selector/alias cases, and 1,280 fence,
tag, request, recovery, maintenance, privilege, and operand-boundary cases.
The generator and repository checker derive the inventories from the canonical
catalogs and reject a missing form, address, behavior class, selector,
immediate value, unique marker, evidence count, or test-suite call.

The 13-trap mapping and recovery envelope remain owned by the closed Stage 2
contract. SYS closure links to that evidence and exhaustively exercises the
trap identities that SYS instructions can actually produce; it does not invent
SYS producers for profile-disabled instruction-page or hardware-debug traps.

## Consequences

- `S4-T6` can close without claiming a modeled physical cache, TLB, scheduler,
  MMU, or debug matcher.
- Rejected swaps are fail-before-read-side-effect transactions.
- ACRE zero and one cannot diverge within PTO-v0.
- ACRC bundle placement remains reviewable under `S4-T7` without reopening its
  instruction-local service-request semantics.
