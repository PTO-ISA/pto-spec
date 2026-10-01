<!-- GENERATED FROM: asl/arch/programming-model/scalar-registers.asl -->
# Scalar Registers

**Normative ASL source:** `asl/arch/programming-model/scalar-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: arch-scalar-registers-purpose-scope role=purpose-scope -->
## Purpose and scope

This unit defines how scalar general-purpose registers (GPRs) are read and written. Each of the four PEs in a Core has its own private file of `24` 64-bit GPRs.

There are two access paths: one for the PE that is currently executing, and one that names a PE explicitly.

<!-- PTO-READER-BLOCK: arch-scalar-registers-concepts-state role=concepts-state -->
## Current-agent and per-PE access

`ReadGPR` and `WriteGPR` delegate to `ReadPEGPR` and `WritePEGPR` using `_CurrentMemoryAgent`, the identity of the PE that is executing. The per-PE helpers index `_PEGPRs` with both the selected memory-agent identity and the GPR index.

Design point: an instruction encodes a GPR number, not a PE. The same encoded selector therefore resolves in the executing PE's own file. When an operation involves several PEs, such as a Shared Tile memory operation, the ASL reads the selector separately from each PE's file through the per-PE helper, so each PE can supply its own base address or stride.

<!-- PTO-READER-BLOCK: arch-scalar-registers-rules-interactions role=rules-interactions -->
## Zero-register behavior

GPR index `0` reads as `Zeros{PTO_XLEN}` for every PE. A write to index `0` has no state effect.

For every nonzero index, reads return the selected `_PEGPRs` entry and writes replace that same entry with the supplied `Word`.

Design point: index `0` works as a constant zero source and as a destination whose result is discarded. Because both helpers check the index before touching `_PEGPRs`, no sequence of writes can make index `0` read anything other than zero.

<!-- PTO-READER-BLOCK: arch-scalar-registers-boundaries role=boundaries -->
## Architectural boundaries

The current-agent wrappers do not broadcast a write across PEs. They select exactly `_CurrentMemoryAgent`; explicit cross-PE inspection or update uses the per-PE helpers.

These helpers cover only selectors `0` through `23`. Scalar selectors `24` through `31` name temporary-queue positions, not GPRs, and are handled by the scalar operand owner.

<!-- PTO-READER-BLOCK: arch-scalar-registers-example-usage role=example-usage -->
## Non-normative aliasing example

Suppose the current memory agent is PE1. Writing a value with `WriteGPR` to a nonzero index changes PE1's corresponding `_PEGPRs` element; reading the same index through `ReadPEGPR` for PE0 is a different state lookup.

If the same program writes `0x5` to GPR index `0` on PE1, a following `ReadGPR` of index `0` still returns zero.

<!-- PTO-READER-BLOCK: arch-scalar-registers-related-owners role=related-owners-navigation -->
## Related owners

- [Core PE topology](core-pe-topology.md) defines the namespace counts and semantic PE identities.
- [Scalar operands](../../scalar/model/types/operands.md) maps five-bit selectors onto GPRs and temporary-queue positions.
- [Program counter](../state/program-counter.md) owns PC, TPC, and BPC access rather than placing them in the GPR array.
- [Interrupt registers](../system-registers/interrupt.md) is this unit's declared dependency.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/scalar-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS","surface":"arch","classification":["programming-model","scalar-registers"],"depends_on":["PTO-ARCH-SYSTEM-REGISTERS-INTERRUPT"]}
readonly func ReadGPR(index: GPRIndex) => Word
begin
    return ReadPEGPR(_CurrentMemoryAgent, index);
end;

readonly func ReadPEGPR(pe: MemoryAgentId, index: GPRIndex) => Word
begin
    if index == 0 then
        return Zeros{PTO_XLEN};
    else
        return _PEGPRs[[pe]][[index]];
    end;
end;

func WriteGPR(index: GPRIndex, value: Word)
begin
    WritePEGPR(_CurrentMemoryAgent, index, value);
end;

func WritePEGPR(pe: MemoryAgentId, index: GPRIndex, value: Word)
begin
    if index != 0 then
        _PEGPRs[[pe]][[index]] = value;
    end;
end;
```
<!-- GENERATED-ASL-END: unit -->
