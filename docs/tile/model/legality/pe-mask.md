<!-- GENERATED FROM: asl/tile/model/legality/pe-mask.asl -->
# PE Mask

**Normative ASL source:** `asl/tile/model/legality/pe-mask.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-TILE-MODEL-LEGALITY-PE-MASK}

<!-- SUPPLEMENTARY-BEGIN -->

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
