<!-- GENERATED FROM: asl/arch/system-registers/context.asl -->
# Context

**Normative ASL source:** `asl/arch/system-registers/context.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-SYSTEM-REGISTERS-CONTEXT}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-system-context-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit defines how a ring number and a low context-register index select an entry in the extended system-register file, plus the PTOv0 read and write helpers for that entry.

<!-- PTO-READER-BLOCK: arch-system-context-concepts-state role=concepts-state -->
## Context-register index

`ContextRegisterIndex` and `PTOv0ContextRegisterIndex` both compute `ring * 4096 + low_index`. The low index is constrained to `0` through `4095`.

The result is a `SystemRegisterFileIndex`, so each ACR receives one contiguous window of `4096` entries.

<!-- PTO-READER-BLOCK: arch-system-context-rules-interactions role=rules-interactions -->
## PTOv0 reads and writes

`PTOv0ReadContextRegister` returns `_ExtendedSystemRegisters` at the computed PTOv0 index. `PTOv0WriteContextRegister` replaces that same entry with the supplied `Word`.

<!-- PTO-READER-BLOCK: arch-system-context-boundaries role=boundaries -->
## Architectural boundaries

The two index helpers currently have the same arithmetic.

Keeping a PTOv0-named helper makes the version-specific access path visible to the reader without assigning semantics to individual low indices on this page.

This unit does not define access permission, side effects of particular registers, or reset values.

<!-- PTO-READER-BLOCK: arch-system-context-example-usage role=example-usage -->
## Non-normative address example

For ACR2 and low index `0x0f08`, the selected extended-register index is `2 * 4096 + 0x0f08`. Reading and writing through the PTOv0 helpers address that same element.

<!-- PTO-READER-BLOCK: arch-system-context-related-owners role=related-owners-navigation -->
## Related owners

- [Access control](access-control.md) defines ACR state and is the direct dependency.
- [Interrupt registers](interrupt.md) assigns meanings to low indices `0x0f07`, `0x0f08`, and `0x0f09`.
- [Timer registers](timer.md) uses low index `0x0f21` for the comparison value.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/system-registers/context.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-SYSTEM-REGISTERS-CONTEXT","surface":"arch","classification":["system-registers","context"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-ACCESS-CONTROL"]}
pure func ContextRegisterIndex(ring: AccessControlRing,
                               low_index: integer {0..4095})
    => SystemRegisterFileIndex
begin
    return ((ring * 4096) + low_index) as SystemRegisterFileIndex;
end;

pure func PTOv0ContextRegisterIndex(ring: AccessControlRing,
                                    low_index: integer {0..4095})
                                    => SystemRegisterFileIndex
begin
    return ((ring * 4096) + low_index) as SystemRegisterFileIndex;
end;

readonly func PTOv0ReadContextRegister(ring: AccessControlRing,
                                       low_index: integer {0..4095}) => Word
begin
    return _ExtendedSystemRegisters[[
        PTOv0ContextRegisterIndex(ring, low_index)]];
end;

func PTOv0WriteContextRegister(ring: AccessControlRing,
                               low_index: integer {0..4095}, value: Word)
begin
    _ExtendedSystemRegisters[[PTOv0ContextRegisterIndex(ring, low_index)]] =
        value;
end;
```
<!-- GENERATED-ASL-END: unit -->
