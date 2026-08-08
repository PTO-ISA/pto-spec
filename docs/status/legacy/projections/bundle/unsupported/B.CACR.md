---
{
  "schema_version": 1,
  "id": "header.header-b.cacr",
  "kind": "header",
  "title": "B.CACR",
  "status": "review",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "family": "Unsupported Block/Header",
  "sources": {
    "davincioo": "header/B.CACR.md"
  }
}
---
# B.CACR

> Historical, non-normative material. This page is excluded from the active PTO architecture and release closure.

> **NON-NORMATIVE / UNSUPPORTED**
> This document is not part of PTO ISA 0.58.0 and must not be used as assembler, decoder, ASL, encoding, or implementation input.

> `B.CACR` 在继承的 Linx header index 中被列为跨特权级/控制类补充 header，但当前可追溯文档没有给出完整 bit-level encoding 和执行语义，因此在 v5 中标为 unsupported/unmapped。

当前 DavinciOO intrinsic 文档不定义 `B.CACR`，assembler 不应为 PE-local tile/matrix/TLSU intrinsic 生成该 header。若后续需要引入，应单独补充 privilege/control state、可见副作用、异常行为和 encoding 表。
