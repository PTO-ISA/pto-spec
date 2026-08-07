---
{
  "schema_version": 1,
  "id": "header.header-c.b.dim",
  "kind": "header",
  "title": "C.B.DIM",
  "status": "active",
  "visibility": "public",
  "profile": "pto-isa-0.58.0",
  "family": "Dimensions & Attributes",
  "sources": { "davincioo": "header/C.B.DIM.md" }
}
---
# C.B.DIM

## v5 Use

The compressed immediate dimension form (`C.B.DIMI`) remains available for
LB0/LB1/LB2. The v4 compressed `C.B.DIM RegSrc` form is not accepted by the
`davincioo-v5-superscalar` profile; a runtime register dimension must use
32-bit [`B.DIM`](./B.DIM.md). The 32-bit [`B.IOS`](../operands/B.IOS.md)
Shared binder is in the Bundle Input & Output opcode group and does not reuse a
compressed dimension encoding.

```asm
C.B.DIM  imm, ->LB0       /* compressed immediate form */
B.DIM    RegSrc, imm, ->LB1 /* v5 runtime register form */
```

`LBx` consumes the low 16 bits of `RegSrc + imm` in the 32-bit form.

## Compatibility

`davincioo-v4-pe-local` continues to decode the inherited compressed register
form as `C.B.DIM RegSrc`. A binary profile is required before decode; v5 rejects
that old form rather than guessing from surrounding instructions.
