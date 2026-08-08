---
{
  "schema_version": 1,
  "id": "coverage.source_gaps_and_conflicts",
  "kind": "coverage",
  "title": "Source Gaps And Conflicts For Review",
  "status": "review",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "SOURCE_GAPS_AND_CONFLICTS.md"
  }
}
---
# Source Gaps And Conflicts For Review

> Historical, non-normative material. This page is excluded from the active PTO architecture and release closure.

This page records implementation follow-ups that do not change the frozen public v5 contract.

## Closed By The v5 Handoff

| Topic | Frozen v5 contract |
| --- | --- |
| Matrix result | 显式 Local D；无 architectural implicit ACC |
| PostProcess | 12 个 active Matrix operation 均带 mandatory B.FPATR |
| Shared TMATMUL | Shared B required for cooperative form；A 可 Local 或 MShard4 Shared |
| TGEMV | PE-local M=1 only；无 SharedTile/B.IOS |
| FIXP | 六页删除；Function 9–14 reserved/illegal |

## Remaining Implementation Detail

上游 pto-isa 仍需独立 handoff 实现 PostProcessConfig、显式 MX variant name、TileDst/TileAccIn 分离、AccPhase 删除与 ACC shorthand 删除。该差异不改变已冻结的 Davinci v5 target contract，也不授权本次刷新 source lock。

## Conflict Handling

If live PTO semantics, active Linx encoding or a future collision checker contradicts a frozen rule, stop the mechanical update and request architecture review. Do not refresh source locks, legacy missing-link baselines or protected Excel overrides to hide a conflict.
