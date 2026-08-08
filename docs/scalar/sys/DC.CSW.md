<!-- GENERATED FROM: asl/scalar/sys/DC.CSW.asl -->
# DC.CSW

**Normative ASL source:** `asl/scalar/sys/DC.CSW.asl`

Execute the DC.CSW scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-DC-CSW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
dc.csw SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_csw_32_2719115a9246 | L32 | 32 | 0x0050602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_csw_32_2719115a9246 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CSW.asl -->
```asl
readonly func InstructionContractOperation_DC_CSW() => ScalarOperation
begin
    return ScalarOperation_DC_CSW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CSW.asl -->
```asl
readonly func InstructionContractHandler_DC_CSW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
