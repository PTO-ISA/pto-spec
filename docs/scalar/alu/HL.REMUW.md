<!-- GENERATED FROM: asl/scalar/alu/HL.REMUW.asl -->
# HL.REMUW

**Normative ASL source:** `asl/scalar/alu/HL.REMUW.asl`

HL.REMUW computes an unsigned low-32-bit remainder/quotient pair from source snapshots, then publishes remainder followed by quotient.

## Normative identity {#PTO-INST-SCALAR-HL-REMUW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.remuw SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_remuw_48_26ea6e70f2fc | HL48 | 48 | 0x00007057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_remuw_48_26ea6e70f2fc | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_remuw_48_26ea6e70f2fc | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_remuw_48_26ea6e70f2fc | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_remuw_48_26ea6e70f2fc | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_remuw_48_26ea6e70f2fc | RegDst0 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_remuw_48_26ea6e70f2fc | RegDst1 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_remuw_48_26ea6e70f2fc | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_remuw_48_26ea6e70f2fc | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | remainder Reg5 destination or discard |
| RegDst1 | quotient Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REMUW.asl -->
```asl
readonly func InstructionContractOperation_HL_REMUW() => ScalarOperation
begin
    return ScalarOperation_HL_REMUW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REMUW.asl -->
```asl
readonly func InstructionContractHandler_HL_REMUW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarRemainderPairW;
end;
pure func InstructionContractQuotient_HL_REMUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsignedW(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_REMUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderUnsignedW(
        dividend,
        divisor);
end;

pure func InstructionContractDst0_HL_REMUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractRemainder_HL_REMUW(
        dividend,
        divisor);
end;

pure func InstructionContractDst1_HL_REMUW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractQuotient_HL_REMUW(
        dividend,
        divisor);
end;
```
<!-- GENERATED-ASL-END: operation -->

## Defaults and encoded zero

- SrcL, SrcR, RegDst0, and RegDst1 are required encoded fields; no field can be omitted.
- There is no encoded arithmetic mode or implicit operand. The mnemonic fixes signedness and operand width; every HL division/remainder spelling returns both quotient and remainder.

## Legality

- SrcL and SrcR codes 0..23 select absolute GPRs, 24..27 select T#1..T#4, and 28..31 select U#1..U#4 without consumption.
- Each destination independently uses the common map: codes 0 and 24..29 discard, codes 1..23 write GPRs, code 30 pushes U, and code 31 pushes T. Duplicate destinations are legal.
- Every value of each Reg5 selector is assigned; fixed encoding bits must match the canonical 48-bit form.

## State effects

- Interpret the selected operands as unsigned values, compute both quotient and remainder using the fixed total division rules. For W forms, use the low 32 bits and sign-extend each 32-bit result to XLEN.
- A zero divisor returns quotient zero and the effective dividend as remainder. Signed minimum divided by negative one returns signed minimum quotient and zero remainder.
- Publish RegDst0 remainder first, then RegDst1 quotient. If both destinations name one GPR, quotient is final; if both push one queue, quotient is newest and remainder is next-newest.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot both sources and compute both results before either destination effect.
- Publish remainder to RegDst0, publish quotient to RegDst1, then advance TPC by six bytes.

## Exceptions

- Division and remainder are total: zero divisors and signed minimum divided by negative one do not raise an arithmetic exception.
- An unavailable selected T/U source raises Fault_IllegalInstruction before either destination effect and before TPC advances.

## Examples

- hl.remuw a0, a1, ->a2, a3
- hl.remuw t#1, zero, ->u, u

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
