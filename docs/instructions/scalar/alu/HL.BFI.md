# HL.BFI

Execute the HL.BFI scalar instruction contract.

<!-- ASL-SOURCE: asl/scalar/alu/HL.BFI.asl -->

## Assembly

```asm
hl.bfi SrcL, SrcR, M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_bfi_48_8adfd476aacc | HL48 | 48 | 0x0000204d000e / 0xfe00707f000f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_bfi_48_8adfd476aacc | RegDst | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |
| hl_bfi_48_8adfd476aacc | immr | 6 | encoding-defined | [{"instruction_lsb":4,"value_lsb":0,"width":6}] |
| hl_bfi_48_8adfd476aacc | imms | 6 | encoding-defined | [{"instruction_lsb":10,"value_lsb":0,"width":6}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.BFI.asl -->
```asl
readonly func InstructionContractOperation_HL_BFI() => ScalarOperation
begin
    return ScalarOperation_HL_BFI;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.BFI.asl -->
```asl
readonly func InstructionContractHandler_HL_BFI() => ScalarSemanticHandler
begin
    return ScalarHandler_InsertBitfield;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
