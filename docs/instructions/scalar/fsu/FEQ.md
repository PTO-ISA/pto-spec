# FEQ

Execute the FEQ scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FEQ.asl -->

## Normative identity {#PTO-INST-SCALAR-FEQ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
feq.{T} SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| feq_32_9435d6959c3c | L32 | 32 | 0x0000005b / 0xf800707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| feq_32_9435d6959c3c | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| feq_32_9435d6959c3c | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| feq_32_9435d6959c3c | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| feq_32_9435d6959c3c | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FEQ.asl -->
```asl
readonly func InstructionContractOperation_FEQ() => ScalarOperation
begin
    return ScalarOperation_FEQ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FEQ.asl -->
```asl
readonly func InstructionContractHandler_FEQ() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingCompare;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
