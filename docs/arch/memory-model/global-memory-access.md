<!-- GENERATED FROM: asl/arch/memory-model/global-memory-access.asl -->
# Global Memory Access

**Normative ASL source:** `asl/arch/memory-model/global-memory-access.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-gm-access-purpose role=purpose-scope -->
## Purpose and scope

This unit owns the cross-PE Global Memory addressing contract used by `TLOAD` and `TSTORE`, including `B.IOR` defaults, packed four-bit columns, Shared-store PE-mask legality, and preflight boundaries.

<!-- PTO-READER-BLOCK: arch-gm-access-concepts role=concepts-state -->
## Address inputs

- A present `B.IOR` supplies absolute GPR selectors for the GM base and row stride in bytes.
- Each selected PE resolves both selectors in its own private GPR file.
- Without `B.IOR`, base is zero and stride is the dense physical row width; an explicitly encoded zero stride stays zero.

<!-- PTO-READER-BLOCK: arch-gm-access-rules role=rules-interactions -->
## Addressing and participation

The byte address is formed from base, row times stride, and column times element size. Packed four-bit data selects `floor(column / 2)` from each byte-aligned row and uses column parity for the nibble.

A zero mask is a no-op. Shared Function `1` requires `'1111'`; otherwise only Function `14` accepts a nonzero subset.

`SharedStorePEMaskLegal` implements that mask rule. `SharedGMPESelected` maps a PE identity through `PTOPEMaskBitOfPEIdentity`.

<!-- PTO-READER-BLOCK: arch-gm-access-boundaries role=boundaries -->
## Preflight and ordering boundaries

All selected-PE accesses are checked before any effect. The architecture does not order those PE accesses against one another, so programs avoid conflicting GM regions rather than relying on an unstated inter-PE order.

<!-- PTO-READER-BLOCK: arch-gm-access-example role=example-usage -->
## Non-normative address example

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-gm-access-related role=related-owners-navigation -->
## Related owners

- Scalar-register and Core/PE-topology units define the selector and agent context.
- Atomicity records resulting memory events; `TLOAD` and `TSTORE` owners define concrete transfers.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/memory-model/global-memory-access.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","surface":"arch","classification":["memory-model","global-memory-access"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS","PTO-ARCH-MEMORY-MODEL-ATOMICITY","PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY"]}

// NDF-BEGIN: PTO-ARCH-GM-ACCESS-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A TLOAD or TSTORE B.IOR binding MUST encode an absolute GPR selector for the
// GM base and an absolute GPR selector for row stride in bytes.
// Each selected PE MUST resolve both selectors in its private GPR file. When
// B.IOR is absent, base MUST default to zero and stride MUST default to the
// dense physical row width in bytes; an explicitly encoded zero stride MUST
// remain zero. The byte address is base + row * stride + column * element size;
// packed four-bit columns select floor(column / 2) from each byte-aligned row
// base and use column parity to select the low or high nibble.
// Shared Function 1 TSTORE MUST use all four PEs, while Function 14 MAY use any
// nonzero PE subset. PE_MASK zero MUST have no effect. Selected PE accesses
// MUST be preflighted before any effect, and the architecture defines no order
// among them. Programmers MUST avoid conflicting GM regions.
// NDF-END: PTO-ARCH-GM-ACCESS-001

pure func SharedStorePEMaskLegal(function: integer {0..31},
                                 pe_mask: bits(4)) => boolean
begin
    if pe_mask == Zeros{4} then return TRUE;
    elsif function == 1 then return pe_mask == '1111';
    else return function == 14;
    end;
end;

pure func SharedGMPESelected(pe_mask: bits(4), pe: MemoryAgentId) => boolean
begin
    return pe_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1';
end;
```
<!-- GENERATED-ASL-END: unit -->
