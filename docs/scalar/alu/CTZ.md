<!-- GENERATED FROM: asl/scalar/alu/CTZ.asl -->
# CTZ

**Normative ASL source:** `asl/scalar/alu/CTZ.asl`

Execute the CTZ scalar instruction contract.

## Normative identity {#PTO-INST-SCALAR-CTZ}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
ctz SrcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| ctz_32_1761cbcc2a89 | L32 | 32 | 0x00004067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| ctz_32_1761cbcc2a89 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| ctz_32_1761cbcc2a89 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| ctz_32_1761cbcc2a89 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| ctz_32_1761cbcc2a89 | imms | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/CTZ.asl -->
```asl
readonly func InstructionContractOperation_CTZ() => ScalarOperation
begin
    return ScalarOperation_CTZ;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Assembler symbols

Supplementary operand names and examples may be added here.

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/CTZ.asl -->
```asl
readonly func InstructionContractHandler_CTZ() => ScalarSemanticHandler
begin
    return ScalarHandler_CountBitfield;
end;
```
<!-- GENERATED-ASL-END: operation -->

## Legality and exceptions

Normative legality is embedded from the ASL source above.

## Operational information

Supplementary implementation-neutral guidance may be added here.

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
