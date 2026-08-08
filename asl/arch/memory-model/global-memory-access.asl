// PTO-UNIT: {"id":"PTO-ARCH-MEMORY-MODEL-GLOBAL-MEMORY-ACCESS","surface":"arch","classification":["memory-model","global-memory-access"],"depends_on":["PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS","PTO-ARCH-MEMORY-MODEL-ATOMICITY"]}

// NDF-BEGIN: PTO-ARCH-GM-ACCESS-001
// ndf: kind=contract level=L1 layer=memory status=accepted
// A TLOAD or TSTORE B.IOR binding MUST encode an absolute GPR selector for the
// GM base and an absolute GPR selector for row stride in logical elements.
// Each selected PE MUST resolve both selectors in its private GPR file. When
// B.IOR is absent, base MUST default to zero and stride MUST default to the
// dense logical row width; an explicitly encoded zero stride MUST remain zero.
// The logical element address is base + (row * stride + column) * element size;
// packed four-bit elements select the containing byte and the indexed nibble.
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
    return pe_mask[pe] == '1';
end;
