# CUBE Formal Contract Design

## Status

Historical implementation planning record. This document is not an active or
normative ISA definition. Where its preliminary alternatives differ from the
accepted ASL-linked decisions in ADR-0062, the ASL owners and those later
decisions govern.

The formal mnemonic audit subsequently completed and is frozen at 642/642
active mnemonics. This historical plan therefore does not describe pending
review work. Any remaining work is ASL, documentation, and independent-test
implementation closure for already reviewed decisions. A normative change
must start from a linked NDF architecture issue and update the owning PTO ASL
clauses first.

## Formal ownership

The normative owners are the CUBE units under `asl/block/` and
`asl/tile/matrix-and-matrix-vector/`. The formal audit records missing or
conflicting operand, dimension, layout, and accumulator rules against those
owners only.

## Encoding Boundary

The CUBE carrier and function allocation do not change:

| Function | Operation |
| ---: | --- |
| 0 | TMATMUL |
| 1 | TMATMUL.BIAS |
| 2 | TMATMUL.ACC |
| 4 | TMATMULMX |
| 5 | TMATMULMX.BIAS |
| 6 | TMATMULMX.ACC |
| 16 | TGEMV |
| 17 | TGEMV.BIAS |
| 18 | TGEMV.ACC |
| 20 | TGEMVMX |
| 21 | TGEMVMX.BIAS |
| 22 | TGEMVMX.ACC |

Functions 3, 7 through 15, 19, and 23 through 31 remain reserved. The global
five-bit DataType encoding also remains intact. Each CUBE opcode accepts only
its declared subset; an unsupported but globally assigned DataType rejects for
that opcode and is not available for reassignment.

## Operation Matrix

CUBE is the product of two shapes, two numeric modes, and three result modes:

- TMATMUL computes `A[M x K] * B[K x N] -> D[M x N]`.
- TGEMV is the exact `M = 1` specialization and computes
  `A[1 x K] * B[K x N] -> D[1 x N]`.
- Ordinary and MX forms share the same shape and destination rules.
- Base forms initialize the product from zero.
- BIAS forms add a `1 x N` Bias through the right/output-column broadcast
  path.
- ACC forms read explicit Local C and write explicit Local D. If D and C name
  the same Tile, execution snapshots the old C value before writing D.

There is no hidden ACC state, no ACCCVT operation, and no post-process path in
a CUBE block.

## Dimensions and Defaults

CUBE interprets the bundle dimensions in one fixed order:

- `LB0 = M`
- `LB1 = N`
- `LB2 = K`

Omitted dimensions retain the bundle reset value and resolve to one. M, N, and
K must be nonzero powers of two. TGEMV additionally requires M to equal one.
Type-specific fractal and scale alignment constraints apply after these common
dimension checks.

The generic Tile meanings `valid columns`, `valid rows`, and `physical
columns` must not reinterpret CUBE LB0/LB1/LB2. CUBE destination allocation
derives D rows, columns, physical shape, layout, and result type from the CUBE
contract.

## Data Types

### Ordinary forms

- Supported floating inputs are FP32, TF32, HF32, FP16, BF16, HiF8, E4M3,
  E5M2, E3M2, E2M3, E2M1X2, and E1M2X2.
- Supported signed-integer inputs are S32, S16, S8, and S4X2.
- Floating A and B may use different supported floating types and widths.
- Signed-integer A and B may use different supported signed types and widths.
- Floating/integer mixing is illegal.
- Unsigned inputs are illegal for CUBE.
- FP64, S64, E8M0, and HiF4X2 are illegal CUBE matrix inputs.
- E8M0 remains an MX scale type.
- HiF4X2 remains supported only by TCVT.
- Floating products produce FP32 D/C/Bias elements.
- Signed-integer products produce S32 D/C/Bias elements.

The globally assigned encodings for unsupported types remain assigned; CUBE
rejects them at opcode-specific legality.

### MX forms

The complete symmetric MX pair set is:

- FP4 (`E2M1X2` or `E1M2X2`) with FP4;
- FP8 (`E4M3` or `E5M2`) with FP8;
- FP8 with FP4 in either operand order; and
- FP16 or BF16 with FP4 in either operand order.

