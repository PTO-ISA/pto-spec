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

This unit owns one arithmetic rule and the two access helpers built on it: how a ring number and a low context-register index together select an entry of the extended system-register file, and how a read or a write reaches that entry.

It covers addressing only. Which low index means what, which ring may touch a given register, and what a particular register does are owned elsewhere on this site.

<!-- PTO-READER-BLOCK: arch-system-context-concepts-state role=concepts-state -->
## The ring-relative index

`ContextRegisterIndex` takes an `AccessControlRing` and a low index in the range 0 through 4095, and returns `ring * 4096 + low_index` cast to `SystemRegisterFileIndex`.

The result is a single flat index into `_ExtendedSystemRegisters`. Because the multiplier is 4096, each ring owns one window of 4096 consecutive entries, and the windows of different rings never overlap.

`ReadContextRegister` returns the entry at that index. `WriteContextRegister` replaces the entry at the same index with the supplied `Word`.

<!-- PTO-READER-BLOCK: arch-system-context-rules-interactions role=rules-interactions -->
## How the helpers interact

Both helpers derive the index through the same function, so a read and a write of the same ring and low index always address the same element.

Design point: the low index is limited to 4095 and only the ring number is multiplied by 4096, so a ring number cannot change which entry inside a window is selected. One ring's value for a low index can never land on another ring's storage.

The two helpers are the only access path this owner defines. Concurrency between rings, the contents of the windows, and register-specific side effects are not part of them.

<!-- PTO-READER-BLOCK: arch-system-context-boundaries role=boundaries -->
## Architectural boundaries

A low index is an offset inside a ring's window, not a register identity. The meaning of an offset comes from the owner of the register that lives there: the interrupt owner defines the interrupt configuration, the interrupt pending bitmap, and the top pending interrupt, the timer owner defines the comparison value, and this page stays silent about every other offset.

Base system registers are reached by a different decode, so their registers do not pass through these helpers on this page.

Design point: the helper takes an `AccessControlRing` rather than a plain integer, so an index computed for one ring cannot be silently reused as another ring's index without an explicit conversion.

<!-- PTO-READER-BLOCK: arch-system-context-example-usage role=example-usage -->
## Non-normative index example

For ACR1 and low index `0x0f21`, the helpers address the window of ACR1 at that offset. For ACR2 and the same low index, they address the window of ACR2 at the same offset, and the two entries differ.

Reading ACR1 at `0x0f21` never returns what ACR2 stores at `0x0f21`, which is why a timer comparison written for one ring never fires for another.

<!-- PTO-READER-BLOCK: arch-system-context-related-owners role=related-owners-navigation -->
## Related owners

- [Access control](access-control.md) defines `AccessControlRing` and the current-ring state, and is the declared dependency.
- [Interrupt registers](interrupt.md) gives meaning to the interrupt offsets read and written through these helpers.
- [Timer registers](timer.md) stores the comparison value for each ring through the same helpers.
- [System-register addressing](addressing.md) owns the base system-register record reached by the other decode path.
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


readonly func ReadContextRegister(ring: AccessControlRing,
                                       low_index: integer {0..4095}) => Word
begin
    return _ExtendedSystemRegisters[[
        ContextRegisterIndex(ring, low_index)]];
end;

func WriteContextRegister(ring: AccessControlRing,
                               low_index: integer {0..4095}, value: Word)
begin
    _ExtendedSystemRegisters[[ContextRegisterIndex(ring, low_index)]] =
        value;
end;
```
<!-- GENERATED-ASL-END: unit -->
