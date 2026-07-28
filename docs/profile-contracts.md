# Architecture profile contracts

PTO has one portable ASL model. An implementation profile may refine only a
named `impdef` boundary; every other state transition and legality rule remains
normative. The machine-readable authority is
[`spec/profile-hooks.json`](../spec/profile-hooks.json).

Each hook records four things that must travel together:

1. the ASL declaration and stable requirement ID;
2. the deterministic portable default used by repository tests;
3. the obligations a concrete profile must satisfy; and
4. the executable evidence path that exercises the enclosing feature.

An override is conforming only when it names the hooks it replaces, specifies
all listed obligations, preserves the non-hook architecture behavior, and adds
raw input/output and state-effect tests. Backend behavior is not an implicit
profile. Unlisted implementation choices are specification defects.

## Registered domains

| Domain | Hooks | Portable boundary | Required refinement |
| --- | --- | --- | --- |
| System time | `ReadMonotonicTime` | architectural cycle counter | unit, monotonicity, rollover, reset |
| Scalar mathematical helpers | `FloatingExponential`, `FloatingRoundNearest` | deterministic real-number defaults | approximation and tie rules |
| Scalar raw floating arithmetic | `ScalarFPBinaryProfile`, `ScalarFPUnaryProfile`, `ScalarFPFusedProfile` | normalized identity/addend payloads, no new flags | correctly rounded encodings, exceptional values, sticky flags |
| Scalar raw conversion | `ScalarFPToIntegerProfile`, `ScalarFPConvertProfile`, `ScalarIntegerToFPProfile` | identity payload before normative destination packing | type-pair legality, rounding, saturation, NaN/overflow/underflow, flags |
| Atomic address class | `AtomicAddress` | preserve the decoded address | address-class selection, translation, faults, reservations |
| Scalar and tile data access | `TranslateDataAddress`, `DataAccessPermitted` | identity translation into bounded read/write memory | translation, permissions, bounds, fault priority, and a stable decision across one instruction's preflight |
| Tile floating functions | `TileSquareRoot`, `TileLogarithm`, `TileReciprocal`, `TileExponential`, `TileExpDifference` | deterministic raw-bitvector defaults | per-type encodings, accuracy, exceptional values, rounding |
| Tile elementwise arithmetic | `TileProfileBinary`, `TileProfileUnary`, `TileProfileAxpy` | deterministic raw-bitvector arithmetic | per-type arithmetic, precision, rounding, exceptional values |
| Tile comparison and ordering | `TileProfileCompare`, `TileProfileOrderLeft` | signed raw-payload ordering with stable ties | per-type ordering, equality, NaN and signed-zero behavior, ties |
| Tile reduction | `TileProfileReductionInitial`, `TileProfileReductionStep` | deterministic raw-bitvector accumulation and selection | identities, precision, rounding, exceptional values, ties |
| Tile expansion and partial operations | `TileProfileExpand`, `TileProfilePartialValue` | deterministic raw-bitvector arithmetic | per-type arithmetic, broadcasting, missing inputs, exceptional values |
| Tile conversion | `TileProfileConvert`, `TileProfileQuantize`, `TileProfileDequantize` | deterministic raw-bitvector conversion defaults | scale/zero-point encodings, rounding, clamping, saturation, per-type legality |
| Tile matrix arithmetic | `TileProfileMatrixAccumulate`, `TileProfileMatrixBias`, `TileProfileMatrixScale` | raw word-width multiply, accumulate, bias, and scale | accepted type combinations, intermediate widths, rounding, saturation, exceptional values |

## Validation rule

The repository checker extracts every `impdef func` declaration from `asl/`
and requires an exact one-to-one match with the profile catalog. A new hook
cannot land without a portable default, requirement owner, closure obligations,
and executable feature evidence. Removing or renaming a hook requires updating
the same contract in one reviewable change.
