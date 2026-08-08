// PTO-UNIT: {"id":"PTO-TILE-MODEL-LEGALITY-PE-MASK","surface":"tile","classification":["model","legality","pe-mask"],"depends_on":["PTO-TILE-MODEL-STATE-TYPES"]}
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

