---
{
  "schema_version": 1,
  "id": "intrinsic.tensor_view_addr",
  "kind": "intrinsic",
  "title": "TENSOR_VIEW_ADDR Intrinsic Status",
  "status": "unmapped",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "opcode": "TENSOR_VIEW_ADDR",
  "family": "element-wise",
  "sources": {
    "davincioo": "status/unmapped/TENSOR_VIEW_ADDR.md",
    "pto": "tile/ops/view-and-tile-buf/tensor-view-addr.md"
  },
  "xlsx": {
    "include": false
  }
}
---
# TENSOR_VIEW_ADDR Intrinsic Status

> Historical, non-normative material. This page is excluded from the active PTO architecture and release closure.

> 状态：当前 DavinciOO 尚未映射，本页不是 normative encoding 定义。

## PTO 语义来源

- PTO ISA source: `tile/ops/view-and-tile-buf/tensor-view-addr.md`

## 当前映射状态

当前 active DavinciOO PE-local intrinsic 集尚未为该 PTO 操作定义完整 block/header 映射。

## 约束与合法性

- 在完成语义、operand、profile 与 encoding 审阅前，不得将本状态页视为可编码指令。
- 任何正式映射必须按 PTO 语义、active header encoding 和 DavinciOO v4 profile 分别核验。
