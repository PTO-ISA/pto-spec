<!-- GENERATED FROM: asl/scalar/alu/MUL.asl -->
# MUL

**Normative ASL source:** `asl/scalar/alu/MUL.asl`

Execute the MUL scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-MUL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
mul SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| mul_32_9f2affd8efb8 | L32 | 32 | 0x00000047 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| mul_32_9f2affd8efb8 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| mul_32_9f2affd8efb8 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| mul_32_9f2affd8efb8 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MUL.asl -->
```asl
readonly func InstructionContractOperation_MUL() => ScalarOperation
begin
    return ScalarOperation_MUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MUL.asl -->
```asl
readonly func InstructionContractHandler_MUL() => ScalarSemanticHandler
begin
    return ScalarHandler_MultiplyWord;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
