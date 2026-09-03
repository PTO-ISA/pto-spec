---
{
  "id": "ADR-CUBE-0018",
  "title": "InternalAcc partial-sum routing for CUBE matrix operations",
  "title_zh": "CUBE 矩阵操作的 InternalAcc 部分和路由",
  "status": "accepted",
  "authors": [
    "Codex"
  ],
  "approvers": [
    "ckwllawliet"
  ],
  "created": "2026-09-03",
  "accepted": "2026-09-03",
  "rejected": null,
  "superseded": null,
  "baseline": "97f61030f08c8435275125d7797a0be438a18dd9",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-B-DATR-FIELDS-001",
    "PTO-B-DATR-MATRIX-ACC-CONTROL-001",
    "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
    "PTO-CUBE-ACCUMULATOR-OUTPUT-001",
    "PTO-CUBE-INTERNAL-ACCUMULATOR-001",
    "PTO-TMATMUL-CONTRACT-001",
    "PTO-TMATMUL-BIAS-CONTRACT-001",
    "PTO-TMATMUL-ACC-CONTRACT-001",
    "PTO-TMATMUL-MX-CONTRACT-001",
    "PTO-TMATMUL-MX-BIAS-CONTRACT-001",
    "PTO-TMATMUL-MX-ACC-CONTRACT-001",
    "PTO-TGEMV-CONTRACT-001",
    "PTO-TGEMV-BIAS-CONTRACT-001",
    "PTO-TGEMV-ACC-CONTRACT-001",
    "PTO-TGEMV-MX-CONTRACT-001",
    "PTO-TGEMV-MX-BIAS-CONTRACT-001",
    "PTO-TGEMV-MX-ACC-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-FPATR",
    "PTO-BLOCK-BSTART-TGEMV",
    "PTO-BLOCK-BSTART-TGEMV-ACC",
    "PTO-BLOCK-BSTART-TGEMV-BIAS",
    "PTO-BLOCK-BSTART-TGEMVMX",
    "PTO-BLOCK-BSTART-TGEMVMX-ACC",
    "PTO-BLOCK-BSTART-TGEMVMX-BIAS",
    "PTO-BLOCK-BSTART-TMATMUL",
    "PTO-BLOCK-BSTART-TMATMUL-ACC",
    "PTO-BLOCK-BSTART-TMATMUL-BIAS",
    "PTO-BLOCK-BSTART-TMATMULMX",
    "PTO-BLOCK-BSTART-TMATMULMX-ACC",
    "PTO-BLOCK-BSTART-TMATMULMX-BIAS",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-ACCUMULATOR-ROUTING",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-DESTINATION",
    "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
    "PTO-TILE-MODEL-EXECUTION-CUBE",
    "PTO-TILE-MODEL-LEGALITY-MATRIX-FUNCTIONS",
    "PTO-TILE-TGEMV",
    "PTO-TILE-TGEMV-ACC",
    "PTO-TILE-TGEMV-BIAS",
    "PTO-TILE-TGEMV-MX",
    "PTO-TILE-TGEMV-MX-ACC",
    "PTO-TILE-TGEMV-MX-BIAS",
    "PTO-TILE-TMATMUL",
    "PTO-TILE-TMATMUL-ACC",
    "PTO-TILE-TMATMUL-BIAS",
    "PTO-TILE-TMATMUL-MX",
    "PTO-TILE-TMATMUL-MX-ACC",
    "PTO-TILE-TMATMUL-MX-BIAS",
    "PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/234",
  "release_impact": "required",
  "interface_change": true,
  "legacy_ids": [],
  "amendments": [
    {
      "date": "2026-09-04",
      "baseline": "5f1cb735aa00ad061ec77c691f6a913711316f92",
      "approvers": [
        "Kevin Zhou <zhoubot@gmail.com>"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/234#issuecomment-5529151834",
      "affected_ndf": [
        "PTO-B-DATR-MATRIX-ACC-CONTROL-001",
        "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
        "PTO-CUBE-ACCUMULATOR-OUTPUT-001",
        "PTO-CUBE-INTERNAL-ACCUMULATOR-001"
      ],
      "affected_units": [
        "PTO-BLOCK-MODEL-DISPATCH-CUBE-ACCUMULATOR-ROUTING",
        "PTO-BLOCK-MODEL-DISPATCH-CUBE-DESTINATION",
        "PTO-BLOCK-MODEL-DISPATCH-CUBE-TMATMUL",
        "PTO-TILE-MODEL-EXECUTION-CUBE",
        "PTO-TILE-MODEL-EXECUTION-INTERNAL-ACCUMULATOR"
      ]
    }
  ]
}
---

# ADR-CUBE-0018: InternalAcc partial-sum routing for CUBE matrix operations

Accepted on 2026-09-03 from the NDF RFC in issue #234 and amended by the
architecture-owner refreeze on 2026-09-04. This ADR changes only the CCTRL
raw-partial selection and transparent-cache hints described below. Explicit C
and D, existing matrix numeric behavior, aliasing, source lifetime, atomic
publication, and CScale remain authoritative unless explicitly amended here.

## Decision

The twelve core-level CUBE matrix and matrix-vector operations gain raw-partial
selection and transparent-cache hints without adding an init bit:

```text
TMATMUL             TMATMUL_BIAS             TMATMUL_ACC
TMATMUL_MX          TMATMUL_MX_BIAS          TMATMUL_MX_ACC
TGEMV               TGEMV_BIAS               TGEMV_ACC
TGEMV_MX            TGEMV_MX_BIAS            TGEMV_MX_ACC
```

The non-ACC forms are init=1 forms. The ACC forms are init=0 forms. Bias is a
mathematical seed on the bias forms and is included in every raw partial result.

## Encoding

For the matrix/CUBE operation schema, the existing two-bit
`B.DATR.PadValueOrByteId` field is aliased as `CCTRL[1:0]`:

```text
CCTRL[0] = RawPartialOutAndReplacementHint
CCTRL[1] = AccumulatorPrefetchHint
```

`CMode` is unchanged. Non-matrix operations retain the existing
`PadValueOrByteId` interpretation.

For ACC forms:

| CCTRL | C input | D output | Transparent-cache hint |
|---:|---:|---:|---|
| `00` | explicit TileReg C | final TileReg D | none |
| `01` | explicit TileReg C | raw-partial TileReg D | cache replacement/fill |
| `10` | explicit TileReg C | final TileReg D | cache use/prefetch for C |
| `11` | explicit TileReg C | raw-partial TileReg D | input prefetch and output replacement |

For init=1 forms, CCTRL[1] is operation-inapplicable and must be zero. `00` is
the legacy final-output form and `01` publishes raw partial D while hinting
transparent-cache replacement; `10` and `11` are illegal.

## Accumulator input

Every ACC form reads explicit TileReg C as its architectural accumulator input.
CCTRL[1] is a non-binding hint that an implementation may satisfy from or use
to prefetch a value-equivalent InternalAcc cache line. The implementation may
ignore the hint. Cache state and behavior cannot alter whether C is validated,
the value consumed, any fault, or source lifetime.

When enabled by the existing CScale contract, CScale is applied to explicit C
before the product is accumulated, independent of cache behavior.

## Accumulator output

Every successful operation allocates and publishes explicit TileReg D.
CCTRL[0]=0 uses the existing final-output post-processing contract. CCTRL[0]=1
publishes the raw accumulator partial sum in D and may additionally hint that
the identical D value replace or fill an InternalAcc cache entry:

- the result remains `FP32`, `S32`, or `U32` as required by the existing
  accumulator class;
- Bias and MX A/B scaling remain active mathematical operations;
- activation, quantization, output conversion, RowMax/GroupMax/MaxAbs
  publication, and other final-output post-processing do not execute;
- CScale remains legal for existing legal ACC forms as an accumulator-input
  transform;
- D's selector/ID, schema, allocation, and atomic publication remain mandatory.

A partial-output form may carry no nonzero final-output post-processing control;
such controls are rejected before effects rather than ignored.

## InternalAcc boundary

InternalAcc is a transparent implementation cache. A target may provide a
128 KiB one-slot cache, but cache capacity, residency, replacement, prefetch,
banking, and timing are not portable ISA state or legality. The portable model
does not read or write cached payload. Hints are non-binding and cannot create
architectural faults or change C/D behavior.

## Ordering, aliasing, and faults

Existing explicit C/D distinctness remains in force for ACC forms.
Complete schema, field, binding, operand, alias, capacity, readiness,
definedness, and post-processing preflight precedes source snapshots, D
allocation/publication, cache hints, and numeric-status effects. Sources persist
unchanged and D/output-status publication remains atomic with rollback on
failure. Cache behavior is never fault-visible.

## Compatibility and protected behavior

Omitted B.DATR/CCTRL is `00`, preserving legacy behavior. No init bit,
continuation bit, implicit C, physical in-place output, or hidden partial-sum
provenance is added. Matrix start-function selectors and encodings, existing
numeric type matrices, C/D alias rules, CScale carrier/layout, and non-matrix
B.DATR meanings remain unchanged except for this decision's matrix-specific
field alias.

## Consequences

Compilers may use CCTRL to publish accumulator-type raw partials in D while
hinting transparent-cache replacement and later prefetch/use. Every split-K
boundary remains correct using explicit D as the next ACC instruction's C;
cache behavior can improve performance but cannot affect correctness.

The authoritative ASL/NDF owners, generated mirrors, catalogs, decoder
witnesses, AVS points, traceability, and release evidence must be updated
 together. This ADR does not itself claim release eligibility.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Existing ACC behavior exposes explicit TileReg C and D. This decision adds raw-partial selection and non-binding cache hints without allowing hidden cache state to replace those architectural operands or alter established numeric, alias, ordering, and rollback contracts.

**中文。** 既有 ACC 行为暴露显式 TileReg C 与 D。本决策增加原始部分和选择及非绑定缓存提示，但不允许隐藏缓存状态替代这些架构操作数，也不改变既有数值、别名、排序及回滚契约。

### Detailed decision / 详细决策

**English.** Explicit C always defines the accumulator input and explicit D is always allocated and published. CCTRL[1] may hint cache use or prefetch of a value-equivalent C; CCTRL[0] selects raw-partial D and may hint cache replacement with the identical published result. Cache capacity, residency, replacement, and timing remain unobservable, and final-output postprocessing remains forbidden on raw-partial paths except for accumulator-input CScale.

**中文。** 显式 C 始终定义累加器输入，显式 D 始终被分配并发布。CCTRL[1] 可提示使用或预取与 C 等值的缓存；CCTRL[0] 选择原始部分和 D，并可提示用相同的已发布结果替换缓存。缓存容量、驻留、替换与时序均不可观察；原始部分和路径仍禁止最终输出后处理，但作为累加器输入变换的 CScale 除外。

### What changed / 改动内容

#### English

- Added the matrix/CUBE CCTRL interpretation of the existing PadValueOrByteId field without changing CMode or non-matrix meanings.
- Added non-binding InternalAcc prefetch and replacement hint hooks without introducing ISA-visible state or a second data path.
- Preserved explicit C/D validation and publication while adding raw-partial D, postprocess rejection, Bias retention, MX scaling, CScale, atomicity, and source persistence.

#### 中文

- 在不改变 CMode 或非矩阵含义的前提下，增加现有 PadValueOrByteId 字段在矩阵/CUBE 中的 CCTRL 解释。
- 增加非绑定 InternalAcc 预取与替换提示钩子，不引入 ISA 可见状态或第二条数据路径。
- 保留显式 C/D 验证和发布，同时增加原始部分和 D、后处理拒绝、Bias 保留、MX 缩放、CScale、原子性和源持久性。

### Scope and boundaries / 范围与边界

**English.** The change is limited to the accepted matrix and matrix-vector CUBE forms, their BSTART owners, the B.DATR matrix schema, directly required dispatch and execution owners, and generated projections. It does not add an opcode, init bit, continuation bit, typed InternalAcc register, hidden provenance, physical in-place output, or any TIMG2COL behavior.

**中文。** 本变更仅限于已接受的矩阵及矩阵向量 CUBE 形式、对应 BSTART owner、B.DATR 矩阵 schema、直接需要的分派与执行 owner 及生成投影。不增加操作码、init 位、续接位、带类型 InternalAcc 寄存器、隐藏来源、物理原地输出，也不涉及任何 TIMG2COL 行为。

## Verification

The implementation must provide focused evidence for all twelve operation
contracts, all ACC CCTRL combinations, init-form reserved values, legacy `00`
behavior, raw-partial D with Bias and MX scaling, CScale equivalence with and
without the input hint, post-processing rejection, mandatory C/D validation,
transparent hint behavior, alias/fault ordering, atomic publication, source
persistence, and unchanged start-function encodings.
