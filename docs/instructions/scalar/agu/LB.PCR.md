# LB.PCR

Execute the LB.PCR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/LB.PCR.asl -->

## Normative identity {#PTO-INST-SCALAR-LB-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
lb.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lb_pcr_32_3fa2540b22d0 | L32 | 32 | 0x00000039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lb_pcr_32_3fa2540b22d0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lb_pcr_32_3fa2540b22d0 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LB.PCR.asl -->
```asl
readonly func InstructionContractOperation_LB_PCR() => ScalarOperation
begin
    return ScalarOperation_LB_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LB.PCR.asl -->
```asl
readonly func InstructionContractHandler_LB_PCR() => ScalarSemanticHandler
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
