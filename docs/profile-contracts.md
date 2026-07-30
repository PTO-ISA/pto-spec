# Architecture profile contracts

PTO retains named ASL `impdef` interfaces so an implementation profile is an
auditable layer rather than hidden backend behavior. The normative repository
selects one complete executable implementation, `pto-v0`, in
`asl/profiles/pto-v0.asl`. Every registered interface has exactly one matching
`implementation func` and a direct witness in `tests/asl/profile-tests.asl`.
The machine-readable authority is `spec/profile-hooks.json`.

The interface declaration, active implementation, and direct profile tests
travel together. Removing, renaming, or adding a hook must update all three in
one reviewable change. The registry records implementation status separately
from target-conformance status: all 37 hooks have deterministic PTO-v0
implementations, and eight non-numeric hooks close their reference contracts.
The checked `S5-T1` inventory assigns all 29 numeric hooks to their affected
scalar and tile operations. Those hooks retain `S5-T2` target-conformance
obligations. The generated
`spec/evidence/numeric-conformance-readiness.json` ledger divides those
obligations into six exact parallel lanes and keeps every unavailable profile,
oracle, vector, result, and review identity null. An alternative
implementation is conforming only if it names the replaced hooks, satisfies
every recorded obligation, preserves non-profile architecture behavior, and
supplies raw input/output and state-effect tests.

## Numeric identity and selection framework

ADR 0037 and `spec/catalog/numeric-profile-identities.json` accept four stable
identities without claiming that their numeric rules are complete:

| Identity | Contract |
| --- | --- |
| `pto-numeric-v1` | Portable numeric legality, result, bounded-variation, and pre-effect rejection contract. |
| `pto-cpu-observation-v1` | Observation-only CPU implementation evidence; never architecture or an independent oracle. |
| `pto-a2a3-numeric-v1` | A2A3 support restrictions and explicitly delegated bounded result rules. |
| `pto-a5-numeric-v1` | A5 support restrictions and explicitly delegated bounded result rules. |

The identity framework is fail-closed. A target may narrow support but cannot
silently change the portable result of an accepted tuple. A delegated variation
must name a target profile or visible mode and provide a finite or
mathematically testable allowed-result contract. Unknown profiles, modes,
formats, tuples, and missing delegated rules reject before architectural
effects. The identity spellings and selection rules are closed; the 12 numeric
decisions and all 20 domain rules remain open.

ADR 0038 fixes the shared scalar exception-state envelope independently of
target arithmetic. `CORE_STATE[36:32]` stores sticky NV/DZ/OF/UF/NX; reset,
software replacement, simultaneous OR, rejected-operation preservation, and
trap recovery are portable. The 30-form ownership matrix is complete, but 19
profile-owned forms still require exact flag-production rules and vectors.

## PTO v0 concrete behavior

### Reset, access-control rings, and time

`ResetProfileState` clears the 24 absolute GPRs, the T/U queues, P0..P7, and
bounded memory; invalidates every `TileInfo`; clears defined extended
system-register storage; resets faults, reservations, concurrency candidates,
and maintenance epochs; sets VERSION to 1 and TILE_CAPACITY to 512 KiB; sets
time to zero; and enters ACR0. Tile payload backing that becomes unobservable
through invalid descriptors is not scrubbed.

ACR0..ACR15 are explicit architecture state. Base system registers are
accessible at every ring subject to their RO/WO/RW class. Context,
translation, interrupt, and debug register families whose low index is at
least `0xF00` require ACR0. A denied system
register access raises `Fault_IllegalInstruction` before the access.

The banked `EBARG` range is the PTO v0 first-layer trap snapshot. Trap entry
records visible PC, target, return, queue, and bundle-control state there;
`ACRE` consumes those visible words and clears the snapshot-valid bit. ACR0 may
edit a managed ring's snapshot before recovery. Bundle argument and commit
state without allocated `EBARG` words use bounded profile-defined `EBSTATE`
backing and are not aliases for hidden system registers.

The bounded reference memory is 4096 bytes. ACR0 and ACR1 can access the full
range; ACR2 through ACR15 can access bytes 0 through 3071. Translation is identity.
Permission and bounds failure use the existing data-page fault envelope. The
translation and permission hooks are readonly: a profile may refine the address
or access decision, but probing an access cannot itself mutate architectural
state.

Scalar prefetch does not enter this translation or permission path. All five-bit
`model` values are legal PTO v0 hint metadata with no architecture-visible
effect. Prefetch forms a modulo-64-bit address but emits no event, touches no
memory or reservation state, and cannot fault. Address-returning forms publish
that formed address through the ordinary Reg5 destination rules. A target may
use the hint metadata microarchitecturally without creating a new architectural
effect; any observable reinterpretation requires a separately named profile.