FP16/BF16 with FP8 and FP16/BF16 with FP16/BF16 are not MX forms. Use an
ordinary operation when its ordinary type rules accept the pair.

Each FP4 or FP8 operand has an E8M0 scale Tile. An FP16/BF16 operand has no
scale operand. Operand binding therefore depends on AType and BType rather
than inserting a dummy scale Tile.

## Data Attributes

CUBE uses the BSTART DataType field as AType. B.DATR is optional and only its
DataType field may be nonzero:

- absent B.DATR means BType equals AType;
- present B.DATR.DataType is the explicit BType, including encoded zero as the
  globally assigned FP64 value, which CUBE rejects;
- Layout, PadValueOrByteId, CMode, RMode, Sat, and Canonicalize must be zero;
  and
- B.FPATR and scalar post-process B.IOR commands are illegal in CUBE blocks.

The model must track B.DATR presence so omission is not confused with an
explicit zero DataType.

## Layouts and Shapes

TMATMUL layouts are:

| Role | Shape | Layout |
| --- | --- | --- |
| A | `M x K` | Nz |
| ScaleA | `M x (K/32)` when present | Zz |
| B | `K x N` | Zn |
| ScaleB | `(K/32) x N` when present | Nn |
| D and C | `M x N` | Nz |
| Bias | `1 x N` | RowMajor |

TGEMV simplifies only the left-vector layout:

| Role | Shape | Layout |
| --- | --- | --- |
| A | `1 x K` | RowMajor |
| ScaleA | `1 x (K/32)` when present | RowMajor |
| B | `K x N` | Zn |
| ScaleB | `(K/32) x N` when present | Nn |
| D and C | `1 x N` | Nz |
| Bias | `1 x N` | RowMajor |

Bias has no scalar, column, or full-matrix alternative. Its type exactly
matches the CUBE result type.

## Operand Binding

Local B.IOT source roles appear in semantic order and the final effective
binding carries `last`:

- base: A, B, then D;
- BIAS: A, B, Bias, then D;
- ACC: C, A, B, then D;
- MX base: A, optional ScaleA, B, optional ScaleB, then D;
- MX BIAS: A, optional ScaleA, B, optional ScaleB, Bias, then D; and
- MX ACC: C, A, optional ScaleA, B, optional ScaleB, then D.

The existing B.IOT stream rules remain in force: a nonzero-mask stream has one
effective terminating `last`; zero-mask bindings are strict no-ops and do not
terminate the stream.

## Shared TMATMUL

Shared input support applies only to the six TMATMUL operations. TGEMV rejects
every B.IOS binding.

For TMATMUL:

- B alone may be Shared, or A and B may both be Shared;
- A alone may not be Shared;
- an MX scale follows the storage domain of its matrix operand;
- Bias, C, and D are always Local;
- all effective Local and Shared bindings use the same nonzero PE mask;
- partial masks are legal; and
- an all-zero mask makes the complete CUBE operation a strict no-op.

An FP16/BF16 matrix has no corresponding scale binding in either storage
domain.

## Required Normative Repair

The later unified architecture change must:

1. add one CUBE-specific legality and descriptor-resolution contract;
2. make the twelve mnemonic owners thin declarations of their shape, numeric,
   and result variants;
3. implement B.DATR presence and opcode-specific DataType applicability;
4. derive destination D from M, N, result type, Nz layout, and B.IOT TSize;
5. implement TGEMV as M-equals-one TMATMUL arithmetic with the simplified
   vector layouts;
6. implement optional MX scale roles from the selected type pair;
7. enforce exact Bias shape/layout/type and explicit C aliasing;
8. retain Shared execution only for the approved TMATMUL source patterns;
9. add positive, boundary, invalid-type, invalid-layout, missing/extra-scale,
   Bias, alias, mask, and Shared-schema ASL points; and
10. regenerate every PTO projection and focused AVS point from the repaired
    ASL owners.

## Deferred Execution

No normative CUBE file was changed as part of this design record. The audit is
now complete; approved semantic repairs are implemented as reviewable
normative changes with their linked NDF issues, focused tests, regenerated
projections, and exact-head release evidence.
