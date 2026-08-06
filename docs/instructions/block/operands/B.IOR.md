---
{
  "schema_version": 1,
  "id": "header.header-b.ior",
  "kind": "header",
  "title": "B.IOR",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Operand Bindings",
  "sources": { "davincioo": "header/B.IOR.md" }
}
---
# B.IOR

## Purpose And Encoding

`B.IOR` declares up to three GGPR inputs and one GGPR output for header-form blocks.

```asm
B.IOR RegSrc0, RegSrc1, RegSrc2, ->RegDst
```

| Bits | Field | Width | Fixed value |
| --- | --- | ---: | --- |
| `[31:27]` | `RegSrc2` | 5 | |
| `[26:25]` | zero | 2 | `0` |
| `[24:20]` | `RegSrc1` | 5 | |
| `[19:15]` | `RegSrc0` | 5 | |
| `[14:12]` | `Func` | 3 | `0` |
| `[11:7]` | `RegDst` | 5 | |
| `[6:4]` | `Opc1` | 3 | `1` |
| `[3:1]` | `Opcode` | 3 | `1` |
| `[0]` | `W` | 1 | `1` |

Value 0 means invalid; 1–23 name GGPRs R1–R23. Repeated inputs/outputs are assembler errors. A decoupled body may access only declared registers. A coupled SYS body accesses GGPR directly under the SYS ABI and does not use `B.IOR` as a formal declaration.

## Shared GM Schema

With a preceding [`B.IOS`](./B.IOS.md), Shared TLOAD/TSTORE use `RegSrc0` as
the GM base and require `RegDst=RegSrc1=RegSrc2=0`. `B.IOR` never carries
Shared size or mask: GM→Shared obtains both from destination `B.IOS`, while
Shared→GM obtains capacity from the persistent Shared descriptor and mask from
source `B.IOS`.

## Matrix PostProcess Scalar Parameters

B.IOR 按 PostProcessConfig 绑定 scalar quant 或 scalar ReLU 参数。canonical None 不发 Matrix scalar B.IOR。cooperative TMATMUL 要求四 PE 对应 GPR 值相等；无需硬件运行时比较或 trap。
