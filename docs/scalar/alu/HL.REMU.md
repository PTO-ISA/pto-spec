<!-- GENERATED FROM: asl/scalar/alu/HL.REMU.asl -->
# HL.REMU

**Normative ASL source:** `asl/scalar/alu/HL.REMU.asl`

HL.REMU computes an unsigned XLEN remainder/quotient pair from source snapshots, then publishes remainder followed by quotient.

## Normative identity {#PTO-INST-SCALAR-HL-REMU}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-remu-purpose role=purpose -->
## What HL.REMU does

`HL.REMU` is a 48-bit scalar ALU instruction. It computes the unsigned remainder and quotient together from source snapshots; its current instruction contract defines the result publication path and any additional state effect.

<!-- PTO-READER-BLOCK: scalar-hl-remu-mechanism role=mechanism -->
## How the result is formed

Execution snapshots the encoded inputs, then computes the unsigned remainder and quotient together from source snapshots, and only afterward performs the destination effects.

- The operation-specific width, signedness, and immediate rules are fixed by the mnemonic and the encoded fields shown below.
- Result publication uses the width and extension rule fixed by this mnemonic's current contract.

<!-- PTO-READER-BLOCK: scalar-hl-remu-inputs role=inputs-outputs -->
## Inputs and destinations

- The 5-bit `RegDst0` field selects the remainder Reg5 target or discards the remainder.
- The 5-bit `RegDst1` field selects the quotient Reg5 target or discards the quotient.
- The 5-bit `SrcL` field selects the dividend through Reg5.
- The 5-bit `SrcR` field selects the divisor through Reg5.

These roles come from the current instruction contract. T/U sources are read and snapshotted without being removed from their queues; exact encoded-zero meanings appear in the generated defaults below.

<!-- PTO-READER-BLOCK: scalar-hl-remu-effects role=effects -->
## Effects and ordering

All results are computed before publication. The destinations are then updated in encoded order (`RegDst0`, `RegDst1`), which also defines the order of duplicate-register writes or queue pushes.

This ALU operation has no memory effect. After its successful architectural effects, `TPC` advances by 6 bytes.

The operation does not introduce a hidden scalar publication target or an implicit memory access. Architectural changes remain limited to the state effects enumerated by the current contract.

<!-- PTO-READER-BLOCK: scalar-hl-remu-constraints role=constraints -->
## Legality and fault boundary

A zero divisor uses the defined quotient and remainder outcomes; both outputs are computed before either destination is written.

The generated legality table is authoritative for assigned field values, reserved encodings, and destination discard codes. Decode and source availability are checked before architectural effects.

<!-- PTO-READER-BLOCK: scalar-hl-remu-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `HL.REMU` example, dividend `13` and divisor `5` produce remainder `3` followed by quotient `2`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.remu SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_remu_48_3bf4e5a663c1 | HL48 | 48 | 0x00005057000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_remu_48_3bf4e5a663c1 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_remu_48_3bf4e5a663c1 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_remu_48_3bf4e5a663c1 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_remu_48_3bf4e5a663c1 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_remu_48_3bf4e5a663c1 | RegDst0 | 5 | 0–31 | none | none | remainder Reg5 destination or discard | Encoded zero discards the remainder. |
| hl_remu_48_3bf4e5a663c1 | RegDst1 | 5 | 0–31 | none | none | quotient Reg5 destination or discard | Encoded zero discards the quotient. |
| hl_remu_48_3bf4e5a663c1 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| hl_remu_48_3bf4e5a663c1 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects defined zero-divisor pair results. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | remainder Reg5 destination or discard |
| RegDst1 | quotient Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.REMU.asl -->
```asl
readonly func InstructionContractOperation_HL_REMU() => ScalarOperation
begin
    return ScalarOperation_HL_REMU;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.REMU.asl -->
```asl
readonly func InstructionContractHandler_HL_REMU() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarRemainderPair;
end;
pure func InstructionContractQuotient_HL_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarDivideUnsigned(
        dividend,
        divisor);
end;

pure func InstructionContractRemainder_HL_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderUnsigned(
        dividend,
        divisor);
end;

pure func InstructionContractDst0_HL_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractRemainder_HL_REMU(
        dividend,
        divisor);
end;

pure func InstructionContractDst1_HL_REMU(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return InstructionContractQuotient_HL_REMU(
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

- Interpret the selected operands as unsigned values, compute both quotient and remainder using the fixed total division rules.
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

- hl.remu a0, a1, ->a2, a3
- hl.remu t#1, zero, ->u, u
