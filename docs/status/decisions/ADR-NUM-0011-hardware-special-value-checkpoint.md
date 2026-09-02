---
{
  "id": "ADR-NUM-0011",
  "title": "Hardware special-value result checkpoint",
  "title_zh": "硬件特殊值结果检查点",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-01",
  "accepted": "2026-08-01",
  "rejected": null,
  "superseded": null,
  "baseline": "9574f0293929bf692517dd29de11a8354440c7dc",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-FMAX-DECISION-BINDING-001",
    "PTO-FMIN-DECISION-BINDING-001",
    "PTO-MATRIX-POSTPROCESS-BITEXACT-001",
    "PTO-NUMERIC-FINITE-DECOMPOSITION-001",
    "PTO-NUMERIC-FORMAT-DESCRIPTOR-001",
    "PTO-TMAX-CONTRACT-001",
    "PTO-TMIN-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-DATA-TYPES-FORMAT-DESCRIPTOR",
    "PTO-ARCH-DATA-TYPES-NUMERIC-FORMATS",
    "PTO-ARCH-PROFILE-MATRIX-POSTPROCESS",
    "PTO-SCALAR-FMAX",
    "PTO-SCALAR-FMIN",
    "PTO-TILE-TMAX",
    "PTO-TILE-TMIN"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "PD-05-SC2",
    "ADR-0050"
  ]
}
---
# ADR-NUM-0011: Hardware special-value result checkpoint

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

## Decision scope

This decision is the bounded special-value checkpoint for the named
`pto-hardware-numeric-0.57.1-ieee-v1` profile. It fixes canonical NaN production
and the NaN/signed-zero result subset for comparisons and MIN/MAX. It does not
complete ADR 0088, change the active `pto-v0` profile, or make an unsupported
operation/type tuple legal.

## Context

ADR 0048 made every numeric value class and canonical NaN encoding executable.
The hardware profile also states that produced NaNs are canonical, comparisons
have exact NaN and signed-zero results, and MIN/MAX selects a numeric operand
when exactly one source is NaN. Those statements were machine-readable but did
not have one typed ASL contract or exhaustive cross-format assertions.

This gap made the profile easy to misread in three ways: treating quiet and
signaling NaNs as different boolean comparison results, allowing a host NaN
payload to escape, or choosing a zero sign from operand order. The existing
scalar FP32/FP64 MIN/MAX and compare paths already implement compatible
portable rules, but the named tile-numeric profile remained unwired.

## Decision

### Produced NaNs

Whenever an otherwise-complete operation rule says that a NaN is produced and
the destination format has a NaN encoding, the result is the exact canonical
NaN from ADR 0048. The source payload and sign do not select another result.
Formats without a NaN encoding report this rule as not applicable; this
checkpoint does not invent a NaN representation for them.

This rule defines the result after an operation has determined that it produces
a NaN. It does not by itself define which ordinary, infinite, invalid, domain,
or conversion inputs produce NaN.

### Comparison special results

For `TCMP` and `TCMPS`, conditional on an otherwise-supported operation/type
tuple:

| Input class | EQ | NE | LT | LE | GT | GE |
| --- | ---: | ---: | ---: | ---: | ---: | ---: |
| Either source is NaN | 0 | 1 | 0 | 0 | 0 | 0 |
| Both sources are zero, including opposite signs | 1 | 0 | 0 | 1 | 0 | 1 |

A signaling NaN has the same boolean result as a quiet NaN and additionally
reports the invalid condition through the operation-defined status interface.
The boolean carrier is exactly zero or one. Invalid internal format encodings
are not NaNs and remain outside this checkpoint.

### MIN/MAX special results

The rule applies to scalar `FMIN`/`FMAX` and tile `TMIN`, `TMINS`, `TMAX`, and
`TMAXS` within their separately accepted type support:

- one NaN selects the non-NaN operand without changing its encoding;
- two NaNs produce the destination canonical NaN;
- a signaling NaN additionally reports invalid;
- equal-sign zero inputs preserve that sign; a mixed-sign zero tie produces
  negative zero for MIN and positive zero for MAX when the format has both zero
  signs; and
- a format with one zero encoding returns that encoding.

Operand order cannot change any of these results.

### Typed boundary

`HardwareNumericCanonicalNaNResult`,
`HardwareNumericSignedZeroEncodings`,
`HardwareNumericComparisonSpecial`, and
`HardwareNumericMinMaxSpecial` expose the accepted rules. The comparison and
MIN/MAX helpers return a handled bit so a future complete numeric profile must
still define ordinary operands, infinity arithmetic, invalid encodings, and
every remaining result dimension. They also return the signaling-invalid
condition instead of mutating hidden flag state.

