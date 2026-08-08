---
{
  "schema_version": 1,
  "id": "coverage.linx_coverage",
  "kind": "coverage",
  "title": "Linx ISA Coverage Notes",
  "status": "review",
  "visibility": "internal",
  "profile": "pto-isa-0.58.0",
  "sources": {
    "davincioo": "LINX_COVERAGE.md"
  }
}
---
# Linx ISA Coverage Notes

> Historical, non-normative material. This page is excluded from the active PTO architecture and release closure.

## v5 Header Extensions

| Surface | Linx/v4 baseline | DavinciOO v5 treatment |
| --- | --- | --- |
| `B.IOT` | `imm4`, reuse bits, 3-bit DstTile | Profile-isolated `PE_MASK`, `TSize`, 2-bit DstTile; no reuse |
| `C.B.DIM RegSrc` | Compressed runtime dimension | Runtime dimension uses `B.DIM`; the overlapping 16-bit Shared binder is retired and replaced by 32-bit `B.IOS` |
| `BSTART.TLSU` | Functions 8–31 reserved | Functions 9–12 分配给 Shared movement，Function 13 分配给 `GMOV`，Function 14 分配给 Shared partition store |
| `BSTART.CUBE` | Existing TMATMUL/TGEMV functions | Numbers retained; Shared binder changes operand schema |
| `FENCE.D` | PE-local fence mode `00000` | Core PE4 mode `00001` added as `FENCE.D.CORE4` |

## Matrix Coverage

DavinciOO v5 保留 12 个 base/BIAS/ACC、MX/non-MX TMATMUL/TGEMV operation，统一写显式 D 并使用 mandatory B.FPATR。六个 *_FIXP 页面与 Function 9–14 mapping 已删除。Function 8 ACCCVT 仅保留 legacy/removed 说明。

## TLSU Coverage

TLOAD/TSTORE/TMOV retain PTO-visible names. GM↔Shared uses functions 0/1 with `B.IOS+B.IOR`; Local↔Shared uses functions 9–12; partition store uses function 14. Gather/scatter/prefetch do not target Shared storage in v5.

## Scalar 与 SYS 覆盖

Complete HTML 的 Scalar ISA 区保留锁定的 Linx source reference。v5 完整纳入锁定 Linx `blockIntro/sys_block/instlist.md` 及其 71 个 `misa_s` 页面，并在 `scalar/misa_s/` 中追加 Core4 fence 扩展。既有 SYS instruction 的 privilege、legality 与 precise-trap 行为不变；只有 `FENCE.D.CORE4` 新增 v5 encoding。

## GMOV 覆盖

`GMOV` 使用原 reserved 的 `BSTART.TLSU Function 13`，operand schema 为
`B.IOT(Local src,dst,PE_MASK,TSize)+B.IOR(a0)`；B.IOR 缺省时 peer 为
`zero`。它是固定 Core4 collective，与 Shared CUBE 一样要求收敛，但不使用
`B.IOS`。

## PTO Mapping Status

Matrix 的 Davinci target contract 已冻结；当前 upstream PTO C++ header 对 PostProcessConfig、MX name split、AccPhase 和 ACC shorthand 的差异由独立跨仓 handoff 处理，不在本目录 source-lock 更新范围内。
