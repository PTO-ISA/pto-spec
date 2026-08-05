---
{
  "schema_version": 1,
  "id": "header.header-c.b.ios",
  "kind": "header",
  "title": "C.B.IOS",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Operand Bindings",
  "sources": { "davincioo": "header/C.B.IOS.md" }
}
---
# C.B.IOS

## 用途

C.B.IOS 为 cooperative TMATMUL 绑定 Shared Left/ScaleLeft/Right/ScaleRight
source，也为 Shared TLOAD/TSTORE/TMOV 绑定其单个 Shared destination/source。
TGEMV 不支持该 prefix。

## 汇编语法

```asm
C.B.IOS S17
C.B.IOS -> S17
```

边界拼写同样是 canonical：source `C.B.IOS S0` / `C.B.IOS S255`，
destination `C.B.IOS -> S0` / `C.B.IOS -> S255`。旧 hash-prefixed Shared
spelling 不是 0.58.0 syntax。

第一种是 source，第二种是 destination。role 不另占字段，而由 BSTART
Function、binder 个数和固定顺序确定；assembler/verifier 必须拒绝与
surrounding operation role 相反的箭头形式。SharedID 是绝对索引 0..255。

## 编码

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[15:14]` | prefix | 2 | `11` |
| `[13:6]` | `SharedTID` | 8 | |
| `[5:4]` | prefix | 2 | `11` |
| `[3:1]` | opcode | 3 | `110` |
| `[0]` | C16 | 1 | `0` |

## 一次性绑定规则

- non-MX：Right，或 Left,Right。
- MX：Right,ScaleRight，或 Left,ScaleLeft,Right,ScaleRight。
- 所有同时出现的 Shared ID 必须不同。
- binder 在随后的 B.IOT stream 中一次消费，不得跨 block 或重复绑定。
- Shared TLOAD/TSTORE/TMOV 恰好使用一个 binder，并由对应 B.IOR/B.IOT
  companion 一次消费。
- TLOAD、Local-to-Shared TMOV 使用 destination `-> Sx`；TSTORE、
  Shared-to-Local TMOV 和所有 CUBE binder 使用 source `Sx`。

## Profile Collision

CUBE 中 C.B.IOS 只对 Function 0–2、4–6 合法；Function 16–18、20–22
（TGEMV）以及 CUBE reserved/illegal Function 9–14 遇到该 prefix 必须产生
确定的 profile diagnostic。TLSU namespace 另行允许 TLOAD Function 0、
TSTORE Function 1/14 与 TMOV Function 9–12 的单 binder companion schema。
