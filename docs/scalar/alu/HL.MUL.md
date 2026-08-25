<!-- GENERATED FROM: asl/scalar/alu/HL.MUL.asl -->
# HL.MUL

**Normative ASL source:** `asl/scalar/alu/HL.MUL.asl`

HL.MUL computes a signed 128-bit scalar product and publishes its low half followed by its high half.

## Normative identity {#PTO-INST-SCALAR-HL-MUL}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Reader guide

> **Non-normative explanation.** Exact behavior remains owned by the ASL source and generated contract on this page.

<!-- SUPPLEMENTARY-BEGIN -->
<!-- PTO-READER-BLOCK: scalar-hl-mul-purpose role=purpose -->
## What HL.MUL does

`HL.MUL` is a 48-bit scalar ALU instruction. It computes the complete unsigned 128-bit product and separates its low and high halves; its current instruction contract defines the result publication path and any additional state effect.

<!-- PTO-READER-BLOCK: scalar-hl-mul-mechanism role=mechanism -->
## How the result is formed

Execution snapshots the encoded inputs, then computes the complete unsigned 128-bit product and separates its low and high halves, and only afterward performs the destination effects.

- The operation-specific width, signedness, and immediate rules are fixed by the mnemonic and the encoded fields shown below.
- Result publication uses the width and extension rule fixed by this mnemonic's current contract.

<!-- PTO-READER-BLOCK: scalar-hl-mul-inputs role=inputs-outputs -->
## Inputs and destinations

- The 5-bit `RegDst0` field selects the Reg5 target for the low product or accumulator half.
- The 5-bit `RegDst1` field selects the Reg5 target for the high product or accumulator half.
- The 5-bit `SrcL` field selects the left multiplicand or additive operand through Reg5.
- The 5-bit `SrcR` field selects the right multiplicand through Reg5.

These roles come from the current instruction contract. T/U sources are read and snapshotted without being removed from their queues; exact encoded-zero meanings appear in the generated defaults below.

<!-- PTO-READER-BLOCK: scalar-hl-mul-effects role=effects -->
## Effects and ordering

All results are computed before publication. The destinations are then updated in encoded order (`RegDst0`, `RegDst1`), which also defines the order of duplicate-register writes or queue pushes.

This ALU operation has no memory effect. After its successful architectural effects, `TPC` advances by 6 bytes.

The operation does not introduce a hidden scalar publication target or an implicit memory access. Architectural changes remain limited to the state effects enumerated by the current contract.

<!-- PTO-READER-BLOCK: scalar-hl-mul-constraints role=constraints -->
## Legality and fault boundary

Fixed-width arithmetic follows the operation’s wraparound rule without an arithmetic exception. A fixed-bit mismatch or unavailable selected T/U source raises `Fault_IllegalInstruction` before publication and before `TPC` advances.

The generated legality table is authoritative for assigned field values, reserved encodings, and destination discard codes. Decode and source availability are checked before architectural effects.

<!-- PTO-READER-BLOCK: scalar-hl-mul-example role=example -->
## Non-normative worked example

This example illustrates the current ASL owner and does not replace the normative operation.

For a small `HL.MUL` example, sources `6` and `7` produce low result `42`; wide pair forms also produce high result `0`.
<!-- SUPPLEMENTARY-END -->

## Assembly

```asm
hl.mul SrcL, SrcR, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_mul_48_0d059ff178fb | HL48 | 48 | 0x00000047000e / 0xfe00707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_mul_48_0d059ff178fb | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_mul_48_0d059ff178fb | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_mul_48_0d059ff178fb | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_mul_48_0d059ff178fb | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_mul_48_0d059ff178fb | RegDst0 | 5 | 0–31 | none | none | low product or accumulator Reg5 destination | Encoded zero discards the low result. |
| hl_mul_48_0d059ff178fb | RegDst1 | 5 | 0–31 | none | none | high product or accumulator Reg5 destination | Encoded zero discards the high result. |
| hl_mul_48_0d059ff178fb | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_mul_48_0d059ff178fb | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | low product or accumulator Reg5 destination |
| RegDst1 | high product or accumulator Reg5 destination |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MUL.asl -->
```asl
readonly func InstructionContractOperation_HL_MUL() => ScalarOperation
begin
    return ScalarOperation_HL_MUL;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MUL.asl -->
```asl
readonly func InstructionContractHandler_HL_MUL() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyPair;
end;
pure func InstructionContractProduct_HL_MUL(left: Word, right: Word) => DoubleWord
begin
    return MultiplyWideSigned(left, right);
end;

pure func InstructionContractLow_HL_MUL(left: Word, right: Word) => Word
begin
    return InstructionContractProduct_HL_MUL(left, right)[63:0];
end;

pure func InstructionContractHigh_HL_MUL(left: Word, right: Word) => Word
begin
    return InstructionContractProduct_HL_MUL(left, right)[127:64];
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

- Sign-extend both XLEN sources into a signed 128-bit product.
- Snapshot every source and compute the complete 128-bit result before destinations. Publish bits 63:0 to RegDst0, then bits 127:64 to RegDst1. Duplicate destinations are legal; the second high result is final/newest.
- No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish the low result to RegDst0, publish the high result to RegDst1, then advance TPC by six bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.mul srcl, srcr, ->dst0, dst1
