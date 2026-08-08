<!-- GENERATED FROM: asl/scalar/sys/DC.CIVA.asl -->
# DC.CIVA

**Normative ASL source:** `asl/scalar/sys/DC.CIVA.asl`

Execute the DC.CIVA scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-DC-CIVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
dc.civa SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_civa_32_265d686549c8 | L32 | 32 | 0x0030602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_civa_32_265d686549c8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.CIVA.asl -->
```asl
readonly func InstructionContractOperation_DC_CIVA() => ScalarOperation
begin
    return ScalarOperation_DC_CIVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.CIVA.asl -->
```asl
readonly func InstructionContractHandler_DC_CIVA() => ScalarSemanticHandler
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
