# HL.PRFI.U

Execute the HL.PRFI.U scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/agu/HL.PRFI.U.asl -->

## Assembly

```asm
hl.prfi.u{.l1,.l2,.l3} [SrcL, simm]
```

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/agu/HL.PRFI.U.asl -->
```asl
readonly func InstructionContractOperation_HL_PRFI_U() => ScalarOperation
begin
    return ScalarOperation_HL_PRFI_U;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/agu/HL.PRFI.U.asl -->
```asl
readonly func InstructionContractHandler_HL_PRFI_U() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarPrefetch;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
