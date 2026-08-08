<!-- GENERATED FROM: asl/scalar/agu/HL.SW.PO.asl -->
# HL.SW.PO

**Normative ASL source:** `asl/scalar/agu/HL.SW.PO.asl`

Execute the HL.SW.PO scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-HL-SW-PO}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.sw.po SrcD, [SrcL, SrcR<{.sw,.uw,.neg}><<2], ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_sw_po_48_84cf0cd97fde | HL48 | 48 | 0x00002049003e / 0x00007fff07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_sw_po_48_84cf0cd97fde | RegDst | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_sw_po_48_84cf0cd97fde | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_sw_po_48_84cf0cd97fde | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_sw_po_48_84cf0cd97fde | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_sw_po_48_84cf0cd97fde | SrcRType | 2 | encoding-defined | [{"instruction_lsb":41,"value_lsb":0,"width":2}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.SW.PO.asl -->
```asl
readonly func InstructionContractOperation_HL_SW_PO() => ScalarOperation
begin
    return ScalarOperation_HL_SW_PO;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.SW.PO.asl -->
```asl
readonly func InstructionContractHandler_HL_SW_PO() => ScalarSemanticHandler
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
