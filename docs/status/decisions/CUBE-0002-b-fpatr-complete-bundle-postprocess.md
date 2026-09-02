---
{
  "id": "ADR-CUBE-0002",
  "title": "B.FPATR Complete-Bundle Matrix PostProcess",
  "title_zh": "B.FPATR 完整 Bundle 矩阵后处理",
  "status": "accepted",
  "authors": [
    "ckwllawliet <641433195@qq.com>"
  ],
  "approvers": [
    "PTO ISA maintainers"
  ],
  "created": "2026-08-11",
  "accepted": "2026-08-11",
  "rejected": null,
  "superseded": null,
  "baseline": "2c663ce22169ee869f47ba766cc8cb9e52053c49",
  "target_releases": [
    "0.58.0",
    "0.58.3"
  ],
  "affected_ndf": [
    "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
    "PTO-MATRIX-POSTPROCESS-BITEXACT-001",
    "PTO-MATRIX-QUANT-BITEXACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-PROFILE-MATRIX-POSTPROCESS",
    "PTO-ARCH-PROFILE-MATRIX-QUANTIZATION",
    "PTO-BLOCK-B-FPATR"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/64",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0064"
  ]
}
---
# ADR-CUBE-0002: B.FPATR Complete-Bundle Matrix PostProcess

- **Date**: 2026-08-11
- **Deciders**: PTO ISA maintainers
- **Issue**: [#64](https://github.com/PTO-ISA/pto-spec/issues/64)

Current release inventory is governed by ASL and generated projections;
numeric inventories below are acceptance-time history, not the current active
decoder set.

## Decision

PTO ISA 0.58.0 accepts `B.FPATR` as the single complete-bundle matrix
post-processing attribute command.  It is latched once per CUBE Matrix bundle,
cleared with the bundle descriptor, and included in trap save/recover state.
Missing, duplicate, or non-Matrix use is rejected as `Fault_BundleControl`;
decode-reserved field values and fixed-bit mismatches use
`Fault_IllegalInstruction`; accepted encodings with incompatible fields,
operand streams, parameters, aliases, or derived shapes use
`Fault_TileLegality` before allocation or destination effects.

The command form is a 32-bit `L32` encoding with mask `0x00007fff`, match and
canonical None word `0x00002023`.  Its closed `PreQuantMode` table, ReLU and
GroupN fields, reduction enables, and fixed bits are owned by the normative
ASL instruction unit.  Matrix B.DATR rounding/saturation legality is resolved
after the complete bundle is known; the None mode requires RMode=NONE and
Sat=0. Fixed FP16, BF16, E4M3, and HiF8 modes require RMode=NONE, fixed shift
modes additionally require Sat=0, and programmable integer modes retain the
full existing selector and final clamp/wrap control.

The dynamic B.IOT schema packs mathematical Local sources first, followed by
optional RowMaxIn, vector quantization, and vector PReLU parameters, with up
to eight Local sources and three Local destinations ordered as D, RowMaxOut,
and GroupMaxOut.  B.IOR scalar parameters retain the dense ADR 0055/0058
order, with LReLU-only consuming RegSrc0.  Output commits are one atomic group.

## Consequences

At acceptance time, the 0.58.0 command projection was corrected to 100 command
forms and 574 total scalar-plus-command forms. Existing twelve CUBE operation
IDs, selectors, and mathematical operand aliases remained unchanged. The
earlier open numeric variation point is closed by Decisions 174 through 181 in
ADR 0085. Assigned post-processing modes now have bit-exact conversion,
activation, FP19, exceptional-value, saturation/wrap, packing, auxiliary
reduction, numeric-status, and atomic-publication rules. A nonzero assigned
mode no longer permits an identity or implementation-selected result.
Activation selects the negative-path multiplier before the single destination
conversion, signed zero participates in affine offsets, and assigned S5, S9,
S17, and shifted-S16 intermediates saturate before final destination encoding.

The normative owners are `asl/block/attributes/B.FPATR.asl`, the complete
bundle state/schema/dispatch/lifecycle units, the trap context and reference
profile owners, and the CUBE execution profile hook.  Catalog, documentation,
traceability, binary-closure, and checked AVS projections are generated from
those owners.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Matrix post-processing depends on the complete bundle. Operand
streams, parameters, conversion controls, auxiliary reductions, and outputs
must agree before execution; one latched attribute prevents partial or
contradictory state from being interpreted after effects begin.

**中文。** 矩阵后处理依赖完整 bundle。操作数流、参数、转换控制、辅助归约与输出
必须在执行前一致；采用一个锁存属性可避免在副作用开始后解释不完整或矛盾状态。

### Detailed decision / 详细决策

**English.** `B.FPATR` is the sole complete-bundle Matrix post-process
attribute. Its encoding, presence, fields, operand ordering, and interaction
with `B.DATR` are checked before allocation. D, auxiliary results,
descriptors, and numeric status publish as one atomic group.

**中文。** `B.FPATR` 是唯一的完整 bundle 矩阵后处理属性。其编码、是否存在、
字段、操作数顺序及与 `B.DATR` 的组合关系都在分配前检查。D、辅助结果、描述符
和数值状态作为一个原子组发布。

### What changed / 改动内容

#### English

- Established one mandatory, once-latched Matrix post-process command.
- Closed its bundle schema, fault classes, and B.DATR compatibility rules.
- Defined atomic publication of main, auxiliary, and status results.

#### 中文

- 建立一个必需且只锁存一次的矩阵后处理命令。
- 闭合其 bundle schema、故障类别及 B.DATR 兼容规则。
- 定义主结果、辅助结果与状态的原子发布。

### Scope and boundaries / 范围与边界

**English.** Matrix function selectors and mathematical operand aliases did
not change. Exact current modes remain owned by the cited ASL, not by the
acceptance-time inventory counts.

**中文。** 矩阵 Function selector 与数学操作数别名未改变；当前精确模式由所列
ASL 持有，不能从接受时清单数量推断。