### Profile and support boundary

The helpers are named hardware-profile contracts, not implementations of the
active raw-carrier profile. `pto-v0` remains unchanged. Every tile operation
row in the generated evidence is conditional on a separately accepted
operation/type support tuple. ADR 0095 still owns generic profile selection and
missing-rule rejection.

## Rejected alternatives

- **Propagate a source NaN payload.** Rejected because the hardware profile
  explicitly requires canonical produced NaNs.
- **Make every NaN comparison false.** Rejected because the profile defines NE
  as true for NaN while the other five relations are false.
- **Let signaling status change the boolean result.** Rejected because result
  and invalid-condition reporting are separate architecture outputs.
- **Choose a zero sign from the left or right operand.** Rejected because MIN
  and MAX have operation-defined zero signs independent of operand order.
- **Apply these rules to `pto-v0`.** Rejected because that profile remains the
  deterministic raw-carrier reference.

## Consequences

ADR 0088 gains an accepted, executable special-result checkpoint, but remains
open. The accepted complete-decision count stays two of twelve, no complete
numeric domain closes, and the 18 selected generic variation routes do not
change. Infinity arithmetic, ordinary ordering, operation-specific NaN
creation, conversions, reductions, ordering placement, quantization, matrix
results, and complete flag/status production remain Stage 5 obligations.

## Verification obligations

Executable assertions cover:

- all ten canonical-NaN formats;
- all seven signaling-NaN formats;
- all six comparison relations with NaN and signed-zero inputs;
- left-NaN, right-NaN, and two-NaN MIN/MAX cases;
- both mixed-sign operand orders and both equal-sign ties for all thirteen
  signed-zero formats;
- every format without a signed-zero pair;
- invalid internal encodings combined with otherwise-special operands;
- decoded scalar FP32 plus direct scalar FP64 equal-sign MIN/MAX zero cases; and
- the signaling-invalid output independently from the result carrier.

The generated contract enumerates all eight affected operation identities and
154 conditional operation/type rows. These are rule-coverage rows, not claims
that all 154 tuples are supported or that arithmetic conformance vectors have
passed.

## Evidence

- `asl/numeric/formats.asl`
- `asl/scalar/floating.asl`
- `asl/scalar/dispatch.asl`
- `spec/hardware-conformance-profile.json`
- `spec/evidence/numeric-format-namespace-contract.json`
- `spec/evidence/numeric-special-value-contract.json`
- `scripts/generate-numeric-special-value-contract`
- `tests/asl/arch/profile/reference-profile/arch-exec-concrete-001.asl`
- `spec/evidence/release-traceability-readiness.json`

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

**English.** Machine-readable profile text lacked one executable contract for
NaN production, comparisons, MIN/MAX, and signed-zero ties, allowing host
payload or operand order to leak into results.

**中文。** 机器可读配置文本缺少统一可执行契约来约束 NaN 产生、比较、MIN/MAX 与
有符号零 tie，可能让 host payload 或操作数顺序泄漏到结果。

### Detailed decision / 详细决策

**English.** Produced NaNs use the destination canonical NaN. Compare results
for NaNs and mixed-sign zeros are fixed; MIN/MAX select the numeric operand for
one NaN, canonicalize two NaNs, and choose operation-defined zero signs.
Signaling invalid is reported separately from the value result.

**中文。** 产生的 NaN 使用目标 canonical NaN。NaN 与异号零的比较结果固定；
MIN/MAX 在单 NaN 时选数值操作数、双 NaN 时 canonicalize，并选择操作定义的零
符号。signaling invalid 与数值结果分开报告。

### What changed / 改动内容

#### English

- Closed canonical produced-NaN behavior.
- Fixed comparison and MIN/MAX NaN and signed-zero results.
- Separated signaling-invalid reporting from boolean/value selection.

#### 中文

- 闭合 canonical 产生 NaN 行为。
- 固定比较及 MIN/MAX 的 NaN 与有符号零结果。
- 将 signaling-invalid 报告与布尔/数值选择分离。

### Scope and boundaries / 范围与边界

**English.** Ordinary infinity arithmetic, invalid encodings, conversions, and
complete operation/type support remain outside this checkpoint. The helpers
apply only after separate support and result rules reach the covered special-
value case.

**中文。** 普通 infinity 算术、无效编码、转换及完整操作/类型支持不在此检查点范围。
