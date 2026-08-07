# BCNT

Execute the BCNT scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/BCNT.asl -->

## Normative identity {#PTO-INST-SCALAR-BCNT}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
bcnt srcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| bcnt_32_e0b06e436a5b | L32 | 32 | 0x00006067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| bcnt_32_e0b06e436a5b | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| bcnt_32_e0b06e436a5b | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| bcnt_32_e0b06e436a5b | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| bcnt_32_e0b06e436a5b | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/BCNT.asl -->
```asl
readonly func InstructionContractOperation_BCNT() => ScalarOperation
begin
    return ScalarOperation_BCNT;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/BCNT.asl -->
```asl
readonly func InstructionContractHandler_BCNT() => ScalarSemanticHandler
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
