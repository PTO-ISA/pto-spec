# ADR 0028: Scalar FSU totality and numeric-profile boundary

- Status: accepted
- Scope: all 30 accepted scalar FSU forms
- Requirement: PTO-REQ-SCALAR-FP-001, PTO-REQ-SCALAR-OPERAND-001,
  PTO-REQ-SCALAR-EXECUTION-001, PTO-REQ-PROFILE-001

## Decision

Decoded FSU source type `00` selects a 64-bit carrier and `01` selects a
32-bit carrier in the low word, zero extended to XLEN. For floating operands
these carriers are FP64 and FP32 encodings; for `SCVTF` and `UCVTF` they are
signed or unsigned 64-bit and 32-bit integers according to the mnemonic.
Source type encodings `10` and `11` are illegal for every FSU form and fault
before source, destination, flag, queue, or TPC effects.

Conversion destination codes 0 through 14 are legal. The exact Stage 4
carrier table is normative in `spec/evidence/scalar-fsu-totality.json` and is
implemented by `NormalizeScalarFPResult` and `NormalizeScalarIntegerResult`.
Floating destination names in that table deliberately name carrier widths,
not target numeric encodings: codes 2 through 14 do not acquire exponent,
fraction, NaN, infinity, saturation, or rounding rules merely by being legal.
Destination codes 15 through 31 are illegal. All reserved codes are tested,
including simultaneous invalid source and destination fields.

`FABS` clears the selected carrier's sign bit and preserves every other bit.
`FMIN` and `FMAX` use architecture-owned FP32/FP64 encoding classification:
one NaN returns the numeric operand, two NaNs return the width-specific
canonical quiet NaN, and any signaling NaN records sticky NV. For two zero
operands, `FMIN` returns negative zero if either operand is negative zero;
`FMAX` returns positive zero. Otherwise they use the width-specific total-order
key defined by the scalar ASL.

All eight comparisons are ordered. Any quiet or signaling NaN therefore
produces false, including `FNE` and `FNES`. Quiet comparison forms record NV
only for a signaling NaN. Signaling forms record NV for any NaN. Every result
is the full-width canonical word zero or one. This PTO-owned rule is explicit
because an independent executable comparison implemented NaN `NE` as the
negation of equality; that behavior is not imported.

CORE_STATE bits 39 through 37 encode nearest, down, up, toward zero, and away
as 0 through 4. Reserved encodings 5 through 7 normalize to nearest before an
active-mode profile hook is called. `FCVTA`, `FCVTM`, `FCVTN`, `FCVTP`, and
`FCVTZ` select fixed modes 4, 1, 0, 2, and 3 respectively through the pure
`ScalarFPFixedConversionRoundingMode` function used by dispatch.

CORE_STATE bits 36 through 32 are sticky NV, DZ, OF, UF, and NX. A decoded
operation ORs returned flags into the old value and never clears a flag.
Architecture-owned comparison and min/max can produce NV. PTO v0 division and
reciprocal treat both positive and negative zero of the selected FP32/FP64
carrier as zero, return an all-ones result normalized to that carrier, and
record DZ. PTO v0 does not produce OF, UF, or NX; their production by a target
numeric implementation remains a Stage 5 obligation, while Stage 4 proves
that all five returned bits are sticky.

Every decoded source is snapshotted before any flag or destination effect.
Consequently the full Reg5 namespace is valid at every source position:
R0..R23, T#1..T#4, and U#1..U#4. Destination 0 and 24 through 29 discard;
1 through 23 write absolute GPRs; 30 pushes U; and 31 pushes T. Source and
destination overlap, all-sources-same-GPR, and same-queue source/push cases use
the pre-instruction source values.

The deterministic PTO-v0 raw-carrier functions close Stage 4 reference
semantics only. Modular carrier arithmetic, carrier multiplication/division,
identity/increment unary surrogates, and raw conversion normalization are
reproducible executable rules, not IEEE-754 or hardware claims. The
real-number helper layer in `asl/scalar/floating.asl` is not the decoded FSU
definition. A named target profile must close S5-T2 for target format names,
correct rounding, approximation accuracy, exceptional values, saturation,
and OF/UF/NX production.

## Rationale

Stage 4 needs a total executable reference without allowing a portable
raw-carrier surrogate to overclaim numerical conformance. Separating carrier,
legality, alias, flag, and dispatch-owned rules from Stage 5 target arithmetic
lets both layers fail closed. It also resolves the former ambiguity in which
negative zero missed the documented PTO-v0 zero-divisor path.

An independent executable ISA/model comparison corroborates the shared
FP32/FP64 source map, legal destination-width map, rounding selections, ABS,
min/max values, signed-zero behavior, and ordinary GPR read-before-write. It
does not model PTO Reg5 queues or PTO's attempt/fault envelope, and it omits or
diverges on several legality and flag rules. PTO remains authoritative.

## Verification

`spec/evidence/scalar-fsu-totality.json` records the format-code table,
comparison disposition, profile boundary, and publication-safe independent
comparison. Generated ASL executes 2,270 decoded cases: 488 type/legality,
500 raw-boundary, 152 rounding-binding, 920 Reg5/alias, and 210 sticky-flag
cases. The type matrix contains 204 rejected instructions and checks precise
fault context plus no partial register, queue, flag, or TPC effect. A further
35 direct helper cases prove arbitrary returned flag bits are ORed into every
seed class. Repository checks derive the exact inventory from the catalogs and
reject missing, extra, or reclassified evidence.
