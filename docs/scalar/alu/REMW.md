<!-- GENERATED FROM: asl/scalar/alu/REMW.asl -->
# REMW

**Normative ASL source:** `asl/scalar/alu/REMW.asl`

REMW computes the signed low-32-bit remainder using total fixed-width semantics and publishes the XLEN result.

## Normative identity {#PTO-INST-SCALAR-REMW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-remw-purpose role=purpose -->
## What REMW does

`REMW` is a 32-bit scalar ALU instruction. It computes the signed remainder over the low 32-bit word, followed by sign-extension to XLEN; its current instruction contract defines the result publication path and any additional state effect.

<!-- PTO-READER-BLOCK: scalar-remw-mechanism role=mechanism -->
## How the result is formed

Execution snapshots the encoded inputs, then computes the signed remainder over the low 32-bit word, followed by sign-extension to XLEN, and only afterward performs the destination effects.

- The operation-specific width, signedness, and immediate rules are fixed by the mnemonic and the encoded fields shown below.
- Result publication uses the width and extension rule fixed by this mnemonic's current contract.

<!-- PTO-READER-BLOCK: scalar-remw-inputs role=inputs-outputs -->
## Inputs and destinations

- The 5-bit `RegDst` field selects the Reg5 result target or discards the result.
- The 5-bit `SrcL` field selects the dividend through Reg5.
- The 5-bit `SrcR` field selects the divisor through Reg5.

These roles come from the current instruction contract. T/U sources are read and snapshotted without being removed from their queues; exact encoded-zero meanings appear in the generated defaults below.

<!-- PTO-READER-BLOCK: scalar-remw-effects role=effects -->
## Effects and ordering

Every scalar source is snapshotted before the destination effect. The completed value is then routed through `RegDst` using the current scalar destination map.

This ALU operation has no memory effect. After its successful architectural effects, `TPC` advances by 4 bytes.

The operation does not introduce a hidden scalar publication target or an implicit memory access. Architectural changes remain limited to the state effects enumerated by the current contract.

<!-- PTO-READER-BLOCK: scalar-remw-constraints role=constraints -->
## Legality and fault boundary

A zero divisor returns the effective dividend as the remainder; the signed overflow combination returns zero. Neither case raises an arithmetic exception.

The generated legality table is authoritative for assigned field values, reserved encodings, and destination discard codes. Decode and source availability are checked before architectural effects.

<!-- PTO-READER-BLOCK: scalar-remw-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `REMW` example, dividend `13` and divisor `5` produce remainder `3`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
remw SrcL, SrcR, ->{t, u, Rd}
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| remw_32_22659af46ec0 | L32 | 32 | 0x00006057 / 0xfe00707f | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| remw_32_22659af46ec0 | RegDst | 5 | encoding-defined | [{"instruction_lsb":7,"value_lsb":0,"width":5}] |
| remw_32_22659af46ec0 | SrcL | 5 | encoding-defined | [{"instruction_lsb":15,"value_lsb":0,"width":5}] |
| remw_32_22659af46ec0 | SrcR | 5 | encoding-defined | [{"instruction_lsb":20,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| remw_32_22659af46ec0 | RegDst | 5 | 0–31 | none | none | Reg5 destination or discard | Encoded zero discards the result. |
| remw_32_22659af46ec0 | SrcL | 5 | 0–31 | none | none | dividend Reg5 source | Encoded zero reads the architectural zero GPR dividend. |
| remw_32_22659af46ec0 | SrcR | 5 | 0–31 | none | none | divisor Reg5 source | Encoded zero reads the architectural zero GPR divisor and therefore selects the defined zero-divisor result. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst | Reg5 destination or discard |
| SrcL | dividend Reg5 source |
| SrcR | divisor Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/REMW.asl -->
```asl
readonly func InstructionContractOperation_REMW() => ScalarOperation
begin
    return ScalarOperation_REMW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/REMW.asl -->
```asl
readonly func InstructionContractHandler_REMW() => ScalarSemanticHandler
begin
    return ScalarHandler_ScalarRemainderSignedW;
end;
pure func InstructionContractResult_REMW(
    dividend: Word,
    divisor: Word)
    => Word
begin
    return ScalarRemainderSignedW(
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

- Interpret each source low 32 bits as signed, return the signed remainder, then sign-extend the low 32-bit result to XLEN.
- A zero low-32-bit divisor returns the sign-extended low 32-bit dividend. Signed 32-bit minimum divided by negative one returns zero.
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

- remw a0, a1, ->a2
- remw t#1, zero, ->u
