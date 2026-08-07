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

`B.IOR` encodes up to three absolute GPR selectors and one absolute GPR output
selector for a header-form block. PTO direct-operation bundles contain zero or
one `B.IOR`; a second instruction is a bundle-control fault and does not replace
the first binding.

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

Every field is an absolute selector in `0..23`. Values `24..31`, including
temporary-queue selector encodings accepted by some scalar instructions, are
illegal in `B.IOR` and reject before bundle state changes. Selector zero names
the architectural zero register; it never means “operand absent”.

Canonical assembly and disassembly use these names:

```text
R0=zero, R1=sp, R2..R9=a0..a7, R10=ra,
R11..R19=s0..s8, R20..R23=x0..x3
```

Assemblers may additionally accept `R0..R23`. Relative `T#n`/`U#n` spelling
and numeric placeholder zero are not B.IOR syntax. Repeated inputs and
source/destination aliases are legal.

## Complete-Bundle Schema Resolution

The canonical operand list is resolved only after the complete bundle has
been collected. `BSTART`, `B.FPATR`/PostProcessConfig, and every other
schema-contributing header participate. A header defines its omitted/default
contribution; an operand is not inferred from a nonzero selector.

For the currently executable direct-operation catalog, register inputs are
bound in architectural operand order:

| Resolved operation shape | Encoded selector |
| --- | --- |
| first register input (`address`, otherwise `scalar0`) | `RegSrc0` |
| second register input (`scalar0` after `address`, otherwise `scalar1`) | `RegSrc1` |
| no current consumer | `RegSrc2`, `RegDst` |

If B.IOR is omitted, each consumed register operand defaults to `zero` unless
the selected operation explicitly defines another default. If B.IOR is
encoded, fields not consumed by the resolved schema must be zero. Execution
reads only consumed fields.

Schema-shaped canonical examples are:

```asm
B.IOR a0
B.IOR zero
B.IOR a0, a0
B.IOR a0, ->a0
```

TLOAD and TSTORE preserve their existing two-input B.IOR encoding and
canonical form:

```asm
B.IOR a0, a1  /* RegSrc0=base, RegSrc1=row stride in elements */
```

If B.IOR is omitted for TLOAD/TSTORE, base defaults to `zero` and row stride
defaults to the resolved `LB2/Col` dimension. Encoding `RegSrc1=zero` is
different: it selects a real zero stride and does not receive the omission
default.

Disassembly must first collect the complete bundle. No encoded B.IOR produces
no B.IOR line; defaults still apply. An encoded all-zero word is preserved and
prints the schema-consumed `zero` operands. A standalone decoder without
bundle context must use a raw/unknown form rather than guess the arity.

A coupled SYS body accesses GPRs directly under the SYS ABI and does not use
`B.IOR` as a formal declaration. PTO does not define LinxISA's decoupled
programmable-body declaration stream.

## Shared GM Schema

With a preceding [`B.IOS`](./B.IOS.md), Shared TLOAD/TSTORE use `RegSrc0` as
the GM base and `RegSrc1` as row stride in elements. If B.IOR is present,
`RegDst=RegSrc2=0`; if it is omitted, the base defaults to `zero` and stride
defaults to the resolved `LB2/Col` for both TLOAD and TSTORE. `B.IOR` never carries
Shared size or mask: GM→Shared obtains both from destination `B.IOS`, while
Shared→GM obtains capacity from the persistent Shared descriptor and mask from
source `B.IOS`.

## Matrix PostProcess Scalar Parameters

B.IOR 的 Matrix arity 由最终 PostProcessConfig 决定，而不是由
`BSTART.opcode` 单独决定。canonical None 不需要编码 Matrix scalar B.IOR；
若参数缺省，其 schema default 为 `zero`。cooperative TMATMUL 要求四 PE
对应 GPR 值相等；无需硬件运行时比较或 trap。
