<!-- GENERATED FROM: asl/arch/features/extension-first-use.asl -->
# Extension First Use

**Normative ASL source:** `asl/arch/features/extension-first-use.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-FEATURES-EXTENSION-FIRST-USE}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-extension-first-use-purpose role=purpose-scope -->
## Purpose and scope

This unit contains one enumeration and two `impdef` functions. `ExtensionFirstUseKind` has exactly two values, `ExtensionFirstUseKind_VECTOR` and `ExtensionFirstUseKind_CUBE`; there is no third value for the absence of an extension.

`ExtensionFirstUseEnabled` answers whether one kind is enabled, and `RaiseExtensionFirstUse` is the trap request. Both portable bodies return `FALSE`, so the portable configuration of this hook is disabled and effect-free.

<!-- PTO-READER-BLOCK: arch-extension-first-use-concepts role=concepts-state -->
## Hook inputs and portable values

The two functions and the enumeration are the whole executable content of the file; the unit declares no state variable, no enable bit, and no counter.

- `ExtensionFirstUseEnabled(kind: ExtensionFirstUseKind) => boolean` is `readonly impdef`, and its body is a single `return FALSE`.
- `RaiseExtensionFirstUse(kind: ExtensionFirstUseKind, source: AccessControlRing, manager: AccessControlRing) => boolean` is `impdef`, and its body is a single `return FALSE`.
- `AccessControlRing` is the integer range `0..15`, so each ring argument has `16` possible values.
- No unit under `asl/` calls either function.

Design point: `ExtensionFirstUseEnabled` is `readonly` while `RaiseExtensionFirstUse` is not, although both portable bodies only return a value. A replacement of the first function may therefore not write architectural state, while a replacement of the second one may, which is why the trap request is the function that carries the ordering and retry obligations.

Design point: the trap request receives the source and manager rings as parameters instead of reading `CurrentACR()`. Its portable body is a function of its arguments alone, and a caller must supply both ring identities explicitly instead of relying on the current ring.

<!-- PTO-READER-BLOCK: arch-extension-first-use-rules role=rules-interactions -->
## Default and enabling rules

The portable result of both hooks is `FALSE` for every argument: `ExtensionFirstUseEnabled` ignores `kind`, and `RaiseExtensionFirstUse` ignores all three parameters, so it returns `FALSE` for both kinds and all `256` ring pairs.

Design point: NDF clause `PTO-ARCH-EXTENSION-FIRST-USE-001` lists seven obligations an enabling profile must define: covered kinds, enable state, source and manager ACRs, the exact trap envelope, pre-effect ordering, retry state, and context-save progress. None of the seven is fixed by this unit, so the same call can trap in one profile and be effect-free in another.

Design point: `FaultCode` has `16` members and none of them names extension first use. The trap-entry mechanism reachable from the declared dependency is `SetFault(code, address)`, which saves the trap context, records `_LastFault` and `_FaultAddress`, writes the per-ring trap fields, switches the current ACR, and redirects TPC to `TrapVectorEntry(ring, address)`. A profile that traps on first use therefore selects one of the existing codes and re-enters through that vector entry; the hook itself returns only a `boolean`.

<!-- PTO-READER-BLOCK: arch-extension-first-use-boundaries role=boundaries -->
## Architectural boundary

The hook does not create extension state, does not detect that an instruction first used an extension, and adds no instruction coverage. `ExtensionFirstUseKind` names two kinds; it does not say which instructions use them.

Because no unit under `asl/` calls the two functions, no instruction gains first-use behavior from this page. An instruction owner or a profile decides whether a call site exists at all, and the NDF clause requires an enabling profile to place that call before effects and to define the retry boundary.

A per-kind default, a coverage table, and a dedicated fault code are absent from the owning file.

<!-- PTO-READER-BLOCK: arch-extension-first-use-example role=example-usage -->
## Non-normative profile example

A reader can evaluate the portable hook by substituting the declared bodies: `ExtensionFirstUseEnabled(ExtensionFirstUseKind_CUBE)` is `FALSE`.

`RaiseExtensionFirstUse(ExtensionFirstUseKind_CUBE, source, manager)` is `FALSE` for any `source` and `manager` in `0..15`, and the same holds for `ExtensionFirstUseKind_VECTOR`; no trap is requested and no ring is switched.

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-extension-first-use-related role=related-owners-navigation -->
## Related owners

- [Fault precision](../memory-model/fault-precision.md) owns `SetFault` and the trap record.
- [Access control](../system-registers/access-control.md) owns `CurrentACR()`, `SetCurrentACR`, `TrapTargetForFault`, and `TrapVectorEntry`.
- [Fault types](../data-types/fault.md) lists the `FaultCode` members a profile must choose from.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/features/extension-first-use.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-FEATURES-EXTENSION-FIRST-USE","surface":"arch","classification":["features","extension-first-use"],"depends_on":["PTO-ARCH-MEMORY-MODEL-FAULT-PRECISION"]}
// NDF-BEGIN: PTO-ARCH-EXTENSION-FIRST-USE-001
// ndf: kind=contract level=L1 layer=architecture status=accepted
// A target profile MAY provide a precise extension first-use trap. The
// portable default MUST remain disabled and effect-free. An enabling profile
// MUST define covered kinds, enable state, source and manager ACRs, the exact
// trap envelope, pre-effect ordering, retry state, and context-save progress.
// NDF-END: PTO-ARCH-EXTENSION-FIRST-USE-001

type ExtensionFirstUseKind of enumeration {
    ExtensionFirstUseKind_VECTOR,
    ExtensionFirstUseKind_CUBE
};

readonly impdef func ExtensionFirstUseEnabled(kind: ExtensionFirstUseKind)
    => boolean
begin
    return FALSE;
end;

impdef func RaiseExtensionFirstUse(kind: ExtensionFirstUseKind,
                                  source: AccessControlRing,
                                  manager: AccessControlRing) => boolean
begin
    return FALSE;
end;
```
<!-- GENERATED-ASL-END: unit -->
