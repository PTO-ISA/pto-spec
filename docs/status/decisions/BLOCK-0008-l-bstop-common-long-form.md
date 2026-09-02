---
{
  "id": "ADR-BLOCK-0008",
  "title": "Restore `L.BSTOP` as the common 64-bit bundle stop",
  "title_zh": "恢复 `L.BSTOP` 为通用 64 位 Bundle 停止指令",
  "status": "accepted",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "created": "2026-08-11",
  "accepted": "2026-08-11",
  "rejected": null,
  "superseded": null,
  "baseline": "4d115387b8a8a3c135f78189778d38547e75c697",
  "target_releases": [
    "0.58.1"
  ],
  "affected_ndf": [
    "PTO-L-BSTOP-DECISION-BINDING-001"
  ],
  "affected_units": [
    "PTO-BLOCK-L-BSTOP"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0060"
  ]
}
---
# ADR-BLOCK-0008: Restore `L.BSTOP` as the common 64-bit bundle stop

- Date: 2026-08-11
- Requirements: PTO-REQ-BUNDLE-DISPATCH-001,
  PTO-REQ-BUNDLE-OPERATION-001, PTO-REQ-BUNDLE-STATE-001

Current release inventory is governed by ASL and generated projections;
numeric inventories below are acceptance-time history, not the current active
decoder set.

## Context

PTO requires compressed, base-width, and long bundle-stop encodings with one
shared commit operation. The 64-bit form was missing from the executable
catalog even though its two-word encoding and distinct canonical mnemonic had
already been selected. Omitting it would leave that 64-bit encoding without a
PTO owner.

## Decision

`L.BSTOP` is an accepted PTO instruction. Its encoding MUST be the
two exact 32-bit words below, in instruction-address order:

| Word | Mask | Match |
| --- | --- | --- |
| low | `0xffffffff` | `0x0000000f` |
| high | `0xffffffff` | `0x00000001` |

No bit in either word is an operand field. Any different bit pattern is not an
`L.BSTOP` encoding and MUST be decoded independently or rejected before
`L.BSTOP` effects.

After successful decode, `L.BSTOP` MUST execute the same normative
`ExecuteBundleStop` operation as `BSTOP` and `C.BSTOP`: it commits the current
bundle and transfers to the bundle's selected continuation. The mnemonic MUST
remain distinct in canonical assembly and disassembly; tools MUST NOT
normalize it to either shorter form.

The PTO command catalog MUST append stable form ID
`l_bstop_64_94c7f0a5e8b3`. Every PTO decoder, assembler, disassembler, AVS
point, generated page, and release projection MUST expose the same two-word
encoding and `ExecuteBundleStop` handler identity.

## Consequences

- At acceptance time, the common command-form inventory increased from 99 to
  100 and the encoded scalar-plus-command envelope increased from 573 to 574
  forms.
- The acceptance-time 574-form binary-closure fingerprint was
  `6d0814b26ed0db560395752a53f4403c0ff000d7c5cf2a7a87ec42048c25678b`.
- PTO decoder, assembly, disassembly, AVS, generated documentation, and release
  projections MUST include `L.BSTOP`.
- The existing `C.BSTOP` and `BSTOP` encodings and semantics are unchanged.
- The manual semantic audit may continue only after both executable catalogs
  agree with this decision and their exact common form is verified.

## Evidence

- `asl/block/lifecycle/L.BSTOP.asl`
- `spec/catalog/command-forms.json`
- `tests/asl/block/lifecycle/L.BSTOP/`

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

The common 64-bit Bundle stop needed one public spelling and one commit-decision binding. Restoring `L.BSTOP` avoids splitting the long-form lifecycle across operation-specific names and keeps decoding, assembly, and executable evidence aligned.

通用 64 位 Bundle 停止需要唯一公开拼写和唯一提交决策绑定。恢复 `L.BSTOP` 可避免把长格式生命周期拆分到操作特定名称中，并保持解码、汇编与可执行证据一致。

### Detailed decision / 详细决策

`L.BSTOP` is the common long Bundle-stop form. It applies the established Bundle completion and BARG decision rules rather than defining an independent stop state. Its encoding and catalog entry are owned by the affected lifecycle unit and verified by decoded tests.

`L.BSTOP` 是通用长格式 Bundle 停止指令。它应用既有的 Bundle 完成与 BARG 决策规则，而不定义独立停止状态。其编码和目录条目由受影响的生命周期单元管理，并通过解码测试验证。

### What changed / 改动内容

#### English

- Restored `L.BSTOP` as the canonical common 64-bit stop form.
- Reconnected the form to the common Bundle commit contract and evidence.

#### 中文

- 恢复 `L.BSTOP` 作为规范的通用 64 位停止形式。
- 将该形式重新连接到通用 Bundle 提交契约和证据。

### Scope and boundaries / 范围与边界

This decision covers the public long-form stop spelling and its decision binding. It does not create a new continuation model or alter the compact and other existing stop contracts.

本决策覆盖公开长格式停止拼写及其决策绑定；不创建新的 continuation 模型，也不修改压缩形式及其他既有停止契约。
