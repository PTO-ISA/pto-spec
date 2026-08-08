<!-- GENERATED FROM: asl/scalar/agu/HL.LWI.UPR.asl -->
# HL.LWI.UPR

**Normative ASL source:** `asl/scalar/agu/HL.LWI.UPR.asl`

Execute the HL.LWI.UPR scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-HL-LWI-UPR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.lwi.upr [SrcL, simm], ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_lwi_upr_48_03b5f7994b14 | HL48 | 48 | 0x00002029002e / 0x0000707f003f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_lwi_upr_48_03b5f7994b14 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_lwi_upr_48_03b5f7994b14 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_lwi_upr_48_03b5f7994b14 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_lwi_upr_48_03b5f7994b14 | simm17 | 17 | signed | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":6,"value_lsb":12,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LWI.UPR.asl -->
```asl
readonly func InstructionContractOperation_HL_LWI_UPR() => ScalarOperation
begin
    return ScalarOperation_HL_LWI_UPR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LWI.UPR.asl -->
```asl
readonly func InstructionContractHandler_HL_LWI_UPR() => ScalarSemanticHandler
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
