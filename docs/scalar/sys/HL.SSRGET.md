<!-- GENERATED FROM: asl/scalar/sys/HL.SSRGET.asl -->
# HL.SSRGET

**Normative ASL source:** `asl/scalar/sys/HL.SSRGET.asl`

Execute the HL.SSRGET scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-HL-SSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.ssrget SSR_ID, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_ssrget_48_fde37e58a3c4 | HL48 | 48 | 0x0000003b000e / 0x000ff07f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_ssrget_48_fde37e58a3c4 | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_ssrget_48_fde37e58a3c4 | SSR_ID | 24 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":12},{"instruction_lsb":4,"value_lsb":12,"width":12}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/HL.SSRGET.asl -->
```asl
readonly func InstructionContractOperation_HL_SSRGET() => ScalarOperation
begin
    return ScalarOperation_HL_SSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/HL.SSRGET.asl -->
```asl
readonly func InstructionContractHandler_HL_SSRGET() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
