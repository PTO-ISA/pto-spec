<!-- GENERATED FROM: asl/scalar/alu/REMUW.asl -->
# REMUW

**Normative ASL source:** `asl/scalar/alu/REMUW.asl`

REMUW computes the unsigned low-32-bit remainder using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-REMUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
remuw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| remuw_32_f10ade2f5ccb | L32 | 32 | 0x00007057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| remuw_32_f10ade2f5ccb | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| remuw_32_f10ade2f5ccb | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| remuw_32_f10ade2f5ccb | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| remuw_32_f10ade2f5ccb | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| remuw_32_f10ade2f5ccb | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| remuw_32_f10ade2f5ccb | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMUW.asl -->
```asl
readonly func InstructionContractOperation_REMUW() => ScalarOperation
begin
    return ScalarOperation_REMUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMUW.asl -->
```asl
readonly func InstructionContractHandler_REMUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderUnsignedW;
end;
pure func InstructionContractResult_REMUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderUnsignedW(
        dividend,
        divisor);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, and RegDst are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness, operand width, and quotient-versus-remainder selection.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- RegDst codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical form.

## State effects

- Interpret each source low 32 bits as unsigned, return the unsigned remainder, then sign-extend the low 32-bit result to XLEN.
- A zero low-32-bit divisor returns the sign-extended low 32-bit dividend.
- Publish the complete XLEN result through the common Reg5 destination map. Relative sources are non-consuming; only a T or U destination push changes a temporary queue.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by four bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources before the destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the result, then advance TPC by four bytes.

## Exceptions

- Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before the destination effect and before TPC advances.

## Examples

- remuw a0, a1, ->a2
- remuw t#1, zero, ->u

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
