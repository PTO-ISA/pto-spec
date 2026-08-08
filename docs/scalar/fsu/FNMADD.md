<!-- GENERATED FROM: asl/scalar/fsu/FNMADD.asl -->
# FNMADD

**Normative ASL source:** `asl/scalar/fsu/FNMADD.asl`

Execute the FNMADD scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-FNMADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fnmadd.{T} SrcL, SrcR, SrcA, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fnmadd_32_7f45e606d299 | L32 | 32 | 0x0000604b / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| fnmadd_32_7f45e606d299 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| fnmadd_32_7f45e606d299 | SrcA | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| fnmadd_32_7f45e606d299 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| fnmadd_32_7f45e606d299 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |
| fnmadd_32_7f45e606d299 | SrcType | 2 | encoding-defined | [{"instruction_lsb":25,"value_lsb":0,"width":2}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/fsu/FNMADD.asl -->
```asl
readonly func InstructionContractOperation_FNMADD() => ScalarOperation
begin
    return ScalarOperation_FNMADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/fsu/FNMADD.asl -->
```asl
readonly func InstructionContractHandler_FNMADD() => ScalarSemanticHandler
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
