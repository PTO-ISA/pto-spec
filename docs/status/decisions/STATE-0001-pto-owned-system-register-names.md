---
{
  "id": "ADR-STATE-0001",
  "title": "Use PTO-owned system-register names",
  "title_zh": "使用 PTO 自有系统寄存器名称",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-07-28",
  "accepted": "2026-07-28",
  "rejected": null,
  "superseded": null,
  "baseline": "edf3ae2df13778317674553a1f1d655b46508f99",
  "target_releases": [
    "unassigned"
  ],
  "affected_ndf": [
    "PTO-C-SSRGET-DIRECT-IDS-001",
    "PTO-HL-SSRGET-DECISION-BINDING-001",
    "PTO-HL-SSRSET-DECISION-BINDING-001",
    "PTO-SSRGET-ADR-CONTRACT-001",
    "PTO-SSRSET-ADR-CONTRACT-001",
    "PTO-SSRSWAP-ADR-CONTRACT-001"
  ],
  "affected_units": [
    "PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL",
    "PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING",
    "PTO-ARCH-SYSTEM-REGISTERS-CONTEXT",
    "PTO-ARCH-SYSTEM-REGISTERS-INTERRUPT",
    "PTO-ARCH-SYSTEM-REGISTERS-MAINTENANCE",
    "PTO-ARCH-SYSTEM-REGISTERS-TIMER",
    "PTO-SCALAR-C-SSRGET",
    "PTO-SCALAR-HL-SSRGET",
    "PTO-SCALAR-HL-SSRSET",
    "PTO-SCALAR-SSRGET",
    "PTO-SCALAR-SSRSET",
    "PTO-SCALAR-SSRSWAP"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/4",
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0003"
  ]
}
---
# ADR-STATE-0001: Use PTO-owned system-register names

- Formal-model issue: [#4](https://github.com/PTO-ISA/pto-spec/issues/4)
- Decision date: 2026-07-28

## Context

The retained scalar system-register addresses include names that carried
source-specific abbreviations or branding rather than portable architectural meaning. The PTO
normative specification must preserve the address and access contracts without
retaining an identity from a superseded source.

## Decision

PTO assigns these canonical names:

| Address | PTO name | Access |
| --- | --- | --- |
| `0x0000` | `THREAD_PTR` | read-write |
| `0x0001` | `GLOBAL_PTR` | read-write |
| `0x0020` | `CORE_STATE` | read-write |
| `0x0021` | `CORE_ID` | read-only |
| `0x0024` | `CORE_FEATURE` | read-only |
| `0x0025` | `CORE_FEATURE_ENABLE` | read-write |
| `0x0026` | `THREAD_ID` | read-only |
| `0x0027` | `TILE_CAPACITY` | read-only |

The rename changes no address, width, access class, or dynamic behavior.

## Consequences

- ASL enumeration members and record fields use the PTO names.
- Catalog generation and access witnesses remain keyed by the same addresses.
- Future documents and profiles must not restore source-branded aliases.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Several retained system-register names carried source-specific branding rather than portable architectural meaning. PTO needed canonical terminology that preserves binary and access compatibility without treating a superseded source as the owner of register identity.

若干保留的系统寄存器名称带有特定来源的品牌或缩写，而不是可移植的架构含义。PTO 需要在保持二进制与访问兼容的同时建立规范术语，避免让已被替代的来源继续拥有寄存器身份。

### Detailed decision / 详细决策

The record assigns PTO-owned names to eight fixed addresses, including `THREAD_PTR`, `GLOBAL_PTR`, `CORE_STATE`, `CORE_ID`, `CORE_FEATURE`, `CORE_FEATURE_ENABLE`, `THREAD_ID`, and `TILE_CAPACITY`. The rename leaves each address, width, access class, and dynamic behavior unchanged.

本记录为八个固定地址分配 PTO 自有名称，包括 `THREAD_PTR`、`GLOBAL_PTR`、`CORE_STATE`、`CORE_ID`、`CORE_FEATURE`、`CORE_FEATURE_ENABLE`、`THREAD_ID` 和 `TILE_CAPACITY`。重命名不改变任何地址、宽度、访问类别或动态行为。

### What changed / 改动内容

#### English

- Replaced source-branded register identities with PTO-owned canonical names.
- Updated ASL enumeration and record terminology while retaining address-keyed catalog and access evidence.
- Prohibited future normative documents from restoring the retired aliases.

#### 中文

- 以 PTO 自有规范名称替换带来源品牌的寄存器身份。
- 更新 ASL 枚举和记录术语，同时保留按地址索引的目录及访问证据。
- 禁止后续规范文档恢复已退役别名。

### Scope and boundaries / 范围与边界

This is a naming decision only. It changes no encoding, address, access permission, reset value, side effect, or runtime behavior.

这仅是命名决策，不改变编码、地址、访问权限、复位值、副作用或运行时行为。
