# HL.LHU.PCR

Execute the HL.LHU.PCR scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.LHU.PCR.asl -->

## Assembly

```asm
hl.lhu.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lhu_pcr_48_444cb4ddde1d | HL48 | 48 | 0x00005039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lhu_pcr_48_444cb4ddde1d | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lhu_pcr_48_444cb4ddde1d | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LHU.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LHU_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LHU_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LHU.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LHU_PCR() => ScalarSemanticHandler
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
