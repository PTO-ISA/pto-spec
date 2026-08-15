<!-- GENERATED FROM: asl/scalar/alu/REV.asl -->
# REV

**Normative ASL source:** `asl/scalar/alu/REV.asl`

REV reverses the bytes of an independently selected wrapping scalar field, zero-fills high result bits, and returns zero for a non-byte width.

## Normative identity {#PTO-INST-SCALAR-REV}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
rev SrcL,  M, N, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| rev_32_58badc109d49 | L32 | 32 | 0x00007067 / 0x0000707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| rev_32_58badc109d49 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| rev_32_58badc109d49 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| rev_32_58badc109d49 | imml | 6 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":6}] |
| rev_32_58badc109d49 | immr | 6 | encoding-defined | [{"instruction_lsb":26,"value_lsb":0,"width":6}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| rev_32_58badc109d49 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| rev_32_58badc109d49 | SrcL | 5 | 0–31 | none | none | Reg5 source | Encoded zero reads the architectural zero GPR. |
| rev_32_58badc109d49 | imml | 6 | 0–63 | none | none | selected field width N minus one | Encoded zero selects a one-bit field. |
| rev_32_58badc109d49 | immr | 6 | 0–63 | none | none | selected field starting bit M | Encoded zero starts the selected field at source bit zero. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | Reg5 source |
| imml | selected field width N minus one |
| immr | selected field starting bit M |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REV.asl -->
```asl
readonly func InstructionContractOperation_REV()
    => ScalarOperation
begin
    return ScalarOperation_REV;
end;

pure func InstructionContractWidth_REV(encoded_imml: bits(6))
    => integer {1..64}
begin
    return UInt(encoded_imml) + 1;
end;

pure func InstructionContractOffset_REV(encoded_immr: bits(6))
    => integer {0..63}
begin
    return UInt(encoded_immr);
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REV.asl -->
```asl
readonly func InstructionContractHandler_REV()
    => ScalarSemanticHandler
begin
    return ScalarHandler_ReverseBitfieldBytes;
end;

pure func InstructionContractResult_REV(
    value: Word,
    width: integer {1..64},
    offset: integer {0..63})
    => Word
begin
    return ReverseBitfieldBytes(
        value,
        width,
        offset);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, imml, immr, and RegDst are required encoded fields; no field can be omitted.
- imml encodes N minus one, so raw values 0 through 63 select widths 1 through 64; encoded zero selects N=1.
- immr directly encodes M from 0 through 63; encoded zero selects source bit zero.

## Legality

- SrcL codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every imml and immr value is assigned. The selected N-bit field begins at bit M and wraps through bit 63 to bit 0.

## State effects

- Extract the N-bit field beginning at bit M, wrapping from bit 63 to bit 0. If N is a multiple of eight, reverse the selected bytes into result bits N-1:0 and zero-fill higher bits; otherwise return zero normally.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot SrcL before any destination effect so a GPR alias or a T/U destination push observes the pre-instruction source value.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.
- A width that is not a multiple of eight is assigned and completes normally with a zero result; it is not an illegal instruction.

## Examples

- rev a0, 0, 64, ->a1
- rev u#1, 60, 16, ->t
- rev a0, 0, 7, ->zero

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