TIME and CYCLE return the same 64-bit modulo counter. Reset sets it to zero and
each scalar or tile decoded execution attempt increments it once, including an
attempt that is later rejected or faults.

PTO v0 resets `ECONFIG[1:0]` to `11` in all 16 ACR banks. Its interrupt pending
bitmap, lowest-ID priority, acknowledgement, timer comparison, and enable
behavior are defined by ADR 0016. Translation and debug control registers not
otherwise consumed by PTO v0 remain visible storage-only profile state; that
classification does not claim active MMU or debug-trigger behavior.

PTO-v0 cache maintenance is a synchronous local epoch completion with an
opaque 64-bit scope token. TLB maintenance is ACR0-only and applies the
canonical-VA48 or low-16-bit ASID checks fixed by ADR 0031. The profile does not
claim physical cache or TLB structures. `BSE`, `BWE`, `BWI`, and `BWT` publish
nonblocking scheduling requests; physical suspension and wakeup do not add
architecture-visible PTO-v0 state. A profile that activates MMU, debug, cache
topology, or visible scheduler state must use a distinct identity and evidence.

### Numeric carrier profile

PTO v0 is a deterministic executable reference profile, not an IEEE-754 claim.
Scalar and tile floating carriers use the documented raw payload widths. The
profile fixes modular word arithmetic, signed raw ordering, normalization,
tie-to-even integer rounding, division-by-zero results, and flag behavior so no
host floating library can change execution.

- The real-number exponential helper is an 18-term Taylor reference algorithm.
- Scalar raw ADD/SUB/MUL/DIV and fused variants use modular XLEN carrier
  arithmetic; either signed zero DIV/reciprocal returns all ones and records
  DZ, as fixed by ADR 0028.
- Scalar conversion hooks preserve the source carrier before the normative
  destination-width normalization already defined in scalar ASL.
- Tile arithmetic, reduction, expansion, partial, conversion, matrix, and
  ordering hooks use the explicit raw-bitvector helpers in the normative model.
- Tile SQRT and LOG preserve the raw carrier, EXP increments it, and reciprocal
  uses unsigned all-ones division. Quantization and dequantization use the
  declared scale and zero-point word operations.

This profile makes the current formal model total and reproducible. A future
IEEE or hardware numeric profile must be a separately named implementation; it
must not silently reinterpret `pto-v0` results.

## Registered domains

| Domain | Concrete boundary |
| --- | --- |
| Architecture reset | deterministic PTO v0 reset state |
| Access-control ring | ACR0..ACR15 memory and system-register policy |
| System time | one modulo-64-bit tick per decoded execution attempt |
| Scalar mathematical helpers | 18-term exponential and nearest-ties-even rounding |
| Scalar carrier arithmetic/conversion | deterministic raw word operations and flags |
| Atomic and data address | FAR-preserving, identity translation, explicit permissions |
| Tile floating and elementwise | deterministic raw carrier operations |
| Tile comparison, reduction, expansion, and partial | signed raw ordering and modular accumulation |
| Tile conversion | raw normalization, quantization, and dequantization |
| Tile matrix arithmetic | modular word-width multiply, bias, accumulate, and scale |

## Validation rule

The repository checker extracts every `impdef func` under `asl/`, every
`implementation func` from the active profile, and every direct call in the
profile conformance test. The three name sets must equal the 37-entry registry
exactly. It also freezes the eight closed non-numeric versus 29 raw-carrier
implemented, target-conformance-open classifications. CI requires the active
profile identity in `specification.toml` and executes the complete ASL suite
with the pinned ASLRef.

The same gate regenerates the S5-T2 readiness ledger from the numeric-contract
inventory. Every domain, hook, and operation key must occur in exactly one
numeric lane. A lane cannot become promotion-ready merely because the active
raw-carrier profile test passes; it must acquire independent profile, oracle,
vector, differential-result, and review evidence in dependency order.

The generated `numeric-profile-decision-inputs.json` ledger is the first
dependency. It records 12 open questions covering profile identity, formats,
rounding, FTZ, special values, flags, conversion overflow, elementary-function
accuracy, reduction/order, quantization, matrix arithmetic, and bounded
implementation-defined behavior. Its CPU, A2A3, and A5 observations are
implementation evidence only. They cannot silently become PTO semantics.
The generated `numeric-profile-decision-proposals.json` ledger imports the
accepted identity catalog and records `S5-T2-A1` closed while keeping every
question acceptance and domain result rule null.
The generated `scalar-numeric-flag-contract.json` ledger records the accepted
flag lifecycle and 30/30 producer-owner matrix without closing PD-06.
The generated `numeric-rounding-selector-contract.json` ledger records the
accepted selector namespaces and owners without closing PD-03. It keeps all 18
affected domain rounding and saturation-order rules explicitly null.
