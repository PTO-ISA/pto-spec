# REM

Execute the REM scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/REM.asl -->

## Normative identity {#PTO-INST-SCALAR-REM}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
rem SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| rem_32_0abbd6a3b865 | L32 | 32 | 0x00004057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| rem_32_0abbd6a3b865 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| rem_32_0abbd6a3b865 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| rem_32_0abbd6a3b865 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REM.asl -->
```asl
readonly func InstructionContractOperation_REM() => ScalarOperation
begin
    return ScalarOperation_REM;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REM.asl -->
```asl
readonly func InstructionContractHandler_REM() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderSigned;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
