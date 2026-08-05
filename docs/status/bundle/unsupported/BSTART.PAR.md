---
{
  "schema_version": 1,
  "id": "header.header-bstart.par",
  "kind": "header",
  "title": "BSTART.PAR",
  "status": "removed",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "family": "Unsupported Block/Header",
  "sources": {
    "davincioo": "header/BSTART.PAR.md"
  }
}
---
# BSTART.PAR

> **NON-NORMATIVE / UNSUPPORTED**
> This document is not part of PTO ISA 0.58.0 and must not be used as assembler, decoder, ASL, encoding, or implementation input.

> Linx inherited reference / current profile boundary. DavinciOO v5 superscalar intrinsic 不发布可编程 parallel/vector block body，也不使用 `BSTART.PAR` 作为 tile/matrix/TLSU intrinsic 的 block start。

`BSTART.PAR` 保留为 Linx-style BSTART block-type 编码的历史参考。当前 active intrinsic 页使用以下 block start：

- [BSTART.TEPL](./BSTART.TEPL.md)：普通 tile compute。
- [BSTART.TLSU](./BSTART.TLSU.md)：TLSU load/store/move/gather/scatter。
- [BSTART.CUBE](./BSTART.CUBE.md)：matrix/CUBE。

如果后续重新引入 programmable parallel/vector block body，需要单独定义对应 body ISA、state、operand 约束和异常边界。
