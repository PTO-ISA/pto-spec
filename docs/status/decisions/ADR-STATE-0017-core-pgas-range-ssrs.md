---
{
  "id": "ADR-STATE-0017",
  "title": "Core PGAS range system registers",
  "title_zh": "Core PGAS 范围系统寄存器",
  "status": "accepted",
  "authors": ["Codex"],
  "approvers": ["PTO-SPEC architecture owner"],
  "created": "2026-11-24",
  "accepted": "2026-11-24",
  "baseline": "a89a53d48f5708328be609fe2e6296ac8bdb4bc2",
  "rejected": null,
  "superseded": null,
  "superseded_by": [],
  "supersedes": [],
  "resolves": [],
  "legacy_ids": [],
  "target_releases": ["unassigned"],
  "affected_ndf": ["PTO-CORE-PGAS-RANGE-001", "PTO-CORE-PGAS-SSR-001"],
  "affected_units": ["PTO-ARCH-DISPATCH-TOP-LEVEL", "PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION", "PTO-ARCH-STATE-KERNEL-LIFECYCLE", "PTO-ARCH-DATA-TYPES-SYSTEM-REGISTERS", "PTO-ARCH-SYSTEM-REGISTERS-ADDRESSING", "PTO-SCALAR-MODEL-SYS-REGISTERS", "PTO-SCALAR-MODEL-SYS-SEMANTICS"],
  "implementation_issue": "https://github.com/PTO-ISA/pto-spec/issues/432",
  "release_impact": "required",
  "release_boundary": false,
  "interface_change": true
}
---

# ADR-STATE-0017: Core PGAS range system registers

The Core PGAS partition is exposed through mandatory read-only Base SSRs
`CORE_PGAS_BASE` at `0x0028` and `CORE_PGAS_LIMIT` at `0x0029`. They report the
executing Core's inclusive lower and exclusive upper global virtual byte
addresses. `(0,0)` is the absent partition. A nonempty partition requires
`BASE < LIMIT`; platform admission owns validation and cross-Core disjointness.

The values belong to a core-indexed platform/model configuration object. They
are immutable during an execution epoch and are independent of PE, ACR, kernel,
address-space selection, traps, retry, context save/restore, and ordinary
architectural reset. Explicit out-of-band platform reinitialization may replace
the configuration between epochs. The portable default is `(0,0)`.

Existing SSRGET and HL.SSRGET access rules apply. SSRSET, HL.SSRSET, and
SSRSWAP reject these read-only addresses with the existing Illegal Instruction
behavior. No compressed encoding, feature bit, bounds fault, mapping effect, or
profile mechanism is introduced.

The authoritative ASL owners define the register catalog, core-indexed state,
and read routing. Generated catalogs, AVS, tests, and reader projections are
mechanical evidence and projections of those owners.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Core PGAS bounds must be available to software that needs to reason about
global address ownership while remaining platform-owned and immutable during
an execution epoch.

Core PGAS 范围必须可供软件判断全局地址归属，同时保持平台所有并在执行 epoch 内不可变。

### Detailed decision / 详细决策

The two Base SSRs report the selected Core's validated half-open range. The
model-only platform admission helper validates host integers before converting
them to Words and rejects reversed, equal-nonzero, out-of-XLEN, or overlapping
ranges. Guest writes retain the existing read-only rejection behavior.

两个 Base SSR 返回所选 Core 的已验证半开区间。仅供模型使用的平台接纳辅助函数在转换为 Word 前校验宿主整数，并拒绝反转、非零相等、超 XLEN 或重叠范围。guest 写入保持现有只读拒绝行为。

### What changed / 改动内容

#### English

- Added core-indexed platform configuration and admission validation.
- Preserved configuration across PE, context, kernel, trap, retry, and reset state changes.
- Added SSRGET and HL.SSRGET read coverage and read-only rejection coverage.

#### 中文

- 增加按 Core 索引的平台配置与接纳校验。
- 配置跨 PE、上下文、kernel、陷阱、重试和 reset 状态变化保持不变。
- 增加 SSRGET、HL.SSRGET 读取及只读拒绝覆盖。

### Scope and boundaries / 范围与边界

This decision defines platform admission and Base SSR observation only. It does
not add guest-visible setters, translation effects, bounds faults, or a new
feature mechanism.

本决策只定义平台接纳与 Base SSR 观测，不增加 guest 可见 setter、地址转换效果、范围故障或新的 feature 机制。
