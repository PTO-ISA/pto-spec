# C.CMP.NEI

Execute the C.CMP.NEI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/bru/C.CMP.NEI.asl -->

## Normative identity {#PTO-INST-SCALAR-C-CMP-NEI}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
c.cmp.nei t#1, simm, ->t
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| c_cmp_nei_16_35d1f02063e2 | C16 | 16 | 0x082c / 0xf83f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| c_cmp_nei_16_35d1f02063e2 | simm5 | 5 | signed | [{"instruction_lsb":6,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/C.CMP.NEI.asl -->
```asl
readonly func InstructionContractOperation_C_CMP_NEI() => ScalarOperation
begin
    return ScalarOperation_C_CMP_NEI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/C.CMP.NEI.asl -->
```asl
readonly func InstructionContractHandler_C_CMP_NEI() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteCompare;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
