<!-- GENERATED FROM: asl/scalar/agu/HL.LH.PCR.asl -->
# HL.LH.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LH.PCR.asl`

Execute the HL.LH.PCR scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-HL-LH-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.lh.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lh_pcr_48_37df3cfe0d6e | HL48 | 48 | 0x00001039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lh_pcr_48_37df3cfe0d6e | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lh_pcr_48_37df3cfe0d6e | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LH.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LH_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LH_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LH.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LH_PCR() => ScalarSemanticHandler
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
