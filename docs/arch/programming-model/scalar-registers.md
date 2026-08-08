<!-- GENERATED FROM: asl/arch/programming-model/scalar-registers.asl -->
# Scalar Registers

**Normative ASL source:** `asl/arch/programming-model/scalar-registers.asl`

This page is a generated reference view of the normative ASL unit.

## ASL unit identity {#PTO-ARCH-PROGRAMMING-MODEL-SCALAR-REGISTERS}

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

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
