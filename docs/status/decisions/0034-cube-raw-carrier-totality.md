# ADR-0034: CUBE raw-carrier totality and composite preflight

- Status: Accepted
- Date: 2026-07-30
- Requirements: PTO-REQ-CUBE-001, PTO-REQ-TILE-LEGALITY-001,
  PTO-REQ-PROFILE-001

## Context

PTO accepts 13 direct CUBE functions covering matrix multiply, bias,
accumulation, MX row/column scaling, accumulator conversion, and the analogous
matrix-vector forms. The model had executable helpers, but Stage 4 lacked a
complete type/layout rule, decoded effect evidence for every selector, and a
single preflight boundary for composite operations.

The numeric hooks intentionally receive source and destination type metadata.
Their hardware-accurate floating, saturation, rounding, accumulation-width,
and exceptional-value behavior is a conformance obligation, not something the
portable reference can infer from raw 64-bit payload carriers.

## Decision

### PTO-v0 type and placement rule

PTO-v0 accepts all 25 architectural `TileDataType` values for every CUBE
operand and permits mixed source, scale, bias, accumulator, and destination
types. The reference profile passes raw XLEN carriers and all operand types to
the named matrix profile hooks. This defines deterministic reference behavior
without claiming target numeric equivalence; target-specific numeric results
remain open under `S5-T2`.

Row-major and column-major descriptors may be mixed because CUBE indexes
logical rows and columns through each operand's descriptor. Vector, Matrix,
Memory, and Any locations do not change PTO-v0 semantics. As for every generic
tile operation, an implementation-defined layout rejects before effects.

### Shape and definedness

Matrix multiply requires left columns to equal right rows and requires the
destination valid shape to be exactly left rows by right columns. GEMV adds a
single-column vector requirement. Bias accepts scalar, row, column, or full
destination broadcast shape. MX row scale is destination-rows by one and
column scale is one by destination-columns.

Every source, bias, and scale valid region must be defined before execution.
Accumulating forms additionally require a defined destination. ACCCVT requires
a defined source and matching configured and valid row/column extents. ACCCVT
uses logical coordinates and therefore does not require source and destination
layouts or element types to match.

### Composite preflight and aliases

Decoded legality validates every descriptor, source-definedness rule, shape,
layout, and accumulate precondition before the first destination write. A
failure reports `TILE_LEGALITY` and preserves the complete destination.

Source payloads are snapshotted before destination writes. Bias and scale
descriptors and payloads are also snapshotted before the matrix phase. PTO-v0
therefore permits destination/source, destination/bias, destination/scale, and
extra-operand aliases. If scale and bias operands alias one another, each role
observes the common pre-instruction value. Multi-stage operations never read a
value they wrote earlier through an aliased operand.

## Evidence contract

The canonical tile catalog and CUBE ASL units own the accepted function
inventory and raw-carrier/profile boundary. `TestCubeDecodedSelectorMatrix` executes
every accepted selector through decoded dispatch and checks its result.
Additional matrices cover all 25 type identities, mixed type/layout/location
execution, implementation-defined layout rejection, all 19 reserved function
codes, ten representative alias classes, and nine preflight failure roles with
complete destination preservation. The alias matrix covers destination-left,
destination-right, source-source, bias, both scale roles, extra-source,
accumulate, ACCCVT, and GEMV aliases. The preflight matrix covers destination,
left, right, bias, both scale roles, accumulator definedness, layout, and shape.

The repository checker derives function/name identity from the canonical tile
catalog and `release-traceability-readiness.json`, and fails closed if the ASL,
test entrypoints, or instruction-contract ownership drifts.

## Consequences

- CUBE reference semantics are total without presenting raw-carrier arithmetic
  as hardware numeric conformance.
- Composite helpers cannot partially update a destination before discovering
  an invalid later bias or scale operand.
- Alias behavior is snapshot-based and independent of helper call order.
- Adding a new type, selector, layout class, or numeric profile requires an
  explicit evidence update.
