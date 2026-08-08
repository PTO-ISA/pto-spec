<!-- GENERATED FROM: asl/scalar/agu/HL.LW.PCR.asl -->
# HL.LW.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LW.PCR.asl`

Execute the HL.LW.PCR scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-HL-LW-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.lw.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lw_pcr_48_00cf25e2ac36 | HL48 | 48 | 0x00002039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lw_pcr_48_00cf25e2ac36 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lw_pcr_48_00cf25e2ac36 | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LW.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LW_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LW_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LW.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LW_PCR() => ScalarSemanticHandler
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
