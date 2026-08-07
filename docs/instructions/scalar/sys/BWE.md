# BWE

Execute the BWE scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/sys/BWE.asl -->

## Assembly

```asm
bwe SrcL
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/sys/BWE.asl -->
```asl
readonly func InstructionContractOperation_BWE() => ScalarOperation
begin
    return ScalarOperation_BWE;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/sys/BWE.asl -->
```asl
readonly func InstructionContractHandler_BWE() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteControlRequest;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
