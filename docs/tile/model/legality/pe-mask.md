<!-- GENERATED FROM: asl/tile/model/legality/pe-mask.asl -->
# PE Mask

**Normative ASL source:** `asl/tile/model/legality/pe-mask.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-PE-MASK}

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: tile-model-legality-pe-mask-purpose role=purpose-scope -->
## Purpose and scope

This unit defines two small pure helpers for reasoning about a four-bit PE mask. A PE mask selects which of the four processing elements (PEs) of a core take part in an operation or own a copy of a Tile.

- `PEMaskPopulation` counts how many mask bits are `1`. The result is in the range 0 to 4.
- `TileCoreAllocationBytes` multiplies that count by a per-PE byte size, giving the bytes an object occupies across the whole core.

Neither helper reads or writes architectural state, and neither raises a fault on its own. Callers use the results inside their own legality and admission checks.

<!-- PTO-READER-BLOCK: tile-model-legality-pe-mask-concepts role=concepts-state -->
## Concepts and visible state

The mask keeps PE0 in its high bit, so `1000` selects PE0 and `0001` selects PE3. Code that indexes a mask by PE identity must go through `PTOPEMaskBitOfPEIdentity`, which returns bit `3 - pe_identity`.

Design point: `PEMaskPopulation` only counts set bits, so it does not need the identity bridge. The count is the same whichever bit order is used, and `1000` and `0001` both have population 1.

Per-PE and core-wide sizes are different quantities. A Tile allocated with capacity 4096 bytes under mask `1100` uses 4096 bytes in each of PE0 and PE1, and 8192 bytes of the core in total.

<!-- PTO-READER-BLOCK: tile-model-legality-pe-mask-rules role=rules-interactions -->
## Rules and interactions

`TileCoreAllocationBytes` is used for core-wide totals. For example, `TileCapacityInUse` in the Local capacity unit sums it over every allocated Local Tile register, `TileCapacityInUseExcept` sums it over all of them except one excluded register, and `InstructionContractCoreCapacity_B_IOT` uses it to report the core capacity of a `B.IOT` size code.

Design point: admission of a new Local Tile does not use the core-wide total. `LocalTileAllocationFitsExcept` checks each selected PE's own pool against `TileCapacityLimitBytes`. A Tile therefore fits only if it fits in every PE it names, not merely in the sum of their pools.

`PEMaskPopulation` is used, for example, to distinguish a single issuing PE from a cooperative group:

- Shared Tile movement treats population 1 as a single issuer, and Shared Tile register updates test for population 1 when deciding how a descriptor update completes.
- The weight-to-Shared dispatch path uses the population as the number of selected PEs and to choose between single and cooperative behavior.
- TIMG2COL execution and range modifiers test the population of a Shared binding's mask.

<!-- PTO-READER-BLOCK: tile-model-legality-pe-mask-boundaries role=boundaries -->
## Architectural boundaries

A mask of `0000` has population 0, so `TileCoreAllocationBytes` returns 0 for it. These helpers do not decide whether a zero mask is legal. That decision belongs to the callers, for example the allocation transitions and the bundle operand checks.

The helpers do not check that `per_pe_bytes` is a legal capacity. Capacity legality is owned by `TileCapacityIsLegal` and the Local capacity unit.

<!-- PTO-READER-BLOCK: tile-model-legality-pe-mask-example role=example-usage -->
## Non-normative reading example

Take mask `1011` and a per-PE size of 2048 bytes.

- Bits set: PE0, PE2, and PE3, so `PEMaskPopulation` returns 3.
- `TileCoreAllocationBytes` returns 3 x 2048 = 6144 bytes.
- Admission still checks the three PE pools one by one; PE1 is not charged.

With mask `0000` the same size gives population 0 and 0 core bytes.

<!-- PTO-READER-BLOCK: tile-model-legality-pe-mask-related role=related-owners-navigation -->
## Related owners

- [Core and PE topology](../../../arch/programming-model/core-pe-topology.md) defines PE identities and the mask bit order.
- [Local capacity](../capacity/local.md) sums core bytes and checks per-PE pools.
- [Shared capacity](../capacity/shared.md) adds Shared Tile usage to the Local total.
- [Tile allocation](../state/allocation.md) consumes the allocation mask.
- [B.IOT](../../../block/operands/B.IOT.md) reports per-PE and core capacity for a size code.
<!-- SUPPLEMENTARY-END -->

## Normative ASL

<!-- GENERATED-ASL-BEGIN: unit source=asl/tile/model/legality/pe-mask.asl -->
```asl
// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-PE-MASK","surface":"tile","classification":["model","legality","pe-mask"],"depends_on":["PTO-TILE-MODEL-STATE-TYPES","PTO-ARCH-PROGRAMMING-MODEL-CORE-PE-TOPOLOGY"]}
pure func PEMaskPopulation(pe_mask: bits(4)) => integer {0..4}
begin
    var count: integer {0..4} = 0;
    for lane = 0 to 3 do
        if pe_mask[lane] == '1' then
            count = (count + 1) as integer {0..4};
        end;
    end;
    return count;
end;

pure func TileCoreAllocationBytes(pe_mask: bits(4),
                                  per_pe_bytes: integer) => integer
begin
    return PEMaskPopulation(pe_mask) * per_pe_bytes;
end;
```
<!-- GENERATED-ASL-END: unit -->
