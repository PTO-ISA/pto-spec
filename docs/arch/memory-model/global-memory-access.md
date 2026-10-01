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

This unit owns the cross-PE Global Memory addressing contract that `TLOAD`, `TSTORE` and the Shared-store forms rely on. Of that contract it implements the predicate part: which `PE_MASK` values a Shared store function accepts, and which PE a mask bit names.

The contract is `PTO-ARCH-GM-ACCESS-001`. The unit has two executable functions and no state of its own; the address arithmetic and the preflight it describes live in the transfer bodies and in the stride helper.

<!-- PTO-READER-BLOCK: arch-gm-access-concepts role=concepts-state -->
## Address inputs and participation state

- A present `B.IOR` supplies an absolute GPR selector for the GM base and an absolute GPR selector for the row stride in bytes; each selected PE resolves both selectors in its own private GPR file.
- Without `B.IOR` the base defaults to zero and the stride defaults to the dense physical row width in bytes; an explicitly encoded zero stride stays zero rather than becoming the default.
- The byte address is `base + row * stride + column * element size`.
- Packed four-bit columns instead select `floor(column / 2)` from each byte-aligned row base and use column parity for the low or high nibble.
- `SharedStorePEMaskLegal` and `SharedGMPESelected` are `pure func` predicates: they read no architectural state, so the mask legality of a Shared store depends only on its function code and the four-bit mask.
- The masks the predicates receive come from `_BundleSharedBindings`: `asl/block/model/dispatch/shared-tlsu.asl` passes `shared_mask`, and `PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY` owns `PTOPEMaskBitOfPEIdentity`.

<!-- PTO-READER-BLOCK: arch-gm-access-rules role=rules-interactions -->
## Mask rule and PE selection

`SharedStorePEMaskLegal(function, pe_mask)` returns true when `pe_mask` is `Zeros{4}`, and otherwise returns `function == 1`. Read that second branch carefully: it does not test that the mask is full. A nonzero subset is accepted for Function `1` and for no other function, and every other function accepts only the all-zero mask.

`SharedGMPESelected(pe_mask, pe)` returns `pe_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1'`, so mask bit `3` is PE0 and mask bit `0` is PE3.

Design point: a zero mask is legal for every function because it is handled before the function test, while a nonzero subset is legal only for Function `1`. A Shared store written with Function `14` and a subset mask is therefore rejected by the caller as a `Fault_TileLegality` rather than silently ignored, and the zero mask that Function `14` does accept selects no PE through `SharedGMPESelected`. Mask legality and PE participation are separate checks; accepting zero does not turn it into an all-PE selection.

Design point: base defaulting and stride defaulting are different operations. An absent `B.IOR` gives base zero and a stride of the dense physical row width, but an explicitly encoded zero GPR value gives a base of zero and a stride of zero, so all rows of that request alias one row of GM. `SharedStorePEMaskLegal` and `SharedGMPESelected` implement none of this: the defaulting belongs to the bundle dispatch that materializes the per-PE base and stride words.

<!-- PTO-READER-BLOCK: arch-gm-access-boundaries role=boundaries -->
## Preflight and ordering boundaries

The clause states that selected PE accesses are preflighted before any effect and that the architecture defines no order among them. This file contains neither the preflight nor the ordering: the transfer bodies probe each element and record or perform it only after the probe passes, and the clause is what makes the missing cross-PE order a defined property rather than an omission. A program that lets two participating PEs touch the same GM bytes therefore has no guaranteed result and must avoid the conflict.

The byte-address formula is also not computed here. `TileMemoryStridedByteAddress` in `asl/tile/model/memory/stride.asl` forms `row_base` as `base_address + row * row_stride_bytes`, then adds `column DIVRM 2` for four-bit data and `column * TileElementBytes(data_type)` otherwise; `TileMemoryStridedByteHighNibble` is the `column MOD 2 == 1` test. `SharedStorePEMaskLegal` is called for example from `asl/tile/memory-and-data-movement/regular/TSTORE.asl` and from `asl/block/model/dispatch/shared-tlsu.asl`.

<!-- PTO-READER-BLOCK: arch-gm-access-example role=example-usage -->
## Non-normative mask example

`SharedStorePEMaskLegal(1, '0001')` is true and `SharedStorePEMaskLegal(14, '1100')` is false, because only the `function == 1` branch accepts a nonzero mask. `SharedStorePEMaskLegal(2, '1111')` is also false for the same reason.

`SharedGMPESelected('0001', 3)` is true and `SharedGMPESelected('0001', 0)` is false, because PE3 maps to bit `0`. A zero mask selects no PE through this helper, which is why the clause states the zero-mask no-effect rule separately.

Use this example block only as a reading aid: apply the rules above, then confirm the result in the normative ASL owner. It does not add an architectural contract.

<!-- PTO-READER-BLOCK: arch-gm-access-related role=related-owners-navigation -->
## Related owners

- `PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY` owns `PTOPEMaskBitOfPEIdentity` and the PE identity numbering.
- `asl/tile/model/memory/stride.asl` computes the byte address and the nibble choice that the clause states in words.
- [Atomicity](atomicity.md) records the events produced by the transfers; [Address space](address-space.md) is the byte storage underneath them.
- `PTO-ARCH-MEMORY-MODEL-ORDERING` classifies the Tile requests these transfers issue.
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
// Shared TSTORE Function 1 MAY use any nonzero participating PE subset.
// PE_MASK zero MUST have no effect. Selected PE accesses
// MUST be preflighted before any effect, and the architecture defines no order
// among them. Programmers MUST avoid conflicting GM regions.
// NDF-END: PTO-ARCH-GM-ACCESS-001

pure func SharedStorePEMaskLegal(function: integer {0..31},
                                 pe_mask: bits(4)) => boolean
begin
    if pe_mask == Zeros{4} then return TRUE; end;
    return function == 1;
end;

pure func SharedGMPESelected(pe_mask: bits(4), pe: MemoryAgentId) => boolean
begin
    return pe_mask[PTOPEMaskBitOfPEIdentity(pe)] == '1';
end;
```
<!-- GENERATED-ASL-END: unit -->
