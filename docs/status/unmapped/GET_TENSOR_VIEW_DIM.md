---
{
  "schema_version": 1,
  "id": "intrinsic.get_tensor_view_dim",
  "kind": "intrinsic",
  "title": "GET_TENSOR_VIEW_DIM Intrinsic Status",
  "status": "unmapped",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "opcode": "GET_TENSOR_VIEW_DIM",
  "family": "element-wise",
  "sources": {
    "davincioo": "status/unmapped/GET_TENSOR_VIEW_DIM.md",
    "pto": "tile/ops/view-and-tile-buf/get-tensor-view-dim.md"
  },
  "xlsx": {
    "include": false
  }
}
---
# GET_TENSOR_VIEW_DIM Intrinsic Status

> 状态：当前 DavinciOO 尚未映射，本页不是 normative encoding 定义。

## PTO 语义来源

- PTO ISA source: `tile/ops/view-and-tile-buf/get-tensor-view-dim.md`

## 当前映射状态

当前 active DavinciOO PE-local intrinsic 集尚未为该 PTO 操作定义完整 block/header 映射。

## 约束与合法性

- 在完成语义、operand、profile 与 encoding 审阅前，不得将本状态页视为可编码指令。
- 任何正式映射必须按 PTO 语义、active header encoding 和 DavinciOO v4 profile 分别核验。
