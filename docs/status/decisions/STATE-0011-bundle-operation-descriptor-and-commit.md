---
{
  "id": "ADR-STATE-0011",
  "title": "Bundle operation descriptor and transactional commit",
  "title_zh": "Bundle 操作描述符与事务式提交",
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
    "PTO-B-CATR-CONTROL-001",
    "PTO-B-DATR-FIELDS-001",
    "PTO-B-DIM-WRITE-001",
    "PTO-B-FPATR-MATRIX-POSTPROCESS-001",
    "PTO-B-IOR-BINDING-001",
    "PTO-B-IOS-SHARED-STATE-001",
    "PTO-B-IOT-STREAM-001",
    "PTO-REQ-BUNDLE-STATE-001"
  ],
  "affected_units": [
    "PTO-BLOCK-B-CATR",
    "PTO-BLOCK-B-DATR",
    "PTO-BLOCK-B-DIM",
    "PTO-BLOCK-B-FPATR",
    "PTO-BLOCK-B-IOR",
    "PTO-BLOCK-B-IOS",
    "PTO-BLOCK-B-IOT",
    "PTO-BLOCK-MODEL-COMMIT-EFFECTS",
    "PTO-BLOCK-MODEL-COMMIT-VALIDATION",
    "PTO-BLOCK-MODEL-LIFECYCLE-BEGIN",
    "PTO-BLOCK-MODEL-LIFECYCLE-ENTER-STOP",
    "PTO-BLOCK-MODEL-OPERANDS-SCALAR-BINDINGS",
    "PTO-BLOCK-MODEL-OPERANDS-SHARED-BINDINGS",
    "PTO-BLOCK-MODEL-OPERANDS-TILE-BINDINGS",
    "PTO-BLOCK-MODEL-SCHEMA-ATTRIBUTES",
    "PTO-BLOCK-MODEL-SCHEMA-DIMENSIONS",
    "PTO-BLOCK-MODEL-SCHEMA-HEADER",
    "PTO-BLOCK-MODEL-STATE-BINDING-STATE",
    "PTO-BLOCK-MODEL-STATE-CONTROL-STATE",
    "PTO-BLOCK-MODEL-STATE-DESCRIPTOR-STATE",
    "PTO-BLOCK-MODEL-STATE-TYPES"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0022"
  ]
}
---
# ADR-STATE-0011: Bundle operation descriptor and transactional commit

> Inventory counts in this record are acceptance-time historical context; the current inventory is owned by the ASL tree and its generated projections.

## Context

The command catalog contains 71 bundle-start forms. Several carry an operation
selector, DataType, Mode, or compressed BrType, but the earlier model retained
only a coarse bundle kind and transfer. A start could therefore decode
successfully while discarding the field that distinguishes its operation. The
earlier start/stop path also had no direct connection to the accepted tile
catalog and could not prove that a failed commit preserved the destination.

Priority decoding matters because some variable-width command masks overlap.
A match-only witness can name one catalog row while the architectural decoder
selects a more-specific row. Exact-form evidence must therefore use the same
priority order as execution.

## Decision

- Every accepted bundle start constructs a `BundleOperationDescriptor` with
  the exact command-form identity, operation class, selector-presence and
  selector value, DataType-presence and value, Mode-presence and value, and
  BrType-presence and value.
- Specific TLSU and CUBE starts use constants from the direct tile-operation
  catalog. Generic TEPL and CUBE starts retain their encoded selector. No
  independent selector table is permitted.
- PTO v0 recognizes compressed BrType values 1 (`FALL`), 5 (`IND`), 6
  (`ICALL`), and 7 (`RET`). Values 0, 2, 3, and 4 are illegal and install no
  descriptor.
- DataType codes map to tile types as follows. Codes not listed are illegal for
  a PTO v0 tile-operation bundle start.

| Codes | Tile types |
| --- | --- |
| 0, 1 | F64, F32 |
| 4, 5 | F16, BF16 |
| 7, 8 | FP8, FPL8 |
| 13, 14 | E8M0, FPL4 |
| 16–20 | S64, S32, S16, S8, S4 |
| 24–28 | U64, U32, U16, U8, U4 |

