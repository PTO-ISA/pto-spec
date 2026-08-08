<!-- GENERATED FROM: asl/scalar/agu/SH.PCR.asl -->
# SH.PCR

**Normative ASL source:** `asl/scalar/agu/SH.PCR.asl`

Execute the SH.PCR scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-SH-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sh.pcr SrcL, [symbol]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sh_pcr_32_14ba505eb3c2 | L32 | 32 | 0x00001069 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sh_pcr_32_14ba505eb3c2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sh_pcr_32_14ba505eb3c2 | simm | 17 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SH.PCR.asl -->
```asl
readonly func InstructionContractOperation_SH_PCR() => ScalarOperation
begin
    return ScalarOperation_SH_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SH.PCR.asl -->
```asl
readonly func InstructionContractHandler_SH_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
