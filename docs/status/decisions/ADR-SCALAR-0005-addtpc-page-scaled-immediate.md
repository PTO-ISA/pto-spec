---
{
  "id": "ADR-SCALAR-0005",
  "title": "ADDTPC page-scaled immediate",
  "title_zh": "ADDTPC 页缩放立即数",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-18",
  "accepted": "2026-08-18",
  "rejected": null,
  "superseded": null,
  "baseline": "1ab747bae485806b0ab73212baa9abf454856c39",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-ADDTPC-PAGE-001",
    "PTO-HL-ADDTPC-PAGE-001"
  ],
  "affected_units": [
    "PTO-SCALAR-ADDTPC",
    "PTO-SCALAR-HL-ADDTPC"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0066"
  ]
}
---
# ADR-SCALAR-0005: ADDTPC page-scaled immediate

- Scope: `ADDTPC`, `HL.ADDTPC`
- Requirements: PTO-ADDTPC-PAGE-001, PTO-HL-ADDTPC-PAGE-001
- Supersedes: only the ADDTPC and HL.ADDTPC halfword-scaling clauses of ADR
  0021 and ADR 0027

## Decision

`ADDTPC` computes `TPC + (SignExtend(imm20) << 12)`. `HL.ADDTPC` computes
`TPC + (SignExtend(imm32) << 12)`. Both additions wrap at XLEN and use the
current instruction TPC before normal scalar retirement. Encoded immediate
zero therefore produces the current instruction TPC.

Both instructions write through the existing Reg5 destination behavior. They
do not install a control-flow target and do not directly advance TPC. The
scalar dispatch boundary advances TPC by four bytes for `ADDTPC` and six bytes
for `HL.ADDTPC` after a successful instruction effect.

The immediate scale is a 4 KiB page unit so the result can serve as the high
part of a PC-relative address and be combined with a separate low 12-bit add.

## Protected behavior

This decision changes no encoding, field width, field placement, mask, match,
assembly spelling, destination selector rule, or exception. Relative branches,
`J`, `JR`, `SETRET`, `HL.SETRET`, and `C.SETRET` retain their existing
halfword-scaled contracts.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

`ADDTPC` constructs an address from TPC and an encoded displacement. Its scaling must be explicit because treating the immediate as a byte or halfword displacement would silently compute a different page address while using the same encoding.

`ADDTPC` 通过 TPC 与编码位移构造地址。必须明确缩放方式，因为若把立即数解释为字节或半字位移，同一编码会静默计算出不同页地址。

### Detailed decision / 详细决策

The instruction sign-extends its immediate and applies the recorded page scale before adding it to the architectural TPC base, then publishes the result through the existing destination-selector rules. The corresponding high-level form follows the same page-scaled interpretation.

该指令先对立即数符号扩展，再应用记录的页缩放后与架构 TPC 基址相加，并通过既有目的 selector 规则发布结果。对应高层形式采用相同的页缩放解释。

### What changed / 改动内容

#### English

- Fixed `ADDTPC` and `HL.ADDTPC` to a signed page-scaled immediate contract.
- Added focused decoded evidence for positive, negative, and boundary displacements.

#### 中文

- 将 `ADDTPC` 与 `HL.ADDTPC` 固定为有符号页缩放立即数契约。
- 为正、负及边界位移增加聚焦解码证据。

### Scope and boundaries / 范围与边界

No encoding, field, selector, or exception changes. Relative branches, `J`, `JR`, `SETRET`, and their high-level or compressed forms retain their existing halfword-scaled contracts.

编码、字段、selector 和异常均不改变。相对分支、`J`、`JR`、`SETRET` 及其高层或压缩形式继续使用既有半字缩放契约。
