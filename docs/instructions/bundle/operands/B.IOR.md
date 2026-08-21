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

Selectors 0–23 name the architectural scalar register set: selector 0 is the
zero register and selectors 1–23 are `sp/a0.../x3` in canonical output order.
Whether a field is absent is determined by the selected `BSTART` opcode's
schema, not by selector zero. Repeated input and output registers are legal.
A decoupled body may access only declared registers. A coupled SYS body
accesses GGPR directly under the SYS ABI and does not use `B.IOR` as a formal
declaration.

## Shared GM Schema

With a preceding [`B.IOS`](./B.IOS.md):

| Role | RegSrc0 | RegSrc1 | RegSrc2 | RegDst `[11:7]` |
| --- | --- | --- | --- | --- |
| GM→Shared TLOAD | this PE's GM base byte address | row stride in bytes | zero | zero |
| Shared→GM TSTORE | this PE's GM base byte address | row stride in bytes | zero | zero |

Shared identity, `PE_MASK`, and destination size are encoded by `B.IOS`.
Shared stores obtain size from the bound Shared descriptor. Every participating
PE reads its own GPR instance, and the program must prevent conflicting GM
address ranges.

Local TLOAD/TSTORE use the same RegSrc0/RegSrc1 byte-address schema. When the
complete B.IOR instruction is omitted, base defaults to zero and row stride
defaults to `ceil(LB2 * element_bits / 8)` bytes. An encoded zero RegSrc1 is a
real zero stride and never selects the dense default.

## Matrix PostProcess Scalar Parameters

B.IOR 按 PostProcessConfig 绑定 scalar quant 或 scalar ReLU 参数。canonical None 不发 Matrix scalar B.IOR。cooperative TMATMUL 要求四 PE 对应 GPR 值相等；无需硬件运行时比较或 trap。
