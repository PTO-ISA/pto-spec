# MIN

Execute the MIN scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/MIN.asl -->

## Assembly

```asm
min SrcL, SrcR, ->{t, u, Rd}
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MIN.asl -->
```asl
readonly func InstructionContractOperation_MIN() => ScalarOperation
begin
    return ScalarOperation_MIN;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MIN.asl -->
```asl
readonly func InstructionContractHandler_MIN() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarBinary;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
