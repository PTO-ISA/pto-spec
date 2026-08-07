# IC.IALL

Execute the IC.IALL scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/IC.IALL.asl -->

## Normative identity {#PTO-INST-SCALAR-IC-IALL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ic.iall
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ic_iall_32_854f0d4d906a | L32 | 32 | 0x0010502b / 0xffffffff | [] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/IC.IALL.asl -->
```asl
readonly func InstructionContractOperation_IC_IALL() => ScalarOperation
begin
    return ScalarOperation_IC_IALL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/IC.IALL.asl -->
```asl
readonly func InstructionContractHandler_IC_IALL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteMaintenance;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
