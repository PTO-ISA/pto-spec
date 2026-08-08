<!-- GENERATED FROM: asl/scalar/agu/HL.LD.PCR.asl -->
# HL.LD.PCR

**Normative ASL source:** `asl/scalar/agu/HL.LD.PCR.asl`

HL.LD.PCR - Load scalar data using this mnemonic's width, signedness, and address-update form.

## Normative identity {#PTO-INST-SCALAR-HL-LD-PCR}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.ld.pcr [<symbol>], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ld_pcr_48_703673c266da | HL48 | 48 | 0x00003039000e / 0x0000707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ld_pcr_48_703673c266da | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ld_pcr_48_703673c266da | simm | 29 | signed | [{"instruction_lsb":31,"value_lsb":0,"width":17},{"instruction_lsb":4,"value_lsb":17,"width":12}] |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | encoded operand or control |
| simm | encoded operand or control |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.LD.PCR.asl -->
```asl
readonly func InstructionContractOperation_HL_LD_PCR() => ScalarOperation
begin
    return ScalarOperation_HL_LD_PCR;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.LD.PCR.asl -->
```asl
readonly func InstructionContractHandler_HL_LD_PCR() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarLoad;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

- No additional catalog constraint beyond decode legality.

## Operational information

- **Semantic summary:** `HL.LD.PCR - Load scalar data using this mnemonic's width, signedness, and address-update form.`
- **Semantic handler:** `ExecuteScalarLoad`

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
