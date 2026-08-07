# BXS

Execute the BXS scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/BXS.asl -->

## Normative identity {#PTO-INST-SCALAR-BXS}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
bxs SrcL, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bxs_32_b1bb003c1703 | L32 | 32 | 0x00000067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bxs_32_b1bb003c1703 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bxs_32_b1bb003c1703 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bxs_32_b1bb003c1703 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bxs_32_b1bb003c1703 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BXS.asl -->
```asl
readonly func InstructionContractOperation_BXS() => ScalarOperation
begin
    return ScalarOperation_BXS;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BXS.asl -->
```asl
readonly func InstructionContractHandler_BXS() => ScalarSemanticHandler
begin
    return ScalarHandler_ExtractBitfield;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
