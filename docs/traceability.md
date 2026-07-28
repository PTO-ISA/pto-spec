# Requirement traceability

`spec/requirements.json` is the machine-readable authority. This table is its
review-oriented projection.

| Requirement ID | ASL definition | Evidence | Status |
| --- | --- | --- | --- |
| PTO-REQ-STATE-001 | `asl/types.asl`, `asl/state.asl` | state tests | implemented baseline |
| PTO-REQ-FAULT-001 | `asl/types.asl`, `asl/state.asl` | state/scalar tests | implemented baseline |
| PTO-REQ-SCALAR-ALU-001 | `asl/scalar/integer.asl` | integer and edge-case tests | implemented subset |
| PTO-REQ-SCALAR-DISPATCH-001 | `asl/scalar/dispatch.asl`, generated decode bindings | all 474 canonical forms plus family effect and rejection tests | implemented |
| PTO-REQ-SCALAR-CONTROL-001 | `asl/scalar/control.asl` | compare/branch/commit tests | implemented subset |
| PTO-REQ-SCALAR-OPERAND-001 | `asl/scalar/operands.asl` | GPR/direct T/U bridge tests | implemented |
| PTO-REQ-SCALAR-ADDRESS-001 | `asl/scalar/addressing.asl`, generated AGU metadata, decoded dispatch | register/immediate/PC-relative/compressed, scaled/unscaled, pre/post, pair, and prefetch tests | implemented |
| PTO-REQ-SCALAR-AMO-001 | `asl/scalar/atomic.asl`, `asl/scalar/dispatch.asl` | decoded LR/SC, CAS, RMW, ordering, and DMA tests | implemented subset |
| PTO-REQ-SCALAR-SYS-001 | `asl/scalar/system.asl`, `asl/scalar/dispatch.asl` | decoded system/register/maintenance/fence/request/fault tests | implemented subset |
| PTO-REQ-SCALAR-SSR-001 | `asl/scalar/system-registers.asl`, system catalog | access/trap/address tests | implemented |
| PTO-REQ-SCALAR-FP-001 | `asl/scalar/floating.asl`, decoded dispatch | carrier/type legality, comparison, NaN, signed-zero, flag, conversion, and mathematical tests | implemented with numeric profile hooks |
| PTO-REQ-MEMORY-001 | `asl/scalar/memory.asl`, decoded dispatch | endian, alignment, signedness, pair, pre/post, and fault tests | implemented subset |
| PTO-REQ-TILE-001 | `asl/types.asl`, `asl/tile/state.asl` | mapping/capacity/alias tests | implemented baseline |
| PTO-REQ-TILE-MANAGEMENT-001 | `asl/tile/management.asl` | tile/global FIFO tests | implemented |
| PTO-REQ-TEPL-001 | `asl/tile/elementwise.asl` | binary/unary/scalar/select tests | implemented subset |
| PTO-REQ-TEPL-REDUCE-001 | `asl/tile/reduction.asl` | row/column reduction tests | implemented subset |
| PTO-REQ-TEPL-EXPAND-001 | `asl/tile/expansion.asl` | row/column expansion tests | implemented subset |
| PTO-REQ-TEPL-GENERATE-001 | `asl/tile/generation.asl` | index/triangle/pad tests | implemented |
| PTO-REQ-TEPL-CONVERT-001 | `asl/tile/conversion.asl` | convert/quantize/dequantize tests | implemented with profile hooks |
| PTO-REQ-TEPL-REARRANGE-001 | `asl/tile/rearrangement.asl` | extract/insert/gather/scatter/layout tests | implemented |
| PTO-REQ-TEPL-COMPLEX-001 | `asl/tile/complex.asl` | partial/sort/merge/histogram tests | implemented |
| PTO-REQ-TMA-001 | `asl/tile/memory.asl` | all six operation tests | implemented subset |
| PTO-REQ-CUBE-001 | `asl/tile/cube.asl` | all eight operation tests | implemented |
| PTO-REQ-ENCODING-001 | canonical catalogs and generated decoder | catalog checker and ASL witnesses | executable canonical |
| PTO-REQ-HIERARCHY-001 | ADR-0001 and one-level boundary | catalog/naming gates | implemented |

Every normative ASL file cites one or more stable IDs. CI verifies that cited
IDs exist, source URLs are public, model/test paths resolve, scalar and tile
catalogs are total, and the architecture boundary remains one-level.