- PTO v0 has no direct FIXP selector family. `BSTART.FIXP` remains recognizable
  as a catalog encoding but returns `CommandExecution_Rejected` with
  `Fault_IllegalInstruction` before changing bundle state.
- A generic CUBE selector must name one of the 13 accepted direct CUBE
  operations. Holes are illegal. Reserved TEPL/TLSU/CUBE selectors and
  unsupported DataTypes fault before an active bundle is committed.
- BSTART validates the new descriptor and target before committing an existing
  bundle. After a successful boundary commit it clears the prior header state,
  installs the new descriptor, records the pending transfer, and advances TPC
  sequentially to the following header command. BPC records the selected
  bundle target.
- BSTOP and the next BSTART are commit boundaries. A tile-operation descriptor
  must have a terminated B.IOT stream that supplies every required tile
  operand. The bound allocated tile types must match the start DataType.
  ADR 0055 supersedes the earlier slot-zero limitation: ordered B.IOT entries
  may supply the complete direct-operation tile schema.
- A legal commit invokes exactly one direct tile semantic operation without a
  second architectural-time increment. The enclosing command remains the one
  decoded execution attempt.
- Descriptor, binding, type, or tile-legality failure leaves tile destinations
  unchanged. Trap entry preserves the live bundle descriptor and header state
  for diagnosis and recovery.
- Generated command witnesses must select their intended form through the real
  priority decoder. Exact-form checks execute in the normal ASL test entrypoint.

## Consequences

Bundle starts are observably distinct wherever their architectural fields are
distinct. A green decode can no longer hide a discarded selector or modifier,
and a bundle can no longer launch a default tile operation accidentally.
Unsupported families and operand shapes have an explicit rejection boundary
instead of placeholder behavior.

The direct B.IOT shape is intentionally narrower than the full direct tile
catalog. Extending it requires a new binding representation, legality rules,
alias ordering, rollback tests, and an update to this decision; it must not fill
missing operands with fixed zero values.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Bundle starts could decode while discarding selectors, DataType, Mode, or BrType, and failed commits lacked destination-preservation proof. Overlapping command masks also required evidence to follow actual priority decoding.

Bundle start 可能在解码成功后丢弃 selector、DataType、Mode 或 BrType，而且失败提交缺少目的状态保持证明。重叠的 command mask 还要求证据遵循真实的优先解码顺序。

### Detailed decision / 详细决策

Each accepted start builds an exact operation descriptor tied to canonical Tile selectors and validates selector, DataType, transfer shape, target, and operand stream before commit. BSTOP and BSTART are transaction boundaries: effects stage before publication, invalid or faulting operations preserve prior architectural state, and exact-form evidence uses execution priority.

每个已接受 start 都构建绑定到规范 Tile selector 的精确操作描述符，并在提交前验证 selector、DataType、transfer shape、目标和操作数流。BSTOP 与 BSTART 是事务边界：效果在发布前暂存，非法或故障操作保持先前架构状态，精确形式证据采用执行优先级。

### What changed / 改动内容

#### English

- Preserved all operation-distinguishing fields in bundle state.
- Bound generic and specific starts to one Tile selector catalog.
- Added transactional validation, staging, rollback, and priority-decoder evidence.

#### 中文

- 在 Bundle 状态中保留所有区分操作的字段。
- 将通用和专用 start 绑定到同一 Tile selector 目录。
- 增加事务式验证、暂存、回滚和优先解码器证据。

### Scope and boundaries / 范围与边界

The current direct B.IOT shape is narrower than the full Tile catalog. Extending it requires a new binding representation and legality/rollback evidence; missing operands cannot be filled with invented zeros.

当前 Direct B.IOT shape 比完整 Tile 目录更窄。扩展它需要新的 binding 表示以及合法性/回滚证据；不能用臆造的零填补缺失操作数。
