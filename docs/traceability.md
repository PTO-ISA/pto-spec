# Requirement traceability

`spec/requirements.json` is the machine-readable authority. This table is its
review-oriented projection.

| Requirement ID | ASL definition | Evidence | Status |
| --- | --- | --- | --- |
| PTO-REQ-STATE-001 | `asl/types.asl`, `asl/state.asl` | state tests | implemented portable model |
| PTO-REQ-PROFILE-001 | `asl/profiles/pto-v0.asl`, profile registry, privilege/state interfaces | all 34 direct hook witnesses plus reset, privilege, memory, time, and numeric tests | implemented by PTO v0 profile |
| PTO-REQ-FAULT-001 | `asl/types.asl`, `asl/state.asl`, tile legality preflight | state/scalar/tile fault and no-partial-effect tests | implemented portable envelope |
| PTO-REQ-SCALAR-ALU-001 | `asl/scalar/integer.asl` | integer and edge-case tests | implemented |
| PTO-REQ-SCALAR-DISPATCH-001 | `asl/scalar/dispatch.asl`, generated decode bindings | all 473 canonical forms plus family effect, removed-DMA, and rejection tests | implemented |
| PTO-REQ-SCALAR-CONTROL-001 | `asl/scalar/control.asl` | compare/branch/commit tests | implemented |
| PTO-REQ-SCALAR-OPERAND-001 | `asl/scalar/operands.asl` | GPR/direct T/U bridge tests | implemented |
| PTO-REQ-SCALAR-ADDRESS-001 | `asl/scalar/addressing.asl`, generated AGU metadata, decoded dispatch | register/immediate/PC-relative/compressed, scaled/unscaled, pre/post, pair, and prefetch tests | implemented |
| PTO-REQ-SCALAR-CONSTRAINT-001 | scalar catalog v2, generated family legality, ADR-0004 | all 85 application witnesses plus positive/negative AGU load/store overlap tests | implemented catalog schema |
| PTO-REQ-SCALAR-AMO-001 | `asl/scalar/atomic.asl`, `asl/scalar/dispatch.asl`, PTO v0 profile | decoded LR/SC, CAS, RMW, ordering, profile, and removed-DMA tests | implemented by PTO v0 profile |
| PTO-REQ-SCALAR-SYS-001 | `asl/scalar/system.asl`, `asl/scalar/dispatch.asl`, PTO v0 profile | decoded system/register/maintenance/fence/request/fault, time, reset, and privilege tests | implemented by PTO v0 profile |
| PTO-REQ-SCALAR-SSR-001 | `asl/scalar/system-registers.asl`, system catalog | access/trap/address tests | implemented |
| PTO-REQ-SCALAR-FP-001 | `asl/scalar/floating.asl`, decoded dispatch, PTO v0 profile | carrier/type legality, raw arithmetic, comparison, NaN, signed-zero, flag, conversion, and direct profile tests | implemented by PTO v0 profile |
| PTO-REQ-MEMORY-001 | `asl/scalar/memory.asl`, decoded dispatch, PTO v0 profile | endian, alignment, signedness, identity translation, privilege, pair, pre/post, and fault tests | implemented by PTO v0 profile |
| PTO-REQ-MEMORY-COMPLETION-001 | shared access probe, scalar pair dispatch, tile memory, PTO v0 profile | pair first/second and tile first/middle/last faults, preservation, restart, and profile access tests | implemented by PTO v0 profile |
| PTO-REQ-MEMORY-TSO-001 | `asl/concurrency.asl`, scalar/tile memory and atomic/fence boundaries, ADR-0006 | allowed/forbidden store-buffering, message-passing, IRIW, same-location, and atomic litmus tests | executable PTO-TSO candidate model |
| PTO-REQ-TILE-001 | `asl/types.asl`, `asl/tile/state.asl` | mapping/capacity/alias tests | implemented portable model |
| PTO-REQ-TILE-DISPATCH-001 | generated tile decode bindings, `asl/types.asl` | all-selector binding witnesses, decoded TEPL/TMA/CUBE effects, result, and rejection tests | implemented |
| PTO-REQ-TILE-LEGALITY-001 | `asl/tile/legality.asl`, generated tile and Reg5 preflight | data, descriptor, shape, pipe, composite, Reg5, fault-address, and no-partial-effect tests | implemented |
| PTO-REQ-TILE-MANAGEMENT-001 | `asl/tile/management.asl` | tile/global FIFO tests | implemented |
| PTO-REQ-TEPL-001 | `asl/tile/elementwise.asl`, PTO v0 profile | binary/unary/scalar/select and direct profile tests | implemented by PTO v0 profile |
| PTO-REQ-TEPL-REDUCE-001 | `asl/tile/reduction.asl`, PTO v0 profile | row/column reduction and direct profile tests | implemented by PTO v0 profile |
| PTO-REQ-TEPL-EXPAND-001 | `asl/tile/expansion.asl`, PTO v0 profile | row/column expansion and direct profile tests | implemented by PTO v0 profile |
| PTO-REQ-TEPL-GENERATE-001 | `asl/tile/generation.asl` | index/triangle/pad tests | implemented |
| PTO-REQ-TEPL-CONVERT-001 | `asl/tile/conversion.asl`, PTO v0 profile | convert/quantize/dequantize and direct profile tests | implemented by PTO v0 profile |
| PTO-REQ-TEPL-REARRANGE-001 | `asl/tile/rearrangement.asl` | extract/insert/gather/scatter/layout tests | implemented |
| PTO-REQ-TEPL-COMPLEX-001 | `asl/tile/complex.asl`, PTO v0 profile | partial/sort/merge/histogram and direct profile tests | implemented by PTO v0 profile |
| PTO-REQ-TMA-001 | `asl/tile/memory.asl`, scalar memory hooks, PTO v0 profile | all six operation, permission, and direct profile tests | implemented by PTO v0 profile |
| PTO-REQ-CUBE-001 | `asl/tile/cube.asl`, PTO v0 profile | all eight operation and direct profile tests | implemented by PTO v0 profile |
| PTO-REQ-ENCODING-001 | canonical catalogs and generated decoder | catalog checker, operand/handler binding assertions, and ASL witnesses | executable canonical |
| PTO-REQ-HIERARCHY-001 | ADR-0001 and one-level boundary | catalog/naming gates | implemented |

Every normative ASL file cites one or more stable IDs. CI verifies that cited
IDs exist, source URLs are public, model/test paths resolve, scalar and tile
catalogs are total, and the architecture boundary remains one-level.
