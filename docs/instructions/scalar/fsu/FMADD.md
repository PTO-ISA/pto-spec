# FMADD

Execute the FMADD scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/fsu/FMADD.asl -->

## Normative identity {#PTO-INST-SCALAR-FMADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fmadd.{T} SrcL, SrcR, SrcA, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fmadd_32_c616a17bcb12 | L32 | 32 | 0x0000404b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fmadd_32_c616a17bcb12 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fmadd_32_c616a17bcb12 | SrcA | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fmadd_32_c616a17bcb12 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fmadd_32_c616a17bcb12 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fmadd_32_c616a17bcb12 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FMADD.asl -->
```asl
readonly func InstructionContractOperation_FMADD() => ScalarOperation
begin
    return ScalarOperation_FMADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FMADD.asl -->
```asl
readonly func InstructionContractHandler_FMADD() => ScalarSemanticHandler
begin
    return ScalarHandler_FloatingFused;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
