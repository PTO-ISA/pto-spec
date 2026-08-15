<!-- GENERATED FROM: asl/scalar/alu/MADDW.asl -->
# MADDW

**Normative ASL source:** `asl/scalar/alu/MADDW.asl`

MADDW adds low 32-bit source values modulo 2^32, sign-extends the accumulated result to XLEN, and publishes it.

## Normative identity {#PTO-INST-SCALAR-MADDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
maddw SrcL, SrcR, SrcD, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| maddw_32_9f922b15e674 | L32 | 32 | 0x00007047 / 0x0600707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| maddw_32_9f922b15e674 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| maddw_32_9f922b15e674 | SrcD | 5 | encoding-defined | [{"instruction_lsb":27,"value_lsb":0,"width":5}] |
| maddw_32_9f922b15e674 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| maddw_32_9f922b15e674 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| maddw_32_9f922b15e674 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| maddw_32_9f922b15e674 | SrcD | 5 | 0–31 | none | none | addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| maddw_32_9f922b15e674 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| maddw_32_9f922b15e674 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcD | addend Reg5 source |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/MADDW.asl -->
```asl
readonly func InstructionContractOperation_MADDW() => ScalarOperation
begin
    return ScalarOperation_MADDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/MADDW.asl -->
```asl
readonly func InstructionContractHandler_MADDW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarMultiplyAddW;
end;
pure func InstructionContractResult_MADDW(addend: Word, left: Word, right: Word) => Word
begin
    return ScalarMultiplyAddW(addend, left, right);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- Every encoded operand and destination field is required; no field can be omitted.
- The mnemonic fixes signedness, effective operand width, single-versus-pair result shape, and add-versus-subtract behavior; there is no encoded arithmetic mode.

## Legality

- Every source Reg5 code is assigned: 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Fixed encoding bits must match the canonical form; every encoded source, destination, and immediate value otherwise has assigned behavior.

## State effects

- Multiply SrcL[31:0] and SrcR[31:0], add SrcD[31:0] modulo 2^32, then sign-extend the final low 32-bit result.
- Snapshot every source before the destination effect, publish the XLEN result through the common Reg5 destination map, and do not consume relative sources.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- maddw srcl, srcr, srcd, ->{t, u, rd}

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
