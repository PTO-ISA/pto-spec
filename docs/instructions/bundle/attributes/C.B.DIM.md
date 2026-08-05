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

The compressed immediate dimension form (`C.B.DIMI`) remains available for LB0/LB1/LB2. The v4 compressed `C.B.DIM RegSrc` bit pattern is reassigned to [`C.B.IOS`](../operands/C.B.IOS.md) in `davincioo-v5-superscalar`; therefore a runtime register dimension must use 32-bit [`B.DIM`](./B.DIM.md).

```asm
C.B.DIM  imm, ->LB0       /* compressed immediate form */
B.DIM    RegSrc, imm, ->LB1 /* v5 runtime register form */
```

`LBx` consumes the low 16 bits of `RegSrc + imm` in the 32-bit form.

## Compatibility

`davincioo-v4-pe-local` continues to decode the inherited compressed register form as `C.B.DIM RegSrc`. A binary profile is required before decode; the same 16-bit pattern cannot be guessed from surrounding instructions.
