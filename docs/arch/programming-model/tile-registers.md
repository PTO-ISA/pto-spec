<!-- GENERATED FROM: asl/arch/programming-model/tile-registers.asl -->
# Tile Registers

**Normative ASL source:** `asl/arch/programming-model/tile-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS}

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/arch/programming-model/tile-registers.asl -->
```asl
// PTO-UNIT: {"id":"PTO-ARCH-PROGRAMMING-MODEL-TILE-REGISTERS","surface":"arch","classification":["programming-model","tile-registers"],"depends_on":["PTO-ARCH-FEATURES-PREDICATION"]}
// This unit owns the named architecture concept; executable state is defined by its dependencies.
```
<!-- GENERATED-ASL-END: unit -->

<!-- SUPPLEMENTARY-BEGIN -->
## CUBE programming guidance

The CUBE layout is persistent Local Tile descriptor state.  A 128-byte CELL
is a storage unit, not an instruction-size limit: PE-level `TMATMUL` may use
`N > 8` by consuming the `CUBE_N8` K-fast/N-slow CELL grid.  For example,
`CUBE_N8` b16 with logical `[K=13,N=19]` uses two K repeats and three N
repeats (six CELLs); the final K and N tails remain outside the valid region.
The same valid-region rule applies to A, C, and D tails.

Allocate or load a CUBE Tile with the matching GM/Local `B.DATR` conversion
(`ND2M32`, `ND2M16`, `ND2N8`, `M322ND`, `M162ND`, or `N82ND`).  These spellings
preserve each element's raw representation and are not numeric `TCVT`
operations.  GM/Shared and Local/Shared transfers remain ordinary two-
dimensional transfers; CUBE conversion is not accepted on those paths.

For group operations, encode the core-level valid M.  Values 1..64 select
`CUBE_M16`, values 65..128 select `CUBE_M32`, and each PE derives its own
local valid-M (including zero rows for inactive PEs).  `B.FPATR` is mandatory
for the matrix family; its explicit `TransA` and `TransB` bits transpose only
the corresponding Shared input, while canonical no-transpose uses both bits
set to zero.  A transpose bit on a Local source, or a nonzero reserved bit,
is rejected before any operand is consumed.

For an accumulator chain, bind a fresh D for every `TMATMUL_ACC`.  A
non-final FP32/S32 D can be bound as C by a later bundle after it commits;
final post-processed or quantized D is not an accumulator input.  Complete-
bundle destination reuse and `D == C` are intentionally deferred, so an
owner legality fault leaves the old C and all other architectural state
unchanged.
<!-- SUPPLEMENTARY-END -->
