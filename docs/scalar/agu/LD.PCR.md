<!-- GENERATED FROM: asl/scalar/agu/LD.PCR.asl -->
# LD.PCR

**Normative ASL source:** `asl/scalar/agu/LD.PCR.asl`

Execute the LD.PCR scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-LD-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ld.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ld_pcr_32_99bc3d2d487b | L32 | 32 | 0x00003039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ld_pcr_32_99bc3d2d487b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ld_pcr_32_99bc3d2d487b | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LD.PCR.asl -->
```asl
readonly func InstructionContractOperation_LD_PCR() => ScalarOperation
begin
    return ScalarOperation_LD_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LD.PCR.asl -->
```asl
readonly func InstructionContractHandler_LD_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
