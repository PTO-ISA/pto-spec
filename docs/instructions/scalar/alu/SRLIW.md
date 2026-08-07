# SRLIW

Execute the SRLIW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/SRLIW.asl -->

## Normative identity {#PTO-INST-SCALAR-SRLIW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
srliw SrcL, shamt, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| srliw_32_ef4aa650f46e | L32 | 32 | 0x00005035 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| srliw_32_ef4aa650f46e | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| srliw_32_ef4aa650f46e | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| srliw_32_ef4aa650f46e | shamt | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/SRLIW.asl -->
```asl
readonly func InstructionContractOperation_SRLIW() => ScalarOperation
begin
    return ScalarOperation_SRLIW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/SRLIW.asl -->
```asl
readonly func InstructionContractHandler_SRLIW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinaryW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
