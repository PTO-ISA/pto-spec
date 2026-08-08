<!-- GENERATED FROM: asl/scalar/sys/DC.IVA.asl -->
# DC.IVA

**Normative ASL source:** `asl/scalar/sys/DC.IVA.asl`

Execute the DC.IVA scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-DC-IVA}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
dc.iva SrcL
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| dc_iva_32_0131d0cf364f | L32 | 32 | 0x0000602b / 0xfff07fff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| dc_iva_32_0131d0cf364f | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/DC.IVA.asl -->
```asl
readonly func InstructionContractOperation_DC_IVA() => ScalarOperation
begin
    return ScalarOperation_DC_IVA;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/DC.IVA.asl -->
```asl
readonly func InstructionContractHandler_DC_IVA() => ScalarSemanticHandler
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
