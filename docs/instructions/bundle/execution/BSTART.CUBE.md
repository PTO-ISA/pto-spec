---
{
  "schema_version": 1,
  "id": "header.header-bstart.cube",
  "kind": "header",
  "title": "BSTART.CUBE",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Execution Classes",
  "sources": { "davincioo": "header/BSTART.CUBE.md" }
}
---
# BSTART.CUBE

## 用途

BSTART.CUBE 选择 12 个 active TMATMUL/TGEMV base/BIAS/ACC、MX/non-MX Function 与 AType。所有 active Matrix operation 显式写 D 并使用一个 B.FPATR；B.IOS 只选择 cooperative TMATMUL operand schema。

## 编码

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:27]` | `DataType` | 5 | |
| `[26:25]` | zero | 2 | `0` |
| `[24:20]` | `Function` | 5 | |
| `[19:15]` | block family | 5 | `6` |
| `[14:12]` | `Func` | 3 | `1` |
| `[11:7]` | fixed | 5 | `3` |
| `[6:4]` | `Opc1` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

## Function 表

| Function | Operation | Function | Operation |
| ---: | --- | ---: | --- |
| 0 | TMATMUL | 9 | reserved/illegal |
| 1 | TMATMUL.BIAS | 10 | reserved/illegal |
| 2 | TMATMUL.ACC | 11 | reserved/illegal |
| 3 | reserved | 12 | reserved/illegal |
| 4 | TMATMULMX | 13 | reserved/illegal |
| 5 | TMATMULMX.BIAS | 14 | reserved/illegal |
| 6 | TMATMULMX.ACC | 15 | reserved |
| 7 | reserved | 16 | TGEMV |
| 8 | reserved (legacy removed selector) | 17 | TGEMV.BIAS |
| 18 | TGEMV.ACC | 20 | TGEMVMX |
| 19 | reserved | 21 | TGEMVMX.BIAS |
| 22 | TGEMVMX.ACC | 23–31 | reserved |

## Local 与 Shared Form

无 B.IOS 时，TMATMUL/TGEMV 都是 PE-local，source/output 由 B.IOT 表达。仅 TMATMUL 可使用 cooperative form：

- non-MX Local A：Right；
- non-MX Shared A：Left, Right；
- MX Local A pair：Right, ScaleRight；
- MX Shared A pair：Left, ScaleLeft, Right, ScaleRight。

B/ScaleB 必须 Shared，PE_MASK=1111；Shared A 配 Local B 非法。TGEMV 遇到 B.IOS 必须诊断 illegal。

## 结果与 TileAcc 约定

所有 active Matrix Function 写 ordinary physical Local D。base 从零开始，BIAS 加显式 Bias，ACC 加显式 C；不存在 implicit ACC generation。canonical None 使 D 保持 AccType/逻辑 TileAcc role，其他 PostProcess 产生 ordinary ND role。Function 9–14 不再提供 FIXP output path。
