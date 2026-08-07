# CLZ

Execute the CLZ scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/CLZ.asl -->

## Normative identity {#PTO-INST-SCALAR-CLZ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
clz SrcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| clz_32_f890415c15b6 | L32 | 32 | 0x00005067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| clz_32_f890415c15b6 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| clz_32_f890415c15b6 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| clz_32_f890415c15b6 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| clz_32_f890415c15b6 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/CLZ.asl -->
```asl
readonly func InstructionContractOperation_CLZ() => ScalarOperation
begin
    return ScalarOperation_CLZ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/CLZ.asl -->
```asl
readonly func InstructionContractHandler_CLZ() => ScalarSemanticHandler
begin
    return ScalarHandler_CountBitfield;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
