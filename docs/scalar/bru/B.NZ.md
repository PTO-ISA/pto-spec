<!-- GENERATED FROM: asl/scalar/bru/B.NZ.asl -->
# B.NZ

**Normative ASL source:** `asl/scalar/bru/B.NZ.asl`

Execute the B.NZ scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-B-NZ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
b.nz label
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| b_nz_32_0f583cdd8d4d | L32 | 32 | 0x00002037 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| b_nz_32_0f583cdd8d4d | simm22 | 22 | signed | [{"instruction_lsb":15,"value_lsb":0,"width":17},{"instruction_lsb":7,"value_lsb":17,"width":5}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/bru/B.NZ.asl -->
```asl
readonly func InstructionContractOperation_B_NZ() => ScalarOperation
begin
    return ScalarOperation_B_NZ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/bru/B.NZ.asl -->
```asl
readonly func InstructionContractHandler_B_NZ() => ScalarSemanticHandler
begin
    return ScalarHandler_BranchRelative;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
