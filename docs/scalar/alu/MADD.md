<!-- GENERATED FROM: asl/scalar/alu/MADD.asl -->
# MADD

**Normative ASL source:** `asl/scalar/alu/MADD.asl`

Execute the MADD scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-MADD}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
madd SrcL, SrcR, SrcD, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| madd_32_6208e8e59303 | L32 | 32 | 0x00006047 / 0x0600707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| madd_32_6208e8e59303 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| madd_32_6208e8e59303 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| madd_32_6208e8e59303 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| madd_32_6208e8e59303 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MADD.asl -->
```asl
readonly func InstructionContractOperation_MADD() => ScalarOperation
begin
    return ScalarOperation_MADD;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MADD.asl -->
```asl
readonly func InstructionContractHandler_MADD() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyAdd;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
