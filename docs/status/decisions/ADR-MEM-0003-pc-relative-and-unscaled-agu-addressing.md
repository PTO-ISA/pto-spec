---
{
  "id": "ADR-MEM-0003",
  "title": "PC-relative and unscaled AGU addressing",
  "title_zh": "PC 相对与非缩放 AGU 寻址",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-31",
  "accepted": "2026-07-31",
  "rejected": null,
  "superseded": null,
  "baseline": "8054a21fc7f98318f936b1dff9d2132b2aa990be",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-HL-SD-UPO-DECISION-BINDING-001",
    "PTO-HL-SD-UPR-DECISION-BINDING-001",
    "PTO-HL-SH-UPO-DECISION-BINDING-001",
    "PTO-HL-SH-UPR-DECISION-BINDING-001",
    "PTO-HL-SW-UPO-DECISION-BINDING-001",
    "PTO-HL-SW-UPR-DECISION-BINDING-001",
    "PTO-SH-PCR-ADR-CONTRACT-001",
    "PTO-SW-PCR-ADR-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-SCALAR-HL-LB-PCR",
    "PTO-SCALAR-HL-LBU-PCR",
    "PTO-SCALAR-HL-LD-PCR",
    "PTO-SCALAR-HL-LH-PCR",
    "PTO-SCALAR-HL-LHU-PCR",
    "PTO-SCALAR-HL-LW-PCR",
    "PTO-SCALAR-HL-LWU-PCR",
    "PTO-SCALAR-HL-SB-PCR",
    "PTO-SCALAR-HL-SD-PCR",
    "PTO-SCALAR-HL-SD-UPO",
    "PTO-SCALAR-HL-SD-UPR",
    "PTO-SCALAR-HL-SH-PCR",
    "PTO-SCALAR-HL-SH-UPO",
    "PTO-SCALAR-HL-SH-UPR",
    "PTO-SCALAR-HL-SW-PCR",
    "PTO-SCALAR-HL-SW-UPO",
    "PTO-SCALAR-HL-SW-UPR",
    "PTO-SCALAR-LB-PCR",
    "PTO-SCALAR-LBU-PCR",
    "PTO-SCALAR-LD-PCR",
    "PTO-SCALAR-LH-PCR",
    "PTO-SCALAR-LHU-PCR",
    "PTO-SCALAR-LW-PCR",
    "PTO-SCALAR-LWU-PCR",
    "PTO-SCALAR-SB-PCR",
    "PTO-SCALAR-SD-PCR",
    "PTO-SCALAR-SH-PCR",
    "PTO-SCALAR-SW-PCR"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0024"
  ]
}
---
# ADR-MEM-0003: PC-relative and unscaled AGU addressing

- Scope: scalar AGU PC-relative and register-offset writeback forms

## Decision

Scalar PC-relative load and store forms align the current TPC down to a
four-byte boundary before adding their signed, four-byte-scaled displacement.
This rule matters when a 32-bit or 48-bit PC-relative form begins at a
halfword-aligned address whose bit 1 is set.

The six register-offset store-writeback forms `HL.SH.UPR`, `HL.SH.UPO`,
`HL.SW.UPR`, `HL.SW.UPO`, `HL.SD.UPR`, and `HL.SD.UPO` are genuinely
unscaled. Their modified register offset is added directly; it is not scaled by
the access width. Pre-index forms access the updated address and post-index
forms access the original base before publishing the same updated address.

## Rationale

Four-byte alignment gives PC-relative displacement encoding a stable base even
when variable-length scalar instructions place the current TPC on the other
halfword of a word. The `.U` marker on the six writeback stores distinguishes
them from their scaled register-offset counterparts and must remain observable
with a nonzero offset.

## Verification

Decoded PC-relative witnesses use a TPC with bit 1 set and assert an address
derived from the aligned base. Decoded witnesses for all six `.UPR/.UPO` forms
use nonzero offsets that distinguish unscaled from access-width-scaled
addresses and check both memory and writeback state.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

PC-relative and register-offset forms need an exact base and scaling rule. Ambiguity over TPC alignment or whether update offsets scale with access width changes the effective address and therefore observable memory behavior.

PC 相对和寄存器偏移形式需要精确的基址与缩放规则。TPC 对齐方式或更新偏移是否按访问宽度缩放的歧义会改变有效地址，进而改变可观察内存行为。

### Detailed decision / 详细决策

PC-relative loads and stores align TPC down to four bytes before adding a signed displacement scaled by four. The six named `.UPR` and `.UPO` store-writeback forms add their modified register offset directly, without access-width scaling. Pre-index uses the updated address; post-index accesses the original base and then publishes the same updated address.

PC 相对加载和存储先将 TPC 向下对齐到 4 字节，再加上按 4 缩放的有符号位移。六个具名 `.UPR` 和 `.UPO` 存储回写形式直接加修改后的寄存器偏移，不按访问宽度缩放。前索引使用更新后的地址；后索引先访问原基址，再发布同一更新地址。

### What changed / 改动内容

#### English

- Fixed four-byte TPC alignment and displacement scaling for PC-relative memory forms.
- Declared the named register-offset writeback forms genuinely unscaled.
- Distinguished pre-index access order from post-index access order.

#### 中文

- 固定 PC 相对内存形式的 4 字节 TPC 对齐和位移缩放。
- 明确具名寄存器偏移回写形式是真正的非缩放形式。
- 区分前索引与后索引的访问顺序。

### Scope and boundaries / 范围与边界

This decision covers only the listed addressing rules. General AGU legality, faults, pair transactions, aliasing, and restart behavior are owned by the broader AGU totality record.

本决策仅覆盖所列寻址规则。通用 AGU 合法性、故障、成对事务、别名和重启行为由更广泛的 AGU 全域语义记录所有。
