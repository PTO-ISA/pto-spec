# REMW

Execute the REMW scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/REMW.asl -->

## Normative identity {#PTO-INST-SCALAR-REMW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
remw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| remw_32_22659af46ec0 | L32 | 32 | 0x00006057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| remw_32_22659af46ec0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| remw_32_22659af46ec0 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| remw_32_22659af46ec0 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMW.asl -->
```asl
readonly func InstructionContractOperation_REMW() => ScalarOperation
begin
    return ScalarOperation_REMW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMW.asl -->
```asl
readonly func InstructionContractHandler_REMW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderSignedW;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
