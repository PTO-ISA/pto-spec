---
{
  "schema_version": 1,
  "id": "header.header-b.next",
  "kind": "header",
  "title": "B.NEXT",
  "status": "removed",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "family": "Unsupported Block/Header",
  "sources": {
    "davincioo": "header/B.NEXT.md"
  }
}
---
# B.NEXT

> Historical, non-normative material. This page is excluded from the active PTO architecture and release closure.

> **NON-NORMATIVE / UNSUPPORTED**
> This document is not part of PTO ISA 0.58.0 and must not be used as assembler, decoder, ASL, encoding, or implementation input.

> 本页保留 Linx 历史 `B.NEXT` 名称，用于说明当前 profile 的边界；v5 将其标为 unsupported/unmapped，不定义 bit-level encoding，也不要求 assembler 生成该 header。

Linx 早期版本曾使用 `BSTART + B.NEXT` 组合表达长距离 block jump，高位 offset 由 `B.NEXT` 承载。后续 Linx 版本删除 `B.NEXT`，改由更宽版本的 `BSTART` 表达长跳转。

当前 DavinciOO intrinsic 文档聚焦 single-PE tile/matrix/TLSU block header，不定义长跳转扩展 header。若后续需要发布完整 block-control ISA，应在 `BSTART`/branch 章节中重新定义 long-jump encoding、合法位置、异常行为和 assembler lowering 规则。
