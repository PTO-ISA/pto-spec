# LSRGET

Execute the LSRGET scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/LSRGET.asl -->

## Normative identity {#PTO-INST-SCALAR-LSRGET}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
lsrget LSR_ID, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| lsrget_32_448b17d7c20a | L32 | 32 | 0x0000303b / 0x000ff07f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| lsrget_32_448b17d7c20a | LSR_ID | 12 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":12}] |
| lsrget_32_448b17d7c20a | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/LSRGET.asl -->
```asl
readonly func InstructionContractOperation_LSRGET() => ScalarOperation
begin
    return ScalarOperation_LSRGET;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/LSRGET.asl -->
```asl
readonly func InstructionContractHandler_LSRGET() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteSystemRegisterGet;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
