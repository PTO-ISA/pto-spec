# Architecture profile contracts

PTO retains named ASL `impdef` interfaces so an implementation profile is an
auditable layer rather than hidden backend behavior. The normative repository
selects one complete executable implementation, `pto-v0`, in
`asl/profiles/pto-v0.asl`. Every registered interface has exactly one matching
`implementation func` and a direct witness in `tests/asl/profile-tests.asl`.
The machine-readable authority is `spec/profile-hooks.json`.

The interface declaration, active implementation, and conformance tests travel
together. Removing, renaming, or adding a hook must update all three in one
reviewable change. An alternative implementation is conforming only if it names
the replaced hooks, satisfies every recorded obligation, preserves non-profile
architecture behavior, and supplies raw input/output and state-effect tests.

## PTO v0 concrete behavior

### Reset, privilege, and time

`ResetProfileState` clears GPRs and bounded memory, invalidates tile and pipe
descriptors, clears defined extended system-register storage, resets faults,
reservations, concurrency candidates and maintenance epochs, sets VERSION to 1,
sets time to zero, and enters `Privilege_Machine`. Tile/pipe payload backing that becomes
unobservable through invalid descriptors is not scrubbed.

Privilege is explicit architecture state with User, Supervisor, and Machine
levels. Base system registers are accessible at every level subject to their
RO/WO/RW class. Context, translation, interrupt, and debug register families
whose low index is at least `0xF00` require Machine privilege. A denied system
register access raises `Fault_IllegalInstruction` before the access.

The bounded reference memory is 4096 bytes. Machine and Supervisor can access
the full range; User can access bytes 0 through 3071. Translation is identity.
Permission and bounds failure use the existing data-page fault envelope.

TIME and CYCLE return the same 64-bit modulo counter. Reset sets it to zero and
each scalar or tile decoded execution attempt increments it once, including an
attempt that is later rejected or faults.

### Numeric carrier profile

PTO v0 is a deterministic executable reference profile, not an IEEE-754 claim.
Scalar and tile floating carriers use the documented raw payload widths. The
profile fixes modular word arithmetic, signed raw ordering, normalization,
tie-to-even integer rounding, division-by-zero results, and flag behavior so no
host floating library can change execution.

- The real-number exponential helper is an 18-term Taylor reference algorithm.
- Scalar raw ADD/SUB/MUL/DIV and fused variants use modular XLEN carrier
  arithmetic; zero DIV/reciprocal returns all ones and records DZ.
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
| Privilege | User/Supervisor/Machine memory and system-register policy |
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
profile conformance test. The three name sets must equal the 34-entry registry
exactly. CI also requires the active profile identity in `specification.toml`
and executes the complete ASL suite with the pinned ASLRef.
