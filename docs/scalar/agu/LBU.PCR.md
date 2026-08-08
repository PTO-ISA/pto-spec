<!-- GENERATED FROM: asl/scalar/agu/LBU.PCR.asl -->
# LBU.PCR

**Normative ASL source:** `asl/scalar/agu/LBU.PCR.asl`

Execute the LBU.PCR scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-LBU-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
lbu.pcr [symbol], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lbu_pcr_32_5b571b0c8dc2 | L32 | 32 | 0x00004039 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lbu_pcr_32_5b571b0c8dc2 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| lbu_pcr_32_5b571b0c8dc2 | simm17 | 17 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/LBU.PCR.asl -->
```asl
readonly func InstructionContractOperation_LBU_PCR() => ScalarOperation
begin
    return ScalarOperation_LBU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/LBU.PCR.asl -->
```asl
readonly func InstructionContractHandler_LBU_PCR() => ScalarSemanticHandler
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
