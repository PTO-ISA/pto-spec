---
{
  "id": "ADR-BLOCK-0003",
  "title": "Predicate state namespace boundary (superseded)",
  "title_zh": "谓词状态命名空间边界（已废止）",
  "status": "superseded",
  "authors": [
    "Kevin Zhou <zhoubot@gmail.com>"
  ],
  "approvers": [],
  "created": "2026-08-01",
  "accepted": "2026-08-01",
  "rejected": null,
  "superseded": "2026-08-11",
  "baseline": "4d115387b8a8a3c135f78189778d38547e75c697",
  "target_releases": [
    "0.58.1"
  ],
  "affected_ndf": [
    "PTO-ARCH-CONDITIONAL-BRANCH-RESERVATION-001"
  ],
  "affected_units": [
    "PTO-ARCH-OVERVIEW-ENCODING-OWNERSHIP",
    "PTO-ARCH-PROGRAMMING-MODEL-PREDICATE-REGISTERS"
  ],
  "resolves": [],
  "supersedes": [],
  "superseded_by": [
    "ADR-BLOCK-0014"
  ],
  "implementation_issue": null,
  "release_impact": "required",
  "legacy_ids": [
    "ADR-0051"
  ]
}
---
# ADR-BLOCK-0003: Predicate state namespace boundary (superseded)

- Decision date: 2026-08-01

## Current boundary

PTO exposes P0 through P7 as eight independent 32-bit predicate registers.
P0 is hardwired to all ones; P1 through P7 reset to zero and are independently
trap-preserved. No accepted instruction produces or consumes this register
file.

Machine-parallel and machine-sequential block encodings are extension-reserved
and have no PTO execution semantics. Their former execution-mask model is not
architectural PTO state. Any future predicate namespace or instruction mapping
requires an explicit encoding, state, reset, trap, producer, consumer, and
executable-test contract.

This file records the superseded decision only. The current executable
contract is defined by the ASL programming-model and scalar BRU units.

## Bilingual decision detail / 双语决策详述

### Why this decision / 为什么做出此决策

Predicate names are meaningful only when their state, lifecycle, and instruction mappings are unambiguous. The namespace boundary prevents reserved machine-body encodings or future extensions from implicitly creating PTO predicate semantics.

只有在状态、生命周期和指令映射明确时，谓词名称才具有架构意义。命名空间边界可防止保留的机器 Body 编码或未来扩展隐式创建 PTO 谓词语义。

### Detailed decision / 详细决策

The retained namespace contains exactly P0 through P7. P0 is constant all ones; P1 through P7 reset to zero and are preserved independently across traps. No accepted instruction currently produces or consumes this register file. Any future mapping requires its own encoding, state, reset, trap, producer, consumer, and executable-test contract.

保留的命名空间仅包含 P0 至 P7。P0 恒为全一；P1 至 P7 复位为零并在陷阱中分别保留。当前没有已接受指令生产或消费该寄存器文件。未来任何映射都必须单独定义编码、状态、复位、陷阱、生产者、消费者和可执行测试契约。

### What changed / 改动内容

#### English

- Closed the visible predicate namespace, reset state, writable members, and lifecycle boundaries.
- Required explicit architectural work before any future predicate instruction mapping can become executable PTO behavior.
- Preserved unallocated predicate encodings as rejected space rather than treating them as implicit aliases.

#### 中文

- 闭合了可见谓词命名空间及其生命周期。
- 要求未来任何谓词指令映射先完成显式架构决策。

### Scope and boundaries / 范围与边界

This superseded record does not define active producers or consumers. The current executable boundary resides in the affected programming-model and scalar BRU units.

本已废止记录不定义现行生产者或消费者。当前可执行边界位于受影响的编程模型和标量 BRU 单元。
