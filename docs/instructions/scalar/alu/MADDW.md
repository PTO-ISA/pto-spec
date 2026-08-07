# MADDW

Execute the MADDW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/MADDW.asl -->

## Normative identity {#PTO-INST-SCALAR-MADDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
maddw SrcL, SrcR, SrcD, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| maddw_32_9f922b15e674 | L32 | 32 | 0x00007047 / 0x0600707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| maddw_32_9f922b15e674 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| maddw_32_9f922b15e674 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| maddw_32_9f922b15e674 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| maddw_32_9f922b15e674 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MADDW.asl -->
```asl
readonly func InstructionContractOperation_MADDW() => ScalarOperation
begin
    return ScalarOperation_MADDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MADDW.asl -->
```asl
readonly func InstructionContractHandler_MADDW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyAddW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
