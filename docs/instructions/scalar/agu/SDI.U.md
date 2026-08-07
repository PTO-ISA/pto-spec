# SDI.U

Execute the SDI.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/SDI.U.asl -->

## Assembly

```asm
sdi.u SrcL, [SrcR, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/SDI.U.asl -->
```asl
readonly func InstructionContractOperation_SDI_U() => ScalarOperation
begin
    return ScalarOperation_SDI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/SDI.U.asl -->
```asl
readonly func InstructionContractHandler_SDI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarStore;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
