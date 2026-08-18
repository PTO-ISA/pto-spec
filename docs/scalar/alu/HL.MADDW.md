<!-- GENERATED FROM: asl/scalar/alu/HL.MADDW.asl -->
# HL.MADDW

**Normative ASL source:** `asl/scalar/alu/HL.MADDW.asl`

HL.MADDW computes a signed 64-bit word multiply-add result and publishes its sign-extended low and high 32-bit halves.

## Normative identity {#PTO-INST-SCALAR-HL-MADDW}

<!-- ndf: kind=executable level=L3 layer=scalar status=accepted -->

The current instruction contract is owned by the ASL source linked above.

## Assembly

```asm
hl.maddw SrcL, SrcR, SrcD, ->Dst0, Dst1
```

## Encoding

| Form | Kind | Bits | Match / mask | Constraints |
| --- | --- | ---: | --- | --- |
| hl_maddw_48_6fac897f0264 | HL48 | 48 | 0x00007047000e / 0x0600707f07ff | [] |

### Fields

| Form | Field | Bits | Signedness | Pieces |
| --- | --- | ---: | --- | --- |
| hl_maddw_48_6fac897f0264 | RegDst0 | 5 | encoding-defined | [{"instruction_lsb":23,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | RegDst1 | 5 | encoding-defined | [{"instruction_lsb":11,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | SrcD | 5 | encoding-defined | [{"instruction_lsb":43,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | SrcL | 5 | encoding-defined | [{"instruction_lsb":31,"value_lsb":0,"width":5}] |
| hl_maddw_48_6fac897f0264 | SrcR | 5 | encoding-defined | [{"instruction_lsb":36,"value_lsb":0,"width":5}] |

## Encoding class

- **Class:** `standalone-encoded`
- **Standalone opcode:** `yes`

## Encoded field closure

Every encoded field value is assigned here, owned by another mnemonic, or reserved by the normative ASL contract.

| Form | Field | Bits | Assigned | Other owner | Reserved | Architectural role | Encoded zero |
| --- | --- | ---: | --- | --- | --- | --- | --- |
| hl_maddw_48_6fac897f0264 | RegDst0 | 5 | 0–31 | none | none | sign-extended result[31:0] Reg5 destination | Encoded zero discards the low result. |
| hl_maddw_48_6fac897f0264 | RegDst1 | 5 | 0–31 | none | none | sign-extended result[63:32] Reg5 destination | Encoded zero discards the high result. |
| hl_maddw_48_6fac897f0264 | SrcD | 5 | 0–31 | none | none | addend Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_maddw_48_6fac897f0264 | SrcL | 5 | 0–31 | none | none | left multiplicand or additive Reg5 source | Encoded zero reads the architectural zero GPR. |
| hl_maddw_48_6fac897f0264 | SrcR | 5 | 0–31 | none | none | right multiplicand Reg5 source | Encoded zero reads the architectural zero GPR. |

## Operands and results

| Field | Architectural role |
| --- | --- |
| RegDst0 | sign-extended result[31:0] Reg5 destination |
| RegDst1 | sign-extended result[63:32] Reg5 destination |
| SrcD | addend Reg5 source |
| SrcL | left multiplicand or additive Reg5 source |
| SrcR | right multiplicand Reg5 source |

## Decode

<!-- GENERATED-ASL-BEGIN: decode source=asl/scalar/alu/HL.MADDW.asl -->
```asl
readonly func InstructionContractOperation_HL_MADDW() => ScalarOperation
begin
    return ScalarOperation_HL_MADDW;
end;
```
<!-- GENERATED-ASL-END: decode -->

## Operation

<!-- GENERATED-ASL-BEGIN: operation source=asl/scalar/alu/HL.MADDW.asl -->
```asl
readonly func InstructionContractHandler_HL_MADDW() => ScalarSemanticHandler
begin
    return ScalarHandler_ExecuteScalarMultiplyAddPair;
end;
pure func InstructionContractResult_HL_MADDW(
    addend: Word,
    left: Word,
    right: Word)
    => Word
begin
    let effective_addend = SignExtend{PTO_XLEN}(addend[31:0]);
    let effective_left = SignExtend{PTO_XLEN}(left[31:0]);
    let effective_right = SignExtend{PTO_XLEN}(right[31:0]);
    let product = MultiplyWideSigned(effective_left, effective_right);
    return product[63:0] + effective_addend;
end;

pure func InstructionContractLow_HL_MADDW(
    addend: Word,
    left: Word,
    right: Word)
    => Word
begin
    return SignExtend{PTO_XLEN}(
        InstructionContractResult_HL_MADDW(addend, left, right)[31:0]);
end;

pure func InstructionContractHigh_HL_MADDW(
    addend: Word,
    left: Word,
    right: Word)
    => Word
begin
    return SignExtend{PTO_XLEN}(
        InstructionContractResult_HL_MADDW(addend, left, right)[63:32]);
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

- Interpret SrcD[31:0], SrcL[31:0], and SrcR[31:0] as signed two-complement values; compute signed32(SrcL) * signed32(SrcR) + signed32(SrcD) modulo 2^64.
- Snapshot every source and compute the complete 64-bit result before destinations. Publish SignExtend(result[31:0]) to RegDst0, then SignExtend(result[63:32]) to RegDst1.
- Duplicate destinations are legal and retain the second high-word result. No memory, reservation, descriptor, numeric-status, block, privilege, branch-target, or other control state changes. Successful execution advances TPC by six bytes.

## Memory effects and ordering

### Memory effects

- none

### Ordering

- Snapshot every source before any destination effect so duplicate selectors and destination aliases observe pre-instruction values.
- Publish SignExtend(result[31:0]) to RegDst0, publish SignExtend(result[63:32]) to RegDst1, then advance TPC by six bytes.

## Exceptions

- Multiplication and accumulation are fixed-width and raise no arithmetic exception; discarded overflow wraps modulo the defined result width.
- An unavailable selected T/U source raises Fault_IllegalInstruction before any destination effect and before TPC advances.

## Examples

- hl.maddw srcl, srcr, srcd, ->dst0, dst1

<!-- SUPPLEMENTARY-BEGIN -->

<!-- SUPPLEMENTARY-END -->
