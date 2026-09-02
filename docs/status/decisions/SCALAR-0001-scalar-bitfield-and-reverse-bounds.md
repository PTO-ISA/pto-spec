---
{
  "id": "ADR-SCALAR-0001",
  "title": "Scalar bitfield and byte-reversal bounds",
  "title_zh": "标量位域与字节反转边界",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "Codex"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>",
    "zhoubot"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned",
    "0.58.5"
  ],
  "affected_ndf": [
    "PTO-BCNT-DECISION-BINDING-001",
    "PTO-BIC-DECISION-BINDING-001",
    "PTO-BIS-DECISION-BINDING-001",
    "PTO-BXS-DECISION-BINDING-001",
    "PTO-BXU-DECISION-BINDING-001",
    "PTO-CLZ-DECISION-BINDING-001",
    "PTO-CTZ-DECISION-BINDING-001",
    "PTO-REV-DECISION-BINDING-001",
    "PTO-HL-BFI-DECISION-BINDING-001",
    "PTO-INST-SCALAR-HL-BFI"
  ],
  "affected_units": [
    "PTO-SCALAR-BCNT",
    "PTO-SCALAR-BIC",
    "PTO-SCALAR-BIS",
    "PTO-SCALAR-BXS",
    "PTO-SCALAR-BXU",
    "PTO-SCALAR-CLZ",
    "PTO-SCALAR-CTZ",
    "PTO-SCALAR-REV",
    "PTO-SCALAR-HL-BFI",
    "PTO-SCALAR-MODEL-ALU-SEMANTICS",
    "PTO-SCALAR-MODEL-DISPATCH-ALU"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0025"
  ],
  "amendments": [
    {
      "date": "2026-09-02",
      "baseline": "cb0d65b584ce3ad82dd133176e34a97babcfd8ca",
      "approvers": [
        "zhoubot"
      ],
      "issue": "https://github.com/PTO-ISA/pto-spec/issues/194",
      "affected_ndf": [
        "PTO-HL-BFI-DECISION-BINDING-001",
        "PTO-INST-SCALAR-HL-BFI"
      ],
      "affected_units": [
        "PTO-SCALAR-HL-BFI",
        "PTO-SCALAR-MODEL-ALU-SEMANTICS",
        "PTO-SCALAR-MODEL-DISPATCH-ALU"
      ]
    }
  ]
}
---
# ADR-SCALAR-0001: Scalar bitfield and byte-reversal bounds

> Historical-evidence note: test paths named below record the evidence used when this ADR was accepted; they are not active architecture or release owners. Current ownership is the four-surface ASL tree, with per-ID AVS coverage projected into `spec/evidence/release-traceability-readiness.json`.

- Scope: scalar `BXS`, `BXU`, `BIC`, `BIS`, `CLZ`, `CTZ`, `BCNT`, `REV`, and `HL.BFI`

## Decision

For the scalar bitfield forms, the six-bit `imml` field encodes the field
width minus one, so every encoded value selects a width from 1 through 64.
The six-bit `imms` or `immr` field independently selects the least-significant
source bit from 0 through 63. A field that crosses bit 63 wraps to bit 0.

`REV` extracts the selected wrapping field and reverses its bytes into the low
bits of the result. Bits above the selected width are zero. A selected width
that is not a multiple of eight completes normally and returns zero; it is not
an illegal instruction and raises no fault. `imml` and `immr` remain independent
encoded operands and must not be collapsed or substituted for one another.

`HL.BFI` is bit-granular. `immr` selects the first destination bit and `imms`
selects the last destination bit. The operation snapshots both sources and,
starting with source bit zero, replaces the inclusive destination interval,
wrapping through bit 63 when `imms` precedes `immr`. All six-bit values are
assigned; equal endpoints select one bit.

All source values are read before the first destination write. Consequently,
an absolute or temporary-queue destination that aliases a source observes the
pre-instruction source value.

## Rationale

This disposition restores the reviewed bit-interval interface. The short-lived
byte-granular interpretation was inferred from implementation behavior after
that behavior had diverged from the architecture, so it cannot define the
interface. Issue
[#194](https://github.com/PTO-ISA/pto-spec/issues/194) records the correction
and downstream compatibility impact.

## Verification

`tests/asl/scalar/model/alu/semantics/scalar-bound-bitfield-contract-001.asl`
varies `imml` while holding `immr` fixed, varies
`immr` while holding `imml` fixed, exercises minimum, byte-aligned, wrapping,
non-byte, and full-width selections, and uses an aliased source/destination.
The catalog checker requires this ADR and the decoded boundary witness to remain
traceable from `PTO-REQ-SCALAR-ALU-001`.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Bitfield insertion/extraction and byte reversal depend on precise width, endpoint, wrapping, and alias rules. Ambiguous bounds would make edge encodings produce different results across assemblers, executable models, and hardware.

位域插入/提取和字节反转依赖精确的宽度、端点、回绕和别名规则。边界若不明确，汇编器、可执行模型与硬件会对边界编码产生不同结果。

### Detailed decision / 详细决策

The decision closes the selected bit interval for `BIS`, `BIC`, `BXS`, `BXU`, and `HL.BFI`, including minimum, full-width, wrapping, and non-byte-aligned cases. It also fixes `REV` legality to byte-granular reversal bounds. Source values are snapshotted before destination publication so source/destination aliasing does not change the result.

本决策闭合 `BIS`、`BIC`、`BXS`、`BXU` 与 `HL.BFI` 的选定位区间，包括最小、全宽、回绕和非字节对齐情况；同时把 `REV` 合法性固定为按字节粒度的反转边界。目的写入前先快照源值，因此源/目的别名不会改变结果。

### What changed / 改动内容

#### English

- Defined exact bitfield and reversal bounds for every affected form.
- Added decoded boundary and alias witnesses for the closed cases.

#### 中文

- 为所有受影响形式定义精确的位域与反转边界。
- 为闭合场景增加解码边界与别名见证。

### Scope and boundaries / 范围与边界

This record governs bounds, selection, and alias ordering only. It does not change instruction encodings or the unrelated ALU arithmetic rules owned by ADR-SCALAR-0002.

本记录仅管理边界、选择与别名顺序；不改变指令编码，也不修改 ADR-SCALAR-0002 管理的其他 ALU 算术规则。
