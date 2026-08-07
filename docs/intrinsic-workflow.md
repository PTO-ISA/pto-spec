---
{
  "schema_version": 1,
  "id": "overview.readme",
  "kind": "overview",
  "title": "DavinciOO PTO Intrinsic 参考",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "README.md"
  }
}
---
# DavinciOO PTO Intrinsic 参考

> 当前 profile：`davincioo-v5-superscalar`。一个 Core 的四个 PE 以独立 PC 运行同一 SPMD image。普通 logical Tile 静态四等分到四个 PE；Core-local `SharedTile` 与 cooperative CUBE form 由 operand type 明确区分。

## 阅读路径

1. [ISA 总览](davincioo-arch/isa-overview.md)说明执行层级和指令族。
2. [编程模型](davincioo-arch/programming-model.md)定义 Tile、scope、SharedTile、CUBE 与同步语义。
3. [状态与类型](davincioo-arch/state-and-data-types.md)定义 Local/Shared storage、distribution、persistent register state 与 TileAcc。
4. [内存与异常](davincioo-arch/memory-ordering-and-exceptions.md)定义数据搬运、完成、顺序与非法程序行为。
5. [汇编语法](davincioo-arch/assembly-syntax.md)和 [Encoding](davincioo-arch/encoding-conventions.md)定义编码与语法。
6. 正式指令按 [Scalar ISA](instructions/scalar.md)、[Block ISA](instructions/block-command.md) 和 [Tile ISA](instructions/tile.md) 三类发布；Tile ISA 当前包含 109 条 operation。

## 架构边界

- 本仓的 109 条 Tile 指令是 PTO ISA 0.58 的唯一正式目录，Markdown、catalog、ASL、Excel 与 HTML 必须保持同一集合。
- `GMOV`、`MGATHER_MASK`、`MSCATTER_MASK`、`MGATHER_CAS`、`TFMA`、`THISTOGRAM` 与带显式 `sort_width` 的 `TSORT` 属于 canonical catalog；`TRANDOM` 的 selector 保留，`TSORT32` 与 `SYNCALL` 不属于 Tile 指令集合。
- 每条正式指令只有一份 Markdown 权威页；HTML 是可重复生成并受 Git 跟踪的发布视图。

## 维护流程

高频维护优先使用结构化 handoff 和 scoped fast path：

```text
node scripts/intrinsic-docs/intrinsic_docs.mjs handoff-check --handoff <file>
node scripts/intrinsic-docs/intrinsic_docs.mjs change-begin --handoff <file>
node scripts/intrinsic-docs/intrinsic_docs.mjs check-change --handoff <file>
node scripts/intrinsic-docs/intrinsic_docs.mjs preview-change --handoff <file>
```

`preview-change` 写入 `/tmp`，不覆盖受 Git 跟踪的 Complete；`build-html` 只生成候选站点，验证后再同步到 `docs/html/`。

- Markdown frontmatter 与固定正文段落是权威源。
- `PTO-ISA.source-lock.json` 与 `LINX-ISA.source-lock.json` 锁定外部语义，只有显式更新 source 时才刷新。
- status 或路径变化后使用 `generate-indexes` 刷新 mapped/unmapped 导航。
- Excel 是受保护的增量投影，必须保留 sidecar 中的 `manual_overrides` 与 merged-layout placeholder。
- `check` 校验 schema、source lock、coverage、链接与 fragment。
- `build-html` 在忽略目录 `build/docs-html-candidate/` 下 clean-build 本地 Complete 站点。
- 本阶段不生成 `intrinsic.zip`；Excel 位于 `spec/encoding/`，HTML 候选位于忽略的 `build/docs-html-candidate/`。

```text
node scripts/intrinsic-docs/intrinsic_docs.mjs generate-indexes
node --test scripts/intrinsic-docs/test_intrinsic_docs.mjs
node --test scripts/intrinsic-docs/test_intrinsic_docs.mjs
python3 scripts/check-publication-hygiene
python3 scripts/check-repository
node scripts/intrinsic-docs/sync_intrinsic_xlsx.mjs audit
node scripts/intrinsic-docs/intrinsic_docs.mjs build-html
```

物理删除 Markdown/Excel 记录是默认 removed-tombstone 与“清空 C:L、保留物理行”策略的窄范围例外，只能由 frozen `change_type=remove` handoff 对精确 stable id 授权。先删除已声明页面，再运行：

```text
<bundled-node> scripts/intrinsic-docs/sync_intrinsic_xlsx.mjs dry-run --artifact-node-modules <path> --physical-delete-id <stable-id>
<bundled-node> scripts/intrinsic-docs/sync_intrinsic_xlsx.mjs apply --artifact-node-modules <path> --physical-delete-id <stable-id>
<bundled-node> scripts/intrinsic-docs/sync_intrinsic_xlsx.mjs dry-run --artifact-node-modules <path> --physical-delete-id <stable-id>
node scripts/intrinsic-docs/sync_intrinsic_xlsx.mjs audit
```

`--physical-delete-id` 只接受 stable id，并删除整行、相关 A:B merge 布局和 sidecar state；多行按当前行号从大到小处理。普通 `--delete-id` 行为不变，只清空 C:L。remove handoff 仅在一个被删除 target 的全部 section action 都是 `remove` 时允许该 Markdown 文件在变更后不存在。

<!-- BEGIN GENERATED: instruction-index -->
## 正式指令目录

- [Scalar ISA](instructions/scalar.md)
- [Block ISA](instructions/block-command.md)
- [109 条 Tile ISA operation](instructions/README.md)
- [覆盖率与迁移状态](status/README.md)
- Complete HTML 入口：`docs/DavinciOO_PTO_Intrinsic_Complete.html`

<!-- END GENERATED: instruction-index -->
