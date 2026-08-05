---
{
  "schema_version": 1,
  "id": "status.bundle-unsupported",
  "kind": "coverage",
  "title": "Unsupported Block/Header Archive",
  "status": "review",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "family": "Unsupported Block/Header"
}
---
# Unsupported Block/Header Archive

> **NON-NORMATIVE / UNSUPPORTED**
> Every document in this directory is excluded from PTO ISA 0.58.0 public documentation and must not be used as assembler, decoder, ASL, encoding, or implementation input.

本目录保留上一轮 DavinciOO-only PE-local header 草案，仅作为历史参考。

当前 active intrinsic profile 已回退到 Linx-style block/header model：

- Tile operand binding 使用 `B.IOT`。
- Shape / dimension 使用 `B.DIM`。
- 数据属性、GPR operand 和 dependency 继续使用 `B.DATR/B.IOR/B.IOD` 等 Linx inherited header。

因此本目录下的 `B.ITP`、`B.OTA`、`B.META`、`B.MSHP`、`B.MRECTR`、`B.MRECTC` 当前不参与 active PE-local intrinsic 展开，也不作为当前 encoding 的实现依据。

另外，[S_TILE_STATE.md](./S_TILE_STATE.md) 保留 Linx `S` Tile state / `TS` scratch contract 的历史说明。当前 DavinciOO active profile 暂不发布 vector micro-ISA 或可编程 vector block body，因此不引入 `S` Tile state，`B.IOT.DstTile=5` 在 active profile 中保持 unused / reserved。

这些文档暂不删除，是为了保留 DavinciOO-only metadata/header 设计探索的上下文；后续若重新引入，需要重新评审与 Linx-style active profile、v4 group-level ISA 之间的边界。
