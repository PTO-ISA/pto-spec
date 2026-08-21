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

## v5 Header Extensions

| Surface | Linx/v4 baseline | DavinciOO v5 treatment |
| --- | --- | --- |
| `B.IOT` | `imm4`, reuse bits, 3-bit DstTile | Profile-isolated `PE_MASK`, `TSize`, 2-bit DstTile; no reuse |
| `C.B.DIM RegSrc` | Compressed runtime dimension | Reinterpreted as `B.IOS`; runtime dimension uses `B.DIM` |
| `BSTART.TLSU` | Linx v0.58 allocation | PTO Functions 0–8 and 13 are common; Linx-only Functions 9–12 and 14 remain reserved/illegal in PTO |
| `BSTART.CUBE` | Existing TMATMUL/TGEMV functions | Numbers retained; Shared binder changes operand schema |
| `FENCE.D` | PE-local fence mode `00000` | Core PE4 mode `00001` added as `FENCE.D.CORE4` |

## Matrix Coverage

DavinciOO v5 保留 12 个 base/BIAS/ACC、MX/non-MX TMATMUL/TGEMV operation，统一写显式 D 并使用 mandatory B.FPATR。六个 *_FIXP 页面与 Function 9–14 mapping 已删除。Function 8 ACCCVT 仅保留 legacy/removed 说明。

## TLSU Coverage

TLOAD/TSTORE/TMOV retain PTO-visible names. GM↔Shared uses Functions 0/1 with
`B.IOS+B.IOR`; TMOV is Local-only at Function 2. Functions 6/7/8 are
MGATHER.MASK/MSCATTER.MASK/MGATHER.CAS. Linx-only Shared movement and
TSTORE.SPART functions remain reserved in PTO. Gather/scatter/prefetch do not
target Shared storage in v5.

## Scalar 与 SYS 覆盖

Complete HTML 的 scalar appendix 保留继承的 Linx compatibility reference。v5 完整纳入锁定 Linx `blockIntro/sys_block/instlist.md` 及其 71 个 `misa_s` 页面，并在 `scalar/misa_s/` 中追加 Core4 fence 扩展。既有 SYS instruction 的 privilege、legality 与 precise-trap 行为不变；只有 `FENCE.D.CORE4` 新增 v5 encoding。

## GMOV 覆盖

`GMOV` 使用原 reserved 的 `BSTART.TLSU Function 13`，operand schema 为 `B.IOT(Local src,dst,PE_MASK,TSize)+B.IOR(peer_tid,0,0)`。它是固定 Core4 collective，与 Shared CUBE 一样要求收敛，但不使用 `B.IOS`。

## PTO Mapping Status

Matrix 的 Davinci target contract 已冻结；当前 upstream PTO C++ header 对 PostProcessConfig、MX name split、AccPhase 和 ACC shorthand 的差异由独立跨仓 handoff 处理，不在本目录 source-lock 更新范围内。
