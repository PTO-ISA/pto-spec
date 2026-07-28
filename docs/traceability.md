# Requirement traceability

`spec/requirements.json` is the machine-readable authority. This table is its
review-oriented projection.

| Requirement ID | ASL definition | Evidence | Status |
| --- | --- | --- | --- |
| PTO-REQ-STATE-001 | `asl/types.asl`, `asl/state.asl` | state tests | implemented portable model |
| PTO-REQ-FAULT-001 | `asl/types.asl`, `asl/state.asl`, tile legality preflight | state/scalar/tile fault and no-partial-effect tests | implemented portable envelope |
| PTO-REQ-SCALAR-ALU-001 | `asl/scalar/integer.asl` | integer and edge-case tests | implemented |
| PTO-REQ-SCALAR-DISPATCH-001 | `asl/scalar/dispatch.asl`, generated decode bindings | all 474 canonical forms plus family effect and rejection tests | implemented |
| PTO-REQ-SCALAR-CONTROL-001 | `asl/scalar/control.asl` | compare/branch/commit tests | implemented |
| PTO-REQ-SCALAR-OPERAND-001 | `asl/scalar/operands.asl` | GPR/direct T/U bridge tests | implemented |
| PTO-REQ-SCALAR-ADDRESS-001 | `asl/scalar/addressing.asl`, generated AGU metadata, decoded dispatch | register/immediate/PC-relative/compressed, scaled/unscaled, pre/post, pair, and prefetch tests | implemented |
| PTO-REQ-SCALAR-AMO-001 | `asl/scalar/atomic.asl`, `asl/scalar/dispatch.asl` | decoded LR/SC, CAS, RMW, ordering, and DMA tests | implemented with address profile |
| PTO-REQ-SCALAR-SYS-001 | `asl/scalar/system.asl`, `asl/scalar/dispatch.asl` | decoded system/register/maintenance/fence/request/fault tests | implemented with platform profile |
| PTO-REQ-SCALAR-SSR-001 | `asl/scalar/system-registers.asl`, system catalog | access/trap/address tests | implemented |
| PTO-REQ-SCALAR-FP-001 | `asl/scalar/floating.asl`, decoded dispatch | carrier/type legality, comparison, NaN, signed-zero, flag, conversion, and mathematical tests | implemented with numeric profile hooks |
| PTO-REQ-MEMORY-001 | `asl/scalar/memory.asl`, decoded dispatch | endian, alignment, signedness, pair, pre/post, and fault tests | implemented with platform profile |
| PTO-REQ-TILE-001 | `asl/types.asl`, `asl/tile/state.asl` | mapping/capacity/alias tests | implemented portable model |
| PTO-REQ-TILE-DISPATCH-001 | generated tile decode bindings, `asl/types.asl` | all-selector binding witnesses, decoded TEPL/TMA/CUBE effects, result, and rejection tests | implemented |
| PTO-REQ-TILE-LEGALITY-001 | `asl/tile/legality.asl`, generated tile and Reg5 preflight | data, descriptor, shape, pipe, composite, Reg5, fault-address, and no-partial-effect tests | implemented |
| PTO-REQ-TILE-MANAGEMENT-001 | `asl/tile/management.asl` | tile/global FIFO tests | implemented |
| PTO-REQ-TEPL-001 | `asl/tile/elementwise.asl` | binary/unary/scalar/select tests | implemented with numeric profile hooks |
| PTO-REQ-TEPL-REDUCE-001 | `asl/tile/reduction.asl` | row/column reduction tests | implemented with numeric profile hooks |
| PTO-REQ-TEPL-EXPAND-001 | `asl/tile/expansion.asl` | row/column expansion tests | implemented with numeric profile hooks |
| PTO-REQ-TEPL-GENERATE-001 | `asl/tile/generation.asl` | index/triangle/pad tests | implemented |
| PTO-REQ-TEPL-CONVERT-001 | `asl/tile/conversion.asl` | convert/quantize/dequantize tests | implemented with numeric profile hooks |
| PTO-REQ-TEPL-REARRANGE-001 | `asl/tile/rearrangement.asl` | extract/insert/gather/scatter/layout tests | implemented |
| PTO-REQ-TEPL-COMPLEX-001 | `asl/tile/complex.asl` | partial/sort/merge/histogram tests | implemented with numeric profile hooks |
| PTO-REQ-TMA-001 | `asl/tile/memory.asl`, scalar memory profile hooks | all six operation tests | implemented with memory profile hooks |
| PTO-REQ-CUBE-001 | `asl/tile/cube.asl` | all eight operation tests | implemented with numeric profile hooks |
| PTO-REQ-ENCODING-001 | canonical catalogs and generated decoder | catalog checker, operand/handler binding assertions, and ASL witnesses | executable canonical |
| PTO-REQ-HIERARCHY-001 | ADR-0001 and one-level boundary | catalog/naming gates | implemented |

Every normative ASL file cites one or more stable IDs. CI verifies that cited
IDs exist, source URLs are public, model/test paths resolve, scalar and tile
catalogs are total, and the architecture boundary remains one-level.
