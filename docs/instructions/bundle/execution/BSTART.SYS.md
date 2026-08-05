---
{
  "schema_version": 1,
  "id": "header.header-bstart.sys",
  "kind": "header",
  "title": "BSTART.SYS",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Execution Classes",
  "sources": { "davincioo": "header/BSTART.SYS.md" }
}
---
# BSTART.SYS

## 编程接口

DavinciOO v5 完整开放 Linx programmable coupled SYS body。SYS 只允许 FALL；body 从 `BSTART.SYS` 后立即开始，到下一个 `BSTART` 或 `BSTOP` 结束，不使用 `B.TEXT`。PTO-AS/assembly 可使用全部合法 Linx SYS/GGPR instruction，并继续遵守其既有 privilege、legality 与 precise-trap 规则。

```asm
BSTART.SYS FALL
    /* programmable scalar/system body */
BSTOP
```

C++ 不暴露 body 的 physical GGPR operand。编译器负责 live-in/live-out 与 clobber allocation；PTO-AS 和 low-level assembly 可按 ABI 命名 GGPR。

## 编码形式

- 16-bit: `C.BSTART.SYS FALL`
- 32-bit: `BSTART.SYS FALL`
- 48-bit: `HL.BSTART.SYS FALL`
- 64-bit: `L.BSTART.SYS FALL`

`FALL` 可以省略。除继承的 coupled-block fetch/termination 规则外，SYS 不增加新的 architectural body-length limit。

## 32-bit 编码

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:15]` | `simm17` | 17 | |
| `[14:12]` | `BrType` | 3 | `1` |
| `[11:7]` | `BlockType` | 5 | `1` |
| `[6:4]` | `Opcode` | 3 | `0` |
| `[3:1]` | `Opcode` | 3 | `0` |
| `[0]` | `W` | 1 | `1` |

## Core4 Collective Fence

```asm
BSTART.SYS FALL
FENCE.D.CORE4 RW, RW
BSTOP
```

`DSB.CORE4` 是 alias。包含该指令的 body 必须 straight-line，并在 PE0–PE3 间静态收敛；fence 必须是最后一条可执行指令，整个 SYS block 是独立的 non-speculative commit/serialization boundary。`SYNCALL<core_scope>()` 的 canonical lowering 就是这个单指令 body。
