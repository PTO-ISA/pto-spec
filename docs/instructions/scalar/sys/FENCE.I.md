# FENCE.I

Execute the FENCE.I scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/FENCE.I.asl -->

## Normative identity {#PTO-INST-SCALAR-FENCE-I}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
fence.i
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| fence_i_32_a321a2a186b1 | L32 | 32 | 0x1000202b / 0xffffffff | [] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/FENCE.I.asl -->
```asl
readonly func InstructionContractOperation_FENCE_I() => ScalarOperation
begin
    return ScalarOperation_FENCE_I;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/FENCE.I.asl -->
```asl
readonly func InstructionContractHandler_FENCE_I() => ScalarSemanticHandler
begin
    return ScalarHandler_FenceInstruction;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
