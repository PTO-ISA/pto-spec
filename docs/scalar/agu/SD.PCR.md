<!-- GENERATED FROM: asl/scalar/agu/SD.PCR.asl -->
# SD.PCR

**Normative ASL source:** `asl/scalar/agu/SD.PCR.asl`

SD.PCR - Store scalar data using this mnemonic's width and address-update form.

## Normative identity {#PTO-INST-SCALAR-SD-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
sd.pcr SrcL, [symbol]
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| sd_pcr_32_2340e0085413 | L32 | 32 | 0x00003069 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| sd_pcr_32_2340e0085413 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| sd_pcr_32_2340e0085413 | simm | 17 | signed | [{"instruction_lsb":20,"value_lsb":0,"width":12},{"instruction_lsb":7,"value_lsb":12,"width":5}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| SrcL | encoded operand or control |
| simm | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SD.PCR.asl -->
```asl
readonly func InstructionContractOperation_SD_PCR() => ScalarOperation
begin
    return ScalarOperation_SD_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SD.PCR.asl -->
```asl
readonly func InstructionContractHandler_SD_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `SD.PCR - Store scalar data using this mnemonic's width and address-update form.`
- **Semantic handler:** `ExecuteScalarStore`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
