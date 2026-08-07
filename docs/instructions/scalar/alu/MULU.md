# MULU

Execute the MULU scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/MULU.asl -->

## Normative identity {#PTO-INST-SCALAR-MULU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
mulu SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mulu_32_10b9d1936631 | L32 | 32 | 0x00001047 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mulu_32_10b9d1936631 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| mulu_32_10b9d1936631 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mulu_32_10b9d1936631 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MULU.asl -->
```asl
readonly func InstructionContractOperation_MULU() => ScalarOperation
begin
    return ScalarOperation_MULU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MULU.asl -->
```asl
readonly func InstructionContractHandler_MULU() => ScalarSemanticHandler
begin
    return ScalarHandler_MultiplyWord;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
