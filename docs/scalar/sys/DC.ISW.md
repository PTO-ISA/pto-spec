<!-- GENERATED FROM: asl/scalar/sys/DC.ISW.asl -->
# DC.ISW

**Normative ASL source:** `asl/scalar/sys/DC.ISW.asl`

Execute the DC.ISW scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-DC-ISW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
dc.isw SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_isw_32_7940273560b2 | L32 | 32 | 0x0040602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_isw_32_7940273560b2 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.ISW.asl -->
```asl
readonly func InstructionContractOperation_DC_ISW() => ScalarOperation
begin
    return ScalarOperation_DC_ISW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.ISW.asl -->
```asl
readonly func InstructionContractHandler_DC_ISW() => ScalarSemanticHandler
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
